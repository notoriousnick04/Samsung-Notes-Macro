; ===== CLICK CYCLER =====

global cyclerConfigFile := A_ScriptDir . "\cyclers.ini"

LoadCyclers()
{
    global cyclers, cyclerConfigFile
    cyclers := Map()
    
    if !FileExist(cyclerConfigFile)
        return
    
    sections := ""
    try sections := IniRead(cyclerConfigFile)
    
    if (sections = "")
        return
    
    for section in StrSplit(sections, "`n")
    {
        if InStr(section, "Cycler_") = 1
        {
            hk := SubStr(section, 8)
            name := IniRead(cyclerConfigFile, section, "Name", hk)
            timeout := IniRead(cyclerConfigFile, section, "Timeout", 5)
            clickType := IniRead(cyclerConfigFile, section, "ClickType", "Left")
            coordsStr := IniRead(cyclerConfigFile, section, "Coords", "")
            
            coords := []
            if (coordsStr != "")
            {
                for pair in StrSplit(coordsStr, "|")
                {
                    parts := StrSplit(pair, ",")
                    if (parts.Length = 2)
                        coords.Push({x: Integer(parts[1]), y: Integer(parts[2])})
                }
            }
            
            cyclers[hk] := {
                name: name,
                coords: coords,
                timeout: Number(timeout),
                clickType: clickType,
                currentIndex: 1,
                lastPressed: 0
            }
            
            try Hotkey(hk, CyclerHotkeyHandler.Bind(hk))
        }
    }
}

SaveCycler(hk, name, coords, timeout, clickType)
{
    global cyclerConfigFile
    
    section := "Cycler_" . hk
    
    coordsStr := ""
    for coord in coords
    {
        if (coordsStr != "")
            coordsStr .= "|"
        coordsStr .= coord.x . "," . coord.y
    }
    
    IniWrite(name, cyclerConfigFile, section, "Name")
    IniWrite(coordsStr, cyclerConfigFile, section, "Coords")
    IniWrite(timeout, cyclerConfigFile, section, "Timeout")
    IniWrite(clickType, cyclerConfigFile, section, "ClickType")
}

DeleteCycler(hk)
{
    global cyclers, cyclerConfigFile
    
    try Hotkey(hk, "Off")
    
    if cyclers.Has(hk)
        cyclers.Delete(hk)
    
    try IniDelete(cyclerConfigFile, "Cycler_" . hk)
}

CyclerHotkeyHandler(hk, *)
{
    global cyclers, lastClickedCoord, windowTitle
    
    ; ALL cyclers only work when Samsung Notes is focused
    if !WinActive(windowTitle)
        return
    
    if !cyclers.Has(hk)
        return
    
    cycler := cyclers[hk]
    
    ; --- RIGHT CLICK ---
    if (cycler.clickType = "Right")
    {
        if (cycler.coords.Length >= 1)
        {
            coord := cycler.coords[1]
            MouseMove(coord.x, coord.y, 0)
            Sleep(50)
            Click(coord.x, coord.y, "Right")
        }
        return
    }
    
    ; --- LEFT CLICK ---
    if (cycler.coords.Length = 0)
        return
    
    now := A_TickCount
    if (cycler.lastPressed > 0 && (now - cycler.lastPressed) > (cycler.timeout * 1000))
        cycler.currentIndex := 1
    
    Loop cycler.coords.Length
    {
        coord := cycler.coords[cycler.currentIndex]
        coordKey := coord.x . "," . coord.y
        
        if (coordKey != lastClickedCoord)
        {
            Click(coord.x, coord.y)
            lastClickedCoord := coordKey
            cycler.lastPressed := now
            
            cycler.currentIndex++
            if (cycler.currentIndex > cycler.coords.Length)
                cycler.currentIndex := 1
            
            return
        }
        
        cycler.currentIndex++
        if (cycler.currentIndex > cycler.coords.Length)
            cycler.currentIndex := 1
    }
}

RefreshCyclerList(lv)
{
    global cyclers
    
    lv.Delete()
    
    for hk, data in cyclers
    {
        coordsText := data.coords.Length . " coord(s)"
        timeoutText := (data.clickType = "Right") ? "N/A" : data.timeout
        lv.Add(, data.name, hk, data.clickType, coordsText, timeoutText)
    }
    
    lv.ModifyCol()
}

