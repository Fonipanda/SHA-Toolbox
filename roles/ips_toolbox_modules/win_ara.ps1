#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy.psm1

# constant vars
$AraPath = 'D:\apps\CA\ReleaseAutomationAgent'
$logsPath = $AraPath+"\logs"
$tempDirectories = "$AraPath\files_cache","$AraPath\files_registry","$AraPath\files_temp","$AraPath\persistency"

$ErrorActionPreference = "Stop"

# function to check Ara
function getCheckNolio{
    <#
    .SYNOPSIS
        Check Nolio install

    .DESCRIPTION
        Check for nolioAgent Service and version of Nolio 

    .EXAMPLE
        getCheckNolio

    #>
    Param()

    $Result = @{}

    #check service presence
    $Service = Get-Service | Where-Object { $_.Name -match "nolioagent" }

    if($Service){
        $Result.Add("Installed","yes")

        $ServiceName = $Service.Name
        $Result.Add("ServiceName",$ServiceName)
        switch($Service.status){
            "Running" { $State = "started" }
            default { $State = "$_" }
        }
        $Result.Add("state",$State)

        $VersionString = Get-content "$logsPath\nimi.log" | Select-String -Pattern "version" | Select-String -Pattern "nodeType=NODE" | Select-Object -Last 1
        $Version = ($VersionString -split ",")[-1].trim() -replace "}" -replace "version="
        $Result.Add("Version",$Version)

    } else {
        $Result.Add("Installed","no")
    }
    return $Result   
}

function setNolioState{
    <#
    .SYNOPSIS
        Set Nolio state

    .DESCRIPTION
        used to start, stop or restart nolioAgent service

    .EXAMPLE
        setNolioState stop
        setNolioState start
        setNolioState restart

    #>
    [CmdletBinding()]
    Param
    (
        #Destination to reach, name or IP
        [Parameter(
            Position=0,
            Mandatory = $True,
            HelpMessage="Provide action",
            ValueFromPipeline = $true
        )]
        [String]$Action
    )

    #result var creation
    $Result = @{
        failed = $false
        action = $Action
        changed = $false
    }

    $Service = Get-Service | Where-Object { $_.Name -match "nolioagent" }

    if($Service){
        if( ($Action -eq "stop") -or ($Action -eq "restart") ){
            if($Service.status -ne "stopped"){
                Set-Service -name $Service.name -Status stopped
                $Result.changed = $true
                $tempDirectories | ForEach-Object {
                    Remove-Item -path "$_\*"
                }
            }
        } 
        
        if( ($Action -eq "start") -or ($Action -eq "restart") ){
            if($Action -eq "restart"){
                $Service = Get-Service -Name $Service.name
            }
            if($Service.status -ne "running"){                
                Set-Service -name $Service.name -Status running
                $Result.changed = $true
            }
        } 

    } else {
        $Result.failed = $true
        $Result.msg = "Nolioagent service notfound"
    }

    return $Result
}

try{

    # set Result hashtable for json output
    $Result = @{
        changed = $false
        failed = $false
    }

    # get params
    $params = Parse-Args $args -supports_check_mode $true
    $Action = Get-AnsibleParam -obj $params -name "Action" -type "str" -failifempty $true

    #prepare vars
    $Action =$Action.trim(" ").ToLower()
    $Result.action = $Action

    if($Action -eq "check"){
        $Result.check = getCheckNolio
    } elseif($Action -eq "start" -or $Action -eq "stop" -or $Action -eq "restart"){
        $ActionResult = setNolioState -Action $Action
        $Result.changed = $ActionResult.changed
        
        if($ActionResult.failed){
            throw $ActionResult.msg
        }
    }
   
} catch {
    $Result.failed = $true
    $Result.msg = "$($_.Exception.message)"
} finally {
}

Exit-Json $Result
