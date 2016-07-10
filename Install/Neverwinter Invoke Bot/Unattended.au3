#RequireAdmin
AutoItSetOption("TrayAutoPause", 0)
#include "..\variables.au3"
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <TrayConstants.au3>
#include "_GetUTCMinutes.au3"
#include "Localization.au3"
Global $Title = $Name & ": Unattended Launcher"
TraySetToolTip($Title)
LoadLocalizations()
If _Singleton($Title & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("UnattendedAlreadyRunning"))
    Exit
EndIf
TraySetIcon(@ScriptDir & "\images\green.ico")
TraySetState($TRAY_ICONSTATE_FLASH)
If @Compiled Then
    Local $deleted = 1
    If FileExists(@ScriptDir & "\Install.exe") Then $deleted = FileDelete(@ScriptDir & "\Install.exe")
    ShellExecuteWait(@ScriptDir & "\Neverwinter Invoke Bot.exe", -1, @ScriptDir)
    If $deleted And FileExists(@ScriptDir & "\Install.exe") Then Exit
Else
    ShellExecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Neverwinter Invoke Bot.au3" -1', @ScriptDir)
EndIf
TraySetState($TRAY_ICONSTATE_STOPFLASH)
While 1
    TraySetIcon(@ScriptDir & "\images\teal.ico")
    Local $min = 0
    While 1
        $min = _GetUTCMinutes(10, 1, True, False, True, $Title)
        If $min >= 0 Then ExitLoop
        TraySetToolTip($Title & @CRLF & Localize("FailedToGetMinutes"))
        Sleep(600000)
    WEnd
    TraySetToolTip($Title)
    TraySetIcon(@ScriptDir & "\images\blue.ico")
    Sleep($min * 60000)
    TraySetIcon(@ScriptDir & "\images\green.ico")
    While ProcessExists("Neverwinter Invoke Bot.exe")
        ProcessClose("Neverwinter Invoke Bot.exe")
        Sleep(500)
    WEnd
    While ProcessExists("GameClient.exe")
        ProcessClose("GameClient.exe")
        Sleep(500)
    WEnd
    If @Compiled Then
        ShellExecuteWait(@ScriptDir & "\Neverwinter Invoke Bot.exe", 1, @ScriptDir)
    Else
        ShellExecuteWait(@AutoItExe, '/AutoIt3ExecuteScript "' & @ScriptDir & '\Neverwinter Invoke Bot.au3" 1', @ScriptDir)
    EndIf
WEnd