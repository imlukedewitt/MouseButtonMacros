#SingleInstance, force
SetTitleMatchMode, 2

; Alt Tab control
XButton2 & WheelDown::AltTab
XButton2 & WheelUp::ShiftAltTab
XButton2:: send !{Tab}

; Check first button for double or single press
XButton1::
	if (A_PriorHotkey = "XButton1 up") && (A_TimeSincePriorHotkey < 200)
    {
        doubleTapButton1 := "1"
    }
    Else
        doubleTapButton1 := "0"
	send, {ctrl down}{LWin Down}
return
XButton1 up::send, {ctrl up}{LWin up}

; first button + wheel action decider
^#WheelDown::
if (doubleTapButton1 = 0)
    send, {right}
if (doubleTapButton1 = 1)
    Button1Double("down")
return
^#WheelUp::
if (doubleTapButton1 = 0)
    send, {left}
if (doubleTapButton1 = 1)
    Button1Double("up")
return


; first button double tap + wheel action decider
Button1Double(scroll)
{
    send {ctrl up}{lwin up}
    if WinActive("Google Chrome") or WinActive("Visual Studio Code")
    {
        if (scroll = "down")
            send ^{PgDn}
        if (scroll = "up")
            send ^{PgUp}
    }
    if WinActive("Telegram")
    {
        if (scroll = "down")
            send ^{Tab}
        if (scroll = "up")
            send ^+{Tab}
    }
    send {ctrl down}{lwin down}
}

; send date on ddate
::ddate::
SendInput, %A_YYYY%-%A_MM%-%A_DD%
return

; send powershell functions to run as admin
::rrunass::
SendRaw,
(
function RunAsAdmin
{
    # Usage:
    # if (!(RunAsAdmin)) { Exit }

    $adminaccess = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')
    if ($adminaccess) { return $true}
    $argList = @("-NoLogo -ExecutionPolicy Bypass -File $(Get-UNCPath -Quotes)" )
    Start-Process Powershell.exe -Verb Runas -ArgumentList $argList
    exit 0
}

function Get-UNCPath
{
    param ( [switch]$ScriptRoot, [switch]$Quotes )

    $path = $script:MyInvocation.MyCommand.Path
    if ($path.contains([io.path]::VolumeSeparatorChar))
    {
        $psDrive = Get-PSDrive -Name $path.Substring(0,1) -PSProvider FileSystem
        if ($psDrive.DisplayRoot) { $path = $path.Replace($psDrive.Name + [io.path]::VolumeSeparatorChar, $psDrive.DisplayRoot) }
    }

    if ($ScriptRoot) { $path = $path.Replace([io.path]::DirectorySeparatorChar + $script:MyInvocation.MyCommand.Name, "") }
    if ($Quotes) { $path = '"' + $path + '"' }
    return $path
}
)
return