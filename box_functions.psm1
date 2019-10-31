# TOOLS
function Get-BoxstarterEnvironmentVariables {
    param
    (
        [Parameter(Mandatory = $false)] [string] $Key
    )

    return Get-Item -Path Env:* | Where-Object {$_.Name -Like 'Boxstarter*'}
}

function Set-BoxstarterEnvironmentVariable {
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

function Test-Variable {
    param(
        [string] $Path
    )

    if (-NOT (Test-Path $Path)) {
        return $false
    }

    if (((Get-ChildItem $Path).Value) -eq "1")
    {
        return $true
    }

    return $false
}

function Get-CheckpointName {
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $CheckpointName
    )
    return "$checkpointPrefix$CheckpointName"
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

function Get-OSEdition {
    # ToDo: implement, use for docker app
    
    # https://docs.microsoft.com/en-us/windows/desktop/api/sysinfoapi/nf-sysinfoapi-getproductinfo
    (Get-WmiObject -class Win32_OperatingSystem).OperatingSystemSKU

    Get-WindowsEdition -online
}

function Test-IsOSWindows10 {
    $osInfo = Get-OSInformation

    return $osInfo.Major -eq 10
}

function Get-SystemDrive {
    return $env:SystemDrive[0]
}

function Enable-ChocolateyFeatures {
    choco feature enable --name=allowGlobalConfirmation
}

function Disable-ChocolateyFeatures {
    choco feature disable --name=allowGlobalConfirmation
}

# FUNCTIONS
function Get-DataDrive {
    $driveLetter = Get-SystemDrive

    if ((Test-Variable -Path env:\BoxStarter:Option:DataDrive) -and (Test-Variable -Path $env:BoxStarter:Option:DataDrive)) {
        $driveLetter = $env:BoxStarter:Option:DataDrive
    }

    return $driveLetter
}

function Set-RegionalSettings {
    #http://stackoverflow.com/questions/4235243/how-to-set-timezone-using-powershell
    &"$env:windir\system32\tzutil.exe" /s "Central European Standard Time"

    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortDate -Value 'dd/MM/yyyy'
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sLongDate -Value 'dd MMMM yyyy'
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sCountry -Value Poland
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime -Value 'HH:mm'
    Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime -Value 'HH:mm:ss'
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
    Install-App -Name taskbar-never-combine             -Args '--limitoutput'
    Install-App -Name explorer-show-all-folders         -Args '--limitoutput'
    Install-App -Name explorer-expand-to-current-folder -Args '--limitoutput'
}

function Set-DesktopSettings {
    # ToDo why return?    
    #if (Test-IsOSWindows10) {
    #    return
    #}

    Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"
    Install-ChocolateyShortcut `
      -ShortcutFilePath "C:\Users\konra\Desktop\Notepad++.lnk" `
      -TargetPath "C:\Program Files\Notepad++\notepad++.exe" `
      -WindowStyle 3 `
      -RunAsAdmin `
      -PinToTaskbar  
}

# ToDo: add NotebookSettings (power)

function Set-DevSettings {
    if (Test-IsOSWindows10) {
        return
    }

    Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe"

    Install-ChocolateyFileAssociation ".dll" "$env:LOCALAPPDATA\JetBrains\Installations\dotPeek06\dotPeek64.exe"
}

function Update-MoveWindowsLibraries {
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

function Install-WindowsUpdateFunc {

    Enable-MicrosoftUpdate
    Install-WindowsUpdate -AcceptEula
}

function New-SourceCodeFolder {
    $sourceCodeFolder = 'GIT'
    if (Test-Variable -Path env:\BoxStarter:Option:SourceCodeFolder) {
        $sourceCodeFolder = $env:BoxStarter:Option:SourceCodeFolder
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

function Add-ToPath {
    param
    (
        [Parameter(Mandatory = $true)] [string] $Value
    )

    [Environment]::SetEnvironmentVariable("Path", [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine) + ";" + $Value, [EnvironmentVariableTarget]::Machine)
}

function Update-Path {

    # ToDo: move it to box.ps1
    Add-ToPath -Value "$($Boxstarter.programFiles86)\Git"
    Add-ToPath -Value "$($Boxstarter.programFiles86)\Git\bin"
    
    # ToDo: what should it be here?
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    $env:PSModulePath = $env:PSModulePath + ";C:\Program Files\Git\bin"
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

    if (Test-Variable -Path $fullFilename) {
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

function Install-VisualStudio2017 {
    if (-not(Test-Variable -Path env:\BoxStarter:Option:InstallVS2017Community)) {
        return
    }

    Install-App -Name visualstudio2017community -Args '--limitoutput'

    Pin-App -Name visualstudio2017community
}

function Install-VisualStudio2017Workloads {
    if (-not(Test-Variable -Path env:\BoxStarter:Option:InstallVS2017Community) -and -not(Test-Variable -Path env:\BoxStarter:Option:InstallVS2017Enterprise)) {
        return
    }

    Install-App -Name visualstudio2017-workload-netcoretools     -Args '--limitoutput --includeOptional'
    Install-App -Name visualstudio2017-workload-netweb           -Args '--limitoutput'
    Install-App -Name visualstudio2017-workload-node             -Args '--limitoutput'
    Install-App -Name visualstudio2017-workload-data             -Args '--limitoutput --includeOptional'
}

function Install-VisualStudioCodeExtensions {
    # ToDo setup sync
    code --install-extension Shan.code-settings-sync
}

function Install-InternetInformationServices {
    # Enable Internet Information Services Feature - will enable a bunch of things by default
    Install-App -Name IIS-WebServerRole                  -Args '--source windowsfeatures --limitoutput'

    # Web Management Tools Features
    Install-App -Name IIS-ManagementScriptingTools     -Args '--source windowsfeatures --limitoutput'
    Install-App -Name IIS-IIS6ManagementCompatibility  -Args '--source windowsfeatures --limitoutput' # installs IIS Metabase

    # Common Http Features
    Install-App -Name IIS-HttpRedirect                  -Args '--source windowsfeatures --limitoutput'

    # .NET Framework 4.5/4.6 Advance Services
    Install-App -Name NetFx4Extended-ASPNET45           -Args '--source windowsfeatures --limitoutput' # installs ASP.NET 4.5/4.6

    # Application Development Features
    Install-App -Name IIS-NetFxExtensibility45         -Args '--source windowsfeatures --limitoutput' # installs .NET Extensibility 4.5/4.6
    Install-App -Name IIS-ISAPIFilter                  -Args '--source windowsfeatures --limitoutput' # required by IIS-ASPNET45
    Install-App -Name IIS-ISAPIExtensions              -Args '--source windowsfeatures --limitoutput' # required by IIS-ASPNET45
    Install-App -Name IIS-ASPNET45                     -Args '--source windowsfeatures --limitoutput' # installs support for ASP.NET 4.5/4.6
    Install-App -Name IIS-ApplicationInit               -Args '--source windowsfeatures --limitoutput'
    Install-App -Name IIS-WebSockets                   -Args '--source windowsfeatures --limitoutput'

    # Health And Diagnostics Features
    Install-App -Name IIS-LoggingLibraries             -Args '--source windowsfeatures --limitoutput' # installs Logging Tools
    Install-App -Name IIS-RequestMonitor                -Args '--source windowsfeatures --limitoutput'
    Install-App -Name IIS-HttpTracing                  -Args '--source windowsfeatures --limitoutput'
    Install-App -Name IIS-CustomLogging                -Args '--source windowsfeatures --limitoutput'

    # Performance Features
    Install-App -Name IIS-HttpCompressionDynamic       -Args '--source windowsfeatures --limitoutput'

    # Security Features
    Install-App -Name IIS-BasicAuthentication          -Args '--source windowsfeatures --limitoutput'

    if (Test-Variable -Path env:\BoxStarter:Option:EnableWindowsAuthFeature) {
        Install-App -Name IIS-WindowsAuthentication    -Args '--source windowsfeatures --limitoutput'
    }
}

function Install-SqlServer2016 {
    param (
        $InstallDrive
    )

    if (-not (Test-Variable -Path env:\choco:sqlserver2016:isoImage) -and -not(Test-Variable -Path env:\choco:sqlserver2016:setupFolder)) {
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

function Install-DevFeatures {
    Install-App -Name TelnetClient -Args '-source windowsFeatures'
    Install-App -Name PowerShell
    Install-App -Name vcredist2010
    Install-App -Name vcredist140
    Install-App -Name dotnetcore
    Install-App -Name dotnetfx
    Install-App -Name mono
}

function Install-InstallLinuxSubsystem {
    # Bash for windows
    $features = choco list --source windowsfeatures
    if ($features | Where-Object {$_ -like "*Linux*"}) {
        Install-App -Name Microsoft-Hyper-V-All -source windowsFeatures
        Install-App -Name Microsoft-Windows-Subsystem-Linux --source windowsfeatures '--limitoutput'
    }

    Enable-WindowsOptionalFeature -Online -FeatureName containers -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
}

function Install-PowerShellModules {
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Trusted'
    Install-Module -Name Carbon -AllowClobber
    Install-Module -Name PowerShellHumanizer
    Install-Module -Name posh-git
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy 'Untrusted'
}

function Pin-App {
    param
        (
            [Parameter(Mandatory = $true)] [String] $Name
        )
		
	Write-BoxstarterMessage "Pin app '$Name'"
	choco pin add -n="$Name"
}

function Install-App {
    param
        (
            [Parameter(Mandatory = $true)] [String] $Name,
            [Parameter(Mandatory = $false)] [String] $Args
        )

    if ([System.Environment]::GetEnvironmentVariable("BoxStarter:Install:Success:$Name", "Machine") -eq "1") {
         Write-BoxstarterMessage "Package '$Name' already installed." -color Cyan
         return
    }

    Write-BoxstarterMessage "Installing '$Name' with parameters '$Args'"

    choco install $Name $Args

    # ToDo: better status check and error information
    if ($LASTEXITCODE -ne 0) {
        Set-BoxstarterEnvironmentVariable -Key "BoxStarter:Install:Success:$Name" -Value "0"
        Write-BoxstarterMessage "Error in installing '$Name'" -color Magenta
    }
    else {
        Set-BoxstarterEnvironmentVariable -Key "BoxStarter:Install:Success:$Name" -Value "1"
        Write-BoxstarterMessage "Installed '$Name' successfully"
    }
}

# ToDo: develop this
function Execute-Step {
    param
        (
            [Parameter(Mandatory = $true)] [String] $Name,
            [Parameter(Mandatory = $false)] [String] $Args
        )

    if (Test-Variable -Path env:\BoxStarter:Option:$Name) {
        Write-BoxstarterMessage "Executing: $Name"

        Use-Checkpoint -Function ${Function:Install-$Name} -CheckpointName $Name -SkipMessage "$Name has already been executed"

        Update-Path
        #if (Test-PendingReboot) { Invoke-Reboot }
    }
    else{
        Write-BoxstarterMessage "Skipping: $Name"
    }
}
