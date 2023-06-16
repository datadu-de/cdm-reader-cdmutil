$cdmconfig = @{}

Get-Content ".env" | foreach {
    $name, $value = $_.split('=', 2)
    $cdmconfig.Add($name, $value)
}

$CDMUtilPath = "./cdmutil"
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

foreach ($key in $cdmconfig.keys) {
    $node = $xml.configuration.appSettings.add | 
    where { $_.key -eq $key }
    $node.value = $cdmconfig[$key]

}

$xml.Save($configpath)
