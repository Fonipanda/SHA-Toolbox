$instances = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server' -ErrorAction SilentlyContinue ).InstalledInstances
$result = $null

if($instances){
    $instanceName = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').($instances[0])
    $SQLEdition = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceName\Setup").Edition
    $SQLVersion = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceName\Setup").Version
    $result = "$SQLEdition $SQLVersion"
}

return $result