OnEditCycler(*)
{
    global mainGui
    lv := mainGui["CyclerList"]
    
    row := lv.GetNext()
    if (row = 0)
    {
        mainGui["CyclerStatus"].Text := "Please select a cycler to edit"
        return
    }
    
    hk := lv.GetText(row, 2)
    ShowCyclerEditor(hk)
}

OnDeleteCycler(*)
{
    global mainGui
    lv := mainGui["CyclerList"]
    
    row := lv.GetNext()
    if (row = 0)
    {
        mainGui["CyclerStatus"].Text := "Please select a cycler to delete"
        return
    }
    
    hk := lv.GetText(row, 2)
    name := lv.GetText(row, 1)
    
    result := MsgBox("Delete cycler '" . name . "' (" . hk . ")?", "Confirm", "YesNo Icon!")
    if (result = "Yes")
    {
        DeleteCycler(hk)
        RefreshCyclerList(lv)
        mainGui["CyclerStatus"].Text := "Deleted: " . name
    }
}

; ===== CYCLER EDITOR =====

ShowCyclerEditor(hk)
{
    global editorGui, editingHotkey, editingCoords, cyclers, mainGui
    
    editingHotkey := hk
    
    if (hk != "" && cyclers.Has(hk))
    {
        editingCoords := []
        for c in cyclers[hk].coords
            editingCoords.Push({x: c.x, y: c.y})
        existingTimeout := cyclers[hk].timeout
        existingName := cyclers[hk].name
        existingClickType := cyclers[hk].clickType
    }
    else
    {
        editingCoords := []
        existingTimeout := 5
        existingName := ""
        existingClickType := "Left"
    }
    
    editorGui := Gui("+Owner" . mainGui.Hwnd, hk = "" ? "New Cycler" : "Edit Cycler: " . hk)
    editorGui.SetFont("s10", "Segoe UI")
    editorGui.MarginX := 15
    editorGui.MarginY := 15
    
    editorGui.Add("Text", , "Name:")
    editorGui.Add("Edit", "xm y+5 w300 vEditName", existingName)
    
    editorGui.Add("Text", "xm y+10", "Hotkey:")
    editorGui.Add("Hotkey", "xm y+5 w300 vEditHotkey", hk)
    
    editorGui.Add("Text", "xm y+10", "Click Type:")
    clickTypeDD := editorGui.Add("DropDownList", "xm y+5 w300 vEditClickType", ["Left", "Right"])
    clickTypeDD.Choose(existingClickType = "Right" ? 2 : 1)
    
    editorGui.Add("Text", "xm y+10 vTimeoutLabel", "Timeout (seconds):")
    editorGui.Add("Edit", "xm y+5 w300 vEditTimeout Number", existingTimeout)
    
    editorGui.Add("Text", "xm y+15 vCoordsLabel", "Coordinates:")
    coordLv := editorGui.Add("ListView", "xm y+5 w300 h150 vCoordsList", ["#", "X", "Y"])
    
    RefreshCoordsList(coordLv)
    
    captureBtn := editorGui.Add("Button", "xm y+10 w145", "Capture Coord (F8)")
    removeBtn := editorGui.Add("Button", "x+10 yp w145", "Remove Selected")
    
    moveUpBtn := editorGui.Add("Button", "xm y+5 w145 vMoveUpBtn", "Move Up")
    moveDownBtn := editorGui.Add("Button", "x+10 yp w145 vMoveDownBtn", "Move Down")
    
    editorGui.Add("Text", "xm y+15 w300 h1 Background555555")
    saveBtn := editorGui.Add("Button", "xm y+10 w145 Default", "Save")
    cancelBtn := editorGui.Add("Button", "x+10 yp w145", "Cancel")
    
    editorGui.Add("Text", "xm y+10 w300 cGray vEditorStatus", "Press F8 anywhere to capture cursor position")
    
    captureBtn.OnEvent("Click", StartCapture)
    removeBtn.OnEvent("Click", OnRemoveCoord)
    moveUpBtn.OnEvent("Click", OnMoveUp)
    moveDownBtn.OnEvent("Click", OnMoveDown)
    saveBtn.OnEvent("Click", OnSaveCycler)
    cancelBtn.OnEvent("Click", (*) => OnEditorClose())
    editorGui.OnEvent("Close", (*) => OnEditorClose())
    editorGui.OnEvent("Escape", (*) => OnEditorClose())
    clickTypeDD.OnEvent("Change", OnClickTypeChange)
    
    Hotkey("F8", (*) => CaptureCycleCoord(), "On")
    
    editorGui.Show("w330")
    
    OnClickTypeChange()
}

