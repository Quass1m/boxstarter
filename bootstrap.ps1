# .\bootstrap.ps1 -InstallDev=$true -SourceCodeFolder "C:\GIT" -SkipWindowsUpdate
# START http://boxstarter.org/package/nr/url?C:\boxstarter-master\box.ps1

param
(
    [Switch]
    $InstallDev = $false,

    [Switch]
    $InstallLinuxSubsystem = $false,

    [Switch]
    $InstallHome = $true,

    [String]
    $DataDrive,

    [String]
    $SourceCodeFolder,

    [Switch]
    $SkipWindowsUpdate,

    [Switch]
    $EnableWindowsAuthFeature,

    [Switch]
    $InstallVS2017Community,

    [Switch]
    $InstallVS2017Enterprise,

    [Switch]
    $CustomiseFolders,

    [String]
    $SqlServer2016IsoImage,

    [String]
    $SqlServer2016SaPassword
)

function Set-EnvironmentVariable
{
    param
    (
        [String]
        [Parameter(Mandatory=$true)]
        $Key,

        [String]
        [Parameter(Mandatory=$true)]
        $Value
    )

    [Environment]::SetEnvironmentVariable($Key, $Value, "Machine") # for reboots
	[Environment]::SetEnvironmentVariable($Key, $Value, "Process") # for right now

}

Write-Host "Path:" $MyInvocation.MyCommand.Path

if ($InstallDev)
{
    Set-EnvironmentVariable -Key "BoxStarter:InstallDev" -Value "1"
}

if ($InstallHome)
{
    Set-EnvironmentVariable -Key "BoxStarter:InstallHome" -Value "1"
}

if ($InstallLinuxSubsystem)
{
    Set-EnvironmentVariable -Key "BoxStarter:InstallLinuxSubsystem" -Value "1"
}

if ($DataDrive)
{
    Set-EnvironmentVariable -Key "BoxStarter:DataDrive" -Value $DataDrive
}

if ($SourceCodeFolder)
{
    Set-EnvironmentVariable -Key "BoxStarter:SourceCodeFolder" -Value $SourceCodeFolder
}

if ($SkipWindowsUpdate)
{
    Set-EnvironmentVariable -Key "BoxStarter:SkipWindowsUpdate" -Value "1"
}

if ($EnableWindowsAuthFeature)
{
    Set-EnvironmentVariable -Key "BoxStarter:EnableWindowsAuthFeature" -Value "1"
}

if ($InstallVS2017Community)
{
    Set-EnvironmentVariable -Key "BoxStarter:InstallVS2017Community" -Value "1"
}

if ($InstallVS2017Enterprise)
{
    Set-EnvironmentVariable -Key "BoxStarter:InstallVS2017Enterprise" -Value "1"
}

#$installScript = 'https://raw.githubusercontent.com/Quass1m/boxstarter/master/box.ps1'
#$installScript =  Join-Path $MyInvocation.MyCommand.Path 'box.ps1'
$installScript =  C:\boxstarter-master\box.ps1
$webLauncherUrl = "http://boxstarter.org/package/nr/url?$installScript"
$edgeVersion = Get-AppxPackage -Name Microsoft.MicrosoftEdge

if ($edgeVersion)
{
    Start-Process microsoft-edge:$webLauncherUrl
}
else
{
    $IE=new-object -com internetexplorer.application
    $IE.navigate2($webLauncherUrl)
    $IE.visible=$true
}
