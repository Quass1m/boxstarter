<#

#OPTIONAL

    ** Windows 7 **
    Should upgrade to WMF 5 first for reduced errors
    https://www.microsoft.com/en-us/download/details.aspx?id=50395

    # If Dev Machine
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


    # If Home Machine
    [Environment]::SetEnvironmentVariable("BoxStarter:InstallHome", "1", "Machine") # for reboots
    [Environment]::SetEnvironmentVariable("BoxStarter:InstallHome", "1", "Process") # for right now

#START
    START http://boxstarter.org/package/nr/url?http://boxstarter.org/package/nr/url?https://raw.githubusercontent.com/JonCubed/boxstarter/master/box.ps1

    wget -Uri 'https://raw.githubusercontent.com/JonCubed/boxstarter/master/bootstrap.ps1' -OutFile "$($env:temp)\bootstrap.ps1";&Invoke-Command -ScriptBlock { &"$($env:temp)\bootstrap.ps1" -InstallDev -SkipWindowsUpdate -SqlServer2014IsoImage 'c:\sql2014\en_sql_server_2014_standard_edition_x64_dvd_3932034.iso' }
#>

$Boxstarter.RebootOk = $true
$Boxstarter.NoPassword = $false
$Boxstarter.AutoLogin = $true

$checkpointPrefix = 'BoxStarter:Checkpoint:'

function Get-CheckpointName {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckpointName
    )
    return "$checkpointPrefix$CheckpointName"
}

function Set-Checkpoint {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckpointName,

        [Parameter(Mandatory = $true)]
        [string]
        $CheckpointValue
    )

    $key = Get-CheckpointName $CheckpointName
    [Environment]::SetEnvironmentVariable($key, $CheckpointValue, "Machine") # for reboots
    [Environment]::SetEnvironmentVariable($key, $CheckpointValue, "Process") # for right now
}

function Get-Checkpoint {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckpointName
    )

    $key = Get-CheckpointName $CheckpointName
    [Environment]::GetEnvironmentVariable($key, "Process")
}

function Clear-Checkpoints {
    $checkpointMarkers = Get-ChildItem Env: | where { $_.name -like "$checkpointPrefix*" } | Select -ExpandProperty name
    foreach ($checkpointMarker in $checkpointMarkers) {
        [Environment]::SetEnvironmentVariable($checkpointMarker, '', "Machine")
        [Environment]::SetEnvironmentVariable($checkpointMarker, '', "Process")
    }
}

function Use-Checkpoint {
    param(
        [string]
        $CheckpointName,

        [string]
        $SkipMessage,

        [scriptblock]
        $Function
    )

    $checkpoint = Get-Checkpoint -CheckpointName $CheckpointName

    if (-not $checkpoint) {
        $Function.Invoke($Args)

        Set-Checkpoint -CheckpointName $CheckpointName -CheckpointValue 1
    }
    else {
        Write-BoxstarterMessage $SkipMessage
    }
}

