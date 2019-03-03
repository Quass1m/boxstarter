<#

#OPTIONAL
    [Environment]::SetEnvironmentVariable("BoxStarter:InstallDev", "1", "Machine") # for reboots
    [Environment]::SetEnvironmentVariable("BoxStarter:InstallDev", "1", "Process") # for right now

    [Environment]::SetEnvironmentVariable("BoxStarter:DataDrive", "D", "Machine") # for reboots
    [Environment]::SetEnvironmentVariable("BoxStarter:DataDrive", "D", "Process") # for right now

    [Environment]::SetEnvironmentVariable("BoxStarter:SourceCodeFolder", "git", "Machine") # relative path to for reboots
    [Environment]::SetEnvironmentVariable("BoxStarter:SourceCodeFolder", "git", "Process") # for right now

    [Environment]::SetEnvironmentVariable("BoxStarter:SkipWindowsUpdate", "1", "Machine") # for reboots
    [Environment]::SetEnvironmentVariable("BoxStarter:SkipWindowsUpdate", "1", "Process") # for right now

    [Environment]::SetEnvironmentVariable("BoxStarter:EnableWindowsAuthFeature", "1", "Machine") # for reboots
    [Environment]::SetEnvironmentVariable("BoxStarter:EnableWindowsAuthFeature", "1", "Process") # for right now

    [Environment]::SetEnvironmentVariable("choco:sqlserver2016:isoImage", "D:\Downloads\en_sql_server_2016_rc_2_x64_dvd_8509698.iso", "Machine") # for reboots
    [Environment]::SetEnvironmentVariable("choco:sqlserver2016:isoImage", "D:\Downloads\en_sql_server_2016_rc_2_x64_dvd_8509698.iso", "Process") # for right now

#START
    START http://boxstarter.org/package/nr/url?http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/kpietralik/boxstarter/master/box.ps1

    wget -Uri 'https://raw.githubusercontent.com/kpietralik/boxstarter/master/bootstrap.ps1' -OutFile "$($env:temp)\bootstrap.ps1";&Invoke-Command -ScriptBlock { &"$($env:temp)\bootstrap.ps1" -InstallDev -SkipWindowsUpdate -SqlServer2014IsoImage 'c:\sql2014\en_sql_server_2014_standard_edition_x64_dvd_3932034.iso' }

    http://boxstarter.org/package/nr/url?http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/kpietralik/boxstarter/master/box.ps1
#>

#$Boxstarter.RebootOk = $true
#$Boxstarter.NoPassword = $false
#$Boxstarter.AutoLogin = $true

. .\box_functions.ps1

$checkpointPrefix = 'BoxStarter:Checkpoint:'

