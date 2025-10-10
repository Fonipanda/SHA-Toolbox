#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy.psm1

# constant vars
$ErrorActionPreference = "Stop"

function test-McafeeInstallation{
    <#
    .SYNOPSIS
        Test mcafee installation.

    .DESCRIPTION
        Test mcafee installation from registry.

    .EXAMPLE
        test-McafeeInstallation

    #>
    Param()
    
    $result = $false
    
    $checkInstallation = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* `
                        | Where-Object { $_.displayName -match "Mcafee endpoint" } `
                        | Select-Object DisplayName
    
    if($checkInstallation ){
        $result = $true
    }
    
    return $result
}

function get-McafeeStatus{
    <#
    .SYNOPSIS
        Get macfee status.

    .DESCRIPTION
        check McAfeeFramework service presence, then status and return them.

    .EXAMPLE
        get-McafeeStatus

    #>
    Param()

    $result = @{}
    
    $serviceStatus = (Get-Service McAfeeFramework).Status.ToString()

    $result.Add("services",@{})
    $result."services".Add("McAfeeFramework service",$serviceStatus)
    $result.Add("state",($serviceStatus -replace "Running", "started") )

    return $result
}


# function to get version
function get-McafeeVersion{
    <#
    .SYNOPSIS
        Get mcafee version.

    .DESCRIPTION
        Get mcafee version from registry.

    .EXAMPLE
        get-McafeeVersion

    #>
    Param()

    $result = ""
    
    $info = Get-ItemProperty HKLM:\SOFTWARE\McAfee\Endpoint\Common\
    
    $result = "$($info.ProductVersion).$($info.BuildNumber)"
    
    return $result
}


function get-ThreatProtectionVersion{
    <#
    .SYNOPSIS
        Get mcafee threat protection version.

    .DESCRIPTION
        Get mcafee threat protection version from registry.

    .EXAMPLE
        get-ThreatProtectionVersion

    #>
    Param()

    $result = ""
    
    $info = Get-ItemProperty HKLM:\SOFTWARE\McAfee\Endpoint\AV\
    
    $result = "$($info.ProductVersion).$($info.BuildNumber)"
    
    return $result
}

function get-McafeeContentVersion{
    <#
    .SYNOPSIS
        Get mcafee content version.

    .DESCRIPTION
        Get mcafee content version from registry.

    .EXAMPLE
        get-McafeeContentVersion

    #>
    Param()

    $result = ""
    
    $info = Get-ItemProperty HKLM:\SOFTWARE\McAfee\AVSolution\DS\DS\
    
    $result = "$($info.dwContentMajorVersion).$($info.dwContentMinorVersion)"
    
    return $result
}

function get-McafeeContentDate{
    <#
    .SYNOPSIS
        Get mcafee content date.

    .DESCRIPTION
        Get mcafee content date from registry.

    .EXAMPLE
        get-McafeeContentDate

    #>
    Param()

    $result = ""
    
    $info = Get-ItemProperty HKLM:\SOFTWARE\McAfee\AVSolution\DS\DS\
    
    $result = $info.szContentCreationDate -replace "-"
    
    
    return $result

}

function get-McafeeContentTime{
    <#
    .SYNOPSIS
        Get mcafee content time.

    .DESCRIPTION
        Get mcafee content time from registry.

    .EXAMPLE
        get-McafeeContentTime

    #>
    Param()

    $result = ""
    
    $info = Get-ItemProperty HKLM:\SOFTWARE\McAfee\AVSolution\DS\DS\
    
    $result = "$($info.szContentCreationTime)"
    
    return $result

}


function get-McafeeEngineVersion{
    <#
    .SYNOPSIS
        Get mcafee engine version.

    .DESCRIPTION
        Get mcafee engine version from registry.

    .EXAMPLE
        get-McafeeContentTime

    #>
    Param()

    $result = ""
    
    $info = Get-ItemProperty HKLM:\SOFTWARE\McAfee\Endpoint\AV\AVCM\
    
    $result = "$($info.EMajor).$($info.EMinor)"
    
    return $result
}


function get-McafeeDATInfo{
    <#
    .SYNOPSIS
        Get mcafee DAT info.

    .DESCRIPTION
        Get mcafee DAT info.

    .EXAMPLE
        get-McafeeDATInfo

    #>
    Param()

    $result = @{}
    if(test-McafeeInstallation){
        $result.Add("content version",$(get-McafeeContentVersion))
        $result.Add("content date", $(get-McafeeContentDate))
        $result.Add("content time", $(get-McafeeContentTime))
        $result.Add("engine version",$(get-McafeeEngineVersion))
        
    }

    return $result
}

# function to check Nimsoft globally
function get-McafeeCheck{
    <#
    .SYNOPSIS
        Get McafeeCheck.

    .DESCRIPTION
        check mcafee install and return informations from it.

    .EXAMPLE
        get-McafeeCheck

    #>
    Param()

    $result = @{}

    if(test-McafeeInstallation){
        $result.Add("installed","yes")
        $result.Add("state",$(get-McafeeStatus))
        $result.Add("version", $(get-McafeeVersion))
        $result.Add("DAT Info",@{})
        $result.Add("thread prevention version",$(get-ThreatProtectionVersion))
        $result."DAT info".Add("content version",$(get-McafeeContentVersion))
        $result."DAT info".Add("content date",$(get-McafeeContentDate))
        $result."DAT info".Add("content time",$(get-McafeeContentTime))
        $result."DAT info".Add("engine version",$(get-McafeeEngineVersion))

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
    $params = Parse-Args $args -supports_check_mode $true
    $Action = Get-AnsibleParam -obj $params -name "Action" -type "str" -failifempty $true

    #prepare vars
    $Action =$Action.trim(" ").ToLower()
    $Result.action = $Action

    if($Action -eq "check"){
        $Result.check = get-McafeeCheck
    }
    
    if($Action -eq "status"){
        $Result.status = get-McafeeStatus
    }

    if($action -eq "check-dat"){
        $Result.check_DAT = get-McafeeDATInfo
    }
    
} catch {
    $Result.failed = $true
    $Result.msg = "$($_.Exception.message)"
} finally {
}

Exit-Json $Result
