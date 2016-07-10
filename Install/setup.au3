#NoTrayIcon
#include "variables.au3"
#include <MsgBoxConstants.au3>
Global $Title = $Name & " v" & $Version & " Installer"
If Not @Compiled Then
    Exit MsgBox($MB_ICONWARNING, $Title, "The script must be a compiled exe to work correctly!")
EndIf
#include <Misc.au3>
#include <WinAPIFiles.au3>
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <StringConstants.au3>
#include ".\Neverwinter Invoke Bot\Localization.au3"
LoadLocalizations(1, @ScriptDir & "\" & $Name & "\Localization.ini")

Local $InstallDir = @ProgramFilesDir & "\" & $Name, $RegLocation = "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\" & $Name, $InstallLocation = StringRegExpReplace(RegRead($RegLocation, "InstallLocation"), "\\+$", "")

Func GetInstallLocation($dir = $InstallDir)
    Local $GUI = GUICreate($Title, 434, 142)
    Local $Input = GUICtrlCreateInput($dir, 16, 56, 329, 21)
    Local $ButtonChange = GUICtrlCreateButton("Change", 352, 54, 75, 25)
    Local $ButtonOK = GUICtrlCreateButton("OK", 168, 104, 75, 25, $BS_DEFPUSHBUTTON)
    Local $ButtonCancel = GUICtrlCreateButton("Cancel", 264, 104, 75, 25)
    Local $Label = GUICtrlCreateLabel(Localize("SelectInstallLocation"), 16, 24, 332, 25)
    GUISetState()
    While 1
        Switch GUIGetMsg()
            Case $GUI_EVENT_CLOSE
                Exit
            Case $ButtonChange
                Local $sFileSelectFolder = FileSelectFolder(Localize("SelectInstallLocation"), StringRegExpReplace(StringRegExpReplace(GUICtrlRead($Input), "\\+$", ""), "\\" & $Name & "$", ""), 0, "", $GUI)
                If @error = 0 Then
                    GUICtrlSetData($Input, StringRegExpReplace($sFileSelectFolder, "\\+$", "") & "\" & $Name)
                EndIf
            Case $ButtonOK
                Local $sCurrInput = StringRegExpReplace(GUICtrlRead($Input), "\\+$", "")
                If StringRegExp($sCurrInput, "\\" & $Name & "$") And FileExists(StringRegExpReplace($sCurrInput, "\\" & $Name & "$", "")) Then
                    GUIDelete()
                    $InstallLocation = RegRead($RegLocation, "InstallLocation")
                    If $InstallLocation <> $sCurrInput And $InstallLocation <> "" Then
                        Local $UninstallString = StringReplace(RegRead($RegLocation, "UninstallString"), '"', "")
                        If StringInStr($UninstallString, $InstallLocation) And FileExists($UninstallString) Then
                            MsgBox($MB_ICONWARNING, $Title, Localize("UninstallPreviousInstallation"))
                            RunWait($UninstallString, $InstallLocation)
                            $InstallLocation = RegRead($RegLocation, "InstallLocation")
                            If $InstallLocation <> "" Then
                                Return GetInstallLocation($InstallLocation)
                            EndIf
                            Return GetInstallLocation($sCurrInput)
                        EndIf
                    EndIf
                    Return $sCurrInput
                EndIf
            Case $ButtonCancel
                Exit
        EndSwitch
    WEnd
EndFunc

If _Singleton($Name & " Installer" & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("InstallerAlreadyRunning"))
    Exit
ElseIf _Singleton($Name & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("CloseBeforeInstall"))
    Exit
ElseIf _Singleton($Name & ": Unattended Launcher" & "Jp4g9QRntjYP", 1) = 0 Then
    MsgBox($MB_ICONWARNING, $Title, Localize("CloseUnattendedBeforeInstall"))
    Exit
EndIf
If $InstallLocation <> "" And StringRegExp($InstallLocation, "\\" & $Name & "$") And FileExists($InstallLocation) Then
    $InstallDir = $InstallLocation
Else
    $InstallDir = GetInstallLocation()
EndIf
If Not DirCopy($Name, $InstallDir, 1) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCopyingFilesToProgramsFolder"))
    Exit
EndIf
If Not RegWrite($RegLocation, "DisplayName", "REG_SZ", $Name) Or Not RegWrite($RegLocation, "DisplayVersion", "REG_SZ", $Version) Or Not RegWrite($RegLocation, "Publisher", "REG_SZ", "BigRedBot") Or Not RegWrite($RegLocation, "DisplayIcon", "REG_SZ", $InstallDir & "\" & $Name & ".exe") Or Not RegWrite($RegLocation, "UninstallString", "REG_SZ", '"' & $InstallDir & '\Uninstall.exe"') Or Not RegWrite($RegLocation, "InstallLocation", "REG_SZ", $InstallDir) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingUninstallerRegistry"))
    Exit
EndIf
FileDelete(@DesktopDir & "\" & $Name & ".lnk")
If Not FileCreateShortcut($InstallDir & "\" & $Name & ".exe", @DesktopCommonDir & "\" & $Name & ".lnk", $InstallDir) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingShortcut"))
    Exit
EndIf
FileDelete(@DesktopDir & "\" & $Name & " Donation.lnk")
If Not FileCreateShortcut($InstallDir & "\Donation.html", @DesktopCommonDir & "\" & $Name & " Donation.lnk", $InstallDir) Then
    MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingShortcut"))
    Exit
EndIf
Local $RunUnattendedOnStartup
If MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("RunUnattendedOnStartup")) = $IDYES Then
    If Not FileCreateShortcut($InstallDir & "\Unattended.exe", @StartupCommonDir & "\" & $Name & " Unattended Launcher.lnk", $InstallDir) Then
        MsgBox($MB_ICONWARNING, $Title, Localize("ErrorCreatingShortcut"))
        Exit
    EndIf
    $RunUnattendedOnStartup = 1
ElseIf FileExists(@StartupCommonDir & "\" & $Name & " Unattended Launcher.lnk") And Not FileDelete(@StartupCommonDir & "\" & $Name & " Unattended Launcher.lnk") Then
    MsgBox($MB_ICONWARNING, $Title, Localize("FailedToDeleteFile", "<FILE>", @StartupCommonDir & "\" & $Name & " Unattended Launcher.lnk"))
    Exit
EndIf
MsgBox($MB_OK, $Title, Localize("SuccessfullyInstalled", "<VERSION>", $Version) & @CRLF & @CRLF & $InstallDir)
If $RunUnattendedOnStartup And MsgBox($MB_YESNO + $MB_ICONQUESTION, $Title, Localize("RunUnattendedNow")) = $IDYES Then
    ShellExecute($InstallDir & "\Unattended.exe", "", $InstallDir)
EndIf