function Get-OSInformation {
    $osInfo = Get-WmiObject -class Win32_OperatingSystem `
        | Select-Object -First 1

    return ConvertFrom-String -Delimiter \. -PropertyNames Major, Minor, Build  $osInfo.version
}

function Test-IsOSWindows10 {
    $osInfo = Get-OSInformation

    return $osInfo.Major -eq 10
}

function Get-SystemDrive {
    return $env:SystemDrive[0]
}

function Get-DataDrive {
    $driveLetter = Get-SystemDrive

    if ((Test-Path env:\BoxStarter:DataDrive) -and (Test-Path $env:BoxStarter:DataDrive)) {
        $driveLetter = $env:BoxStarter:DataDrive
    }

    return $driveLetter
}

function Set-RegionalSettings {
    #http://stackoverflow.com/questions/4235243/how-to-set-timezone-using-powershell
    &"$env:windir\system32\tzutil.exe" /s "AUS Eastern Standard Time"

    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortDate -Value 'dd MMM yy'
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sCountry -Value Australia
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime -Value 'hh:mm tt'
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sTimeFormat -Value 'hh:mm:ss tt'
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sLanguage -Value ENA
}

function Set-RegistrySettings {
    Set-ItemProperty -Path HKCU:\Software\Microsoft\VisualStudio\15.0\General -Name SuppressUppercaseConversion -Type DWord -Value 1
    Set-ItemProperty -Path HKCU:\Software\Microsoft\VisualStudio\17.0\General -Name SuppressUppercaseConversion -Type DWord -Value 1
    Set-ItemProperty -Path HKCU:\Console\%SystemRoot%_system32_cmd.exe -Name QuickEdit -Type DWord -Value 0
    Set-ItemProperty -Path HKCU:\Console\%SystemRoot%_System32_WindowsPowerShell_v1.0_powershell.exe -Name QuickEdit -Type DWord -Value 0
    Set-ItemProperty -Path HKCU:\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe -Name QuickEdit -Type DWord -Value 0
}

function Set-BaseSettings {
    Update-ExecutionPolicy -Policy Unrestricted
    Update-Help

    Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -DisableShowProtectedOSFiles -EnableShowFileExtensions -EnableShowFullPathInTitleBar -DisableOpenFileExplorerToQuickAccess -DisableShowRecentFilesInQuickAccess -DisableShowFrequentFoldersInQuickAccess -DisableExpandToOpenFolder
    #Set-TaskbarOptions -Size Small
    Set-CornerNavigationOptions -EnableUsePowerShellOnWinX
    Set-StartScreenOptions -EnableBootToDesktop -EnableDesktopBackgroundOnStart -EnableShowStartOnActiveScreen -EnableShowAppsViewOnStartScreen -EnableSearchEverywhereInAppsView -EnableListDesktopAppsFirst
    Set-TaskbarOptions -Size Large -UnLock -Dock Bottom -Combine Never
    # Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneExpandToCurrentFolder -Value 1
    # Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name NavPaneShowAllFolders -Value 1
    # Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name LaunchTo -Value 1
    # Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name MMTaskbarMode -Value 2

    Enable-RemoteDesktop
    Enable-PSRemoting -Force -SkipNetworkProfileCheck

    Disable-InternetExplorerESC
    Disable-GameBarTips
    Disable-BingSearch
}

function Set-UserSettings {
    choco install taskbar-never-combine             --limitoutput
    choco install explorer-show-all-folders         --limitoutput
    choco install explorer-expand-to-current-folder --limitoutput
}

function Set-BaseDesktopSettings {
    # ToDo why return?    
    #if (Test-IsOSWindows10) {
    #    return
    #}

    Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"
    Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)Microsoft Visual Studio\2017\Community\Common7\IDE\devenv.exe"
    Install-ChocolateyShortcut `
      -ShortcutFilePath "C:\Users\Admin\Desktop\Notepad++.lnk" `
      -TargetPath "C:\Program Files\Notepad++\notepad++.exe" `
      -WindowStyle 3 `
      -RunAsAdmin `
      -PinToTaskbar  
}

function Set-DevDesktopSettings {
    if (Test-IsOSWindows10) {
        return
    }

    Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"

    Install-ChocolateyFileAssociation ".dll" "$env:LOCALAPPDATA\JetBrains\Installations\dotPeek06\dotPeek64.exe"
}

function Update-WindowsLibraries {
    if(-not(Test-Path Env:\BoxStarter:CustomiseFolders)) {
        return
    }
    
    Set-Volume -DriveLetter $sytemDrive -NewFileSystemLabel "OS"

    $dataDriveLetter = Get-DataDrive
    $dataDrive = "$dataDriveLetter`:"

    if (Get-SystemDrive -eq $dataDriveLetter) {
        return
    }

    Write-BoxstarterMessage "Configuring $dataDrive\"

    Set-Volume -DriveLetter $dataDriveLetter -NewFileSystemLabel "Data"

    $userDataPath = "$dataDrive\Data\Documents"
    $mediaPath = "$dataDrive\Media"

    Move-WindowsLibrary -libraryName "My Pictures" -newPath (Join-Path $userDataPath "Pictures")
    Move-WindowsLibrary -libraryName "Personal"    -newPath (Join-Path $userDataPath "Documents")
    Move-WindowsLibrary -libraryName "Desktop"     -newPath (Join-Path $userDataPath "Desktop")
    Move-WindowsLibrary -libraryName "My Video"    -newPath (Join-Path $mediaPath "Videos")
    Move-WindowsLibrary -libraryName "My Music"    -newPath (Join-Path $mediaPath "Music")
    Move-WindowsLibrary -libraryName "Downloads"   -newPath "$dataDrive\Downloads"
}

