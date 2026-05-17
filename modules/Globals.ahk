; ===== GLOBAL VARIABLES =====

global configFile := A_ScriptDir . "\samsung_notes_config.ini"
global defaultHotkey := "F9"
global currentHotkey := defaultHotkey

global appPath := 'shell:AppsFolder\SAMSUNGELECTRONICSCoLtd.SamsungNotes_wyx1vj98g3asy!App'
global windowTitle := 'Samsung Notes'

global mainGui := ""

; Click Cycler globals
global cyclers := Map()
global lastClickedCoord := ""
global editorGui := ""
global editingHotkey := ""
global editingCoords := []