### ToDo:
# FIX IT
# choco feature enable -n allowGlobalConfirmation

# Update-Path
# take care of chocolatey and boxstarter module dependency at start
# log each app status ($LASTEXITCODE?)
# log section complete status
# display all input information
# display final status
# defaults: only home apps?
# echo each install
# split info multiple files and modules
# unify usage of 'SetEnvironmentVariable'
# powerplans.ps1 as switch
# add switch to only clean checkpoints

function Install-HomeApps {
    $apps = @(
        ('chocolatey',''),
        ('boxstarter',''),
        ('chocolatey-core.extension',''),        
        ('vscode',''),
        ('7zip',''),
        ('allow-block-remove-firewall',''),
        ('autohotkey.portable',''),
        ('calibre',''),
        ('chocolateygui',''),
        ('ccleaner',''),
        ('clink',''),
        ('cpu-z',''),
        ('dropbox',''),
        ('dws.portable',''),
        ('gpu-z',''),
        ('hwinfo',''),
        ('openhardwaremonitor',''),
        ('coretemp',''),
        ('crystaldiskinfo',''),
        ('crystaldiskmark',''),
        ('firefox',''),
        ('foobar2000',''),
        ('googlechrome',''),
        ('googledrive',''),
        ('greenshot',''),
	    ('irfanviewplugins',''),
        ('irfanview',''),
        ('imgburn',''),
        ('jdk8',''),
        ('k-litecodecpackfull',''),
        ('lockhunter',''),
        ('notepadplusplus',''),
        ('glogg',''),
        ('paint.Net',''),
        ('pip',''),
        ('qbittorrent',''),
        ('rufus',''),
        ('skype',''),
        ('speccy',''),
        ('steam',''),
        ('virtualbox',''),
        ('vlc',''),
        ('wget',''),
        ('windirstat',''),
        ('winscp',''),
        ('wireshark',''),
        ('youtube-dl',''),
        ('teamspeak',''),
        ('mumble',''),
        ('spotify',''),
        ('firacode',''),
        ('handbrake',''),
        ('audacity',''),
        ('audacity-lame',''),
        ('audacity-ffmpeg','')
        #('cdburnerxp',''),
        #('f.lux',''),
        #('miktex',''),
        #('TeXstudio',''),
    )

    foreach ($app in $apps) {
        Install-App -Name $app[0] -Args $app[0]

    }   
    
    # Install vscode extensions
    Use-Checkpoint -Function ${Function:Install-VisualStudioCodeExtensions} -CheckpointName '$checkpointPrefix:VisualStudioCodeExtensions' -SkipMessage 'VSCode extensions are already installed'

    # pin apps that update themselves
    $pinApps = @(
        'skype',
        'steam',
        'firefox',
        'vscode',
        'googlechrome'
    )

    foreach ($pin in $pinApps) {
        Pin-App -Name $pin
    }
}

function Install-DevTools {	
    $apps = @(
        ('curl',''),
        ('jq',''), #bash json parsing
		('sql-server-management-studio', '--limitoutput'),
		('sql-operations-studio', '--limitoutput'),
		('curl',''),
		('cmder',''),
		('git','"/GitAndUnixToolsOnPath"'),
		#('git -params '"/GitAndUnixToolsOnPath"'
		('hyper',''),
		#('cygwin',''),
		('firacode',''),
		('fciv',''),
		('filezilla',''),
		('git-credential-winstore',''),
		('poshgit',''),
		('linqpad',''),
		('nuget.commandline',''),
		('nimbletext',''),
		('powershell',''),
		('azure-cli',''),
		('procexp',''),
		('putty',''),
		('python',''),
		('anaconda3','/AddToPath:1'),
		('postman',''),
		('sysinternals',''),
		('vim',''),
		# ('vscode',''), installed in Install-VisualStudioCode
		('windbg',''),
		('winmerge',''),
		('docker-cli',''),
		('docker-for-windows',''), # Windows Enterprise?
		('docker-toolbox',''),     # Windows Home?
		('nugetpackageexplorer',''),
		('windowsazurepowershell',''),
		('microsoftazurestorageexplorer',''),
		('servicebusexplorer',''),
		('dotnetcore-sdk',''),
		('azure-functions-core-tools','')
		('az.powershell','')
		
		#('gcloudsdk',''),
		#('intellijidea-community',''),
		#('gitkraken',''),
		#('windowsazurelibsfornet',''),
		#('rapidee',''),
		#('scala',''),
		#('lessmsi',''),
		#('terraform',''),
		#('draft ',''),
		#('kubernetes-helm',''), 
		#('packer',''),
		#('golang',''),
		#('vagrant',''),
		#('tortoisegit',''),
		#('azurestorageexplorer cloudberryexplorer.azurestorage',''),
	)
	
	foreach ($app in $apps) {
        Install-App -Name $app[0] -Args $app[1]
    }
	
    # Azure Az
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force

    # set HOME to user profile for git
    [Environment]::SetEnvironmentVariable("HOME", $env:UserProfile, "User")

    # pin apps that update themselves
    #choco pin add -n=gitkraken
    #choco pin add -n=docker-for-windows
}

