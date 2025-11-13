#!powershell
# This file is part of Ansible

# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

#Requires -Module Ansible.ModuleUtils.Legacy.psm1

Import-Module Servermanager


$result = @{
    changed = $false
}

$params = Parse-Args $args -supports_check_mode $true

$name = Get-AnsibleParam -obj $params -name "name" -type "str" -failifempty $true

$name = $name -split ',' | % { $_.Trim() }


# Base params to cover both Add/Install-WindowsFeature
$getParams = @{
    Name = $name
}

$request = get-Windowsfeature @getParams

# Loop through results and create a hash containing details about
# each role/feature
$features_infos = @()

If ($request)
{
    ForEach ($item in $request) {
	$installState = ""

	switch ($item.Installed) {
    		"True" {
        		$installState = "Installed" 
    		}
    		"False" {
        		$installState = "Not Installed"
    		}
	}

        $features_infos += @{
            Name = $item.name
            Display_name = $item.DisplayName
            InstallState = $installState
        }
    }
}

$result.features_info = $features_infos

Exit-Json $result