function Move-WindowsLibrary {
    param(
        $libraryName,
        $newPath
    )

    if (-not (Test-Path $newPath)) {
        Move-LibraryDirectory -libraryName $libraryName -newPath $newPath
    }
}

function New-SourceCodeFolder {
    $sourceCodeFolder = 'GIT'
    if (Test-Path env:\BoxStarter:SourceCodeFolder) {
        $sourceCodeFolder = $env:BoxStarter:SourceCodeFolder
    }

    if ([System.IO.Path]::IsPathRooted($sourceCodeFolder)) {
        $sourceCodePath = $sourceCodeFolder
    }
    else {
        $drivePath = Get-DataDrive
        $sourceCodePath = Join-Path "$drivePath`:" $sourceCodeFolder
    }

    if (-not (Test-Path $sourceCodePath)) {
        New-Item $sourceCodePath -ItemType Directory
    }
}

function New-InstallCache {
    param
    (
        [String]
        $InstallDrive
    )

    $tempInstallFolder = Join-Path $InstallDrive "temp\install-cache"

    if (-not (Test-Path $tempInstallFolder)) {
        New-Item $tempInstallFolder -ItemType Directory
    }

    return $tempInstallFolder
}

function Enable-ChocolateyFeatures {
    choco feature enable --name=allowGlobalConfirmation
}

function Disable-ChocolateyFeatures {
    choco feature disable --name=allowGlobalConfirmation
}

function Update-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    Install-ChocolateyPath -PathToInstall "$($Boxstarter.programFiles86)\Git"
    Install-ChocolateyPath -PathToInstall "$($Boxstarter.programFiles86)\Git\bin"
    $env:PSModulePath = $env:PSModulePath + ";C:\Program Files\Git\bin"
}

function Install-WindowsUpdate {
    if (Test-Path env:\BoxStarter:SkipWindowsUpdate) {
        return
    }

    Enable-MicrosoftUpdate
    Install-WindowsUpdate -AcceptEula
    #if (Test-PendingReboot) { Invoke-Reboot }
}

function Install-WebPackage {
    param(
        $packageName,
        [ValidateSet('exe', 'msi')]
        $fileType,
        $installParameters,
        $downloadFolder,
        $url,
        $filename
    )

    if ([String]::IsNullOrEmpty($filename)) {
        $filename = Split-Path $url -Leaf
    }

    $fullFilename = Join-Path $downloadFolder $filename

    if (test-path $fullFilename) {
        Write-BoxstarterMessage "$fullFilename already exists"
        return
    }

    Get-ChocolateyWebFile $packageName $fullFilename $url
    Install-ChocolateyInstallPackage $packageName $fileType $installParameters $fullFilename
}

function Install-WebPackageWithCheckpoint {
    param(
        $packageName,
        [ValidateSet('exe', 'msi')]
        $fileType,
        $installParameters,
        $downloadFolder,
        $url,
        $filename
    )

    Use-Checkpoint `
        -Function ${Function:Install-WebPackage} `
        -CheckpointName $packageName `
        -SkipMessage "$packageName is already installed" `
        $packageName `
        $fileType `
        $installParameters `
        $downloadFolder `
        $url `
        $filename
}

function Install-SqlServer2016 {
    param (
        $InstallDrive
    )

    if (-not (Test-Path env:\choco:sqlserver2016:isoImage) -and -not(Test-Path env:\choco:sqlserver2016:setupFolder)) {
        return
    }

    $dataPath = Join-Path $InstallDrive "Data\Sql"

    #rejected by chocolatey.org since iso image is required  :|
    $sqlPackageSource = "https://www.myget.org/F/nm-chocolatey-packs/api/v2"

    # Note: No support for Windows 7 https://msdn.microsoft.com/en-us/library/ms143506.aspx
    $env:choco:sqlserver2016:INSTALLSQLDATADIR = $dataPath
    $env:choco:sqlserver2016:INSTANCEID = "sql2016"
    $env:choco:sqlserver2016:INSTANCENAME = "sql2016"
    $env:choco:sqlserver2016:AGTSVCACCOUNT = "NT Service\SQLAgent`$SQL2016"
    $env:choco:sqlserver2016:SQLSVCACCOUNT = "NT Service\MSSQL`$SQL2016"
    $env:choco:sqlserver2016:SQLCOLLATION = "SQL_Latin1_General_CP1_CI_AS"
    choco install sqlserver2016 --source=$sqlPackageSource
}

