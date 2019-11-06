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
        #('chocolatey',''),
        #('boxstarter',''),
        #('chocolatey-core.extension',''),        
        #('chocolateygui',''),
        ('notepadplusplus',''),
        ('vscode',''),
        ('k-litecodecpackfull',''),
        ('7zip',''),
        #('allow-block-remove-firewall',''), # "This program will add a right click option to all .exe and .com programs, allowing you to allow, block or remove a program from the Windows firewall in 1 click."
        #('autohotkey.portable',''),
        #('calibre',''),
        ('ccleaner',''),
        ('clink',''),
        ('cpu-z',''),
        ('dropbox',''),
        #('dws.portable',''),
        ('gpu-z',''),
        ('hwinfo',''),
        ('openhardwaremonitor',''),
        ('coretemp',''),
        ('crystaldiskinfo',''),
        ('crystaldiskmark',''),
        ('firefox',''),
        ('foobar2000',''),
        ('googlechrome',''),
        ('google-backup-and-sync',''),
        ('greenshot',''),
		('irfanview',''),
        ('irfanviewplugins',''),
        #('imgburn',''),
        ('jdk8',''),
        #('lockhunter',''),
        ('paint.Net',''),
        ('qbittorrent',''),
        ('rufus',''),
        ##('skype',''), # Windows Store pre-installed app
        #('speccy',''),
        ('steam',''),
        ('virtualbox',''),
        ('vlc',''),
        ('wget',''),
        ('youtube-dl',''),
        ('teamspeak',''),
        ('mumble',''),
        ##('spotify',''), # Windows Store pre-installed app
        ('firacode',''),
        ('handbrake',''),
        #('cdburnerxp',''),
        #('f.lux',''),
        #('miktex',''),
        #('TeXstudio',''),
        ('audacity',''),
        ('audacity-lame',''),
        ('audacity-ffmpeg','')
    )

    foreach ($app in $apps) {
        Install-App -Name $app[0] -Args $app[1]
    }   
	
    # pin apps that update themselves
    $pinApps = @(
        #'skype',
        'vscode',
        'steam',
        'firefox',
        'vscode',
        'googlechrome'
    )

    foreach ($pin in $pinApps) {
        Pin-App -Name $pin
    }

    # Install vscode extensions
    Use-Checkpoint -Function ${Function:Install-VisualStudioCodeExtensions} -CheckpointName $checkpointPrefix'VisualStudioCodeExtensions' -SkipMessage 'VSCode extensions are already installed'
}

function Install-DevTools {	
    $apps = @(
        ('curl',''),
        ('jq',''), #bash json parsing
		('sql-server-management-studio', '--limitoutput'),
		('sql-operations-studio', '--limitoutput'),
		('cmder',''),
		('git','/GitAndUnixToolsOnPath'),
		('git-credential-manager-for-windows',''),
		('hyper',''),
		('fciv',''),
		('poshgit',''),
		('linqpad',''),
		('nuget.commandline',''),
		('nimbletext',''),
		('powershell',''),
		('azure-cli',''),
		('procexp',''),
		('putty',''),
		('anaconda3','/AddToPath'),
		#('python',''), # Is it necessary when installing Anaconda3?
		#('pip',''),	# Is it necessary when installing Anaconda3?
		('postman',''),
		('sysinternals',''),
		('vim',''),
		('windbg',''),
		('winmerge',''),
		('nugetpackageexplorer',''),
		('azurepowershell',''),
		('microsoftazurestorageexplorer',''),
		('servicebusexplorer',''),
		('dotnetcore-sdk',''),
		('azure-functions-core-tools',''),
		('az.powershell','')
		
		#('winscp',''),
		#('wireshark',''),
		#('cygwin',''),
		#('glogg',''),
		#('gcloudsdk',''),
		#('intellijidea-community',''),
		#('terraform',''),
		#('draft ',''),
		#('kubernetes-helm',''), 
		#('golang','')
		# ToDo: add 'Azurite' package when it's up on chocolatey
	)
	
    foreach ($app in $apps) {
        Install-App -Name $app[0] -Args $app[1]
    }

	Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
	Install-Module -Name PowerShellGet -Force
	
    # Azure Az
    Install-Module -Name Az -AllowClobber -Scope CurrentUser -Force

    # set HOME to user profile for git
    [Environment]::SetEnvironmentVariable("HOME", $env:UserProfile, "User")
}