function Install-Docker {
    $apps = @(
		('docker-for-windows',''), # Windows Enterprise?
		('docker-toolbox',''),
		('docker-cli','')
	)
	
	foreach ($app in $apps) {
        Install-App -Name $app[0] -Args $app[1]
    }

    # pin apps that update themselves
    #choco pin add -n=docker-for-windows
}

Write-Host "Script root $PSScriptRoot"

$modulePath = (Get-ChildItem env:\BoxStarter:ModulePath).Value
Write-Host "Module path $modulePath"

Import-Module -Name (Join-Path "$modulePath" "box_functions.psm1") -Verbose

$checkpointPrefix = 'BoxStarter:Checkpoint:'

###### Start ######
Write-Host "aaa"

######3
Write-Host "bbbb"
choco feature enable -n allowGlobalConfirmation

Write-Host "ccc"
Disable-UAC
Write-Host "dddddd"
$dataDriveLetter = Get-DataDrive
$dataDrive = "$dataDriveLetter`:"
$tempInstallFolder = New-InstallCache -InstallDrive $dataDrive

Write-Host "eeeee"
Use-Checkpoint -Function ${Function:Set-RegionalSettings} -CheckpointName 'RegionalSettings' -SkipMessage 'Regional settings are already configured'

Write-Host "ffffff"
if (-NOT (Test-Variable -Path env:\BoxStarter:Option:SkipWindowsUpdate)) {
    Write-BoxstarterMessage "Windows update..."

    Use-Checkpoint -Function ${Function:Install-WindowsUpdateFunc} -CheckpointName 'WindowsUpdateFunc' -SkipMessage 'WindowsUpdateFunc is already configured'

    #if (Test-PendingReboot) { Invoke-Reboot }
}

Write-Host "gggg"
Use-Checkpoint -Function ${Function:Enable-ChocolateyFeatures} -CheckpointName 'IntialiseChocolatey' -SkipMessage 'Chocolatey features already configured'

Write-Host "hhhhhh"
Write-BoxstarterMessage "Starting installs"

#install apps for home use
#Execute-Step -Name 'HomeApps'
#Use-Checkpoint -Function ${Function:Install-HomeApps} -CheckpointName 'HomeApps' -SkipMessage 'Home apps are already installed'

Write-Host "iiiiiiiii"

if (Test-Variable -Path env:\BoxStarter:Option:InstallHome) {
    Write-BoxstarterMessage "Installing home apps"

    Use-Checkpoint -Function ${Function:Install-HomeApps} -CheckpointName 'InstallHomeApps' -SkipMessage 'Home apps are already installed'
}

