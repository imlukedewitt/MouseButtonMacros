## Creates scheduled task to run mousebuttons.ahk on login as current user with highest priviledges

## Replace named network paths with UNC path if necessary
$path = $script:MyInvocation.MyCommand.Path
if ($path.contains([io.path]::VolumeSeparatorChar))
{
    $psDrive = Get-PSDrive -Name $path.Substring(0,1) -PSProvider FileSystem
    if ($psDrive.DisplayRoot) { $path = $path.Replace($psDrive.Name + [io.path]::VolumeSeparatorChar, $psDrive.DisplayRoot) }
}

## Re-open script as administrator if necessary
$adminAccess = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
if ($adminAccess) { $path = Split-Path -Parent $path }
else
{
    Start-Process Powershell -Verb RunAs -ArgumentList "-NoLogo -NoProfile -ExecutionPolicy Bypass -File `"$path`""
    Exit
}

## Misc setup
$currentUser = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty UserName | Split-Path -Leaf
if (Test-Path "C:\Program Files\AutoHotkey\AutoHotkey.exe") { $AHKPath = "C:\Program Files\AutoHotkey\AutoHotkey.exe" }
elseif (Test-Path "C:\Program Files (x86)\AutoHotKey\AutoHotKey.exe") { $AHKPath = "C:\Program Files (x86)\AutoHotKey\AutoHotKey.exe" }
else { Write-Warning "AutoHotKey installation not found!"; Pause; Exit 1 }

## Create Scheduled Task
$taskAction = New-ScheduledTaskAction -Execute "`"$AHKPath`"" -Argument "`"$path\mousebuttons.ahk`""
$taskPrincipal = New-ScheduledTaskPrincipal -UserId $currentUser -RunLevel Highest
$taskTrigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName 'MouseButtonMacros' -Trigger $taskTrigger -Action $taskAction -Principal $taskPrincipal

Pause