<#
#START
    START http://boxstarter.org/package/nr/url?http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/kpietralik/boxstarter/master/box.ps1
#>

### ToDo:
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

#$Boxstarter.RebootOk = $true
#$Boxstarter.NoPassword = $false
#$Boxstarter.AutoLogin = $true

. .\box_functions.ps1

function Install-HomeApps {
    if (-not(Test-Path env:\BoxStarter:InstallHome)) {
        return
    }

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
        ('irfanview',''),
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
        ('firacode','')

        #('cdburnerxp',''),
        #('f.lux',''),
        #('miktex',''),
        #('TeXstudio',''),
    )

    
    # Install vscode extensions
    Use-Checkpoint -Function ${Function:Install-VisualStudioCodeExtensions} -CheckpointName '$checkpointPrefix:VisualStudioCodeExtensions' -SkipMessage 'VSCode extensions are already installed'


    foreach ($app in $apps) {
        Install-App -Name $app[0] -Args $app[0]
    }

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
	if (-not(Test-Path env:\BoxStarter:InstallDev)) {
        return
    }
	
    $apps = @(
        ('curl',''),
		('sql-server-management-studio', '--limitoutput'),
		('sql-operations-studio', '--limitoutput'),
		('curl',''),
		('cmder',''),
		('hyper',''),
		('cygwin',''),
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
		('vscode',''),
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
		
		#('gcloudsdk',''),
		#('git -params '"/GitAndUnixToolsOnPath"'
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
	
    # pin apps that update themselves
    #choco pin add -n=gitkraken
    #choco pin add -n=docker-for-windows
}

###### Start ######

### TEMP
Set-BoxstarterEnvironmentVariable -Key "BoxStarter:InstallDev" -Value "1"
Set-BoxstarterEnvironmentVariable -Key "BoxStarter:InstallHome" -Value "1"
Set-BoxstarterEnvironmentVariable -Key "BoxStarter:SkipWindowsUpdate" -Value "1"

######

# Display boxstarter environmant variables:
$options = Get-BoxstarterEnvironmentVariables

foreach($opt in $options) {
    Write-BoxstarterMessage "Env '$($opt.Name) = $($opt.Value)'" -color Gray
}

######

Disable-UAC

$dataDriveLetter = Get-DataDrive
$dataDrive = "$dataDriveLetter`:"
$tempInstallFolder = New-InstallCache -InstallDrive $dataDrive
$checkpointPrefix = 'BoxStarter:Checkpoint:'

Write-BoxstarterMessage "Registry and regional settings..."
Use-Checkpoint -Function ${Function:Set-RegionalSettings} -CheckpointName '$checkpointPrefix:RegionalSettings' -SkipMessage 'Regional settings are already configured'
Use-Checkpoint -Function ${Function:Set-RegistrySettings} -CheckpointName '$checkpointPrefix:RegistrySettings' -SkipMessage 'Registry settings are already configured'

Write-BoxstarterMessage "Windows update..."
Install-WindowsUpdate

# Disable chocolatey default confirmation behaviour (no need for --yes)
Use-Checkpoint -Function ${Function:Enable-ChocolateyFeatures} -CheckpointName '$checkpointPrefix:IntialiseChocolatey' -SkipMessage 'Chocolatey features already configured'

Write-BoxstarterMessage "Base, User and Desktop settings..."
Use-Checkpoint -Function ${Function:Set-BaseSettings} -CheckpointName '$checkpointPrefix:BaseSettings' -SkipMessage 'Base settings are already configured'
Use-Checkpoint -Function ${Function:Set-UserSettings} -CheckpointName '$checkpointPrefix:UserSettings' -SkipMessage 'User settings are already configured'
Use-Checkpoint -Function ${Function:Set-BaseDesktopSettings} -CheckpointName '$checkpointPrefix:BaseDesktopSettings' -SkipMessage 'Base desktop settings are already configured'


# Move Windows libraries to data drive
Use-Checkpoint -Function ${Function:Update-WindowsLibraries} -CheckpointName '$checkpointPrefix:WindowsLibraries' -SkipMessage 'Libraries are already configured'

###########
Write-BoxstarterMessage "Starting installs..."

# re-enable chocolatey default confirmation behaviour
Use-Checkpoint -Function ${Function:Disable-ChocolateyFeatures} -CheckpointName '$checkpointPrefix:DisableChocolatey' -SkipMessage 'Chocolatey features already configured'

# Install apps for home use
Write-BoxstarterMessage "Installing home apps..."
Use-Checkpoint -Function ${Function:Install-HomeApps} -CheckpointName '$checkpointPrefix:HomeApps' -SkipMessage 'Home apps are already installed'

if (Test-Path env:\BoxStarter:Option:InstallDev) {
    Write-BoxstarterMessage "Installing dev apps..."
        
    New-SourceCodeFolder
    
    Use-Checkpoint -Function ${Function:Install-DevFeatures} -CheckpointName '$checkpointPrefix:DevFeatures' -SkipMessage 'Windows dev features are already configured'

    Use-Checkpoint -Function ${Function:Install-InternetInformationServices} -CheckpointName '$checkpointPrefix:InternetInformationServices' -SkipMessage 'IIS features are already configured'

    if (Test-PendingReboot) { Invoke-Reboot }

    Use-Checkpoint -Function ${Function:Install-DevTools} -CheckpointName '$checkpointPrefix:DevTools' -SkipMessage 'Dev tools are already installed'

    Use-Checkpoint -Function ${Function:Install-VisualStudio2017} -CheckpointName '$checkpointPrefix:VisualStudio2017Community' -SkipMessage 'Visual Studio 2017 Community is already installed'

    Use-Checkpoint -Function ${Function:Install-VisualStudio2017Workloads} -CheckpointName '$checkpointPrefix:VisualStudio2017Workloads' -SkipMessage 'Visual Studio 2017 Workloads are already installed'
}

if (Test-Path env:\BoxStarter:Option:InstallLinuxSubsystem) {
    Write-BoxstarterMessage "Installing linux subsystem apps"
    Use-Checkpoint -Function ${Function:Install-LinuxSubsystem} -CheckpointName '$checkpointPrefix:LinuxSubsystem' -SkipMessage 'LinuxSubsystem is already configured'

    if (Test-PendingReboot) { Invoke-Reboot }
}

if (Test-PendingReboot) { Invoke-Reboot }

# Eeload path environment variable
Update-Path

Use-Checkpoint -Function ${Function:Install-PowerShellModules} -CheckpointName '$checkpointPrefix:PowerShellModules' -SkipMessage 'PowerShell modules are already installed'

# set HOME to user profile for git
[Environment]::SetEnvironmentVariable("HOME", $env:UserProfile, "User")

# rerun windows update after we have installed everything
Write-BoxstarterMessage "Windows update..."
Install-WindowsUpdate

Enable-UAC

Clear-Checkpoints
Write-BoxstarterMessage "--- END ---"
