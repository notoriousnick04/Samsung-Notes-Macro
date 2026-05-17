; ===== HOTKEY MANAGEMENT =====

RegisterHotkeys()
{
    global currentHotkey
    try Hotkey(currentHotkey, ShowGui)
}

UpdateHotkey(newHotkey)
{
    global currentHotkey
    
    if (newHotkey = "")
        return { success: false, message: "Invalid hotkey" }
    
    try Hotkey(currentHotkey, "Off")
    
    try {
        Hotkey(newHotkey, ShowGui)
        currentHotkey := newHotkey
        SaveSetting("Settings", "Hotkey", newHotkey)
        return { success: true, message: "Hotkey saved as " . newHotkey }
    } catch as e {
        try Hotkey(currentHotkey, "On")
        return { success: false, message: "Failed - " . e.Message }
    }
}