#!powershell


#Requires -Module Ansible.ModuleUtils.Legacy.psm1

# constant vars
$NimsoftPath = 'C:\Program Files\Nimsoft\custo\scripts\exploitation'
$PolicyGroupManagePath = "$NimsoftPath\PolicyGroupManage.cmd"
$RepairPath = "$NimsoftPath\RepairNimsoftAgent.bat"
$ErrorActionPreference = "Stop"

# function to launch a cmd with quotes in args with wait possibilities
function launcher{
    <#
    .SYNOPSIS
        launch a cmd 

    .DESCRIPTION
        allo use of a cmd with quotes in args with wait possibilities

    .EXAMPLE
        launcher -ProcessPath $PolicyGroupManagePath -ProcessArgs "/a:get"
    #>
    Param
    (
        #Destination to reach, name or IP
        [Parameter(
            Position=0,
            Mandatory = $True,
            HelpMessage="Provide path of the command",
            ValueFromPipeline = $true
        )]
        [String]$ProcessPath,
        [Parameter(
            Position=0,
            Mandatory = $False,
            HelpMessage="Provide arguments of the command",
            ValueFromPipeline = $true
        )]
        $ProcessArgs
    )
    $ProcessInfo = New-Object System.Diagnostics.ProcessStartInfo
    $ProcessInfo.FileName = $ProcessPath
    $ProcessInfo.RedirectStandardError = $true
    $ProcessInfo.RedirectStandardOutput = $true
    $ProcessInfo.UseShellExecute = $false
    $ProcessInfo.Arguments = $ProcessArgs
    $Process= New-Object System.Diagnostics.Process
    $Process.StartInfo = $ProcessInfo
    $Process.Start() | Out-Null
    $Process.WaitForExit()
    return New-Object PSObject -Property @{
        Stdout = $Process.StandardOutput.ReadToEnd();
        Stderr = $Process.StandardError.ReadToEnd()
    }
}

# function to get policies
function getNimsoftPolicies{
    <#
    .SYNOPSIS
        Get nimsoft policies.

    .DESCRIPTION
        Get nimsoft policies from PolicyGroupManage.cmd.

    .EXAMPLE
        getNimsoftPolicies

    #>
    Param()

    $GetResult = (launcher -ProcessPath $PolicyGroupManagePath -ProcessArgs "/a:get").stdout.Split("`r`n")
    $ActualPoliciesList = ($GetResult | Where-Object { $_ -match "GROUP: " }).replace("GROUP: ","")
    return $ActualPoliciesList
}

# function to check Nimsoft globally
function getNimsoftCheck(){
    <#
    .SYNOPSIS
        Check Nimsoft installation.

    .DESCRIPTION
        Check if Nimsoft is installed and get the version.

    .EXAMPLE
        getNimsoftCheck

    #>
    Param()


    $Result = @{}
    
    if(Get-Service NimbusWatcherService){
        $Result.Add("Installed","yes")
        #get version
        [string]$version=""
        Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue| Where-Object {$_.DisplayName -Like "Nimsoft*"}|ForEach-Object {$version=$_.DisplayVersion}
        Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName -Like "Nimsoft*"}|ForEach-Object {$version=$_.DisplayVersion}
        $Result.Add("Version",$version)

        $Step = ""
        #$i=0
        
        $Command = (launcher -ProcessPath $RepairPath -ProcessArgs "/check").stdout.Split("`r`n")
        $Command | ForEach-Object {
            #$i++
            if( $_ -match "Step  : " ){
                $Step = $_ -replace "Step  : Check Nimsoft ", ""
                $Result.Add($Step,@{})
            }
            if( $_ -match " \.\.\.\.\.\.\. "){
                $Check = $_ -split " \.\.\.\.\.\.\. "
                $CheckValue = $Check[0] -replace '\[ ','' -replace ' \]','' -replace 'FAIL','KO'
                $CheckTitle = $Check[1] -replace 'The Nimsoft ' 
            
            
                switch($Step){

                    "Processes"{
                        $CheckTitle = $CheckTitle -replace "The "," " 
                        
                        if($CheckTitle -match "All Nimsoft process"){
                            $Result."$step".Add("Global status",$CheckValue)
                        } elseif($CheckTitle -match "Some Nimsoft processes are DOWN"){
                            $Result."$step".Add("Global status",$CheckValue)
                        } elseif($CheckTitle -match "There is"){
                            $ProcessDetail = $CheckTitle -replace "There is ","" -replace " Nimsoft process","" -split " and "
                            $ProcessDetail | ForEach-Object {
                                $DetailSplit = $_ -split " "
                                $Result."$step".Add($DetailSplit[1],$DetailSplit[0])
                            }
                        } else {
                            $Result."$step".Add(($CheckTitle -replace "process " -replace '"' -split " is ")[0],$CheckValue)
                        }
                    }

                    "Prerequisites"{
                        $CheckTitle = $CheckTitle -replace "The " `
                                                -replace " file" `
                                                -replace "directory " `
                                                -replace "There is no robotip parameter specified in", "No robotip in" `
                                                -replace '"',"'"
                        
                        if($CheckTitle -match "IP address"){
                            $CheckTitle = $CheckTitle -replace " main","Main"
                            $DetailSplit = $CheckTitle -split " is : "
                            $Result."$step".Add($DetailSplit[0],$DetailSplit[1])
                        } else{
                            $Result."$step".Add($CheckTitle, $CheckValue)
                        }

                    }
                    "Service"{
                        $DetailSplit = $CheckTitle -split '"'
                        
                        $Result."$step".Add($DetailSplit[1],($DetailSplit[2] -replace " is ",""))
                    }
                    "Agent packages deployment"{
                        $CheckTitle = $CheckTitle -replace "The Package "
                        $DetailSplit = $CheckTitle -split ' is '
                        $Result."$step".Add($DetailSplit[0],$DetailSplit[1])
                    }

                }
            }

        }
    } else {
        $Result.Add("Installed","no")
    }

    return $Result
}

