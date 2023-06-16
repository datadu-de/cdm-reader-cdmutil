get-content ".env" | foreach {
    $name, $value = $_.split('=', 2)
    set-content env:\$name $value
}

$TenantId = $env:TenantId
$AccessKey = $env:AccessKey
$ManifestURL = $env:ManifestURL
$TargetDbConnectionString = $env:TargetDbConnectionString
$CDMUtilPath = $env:CDMUtilPath

#$CDMUtilPath = "$($env:TMPDIR)/cdmutil"

$cdmutilurl = "https://github.com/microsoft/Dynamics-365-FastTrack-Implementation-Assets/raw/master/Analytics/CDMUtilSolution/CDMUtilConsoleApp.zip"

$cdmutilfile = "CDMUtilConsoleApp.zip"
$configpath = "$($CDMUtilPath)/CDMUtilConsoleApp/CDMUtil_ConsoleApp.dll.config"
$execpath = "$($CDMUtilPath)/CDMUtilConsoleApp/CDMUtil_ConsoleApp.exe"

if (-Not (Test-Path -Path $CDMUtilPath)) {
    New-Item -Path $CDMUtilPath -ItemType Directory 
}

if (-Not (Test-Path -Path "$CDMUtilPath/$cdmutilfile")) {
    Invoke-WebRequest -URI $cdmutilurl -OutFile "$CDMUtilPath/$cdmutilfile"
}

if (-Not (Test-Path $configpath)) {
    Expand-Archive -Path "$CDMUtilPath/$cdmutilfile" -DestinationPath $CDMUtilPath
}

$xml = [xml](Get-Content -Path $configpath)
$node = $xml.configuration.appSettings.add | 
where { $_.key -eq "TenantId" }
$node.value = $TenantId

$xml.Save($configpath)