function Install-HomeApps {
    if (-not(Test-Path env:\BoxStarter:InstallHome)) {
        return
    }

    choco install chocolatey
    choco install boxstarter
    choco install wudt
    choco install chocolatey-core.extension
    choco install 7zip
    choco install allow-block-remove-firewall
    choco install autohotkey.portable
    choco install calibre
    choco install chocolateygui
    choco install ccleaner
    #choco install cdburnerxp
    choco install clink
    choco install cpu-z
    choco install dropbox
    choco install dws.portable
    choco install gpu-z
    choco install hwinfo
    choco install openhardwaremonitor
    choco install coretemp
    choco install crystaldiskinfo
    choco install crystaldiskmark
    choco install firefox
    choco install foobar2000
    choco install googlechrome
    choco install googledrive
    choco install greenshot
    choco install irfanview
    choco install jdk8
    choco install jre8
    choco install jdk9
    choco install jre9
    choco install k-litecodecpackfull
    choco install lockhunter
    choco install notepadplusplus
    choco install glogg
    choco install paint.Net
    choco install pip
    choco install qbittorrent
    choco install rufus
    choco install skype
    choco install speccy
    choco install steam
    choco install virtualbox
    choco install vlc
    choco install wget
    choco install windirstat
    choco install winscp
    choco install wireshark
    choco install youtube-dl
    choco install teamspeak
    choco install mumble
    choco install spotify
    choco install ditto
    choco install firacode
    #choco install f.lux
    #choco install miktex
    #choco install TeXstudio

    # pin apps that update themselves
    choco pin add -n=skype
    choco pin add -n=steam
    choco pin add -n=firefox
    choco pin add -n=visualstudiocode
    choco pin add -n=googlechrome
    choco pin add -n='paint.net'
}

function Install-DevTools {
    
    choco install sql-server-management-studio  --limitoutput
    choco install sql-operations-studio         --limitoutput
    choco install windowsazurelibsfornet
    choco install NugetPackageExplorer
    choco install curl
    choco install cmder
    choco install hyper
    choco install cygwin
    choco install firacode
    choco install fciv
    choco install filezilla
    choco install gcloudsdk
    choco install git -params '"/GitAndUnixToolsOnPath"'
    choco install git-credential-winstore
    choco install poshgit
    choco install intellijidea-community
    choco install linqpad
    choco install nuget.commandline
    choco install nimbletext
    choco install posh-git
    choco install powershell
    choco install azure-cli
    choco install procexp
    choco install putty
    choco install python
    choco install anaconda3 /AddToPath:1
    choco install postman
    choco install sysinternals
    choco install vim
    choco install vscode
    choco install windbg
    choco install winmerge
    choco install Microsoft-Hyper-V-All -source windowsFeatures
    choco install Microsoft-Windows-Subsystem-Linux -source windowsfeatures
    choco install docker
    choco install docker-for-windows
    choco install nugetpackageexplorer
    Install-WebPackage 'Docker Toolbox' 'exe' '/SILENT /COMPONENTS="Docker,DockerMachine,DockerCompose,VirtualBox,Kitematic" /TASKS="modifypath"' $tempInstallFolder https://github.com/docker/toolbox/releases/download/v1.9.1i/DockerToolbox-1.9.1i.exe
    #choco install poshgit
    #choco install rapidee
    #choco install scala
    #choco install lessmsi
    #choco install terraform 
    #choco install draft 
    #choco install kubernetes-helm 
    #choco install packer
    #choco install golang
    #choco install vagrant
    #choco install sql-server-express
    #choco install tortoisegit
    #choco install windowsazurepowershell
    #choco install azurestorageexplorer cloudberryexplorer.azurestorage

    choco install dotnetcore-sdk
    choco install azure-functions-core-tools
    choco install gitkraken

    # pin apps that update themselves
    choco pin add -n=gitkraken
    choco pin add -n=docker-for-windows
}

