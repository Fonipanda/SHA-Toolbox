#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy

$ErrorActionPreference = "Stop"

$params = Parse-Args -arguments $args -supports_check_mode $true
$version= Get-AnsibleParam -obj $params -name "version" -type "str"
$action = Get-AnsibleParam -obj $params -name "action" -type "str" -validateSet "check","compare"

$result = @{
    changed = $false
    action = $action
}


if ( $action -eq 'check' )
{
  if (Get-ItemProperty -Path HKLM:\SOFTWARE\Toolboxes -Name Version -ErrorAction SilentlyContinue)
  {
    $InstalledVersion = (Get-ItemProperty -Path HKLM:\SOFTWARE\Toolboxes).Version

    $result.check = @{
      Installed = 'yes'
      Version = $InstalledVersion
      }
  }
  else
  {
    Fail-Json -obj $result -message "Toolbox is not installed"

    $result.check = @{
      Installed = 'no'
    }
  }
}


if( $action -eq 'compare' )
{
  $InstalledVersion = (Get-ItemProperty -Path HKLM:\SOFTWARE\Toolboxes).Version

  if($version -notmatch '^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)|([0-9]+\.[0-9]+\.[0-9]+)$')
  {
    Fail-Json -obj $result -message "Invalid format for parameter version"
  }

  if($InstalledVersion -notmatch '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
  {
    Fail-Json -obj $result -message "Invalid toolbox version on server"
  }

  $result.installed_version = $InstalledVersion
  $result.compared_version = $version

  if ([version]$InstalledVersion -ge [version]$version) 
  {
    $result.greater = $true
  }
  else
  {
    $result.greater = $false
  }
}

Exit-Json -obj $result