function Install-Docker {
    $apps = @(
		# ToDo: install proper version based on windows 10 home/pro edition
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

Import-Module -Name (Join-Path "$modulePath" "box_functions.psm1") -Verbose -Force

###### Start ######
choco feature enable -n allowGlobalConfirmation

Disable-UAC
$dataDriveLetter = Get-DataDrive
$dataDrive = "$dataDriveLetter`:"
$tempInstallFolder = New-InstallCache -InstallDrive $dataDrive

$checkpointPrefix = 'BoxStarter:Checkpoint:'

Use-Checkpoint -Function ${Function:Set-RegionalSettings} -CheckpointName $checkpointPrefix'RegionalSettings' -SkipMessage 'Regional settings are already configured'

if (Test-Variable -Path env:\BoxStarter:Option:RunWindowsUpdate) {
    Write-BoxstarterMessage "Windows update..."

    Use-Checkpoint -Function ${Function:Install-WindowsUpdateFunc} -CheckpointName $checkpointPrefix'WindowsUpdateFunc' -SkipMessage 'WindowsUpdateFunc is already configured'

    #if (Test-PendingReboot) { Invoke-Reboot }
}

Use-Checkpoint -Function ${Function:Enable-ChocolateyFeatures} -CheckpointName $checkpointPrefix'IntialiseChocolatey' -SkipMessage 'Chocolatey features already configured'

Write-BoxstarterMessage "Starting installs"

# ToDo: use this approach 
# install apps for home use
#Execute-Step -Name 'HomeApps'
#Use-Checkpoint -Function ${Function:Install-HomeApps} -CheckpointName $checkpointPrefix'HomeApps' -SkipMessage 'Home apps are already installed'

if (Test-Variable -Path env:\BoxStarter:Option:InstallHome) {
    Write-BoxstarterMessage "Installing home apps"

    Use-Checkpoint -Function ${Function:Install-HomeApps} -CheckpointName $checkpointPrefix'InstallHomeApps' -SkipMessage 'Home apps are already installed'
}

if (Test-Variable -Path env:\BoxStarter:Option:InstallDev) {
    Write-BoxstarterMessage "Installing dev apps"

    #enable dev related windows features
    Use-Checkpoint -Function ${Function:Install-DevFeatures} -CheckpointName $checkpointPrefix'DevFeatures' -SkipMessage 'Windows dev features are already configured'

	# ToDo: fix it
    #setup IIS & EnableWindowsAuthFeature
    #Use-Checkpoint -Function ${Function:Install-InternetInformationServices} -CheckpointName $checkpointPrefix'InternetInformationServices' -SkipMessage 'IIS features are already configured'

    #install apps used for dev
    Use-Checkpoint -Function ${Function:Install-DevTools} -CheckpointName $checkpointPrefix'DevTools' -SkipMessage 'Dev tools are already installed'

	# ToDo: implement in a better way
    ##install vscode and extensions
    #Use-Checkpoint -Function ${Function:Install-VisualStudioCode} -CheckpointName $checkpointPrefix'VisualStudioCode' -SkipMessage 'VSCode is already installed'

    # make folder for source code
    New-SourceCodeFolder
}

if (Test-Variable -Path env:\BoxStarter:Option:InstallDocker) {
    Write-BoxstarterMessage "Installing docker"
    Use-Checkpoint -Function ${Function:Install-Docker} -CheckpointName $checkpointPrefix'InstallDocker' -SkipMessage 'Docker already installed'
}

# ToDo: install SqlServer 2019 (Developer)
# if (Test-Variable -Path env:\BoxStarter:Option:SqlServer) {
#     Write-BoxstarterMessage "SqlServer2016"

#     Use-Checkpoint -Function ${Function:Set-SqlServer2016} -CheckpointName $checkpointPrefix'SqlServer2016' -SkipMessage 'SqlServer2016 are already configured'
# }

if (Test-Variable -Path env:\BoxStarter:Option:BaseSettings) {
    Write-BoxstarterMessage "Setting up BaseSettings"

    Use-Checkpoint -Function ${Function:Set-BaseSettings} -CheckpointName $checkpointPrefix'BaseSettings' -SkipMessage 'BaseSettings are already configured'
}

if (Test-Variable -Path env:\BoxStarter:Option:UserSettings) {
    Write-BoxstarterMessage "Setting up UserSettings"

    Use-Checkpoint -Function ${Function:Set-UserSettings} -CheckpointName $checkpointPrefix'UserSettings' -SkipMessage 'UserSettings are already configured'
}

if (Test-Variable -Path env:\BoxStarter:Option:DesktopSettings) {
    Write-BoxstarterMessage "Setting up DesktopSettings"

    Use-Checkpoint -Function ${Function:Set-DesktopSettings} -CheckpointName $checkpointPrefix'DesktopSettings' -SkipMessage 'DesktopSettings are already configured'
}

# ToDo: NotebookSettings

if (Test-Variable -Path env:\BoxStarter:Option:DevSettings) {
    Write-BoxstarterMessage "Setting up DevSettings"

    Use-Checkpoint -Function ${Function:Set-DevSettings} -CheckpointName $checkpointPrefix'DevSettings' -SkipMessage 'Dev settings are already configured'
}

if (Test-Variable -Path env:\BoxStarter:Option:MoveWindowsLibraries) {
    Write-BoxstarterMessage "MoveWindowsLibraries"

    Use-Checkpoint -Function ${Function:Install-MoveWindowsLibraries} -CheckpointName $checkpointPrefix'PowerShellModules' -SkipMessage 'PowerShell modules are already installed'
}

# reload path environment variable
Update-Path

# rerun windows update after we have installed everything
if (Test-Variable -Path env:\BoxStarter:Option:RunWindowsUpdate) {
    Write-BoxstarterMessage "Windows update..."

    Use-Checkpoint -Function ${Function:Install-WindowsUpdateFunc} -CheckpointName $checkpointPrefix'WindowsUpdateFunc' -SkipMessage 'WindowsUpdateFunc is already configured'

    if (Test-PendingReboot) { Invoke-Reboot }
}

Enable-UAC

#Clear-Checkpoints
Write-BoxstarterMessage "--- END ---"