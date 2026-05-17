; ===== SAMSUNG NOTES LAUNCHER =====

LaunchSamsungNotes()
{
    global appPath, windowTitle
    
    if WinExist(windowTitle)
    {
        WinActivate(windowTitle)
        WinMaximize(windowTitle)
        SetTimer(WatchForClose, 500)
        return
    }
    
    Run(appPath)
    
    if !WinWait(windowTitle,, 10)
    {
        TrayTip("Error", "Samsung Notes didn't open in time.", 3)
        return
    }
    
    WinActivate(windowTitle)
    WinMaximize(windowTitle)
    
    SetTimer(WatchForClose, 500)
}

WatchForClose()
{
    global windowTitle
    
    if !WinExist(windowTitle)
    {
        SetTimer(, 0)
        
        ; Lock cursor to current position
        MouseGetPos(&cx, &cy)
        rect := Buffer(16, 0)
        NumPut("Int", cx, "Int", cy, "Int", cx+1, "Int", cy+1, rect)
        DllCall("ClipCursor", "Ptr", rect.Ptr)
        
        BlockInput("On")
        BlockInput("MouseMove")
        
        Sleep(500)
        FullyCloseSamsungNotes()
    }
}

FullyCloseSamsungNotes()
{
    ; Force the 64-bit Task Manager to avoid legacy view
    Run("C:\Windows\System32\Taskmgr.exe")
    
    if !WinWait("ahk_class TaskManagerWindow",, 5)
    {
        DllCall("ClipCursor", "Ptr", 0)
        BlockInput("Off")
        BlockInput("MouseMoveOff")
        ExitApp()
        return
    }
    
    WinActivate("ahk_class TaskManagerWindow")
    WinMaximize("ahk_class TaskManagerWindow")
    Sleep(1500)
    
    Send("^f")
    Sleep(500)
    Send("Samsung Notes")
    Sleep(1500)
    
    savedX := GetSetting("Coords", "X", "")
    savedY := GetSetting("Coords", "Y", "")
    
    if (savedX != "" && savedY != "")
    {
        EndTaskAndExit(savedX, savedY)
    }
    else
    {
        DllCall("ClipCursor", "Ptr", 0)
        BlockInput("Off")
        BlockInput("MouseMoveOff")
        FirstTimeSetup()
    }
}

FirstTimeSetup()
{
    MsgBox("First-time setup!`n`nHover your mouse over the Samsung Notes row in Task Manager, then press F1.", "Setup", "Iconi")
    
    HotIfWinActive("ahk_class TaskManagerWindow")
    Hotkey("F1", CaptureCoords, "On")
    HotIf()
}

CaptureCoords(*)
{
    MouseGetPos(&x, &y)
    
    SaveSetting("Coords", "X", x)
    SaveSetting("Coords", "Y", y)
    
    HotIfWinActive("ahk_class TaskManagerWindow")
    Hotkey("F1", "Off")
    HotIf()
    
    TrayTip("Coordinates Saved", "X: " . x . ", Y: " . y, 1)
    
    ; Re-lock for click sequence
    BlockInput("On")
    BlockInput("MouseMove")
    
    EndTaskAndExit(x, y)
}

EndTaskAndExit(x, y)
{
    ; Release cursor lock so click can happen
    DllCall("ClipCursor", "Ptr", 0)
    
    try {
        Click(x, y)
        
        ; Re-lock cursor at click position
        rect := Buffer(16, 0)
        NumPut("Int", x, "Int", y, "Int", x+1, "Int", y+1, rect)
        DllCall("ClipCursor", "Ptr", rect.Ptr)
        
        Sleep(500)
        Send("{Delete}")
        Sleep(800)
        Send("{Enter}")
        Sleep(500)
        WinClose("ahk_class TaskManagerWindow")
    }
    
    ; Release everything
    DllCall("ClipCursor", "Ptr", 0)
    BlockInput("Off")
    BlockInput("MouseMoveOff")
    
    ExitApp()
}