; ===== TRAY MENU =====

SetupTray()
{
    A_TrayMenu.Delete()
    A_TrayMenu.Add("Open Menu", ShowGui)
    A_TrayMenu.Add()
    A_TrayMenu.Add("Exit", (*) => ExitApp())
    A_TrayMenu.Default := "Open Menu"
    A_TrayMenu.ClickCount := 1
    A_IconTip := "Samsung Notes Helper"
}