if (Test-Variable -Path env:\BoxStarter:Option:InstallDev) {
    Write-BoxstarterMessage "Installing dev apps"

    #enable dev related windows features
    Use-Checkpoint -Function ${Function:Install-DevFeatures} -CheckpointName 'DevFeatures' -SkipMessage 'Windows dev features are already configured'

    #setup IIS & EnableWindowsAuthFeature
    Use-Checkpoint -Function ${Function:Install-InternetInformationServices} -CheckpointName 'InternetInformationServices' -SkipMessage 'IIS features are already configured'

    #install apps used for dev
    Use-Checkpoint -Function ${Function:Install-DevTools} -CheckpointName 'DevTools' -SkipMessage 'Dev tools are already installed'

    #install vscode and extensions
    Use-Checkpoint -Function ${Function:Install-VisualStudioCode} -CheckpointName 'VisualStudioCode' -SkipMessage 'VSCode is already installed'

    # make folder for source code
    New-SourceCodeFolder
}

if (Test-Variable -Path env:\BoxStarter:Option:InstallDocker) {
    Write-BoxstarterMessage "Installing docker"
    Use-Checkpoint -Function ${Function:Install-Docker} -CheckpointName 'InstallDocker' -SkipMessage 'Docker already installed'
}

if (Test-Variable -Path env:\BoxStarter:Option:InstallLinuxSubsystem) {
    Write-BoxstarterMessage "Installing linux subsystem apps"

    Use-Checkpoint -Function ${Function:Install-InstallLinuxSubsystem} -CheckpointName 'InstallLinuxSubsystem' -SkipMessage 'InstallLinuxSubsystem is already configured'
}

# if (Test-Variable -Path env:\BoxStarter:Option:SqlServer2016) {
#     Write-BoxstarterMessage "SqlServer2016"

#     Use-Checkpoint -Function ${Function:Set-SqlServer2016} -CheckpointName 'SqlServer2016' -SkipMessage 'SqlServer2016 are already configured'
# }

if (Test-Variable -Path env:\BoxStarter:Option:BaseSettings) {
    Write-BoxstarterMessage "Setting up BaseSettings"

    Use-Checkpoint -Function ${Function:Set-BaseSettings} -CheckpointName 'BaseSettings' -SkipMessage 'BaseSettings are already configured'
}

if (Test-Variable -Path env:\BoxStarter:Option:UserSettings) {
    Write-BoxstarterMessage "Setting up UserSettings"

    Use-Checkpoint -Function ${Function:Set-UserSettings} -CheckpointName 'UserSettings' -SkipMessage 'UserSettings are already configured'
}

if (Test-Variable -Path env:\BoxStarter:Option:DesktopSettings) {
    Write-BoxstarterMessage "Setting up DesktopSettings"

    Use-Checkpoint -Function ${Function:Set-DesktopSettings} -CheckpointName 'DesktopSettings' -SkipMessage 'DesktopSettings are already configured'
}

# ToDo: NotebookSettings

if (Test-Variable -Path env:\BoxStarter:Option:DevSettings) {
    Write-BoxstarterMessage "Setting up DevSettings"

    Use-Checkpoint -Function ${Function:Set-DevSettings} -CheckpointName 'DevSettings' -SkipMessage 'Dev settings are already configured'
}

if (Test-Variable -Path env:\BoxStarter:Option:MoveWindowsLibraries) {
    Write-BoxstarterMessage "MoveWindowsLibraries"

    Use-Checkpoint -Function ${Function:Install-MoveWindowsLibraries} -CheckpointName 'PowerShellModules' -SkipMessage 'PowerShell modules are already installed'
}

# re-enable chocolatey default confirmation behaviour
#Use-Checkpoint -Function ${Function:Disable-ChocolateyFeatures} -CheckpointName 'DisableChocolatey' -SkipMessage 'Chocolatey features already configured'

# reload path environment variable
Update-Path

# rerun windows update after we have installed everything
if (-NOT (Test-Variable -Path env:\BoxStarter:Option:SkipWindowsUpdate)) {
    Write-BoxstarterMessage "Windows update..."

    Use-Checkpoint -Function ${Function:Install-WindowsUpdateFunc} -CheckpointName 'WindowsUpdateFunc' -SkipMessage 'WindowsUpdateFunc is already configured'

    #if (Test-PendingReboot) { Invoke-Reboot }
}

### ?????? ###
# install chocolatey as last choco package
#choco install chocolatey --limitoutput

Enable-UAC

Clear-Checkpoints
Write-BoxstarterMessage "--- END ---"