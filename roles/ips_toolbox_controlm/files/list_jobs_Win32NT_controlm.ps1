#requires -Version 4
#requires -RunAsAdministrator

<#
.SYNOPSIS
List ruuning job on Control-M Agent
.DESCRIPTION
.PARAMETER ToolboxZip
Toolboxes zip file
.EXAMPLE
list_jobs_Win32NT_controlm.ps1 -agent_name "Default" 
.EXAMPLE
.INPUTS
.OUTPUTS
 .NOTES
#> 
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $false)][string]$agent_name = "Default"
)

$ErrorActionPreference = "Stop"

function Set-JSON
{
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][object]$processes) 
    begin {}
    process {
        try{
            $global:ouput_json+="{`"name`":`"$($processes.name)`",`"ProcessId`":`"$($processes.ProcessId)`",`"CommandLine`":`"$($processes.CommandLine.replace('\','\\').replace('`"','\`"'))`",`"Owner`":`"$($processes.Owner)`""
            if ($processes.process.count -ne 0)
            {
                $processes.process| ForEach-Object { 
                    $global:ouput_json+=",`"processes`":["
                    Set-JSON $_ 
                    $global:ouput_json+="]"
                }
            }
            else
            {
                $global:ouput_json+=",`"processes`":[]"
            }
            $global:ouput_json+="},"
        }
        Catch 
        {
            write-error "$($_.Exception.Message)"
            return $false
        }
    }
    end {}
} 

. D:\Apps\toolboxes\ToolboxProfile.ps1

try
{
    (Get-CTMAgentJobs -CTMAgent $agent_name ).SelectNodes("/root")| ForEach-Object { 
        [string]$global:ouput_json="{`"agent_name`": `"$($agent_name)`" ,`"processes`": ["  
        if($_.process.count -ne 0)
        {
            $_.process| ForEach-Object { 
                Set-JSON $_ 
            }
        }
        $global:ouput_json+="]}"  
    }
    write-output $global:ouput_json.Replace(",]","]")
}
Catch 
{
    write-error "$($_.Exception.Message)"
    return $false
}
