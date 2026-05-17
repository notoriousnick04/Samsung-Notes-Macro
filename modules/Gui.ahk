; ===== GUI =====

ShowGui(*)
{
    global mainGui, currentHotkey
    
    if (mainGui && WinExist("ahk_id " . mainGui.Hwnd))
    {
        WinActivate("ahk_id " . mainGui.Hwnd)
        return
    }
    
    mainGui := Gui("+Resize", "Samsung Notes Helper")
    mainGui.SetFont("s10", "Segoe UI")
    mainGui.MarginX := 15
    mainGui.MarginY := 15
    
    ; Title
    mainGui.SetFont("s14 Bold")
    mainGui.Add("Text", "w450", "Samsung Notes Helper")
    mainGui.SetFont("s10 Norm")
    
    ; Tabs
    tabs := mainGui.Add("Tab3", "xm y+10 w450 h350", ["General", "Click Cycler"])
    
    ; ===== TAB 1: GENERAL =====
    tabs.UseTab(1)
    
    mainGui.Add("Text", "xm+15 y+20", "Open menu hotkey:")
    mainGui.Add("Hotkey", "xm+15 y+5 w200 vHotkeyInput", currentHotkey)
    saveBtn := mainGui.Add("Button", "x+10 yp w90", "Save")
    
    mainGui.Add("Text", "xm+15 y+20 w420 h1 Background555555")
    resetBtn := mainGui.Add("Button", "xm+15 y+15 w200", "Reset Task Manager Coords")
    
    mainGui.Add("Text", "xm+15 y+20 w420 cGray vStatus", "Status: Ready")
    
    ; ===== TAB 2: CLICK CYCLER =====
    tabs.UseTab(2)
    
    mainGui.Add("Text", "xm+15 y+20", "Configured Cyclers:")
    lv := mainGui.Add("ListView", "xm+15 y+5 w420 h200 vCyclerList", ["Name", "Hotkey", "Type", "Coords", "Timeout (s)"])
    lv.OnEvent("DoubleClick", OnEditCycler)
    RefreshCyclerList(lv)
    
    addBtn := mainGui.Add("Button", "xm+15 y+10 w130", "Add New")
    editBtn := mainGui.Add("Button", "x+10 yp w130", "Edit Selected")
    deleteBtn := mainGui.Add("Button", "x+10 yp w130", "Delete Selected")
    
    mainGui.Add("Text", "xm+15 y+15 w420 cGray vCyclerStatus", "Ready")
    
    tabs.UseTab()
    
    ; ===== EVENTS =====
    saveBtn.OnEvent("Click", OnSaveHotkey)
    resetBtn.OnEvent("Click", OnResetCoords)
    addBtn.OnEvent("Click", (*) => ShowCyclerEditor(""))
    editBtn.OnEvent("Click", OnEditCycler)
    deleteBtn.OnEvent("Click", OnDeleteCycler)
    
    mainGui.OnEvent("Close", (*) => mainGui.Hide())
    mainGui.OnEvent("Escape", (*) => mainGui.Hide())
    
    mainGui.Show("w480 h410")
}

OnSaveHotkey(*)
{
    global mainGui
    newHotkey := mainGui["HotkeyInput"].Value
    statusText := mainGui["Status"]
    
    result := UpdateHotkey(newHotkey)
    
    statusText.Text := "Status: " . result.message
    statusText.Opt(result.success ? "cGreen" : "cRed")
}

OnResetCoords(*)
{
    global mainGui
    statusText := mainGui["Status"]
    
    if DeleteSetting("Coords")
    {
        statusText.Text := "Status: Coordinates reset"
        statusText.Opt("cGreen")
    }
    else
    {
        statusText.Text := "Status: No coordinates to reset"
        statusText.Opt("cGray")
    }
}