# Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
# . { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; Get-Boxstarter -Force

# .\bootstrap.ps1 -InstallDev=$true -SourceCodeFolder "C:\GIT"

# START http://boxstarter.org/package/nr/url?C:\boxstarter-master\box.ps1

# 1. CMD install choco:
# @"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
# 2. Install boxstarter:
# choco install boxstarter
# 3. Set script execution policy
# Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine
# 4. Execute script from its directory 

param
(
    [Switch]
    $InstallHome = $true,

    [Switch]
    $InstallDev = $true,

    [Switch]
    $InstallDocker,

    [String]
    $DataDrive,

    [String]
    $SourceCodeFolder = "D:\GIT",

    [Switch]
    $RunWindowsUpdate,

    [Switch]
    $EnableWindowsAuthFeature,

    [Switch]
    $BaseSettings,

    [Switch]
    $UserSettings,

    [Switch]
    $DesktopSettings,

    [Switch]
    $NotebookSettings,

    [Switch]
    $DevSettings,

    [Switch]
    $MoveWindowsLibraries,

    [Switch]
    $InstallVsCommunity,

    [Switch]
    $InstallVsEnterprise,

    [Switch]
    $SqlServer
)

function Set-EnvironmentVariable
{
    param
    (
        [String]
        [Parameter(Mandatory=$true)]
        $Key,

        [String]
        [Parameter(Mandatory=$false)]
        $Value
    )

    [Environment]::SetEnvironmentVariable($Key, $Value, "Machine") # for reboots
    [Environment]::SetEnvironmentVariable($Key, $Value, "Process") # for right now
}

function Get-Option
{
    param
    (
        [Boolean] [Parameter(Mandatory=$true, Position=0)] $Name
    )    
	
    if ($Name)
    {
        return "1"
    }
    else
    {    
        return "0"
    }
}

$path = $PSScriptRoot

Write-Host "Path:" $path

Set-EnvironmentVariable -Key "BoxStarter:Option:InstallHome" -Value (Get-Option $InstallHome)
Set-EnvironmentVariable -Key "BoxStarter:Option:InstallDev" -Value (Get-Option $InstallDev)
Set-EnvironmentVariable -Key "BoxStarter:Option:InstallDocker" -Value (Get-Option $InstallDocker)
Set-EnvironmentVariable -Key "BoxStarter:Option:DataDrive" -Value $DataDrive
Set-EnvironmentVariable -Key "BoxStarter:Option:SourceCodeFolder" -Value $SourceCodeFolder
Set-EnvironmentVariable -Key "BoxStarter:Option:RunWindowsUpdate" -Value (Get-Option $RunWindowsUpdate)
Set-EnvironmentVariable -Key "BoxStarter:Option:EnableWindowsAuthFeature" -Value (Get-Option $EnableWindowsAuthFeature)
Set-EnvironmentVariable -Key "BoxStarter:Option:BaseSettings" -Value (Get-Option $BaseSettings)
Set-EnvironmentVariable -Key "BoxStarter:Option:UserSettings" -Value (Get-Option $UserSettings)
Set-EnvironmentVariable -Key "BoxStarter:Option:DesktopSettings" -Value (Get-Option $DesktopSettings)
Set-EnvironmentVariable -Key "BoxStarter:Option:NotebookSettings" -Value (Get-Option $NotebookSettings)
Set-EnvironmentVariable -Key "BoxStarter:Option:DevSettings" -Value (Get-Option $DevSettings)
Set-EnvironmentVariable -Key "BoxStarter:Option:MoveWindowsLibraries" -Value (Get-Option $MoveWindowsLibraries)
Set-EnvironmentVariable -Key "BoxStarter:Option:SqlServer" -Value (Get-Option $SqlServer)
Set-EnvironmentVariable -Key "BoxStarter:Option:InstallVsCommunity" -Value (Get-Option $InstallVsCommunity)
Set-EnvironmentVariable -Key "BoxStarter:Option:InstallVsEnterprise" -Value (Get-Option $InstallVsEnterprise)

# Module path
Set-EnvironmentVariable -Key "BoxStarter:ModulePath" -Value $path


# ToDo: TEMP
return;


$installScript =  Join-Path $PSScriptRoot 'box.ps1'
$webLauncherUrl = "http://boxstarter.org/package/nr/url?$installScript"
$edgeVersion = Get-AppxPackage -Name Microsoft.MicrosoftEdge

Write-Host "Url: " $webLauncherUrl

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
