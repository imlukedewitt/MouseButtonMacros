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
    if WinActive("Google Chrome") or WinActive("Visual Studio Code") or WinActive("Mozilla Firefox")
    {
        if (scroll = "down")
            send ^{PgDn}
        if (scroll = "up")
            send ^{PgUp}
    }
    if WinActive("Telegram") or WinActive("ahk_exe WindowsTerminal.exe")
    {
        if (scroll = "down")
            send ^{Tab}
        if (scroll = "up")
            send ^+{Tab}
    }
    send {ctrl down}{lwin down}
}

; send date on 'ddate'
::ddate::
SendInput, %A_YYYY%-%A_MM%-%A_DD%
return

; send domain suffix on '.wwork'
:?:.wwork::
SendInput, .workstation.mssu.edu
return

; tomcat check script
^!+t::
SendRaw, for i in $(seq 1 10)`; do service tomcat$i status 2>/dev/null | awk -v i=$i `'/not running/{print "\033[31mTomcat" i " is not running\033[0m"} /is running/{print "\033[32mTomcat" i " is running\033[0m"}`'`; sleep 0.1`; done

; leap mode (inspired by vim mode)
~CapsLock::Toggle := !Toggle

#If Toggle

*j::Left
*l::Right
*i::Up
*k::Down
*u::Home
*o::End
*h::PgUp
*`;::PgDn

#If

; enter timesheet when you type 'ttime'
::ttime::
Send, 08:00 AM
Send, {Tab}
Send, 01:00 PM
Send, {Tab}
Send, {Enter}
Sleep, 300
Send, 02:00 PM
Send, {Tab}
Send, 05:00 PM
return