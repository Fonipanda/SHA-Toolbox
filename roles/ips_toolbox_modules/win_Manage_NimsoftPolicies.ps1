#!powershell
# This file is part of Ansible

# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy.psm1

# set Result hashtable for json output
$Result = @{
    changed = $false
    failed = $false
    action = ""
    policy = ""
    message = ""
}

# get params
$params = Parse-Args $args -supports_check_mode $true

$Action = Get-AnsibleParam -obj $params -name "Action" -type "str" -failifempty $true
$Policy = Get-AnsibleParam -obj $params -name "Policy" -type "str" -failifempty $true

# prepare vars
$Action =$Action.trim(" ").ToLower()
$Policy = $Policy.trim(" ")
$PolicyList = $Policy.Split(',')
$NimsoftExe='C:\Program Files\Nimsoft\custo\scripts\exploitation\PolicyGroupManage.cmd'
$ErrorActionPreference = "Stop"

# function to launch a cmd with quotes in args with wait possibilities
function launcher($ProcessPath,$ProcessArgs){
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
function Get-Policies(){
    $GetResult = (launcher -ProcessPath $NimsoftExe -ProcessArgs "/a:get").stdout.Split("`r`n")
    $ActualPoliciesList = ($GetResult | Where-Object { $_ -match "GROUP: " }).replace("GROUP: ","")
    return $ActualPoliciesList
}

try{
    
    $Result.policy = $PolicyList
    $Result.action = $Action

    #get actual policies
    $ActualPoliciesList =  Get-Policies

    # check if asked policies need to be processed
    $Trigger = $false
    Switch($Action){
        "Add"{
            $PolicyList | ForEach-Object {
                if( $ActualPoliciesList -notcontains $_ ){
                    $Trigger = $true
                }
            }
        }
        "Remove"{
            $PolicyList | ForEach-Object {
                if($ActualPoliciesList -contains $_ ){
                    $Trigger = $true
                }
            }
        }
    }

    # if needed, launch the operation
    if($Trigger){        
        $ActionResult = launcher -ProcessPath $NimsoftExe -ProcessArgs "/a:$Action /g:""$Policy"""
        $Result.changed = $true
    }
   
} catch {
    $Result.failed = $true
    $Result.message = "$($_.Exception.Message)"
} finally {
}

Exit-Json $Result
