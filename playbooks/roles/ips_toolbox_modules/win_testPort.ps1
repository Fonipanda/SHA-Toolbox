#!powershell


#Requires -Module Ansible.ModuleUtils.Legacy.psm1

$ErrorActionPreference = "Stop"

Function Test-PortConnection {
    <#
    .SYNOPSIS
        Test connection between the host and a destination point.

    .DESCRIPTION
        Function to test a TCP connection between the host and a destination point.
        Can use a single port, multiple Ports or a range

    .EXAMPLE
        Test-PortConnection -Destination MyServer -Port 80
        Test-PortConnection -Destination 127.0.0.1 -Port 80,443
        Test-PortConnection -Destination OtherServer -Port [80-85]

    #>
    [CmdletBinding()]
    Param
    (
        #Destination to reach, name or IP
        [Parameter(
            Position=0,
            Mandatory = $True,
            HelpMessage="Provide destination source",
            ValueFromPipeline = $true
        )]
        [string[]]$Destination,

        #TCP Ports to use, can be a range
        [Parameter(
            Position=1,
            Mandatory = $False,
            HelpMessage="Provide port numbers",
            ValueFromPipeline = $true
        )]
        [object[]]$Port = 80
    ) 
 
    $ErrorActionPreference = "SilentlyContinue"
    $Results = @()
    
    if($Port -match '^[0-9]+\-[0-9]+$'){
        $Split = $Port -replace '\[' -replace '\]' -split '-'
        $Port = $Split[0]..$Split[1]
    }
    
    ForEach($D in $Destination){
        # Create a custom object
        $Object = New-Object PSCustomObject
        $Object | Add-Member -MemberType NoteProperty -Name "Destination" -Value $D
        
        ForEach ($P in $Port){
            $Result = $null
            $Result = Test-NetConnection -Port $p -ComputerName $D -InformationLevel Quiet
            $Object | Add-Member Noteproperty "$("Port " + "$p")" -Value "$($Result)"
        }
        $Results += $Object
    }
 
    # Final results displayed in new pop-up window
    return $Results
    
} 


try{

    # set Result hashtable for json output
    $Result = @{
        changed = $false
        failed = $false
    }

    # get params
    $params = Parse-Args $args -supPort_check_mode $true
    $Destination = Get-AnsibleParam -obj $params -name "destination" -type "str" -failifempty $true
    $Port = Get-AnsibleParam -obj $params -name "port" -type "str" -failifempty $false
    
    $Result.destination = $Destination

    if($Destination -match ","){
        $Destination = $Destination -split ","
    }
    
    if($Port){
        $Result.port = $Port
        if($Port -match ","){
            $Port = $Port -split ","
        }
        $Result.results = Test-PortConnection -Destination $Destination -Port $Port
    } else {
        $Result.port = "80"
        $Result.results = Test-PortConnection -Destination $Destination
    }


} catch {
    $Result.failed = $true
    $Result.msg = "$($_.Exception.message)"
} finally {
}

Exit-Json $Result