function Install-VisualStudio2017 {
    if (-not(Test-Path env:\BoxStarter:InstallVS2017Community)) {
        return
    }

    choco install visualstudio2017community --limitoutput

    choco pin add -n=visualstudio2017community
}

function Install-VisualStudio2017Workloads {
    if (-not(Test-Path env:\BoxStarter:InstallVS2017Community) -and -not(Test-Path env:\BoxStarter:InstallVS2017Enterprise)) {
        return
    }

    choco install visualstudio2017-workload-netcoretools    --limitoutput --includeOptional
    choco install visualstudio2017-workload-netweb          --limitoutput
    choco install visualstudio2017-workload-node            --limitoutput
    choco install visualstudio2017-workload-data            --limitoutput --includeOptional
}

function Install-VisualStudioCode {

    # ToDo setup sync
    code --install-extension Shan.code-settings-sync

    Update-Path
}

function Install-InternetInformationServices {
    # Enable Internet Information Services Feature - will enable a bunch of things by default
    choco install IIS-WebServerRole                 --source windowsfeatures --limitoutput

    # Web Management Tools Features
    choco install IIS-ManagementScriptingTools      --source windowsfeatures --limitoutput
    choco install IIS-IIS6ManagementCompatibility   --source windowsfeatures --limitoutput # installs IIS Metabase

    # Common Http Features
    choco install IIS-HttpRedirect                  --source windowsfeatures --limitoutput

    # .NET Framework 4.5/4.6 Advance Services
    choco install NetFx4Extended-ASPNET45           --source windowsfeatures --limitoutput # installs ASP.NET 4.5/4.6

    # Application Development Features
    choco install IIS-NetFxExtensibility45          --source windowsfeatures --limitoutput # installs .NET Extensibility 4.5/4.6
    choco install IIS-ISAPIFilter                   --source windowsfeatures --limitoutput # required by IIS-ASPNET45
    choco install IIS-ISAPIExtensions               --source windowsfeatures --limitoutput # required by IIS-ASPNET45
    choco install IIS-ASPNET45                      --source windowsfeatures --limitoutput # installs support for ASP.NET 4.5/4.6
    choco install IIS-ApplicationInit               --source windowsfeatures --limitoutput
    choco install IIS-WebSockets                    --source windowsfeatures --limitoutput

    # Health And Diagnostics Features
    choco install IIS-LoggingLibraries              --source windowsfeatures --limitoutput # installs Logging Tools
    choco install IIS-RequestMonitor                --source windowsfeatures --limitoutput
    choco install IIS-HttpTracing                   --source windowsfeatures --limitoutput
    choco install IIS-CustomLogging                 --source windowsfeatures --limitoutput

    # Performance Features
    choco install IIS-HttpCompressionDynamic        --source windowsfeatures --limitoutput

    # Security Features
    choco install IIS-BasicAuthentication           --source windowsfeatures --limitoutput

    if (Test-Path env:\BoxStarter:EnableWindowsAuthFeature) {
        choco install IIS-WindowsAuthentication     --source windowsfeatures --limitoutput
    }
}

function Install-DevFeatures {
    # Bash for windows
    $features = choco list --source windowsfeatures
    if ($features | Where-Object {$_ -like "*Linux*"}) {
        choco install Microsoft-Windows-Subsystem-Linux --source windowsfeatures --limitoutput
    }

    Enable-WindowsOptionalFeature -Online -FeatureName containers -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

    cinst TelnetClient -source windowsFeatures
    cinst PowerShell
    cinst vcredist2010
    cinst vcredist140
    cinst dotnetcore
    cinst dotnetfx
    cinst mono
}