OnClickTypeChange(*)
{
    global editorGui
    
    isRight := (editorGui["EditClickType"].Text = "Right")
    
    editorGui["EditTimeout"].Enabled := !isRight
    editorGui["MoveUpBtn"].Enabled := !isRight
    editorGui["MoveDownBtn"].Enabled := !isRight
    
    editorGui["CoordsLabel"].Text := isRight ? "Coordinate (only 1 - F8 replaces):" : "Coordinates (in order):"
}

OnEditorClose(*)
{
    global editorGui
    try Hotkey("F8", "Off")
    try editorGui.Destroy()
}

StartCapture(*)
{
    global editorGui
    editorGui["EditorStatus"].Text := "Hover anywhere and press F8 to capture..."
}

CaptureCycleCoord(*)
{
    global editingCoords, editorGui
    
    MouseGetPos(&x, &y)
    
    isRight := (editorGui["EditClickType"].Text = "Right")
    
    if (isRight)
    {
        editingCoords := [{x: x, y: y}]
        editorGui["EditorStatus"].Text := "Right click coord set: (" . x . ", " . y . ")"
    }
    else
    {
        editingCoords.Push({x: x, y: y})
        editorGui["EditorStatus"].Text := "Captured: (" . x . ", " . y . ") - Total: " . editingCoords.Length
    }
    
    RefreshCoordsList(editorGui["CoordsList"])
}

RefreshCoordsList(lv)
{
    global editingCoords
    
    lv.Delete()
    for index, coord in editingCoords
        lv.Add(, index, coord.x, coord.y)
    
    lv.ModifyCol()
}

OnRemoveCoord(*)
{
    global editingCoords, editorGui
    lv := editorGui["CoordsList"]
    
    row := lv.GetNext()
    if (row = 0)
        return
    
    editingCoords.RemoveAt(row)
    RefreshCoordsList(lv)
}

OnMoveUp(*)
{
    global editingCoords, editorGui
    lv := editorGui["CoordsList"]
    
    row := lv.GetNext()
    if (row <= 1)
        return
    
    temp := editingCoords[row]
    editingCoords[row] := editingCoords[row - 1]
    editingCoords[row - 1] := temp
    
    RefreshCoordsList(lv)
    lv.Modify(row - 1, "Select Focus")
}

OnMoveDown(*)
{
    global editingCoords, editorGui
    lv := editorGui["CoordsList"]
    
    row := lv.GetNext()
    if (row = 0 || row >= editingCoords.Length)
        return
    
    temp := editingCoords[row]
    editingCoords[row] := editingCoords[row + 1]
    editingCoords[row + 1] := temp
    
    RefreshCoordsList(lv)
    lv.Modify(row + 1, "Select Focus")
}

OnSaveCycler(*)
{
    global editorGui, editingHotkey, editingCoords, cyclers, mainGui
    
    newName := editorGui["EditName"].Value
    newHotkey := editorGui["EditHotkey"].Value
    timeout := Number(editorGui["EditTimeout"].Value)
    clickType := editorGui["EditClickType"].Text
    
    if (newName = "")
    {
        editorGui["EditorStatus"].Text := "Please set a name"
        return
    }
    
    if (newHotkey = "")
    {
        editorGui["EditorStatus"].Text := "Please set a hotkey"
        return
    }
    
    if (editingCoords.Length = 0)
    {
        editorGui["EditorStatus"].Text := "Please capture at least one coord"
        return
    }
    
    if (timeout < 1)
        timeout := 5
    
    if (editingHotkey != "" && editingHotkey != newHotkey)
        DeleteCycler(editingHotkey)
    
    cyclers[newHotkey] := {
        name: newName,
        coords: editingCoords,
        timeout: timeout,
        clickType: clickType,
        currentIndex: 1,
        lastPressed: 0
    }
    
    SaveCycler(newHotkey, newName, editingCoords, timeout, clickType)
    
    try Hotkey(newHotkey, CyclerHotkeyHandler.Bind(newHotkey))
    
    if (mainGui && WinExist("ahk_id " . mainGui.Hwnd))
        RefreshCyclerList(mainGui["CyclerList"])
    
    OnEditorClose()
}