; ===== SETTINGS =====

LoadSettings()
{
    global currentHotkey, configFile, defaultHotkey
    currentHotkey := IniRead(configFile, "Settings", "Hotkey", defaultHotkey)
}

SaveSetting(section, key, value)
{
    global configFile
    IniWrite(value, configFile, section, key)
}

GetSetting(section, key, defaultValue := "")
{
    global configFile
    return IniRead(configFile, section, key, defaultValue)
}

DeleteSetting(section, key := "")
{
    global configFile
    try {
        if (key = "")
            IniDelete(configFile, section)
        else
            IniDelete(configFile, section, key)
        return true
    } catch {
        return false
    }
}