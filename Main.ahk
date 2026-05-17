#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent(true)
CoordMode("Mouse", "Screen")

; ===== LOAD MODULES =====
#Include modules\Globals.ahk
#Include modules\Settings.ahk
#Include modules\Hotkeys.ahk
#Include modules\Tray.ahk
#Include modules\Gui.ahk
#Include modules\Launcher.ahk
#Include modules\ClickCycler.ahk

; ===== INITIALIZE =====
LoadSettings()
SetupTray()
RegisterHotkeys()
LoadCyclers()

; ===== AUTO-LAUNCH SAMSUNG NOTES =====
LaunchSamsungNotes()