function Install-HomeApps {
    if (-not(Test-Path env:\BoxStarter:InstallHome)) {
        return
    }

    $apps = @(
        ('chocolatey',''),
        ('boxstarter',''),
        ('chocolatey-core.extension',''),
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

    foreach ($app in $apps) {
        Install-App -Name $app[0] -Args $app[0]
    }

    # pin apps that update themselves
    $pinApps = @(
        'skype',
        'steam',
        'firefox',
        'visualstudiocode',
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
        ('sql-server-management-studio', '--limitoutput'),
        ('sql-operations-studio', '--limitoutput'),
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

######3

Disable-UAC

$dataDriveLetter = Get-DataDrive
$dataDrive = "$dataDriveLetter`:"
$tempInstallFolder = New-InstallCache -InstallDrive $dataDrive

Use-Checkpoint -Function ${Function:Set-RegionalSettings} -CheckpointName 'RegionalSettings' -SkipMessage 'Regional settings are already configured'

Use-Checkpoint -Function ${Function:Set-RegistrySettings} -CheckpointName 'RegistrySettings' -SkipMessage 'Registry settings are already configured'

# SQL Server requires some KB patches before it will work, so windows update first
Write-BoxstarterMessage "Windows update..."
Install-WindowsUpdate

# Disable chocolatey default confirmation behaviour (no need for --yes)
Use-Checkpoint -Function ${Function:Enable-ChocolateyFeatures} -CheckpointName 'IntialiseChocolatey' -SkipMessage 'Chocolatey features already configured'

Use-Checkpoint -Function ${Function:Set-BaseSettings} -CheckpointName 'BaseSettings' -SkipMessage 'Base settings are already configured'
Use-Checkpoint -Function ${Function:Set-UserSettings} -CheckpointName 'UserSettings' -SkipMessage 'User settings are already configured'

Write-BoxstarterMessage "Starting installs"

Use-Checkpoint -Function ${Function:Set-BaseDesktopSettings} -CheckpointName 'BaseDesktopSettings' -SkipMessage 'Base desktop settings are already configured'

if (Test-Path env:\BoxStarter:InstallHome) {
    Write-BoxstarterMessage "Installing home apps"

    #enable dev related windows features
    Use-Checkpoint -Function ${Function:Install-HomeApps} -CheckpointName 'InstallHomeApps' -SkipMessage 'Home apps are already installed'

    if (Test-PendingReboot) { Invoke-Reboot }
}

if (Test-Path env:\BoxStarter:InstallDev) {
    Write-BoxstarterMessage "Installing dev apps"

    #enable dev related windows features
    Use-Checkpoint -Function ${Function:Install-DevFeatures} -CheckpointName 'DevFeatures' -SkipMessage 'Windows dev features are already configured'

    #setup iis
    Use-Checkpoint -Function ${Function:Install-InternetInformationServices} -CheckpointName 'InternetInformationServices' -SkipMessage 'IIS features are already configured'

    if (Test-PendingReboot) { Invoke-Reboot }

    #install apps used for dev
    Use-Checkpoint -Function ${Function:Install-DevTools} -CheckpointName 'DevTools' -SkipMessage 'Dev tools are already installed'

    # make folder for source code
    New-SourceCodeFolder

    #install sql server 2016
    #Use-Checkpoint -Function ${Function:Install-SqlServer2016} -CheckpointName 'SqlServer2016' -SkipMessage 'SQL Server 2016 are already installed' $dataDrive

    #install vs2017 community
    #Use-Checkpoint -Function ${Function:Install-VisualStudio2017} -CheckpointName 'VisualStudio2017Community' -SkipMessage 'Visual Studio 2017 Community is already installed'

    #install vs2017 workloads
    #Use-Checkpoint -Function ${Function:Install-VisualStudio2017Workloads} -CheckpointName 'VisualStudio2017Workloads' -SkipMessage 'Visual Studio 2017 Workloads are already installed'

    #install vscode and extensions
    Use-Checkpoint -Function ${Function:Install-VisualStudioCode} -CheckpointName 'VisualStudioCode' -SkipMessage 'VSCode is already installed'

    Use-Checkpoint -Function ${Function:Set-DevDesktopSettings} -CheckpointName 'DevDesktopSettings' -SkipMessage 'Dev desktop settings are already configured'
}

if (Test-Path env:\BoxStarter:LinuxSubsystem) {
    Write-BoxstarterMessage "Installing linux subsystem apps"

    ##install LinuxSubsystem
    Use-Checkpoint -Function ${Function:Install-LinuxSubsystem} -CheckpointName 'LinuxSubsystem' -SkipMessage 'LinuxSubsystem is already configured'

    if (Test-PendingReboot) { Invoke-Reboot }
}

#install apps for home use
Use-Checkpoint -Function ${Function:Install-HomeApps} -CheckpointName 'HomeApps' -SkipMessage 'Home apps are already installed'

#move windows libraries to data drive
Use-Checkpoint -Function ${Function:Update-WindowsLibraries} -CheckpointName 'WindowsLibraries' -SkipMessage 'Libraries are already configured'

# install chocolatey as last choco package
# ToDo: why last? install first?
choco install chocolatey --limitoutput

# re-enable chocolatey default confirmation behaviour
Use-Checkpoint -Function ${Function:Disable-ChocolateyFeatures} -CheckpointName 'DisableChocolatey' -SkipMessage 'Chocolatey features already configured'

if (Test-PendingReboot) { Invoke-Reboot }

# reload path environment variable
Update-Path

Use-Checkpoint -Function ${Function:Install-PowerShellModules} -CheckpointName 'PowerShellModules' -SkipMessage 'PowerShell modules are already installed'

# set HOME to user profile for git
[Environment]::SetEnvironmentVariable("HOME", $env:UserProfile, "User")

# rerun windows update after we have installed everything
Write-BoxstarterMessage "Windows update..."
Install-WindowsUpdate

Enable-UAC

Clear-Checkpoints
Write-BoxstarterMessage "--- END ---"

#Update-Path
# take care of chocolatey and boxstarter module dependency at start
# log each app status ($LASTEXITCODE?)
# log section complete status
# display all input information
# defaults: only home apps?
# echo each install
# split info multiple files and modules
# unify usage of 'SetEnvironmentVariable'