function Install-PowerShellModules {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'
    Install-Module -Name Carbon -AllowClobber
    Install-Module -Name PowerShellHumanizer
    Install-Module -Name posh-git
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Untrusted'
}

###### Start ######

Disable-UAC

$dataDriveLetter = Get-DataDrive
$dataDrive = "$dataDriveLetter`:"
$tempInstallFolder = New-InstallCache -InstallDrive $dataDrive

Use-Checkpoint -Function ${Function:Set-RegionalSettings} -CheckpointName 'RegionalSettings' -SkipMessage 'Regional settings are already configured'

Use-Checkpoint -Function ${Function:Set-RegistrySettings} -CheckpointName 'RegistrySettings' -SkipMessage 'Registry settings are already configured'

# SQL Server requires some KB patches before it will work, so windows update first
Write-BoxstarterMessage "Windows update..."
Install-WindowsUpdate

# disable chocolatey default confirmation behaviour (no need for --yes)
Use-Checkpoint -Function ${Function:Enable-ChocolateyFeatures} -CheckpointName 'IntialiseChocolatey' -SkipMessage 'Chocolatey features already configured'

Use-Checkpoint -Function ${Function:Set-BaseSettings} -CheckpointName 'BaseSettings' -SkipMessage 'Base settings are already configured'
Use-Checkpoint -Function ${Function:Set-UserSettings} -CheckpointName 'UserSettings' -SkipMessage 'User settings are already configured'

Write-BoxstarterMessage "Starting installs"

Use-Checkpoint -Function ${Function:Set-BaseDesktopSettings} -CheckpointName 'BaseDesktopSettings' -SkipMessage 'Base desktop settings are already configured'

if (Test-Path env:\BoxStarter:InstallDev) {
    Write-BoxstarterMessage "Installing dev apps"

    #enale dev related windows features
    Use-Checkpoint -Function ${Function:Install-DevFeatures} -CheckpointName 'DevFeatures' -SkipMessage 'Windows dev features are already configured'

    #setup iis
    Use-Checkpoint -Function ${Function:Install-InternetInformationServices} -CheckpointName 'InternetInformationServices' -SkipMessage 'IIS features are already configured'

    if (Test-PendingReboot) { Invoke-Reboot }

    #install sql server 2016
    Use-Checkpoint -Function ${Function:Install-SqlServer2016} -CheckpointName 'SqlServer2016' -SkipMessage 'SQL Server 2016 are already installed' $dataDrive

    #install vs2017 community
    Use-Checkpoint -Function ${Function:Install-VisualStudio2017} -CheckpointName 'VisualStudio2017Community' -SkipMessage 'Visual Studio 2017 Community is already installed'

    #install vs2017 workloads
    Use-Checkpoint -Function ${Function:Install-VisualStudio2017Workloads} -CheckpointName 'VisualStudio2017Workloads' -SkipMessage 'Visual Studio 2017 Workloads are already installed'

    #install vscode and extensions
    Use-Checkpoint -Function ${Function:Install-VisualStudioCode} -CheckpointName 'VisualStudioCode' -SkipMessage 'VSCode is already installed'

    #install apps used for dev
    Use-Checkpoint -Function ${Function:Install-DevTools} -CheckpointName 'DevTools' -SkipMessage 'Dev tools are already installed'

    # make folder for source code
    New-SourceCodeFolder

    Use-Checkpoint -Function ${Function:Set-DevDesktopSettings} -CheckpointName 'DevDesktopSettings' -SkipMessage 'Dev desktop settings are already configured'
}

#install apps for home use
Use-Checkpoint -Function ${Function:Install-HomeApps} -CheckpointName 'HomeApps' -SkipMessage 'Home apps are already installed'

#move windows libraries to data drive
Use-Checkpoint -Function ${Function:Update-WindowsLibraries} -CheckpointName 'WindowsLibraries' -SkipMessage 'Libraries are already configured'

# install chocolatey as last choco package
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
