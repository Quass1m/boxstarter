##################
# List power plans
gwmi -NS root\cimv2\power -Class win32_PowerPlan | select ElementName, IsActive | ft -a

##################
# https://www.reddit.com/r/PowerShell/comments/748xgr/editing_power_plan_with_powershell_v5/
# GUID for the "Balanced" Power Scheme
$balancedGUID = '381b4222-f694-41f0-9685-ff5bb260df2e'
# GUID for the "High performance" Power Scheme
$highGUID = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'

# GUID for "Power buttons and lid"
$subGUID = '4f971e89-eebd-4455-a8de-9e59040e7347'

# GUID for "Lid close action"
$lidGUID = '5ca83367-6e45-459f-a27b-476b1d01c936'
# GUID for "Power button action"
$buttonGUID = '7648efa3-dd9c-4e3e-b566-50f929386280'
# GUID for "Sleep button action"
$sleepGUID = '96996bc0-ad50-47ec-923b-6f41874dd9eb'

# Options
$DoNothing = 0
$Sleep = 1
$Hibernate = 2
$ShutDown = 3

# Switches
$ac = '-setacvalueindex'
$dc = '-setdcvalueindex'

Write-Host powercfg $ac $balancedGUID $subGUID $lidGUID    $DoNothing
Write-Host powercfg $ac $balancedGUID $subGUID $buttonGUID $ShutDown
Write-Host powercfg $ac $balancedGUID $subGUID $sleepGUID  $Sleep
Write-Host powercfg $ac $highGUID     $subGUID $lidGUID    $DoNothing
Write-Host powercfg $ac $highGUID     $subGUID $buttonGUID $ShutDown
Write-Host powercfg $ac $highGUID     $subGUID $sleepGUID  $Sleep
Write-Host 
Write-Host powercfg $dc $balancedGUID $subGUID $lidGUID    $DoNothing
Write-Host powercfg $dc $balancedGUID $subGUID $buttonGUID $ShutDown
Write-Host powercfg $dc $balancedGUID $subGUID $sleepGUID  $Sleep
Write-Host powercfg $dc $highGUID     $subGUID $lidGUID    $DoNothing
Write-Host powercfg $dc $highGUID     $subGUID $buttonGUID $ShutDown
Write-Host powercfg $dc $highGUID     $subGUID $sleepGUID  $Sleep