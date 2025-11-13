#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy.psm1
#Import-Module D:\apps\toolboxes\exploit\lib\powershell\cft\CFT.psm1

$ErrorActionPreference = "Stop"

function InvokeCftUtil
{
<#
.SYNOPSIS
Invoke command CFTUTIL
.DESCRIPTION
.PARAMETER Arguments
Argument(s) of CFTUTIL command
.EXAMPLE
InvokeCftUtil -Arguments "cftext TYPE=SEND"

#> 
    [CmdletBinding()]
    Param([Parameter(ValueFromPipelineByPropertyName=$true,Position=0,Mandatory=$true)][ValidateNotNullOrEmpty()][string]$Arguments)
    Begin{
        $ReturnArray=@()
    }
    Process{
        try{
            $CFT = New-Object PSObject
            if(Test-Path "$($env:DIR_Transfer_CFT_Shared)\runtime\profile.bat"){
                $ScriptBlock='cmd /c "Call %DIR_Transfer_CFT_Shared%\runtime\profile.bat && CFTUTIL $($Arguments)"'

                $Output=Invoke-Expression -Command $ScriptBlock
                $CFT  | Add-Member -type NoteProperty -name Command -value "cftutil $($Arguments)"
                $CFT  | Add-Member -type NoteProperty -name Output -value $Output
                $CFT  | Add-Member -type NoteProperty -name ReturnCode -value $LASTEXITCODE
            }
            $ReturnArray +=$CFT
        }
        Catch 
        {
            Write-Error "[$(Get-Date) - $($Function)] - $($_.Exception.Message)"
        }
        Finally
        {
        }
    }
    End
    {
        return $ReturnArray
    }
}

function getCFTStatus{
    <#
    .SYNOPSIS
        Get CFT status from toolbox modules

    .DESCRIPTION
        Get CFT status from toolbox modules and format it

    .EXAMPLE
        getCFTStatus()
    #>
    Param()
    $result = "not installed"
        if(Test-Path "$($env:DIR_Transfer_CFT_Shared)\runtime\profile.bat"){
            $ScriptBlock='cmd /c "Call %DIR_Transfer_CFT_Shared%\runtime\profile.bat && cft status"'
            $result = (Invoke-Expression -Command $ScriptBlock) -replace 'Transfer CFT is '
        }

    return $result
}

function getCFTPartners{
    <#
    .SYNOPSIS
        Get CFT Partners from toolbox modules

    .DESCRIPTION
        Get CFT status from toolbox modules and format it

    .EXAMPLE
        getCFTPartners()
    #>
    Param()

    $status = getCFTStatus
    $result = @()

    if($status -ne "not installed"){
        $toolbox_query = InvokeCftUtil listpart -ErrorAction SilentlyContinue
        $toolbox_query.Output | ForEach-Object {
            if($_ -match '^  [A-Z]+'){
                $partnerName = $_.trim()
                
                if($result -notcontains $partnerName){
                    $result += $partnerName 
                }
            }
        }
    }
    return $result
}

function getCFTCheck{
    <#
    .SYNOPSIS
        Get CFT info from toolbox modules and format it

    .DESCRIPTION
        Get CFT info from toolbox modules and format it

    .EXAMPLE
        getCFTCheck()
    #>
    Param()
    
    $result = @{}
    
    $status = getCFTStatus

    if($status -ne "not installed"){
        $toolbox_query = InvokeCftUtil listpart -ErrorAction SilentlyContinue
        $toolbox_query.Output | ForEach-Object {
            if($_ -match '^[A-Z]+'){
                if($_ -match "Version"){
                    $splitVersion = $_ -split "Version"
                    $version = ($splitVersion[1]).trim()
                    $result.Add("Version",$version)
                    $result.Add("Installed","yes")
                }elseif($_ -match "Parameters file"){
                    $result.Add("Parameters file",($_ -split " :" )[1])
                }elseif($_ -match "Partners file"){
                    $result.Add("Partners file",($_ -split " :" )[1])
                }elseif($_ -match "Catalog file"){
                    $result.Add("Catalog file",($_ -split " :" )[1])
                }
            }elseif($_ -match '^  [A-Z]+'){
                $partnerName = $_.trim()
                if($result.Keys -notcontains "Partners"){
                    $result.Add("Partners",@{}) 
                }
                if($result.Partners.Keys -notcontains $partnerName){
                    $result.Partners.Add($partnerName,@{}) 
                }
            }elseif($_ -match '^          (\w)+.*=.*'){
                $equalCount = ($_.ToCharArray() | Where-Object {$_ -eq "="} | Measure-Object).Count
                $lineSplit = $_.trim() -split "="
                if($equalCount -eq 1){
                    $infoName = $lineSplit[0].trim() -creplace "\s+", " "
                    $infoValue = $lineSplit[1].trim()
                    if($result.Partners."$partnerName".Keys -notcontains $infoName){ 
                        $result.Partners."$partnerName".Add($infoName,$infoValue)
                    }
                }elseif($equalCount -eq 2){
                    $MiddleSplit = $lineSplit[1].trim() -split " ", 2
                    $infoName1 = $lineSplit[0].trim() -creplace "\s+", " "
                    $infoValue1 = $MiddleSplit[0].trim()
                    $infoName2 = $MiddleSplit[1].trim() -creplace "\s+", " "
                    $infoValue2 = $lineSplit[2].trim()
                    if($result.Partners."$partnerName".Keys -notcontains $infoName){ 
                        $result.Partners."$partnerName".Add($infoName1,$infoValue1)
                        $result.Partners."$partnerName".Add($infoName2,$infoValue2)
                    }
                }
            }
        }

    } else {
        $result.Add("Installed","no")
    }

    return $result
}


try{

    # set Result hashtable for json output
    $Result = @{
        changed = $false
        failed = $false
    }

    # get params
    $Params = Parse-Args $args -supports_check_mode $true
    $Action = Get-AnsibleParam -obj $Params -name "action" -type "str" -failifempty $true

    #prepare vars
    $Action =$Action.trim(" ").ToLower()
    $Result.action = $Action    

    if($Action -eq "check"){
        $Result.check = getCFTCheck
    }
    
    if($Action -eq "status"){
        $Result.status = getCFTStatus
    }

    if($Action -eq "list"){
        $Result.partners = getCFTPartners
    }
    
} catch {
    $Result.failed = $true
    $Result.msg = "$($_.Exception.message)"
} finally {
}

Exit-Json $Result