# function to set Nimsoft state
function setNimsoft{
    <#
    .SYNOPSIS
        Set Nimsoft status 

    .DESCRIPTION
        Set Nimsoft status

    .EXAMPLE
        setNimsoft start
    #>
    Param
    (
        #Destination to reach, name or IP
        [Parameter(
            Position=0,
            Mandatory = $True,
            HelpMessage="Provide status to set",
            ValueFromPipeline = $true
        )]
        [String]$Status
    )

    $Result = @{
        changed = $false
        failed = $false
        msg = ""
    }
    
       
    if($Status -eq "stop" -or $Status -eq "restart" ){
        $CommandOutput = (launcher -ProcessPath $RepairPath -ProcessArgs "/stop" ).stdout.Split("`r`n")
        $CommandOutput | ForEach-Object {
            if($_ -match "Stop Nimsoft Agent"){
                $Result.changed = $true
            }
        }
        $i = 0
        $StayInLoop = $true
        while( $Result.changed -and $StayInLoop ){
            
            $stopCheck = getNimsoftCheck
            if($stopCheck.Processes.RUNNING -eq "0"){
                $StayInLoop = $false
            }
            
            $i++
            if( ($i -ge 10) -and $StayInLoop){
                $StayInLoop = $false
                $Result.msg = "Did not stop before timeout"
                $Result.failed = $true
            }
            if($StayInLoop){ 
                start-sleep 10
            }
        }
     
    }
    if(($Result.failed -eq $false) -and (($Status -eq "start") -or ($Status -eq "restart"))){
        $CommandOutput = (launcher -ProcessPath $RepairPath -ProcessArgs "/start" ).stdout.Split("`r`n")
        $CommandOutput | ForEach-Object {
            if($_ -match "Start Nimsoft Agent"){
                $Result.changed = $true
            }
        }
        $i = 0
        $StayInLoop = $true
        while( $Result.changed -and $StayInLoop ){
            
            $StartCheck = getNimsoftCheck
            if($StartCheck.Processes.STOPPED -eq "0"){
                $StayInLoop = $false
            }
            
            $i++
            if( ($i -ge 10) -and $StayInLoop){
                $StayInLoop = $false
                $Result.msg = "Did not start before timeout"
                $Result.failed = $true
            }
            if($StayInLoop){ 
                start-sleep 10
            }
        }       
    }
    return $Result
}


try{

    # set Result dict for json output
    $Result = @{
        changed = $false
        failed = $false
    }

    # get params
    $params = Parse-Args $args -supports_check_mode $true
    $Action = Get-AnsibleParam -obj $params -name "Action" -type "str" -failifempty $true
    $Policy = Get-AnsibleParam -obj $params -name "Policy" -type "str" -failifempty $false

    #prepare vars
    $Action =$Action.trim(" ").ToLower()
    $Result.action = $Action

    if($Action -eq "check"){
        $Result.check = getNimsoftCheck
    } elseif($Action -eq "get") {
        $Result.policy = getNimsoftPolicies
    } elseif($Action -eq "add" -or $Action -eq "remove"){
        if($Policy){
            $Policy = $Policy.trim(" ")
            $PolicyList = $Policy.Split(',')
            $Result.policy = $PolicyList

            # create a trigger for policy management to be processed when true
            $PolicyManageTrigger = $false   

            $ActualPoliciesList =  getNimsoftPolicies
            
            $PolicyList | ForEach-Object {
                if(($Action -eq "add" -and $ActualPoliciesList -notcontains $_ ) `
                     -or ($Action -eq "remove" -and $ActualPoliciesList -contains $_ ) ){
                    $PolicyManageTrigger = $true                    
                }
            }
            # if needed, manage the policy
            if($PolicyManageTrigger){        
                $ActionResult = launcher -ProcessPath $PolicyGroupManagePath -ProcessArgs "/a:$Action /g:""$Policy"""
                $Result.changed = $true
            }

        }else{
            throw "Policy parameter is missing"
        }
    } elseif($Action -eq "start" -or $Action -eq "stop" -or $Action -eq "restart"){
        $ActionResult = setNimsoft -status $Action
        $Result.changed = $ActionResult.changed
        if($ActionResult.failed){
            throw $ActionResult.msg
        }
    } else {
        $Result.msg = "Action '$Action' does not exist"
        $Result.failed = $true
    }

} catch {
    $Result.failed = $true
    $Result.msg = "$($_.Exception.message)"
} finally {
}

Exit-Json $Result
