/************************************************************************
 * @description Robust, Modular Menu (No-Crash Dependency Checking)
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/08/12
 * @version 1.3.2
 ***********************************************************************/

#Requires AutoHotkey v2.0

Menu_Custom() {

    TrayMenu := A_TrayMenu
    MoreMenu := TrayMenu.HasProp("MoreMenu") ? TrayMenu.MoreMenu : ""

    TrayMenu.Insert("More", "Show OSD", OSDHandler)

	OSDHandler(ItemName, ItemPos, MyMenu) {
		Global General

		General.UseOSD := !General.UseOSD
		(General.UseOSD = true) ? MyMenu.Check(ItemName) : MyMenu.Uncheck(ItemName)
	}

	(General.UseOSD = true) ? TrayMenu.Check("Show OSD") : TrayMenu.Uncheck("Show OSD")


	PopupMenu := Menu()
	A_TrayMenu.PopupMenu := PopupMenu

	for popupmode in General.MediaPopupArtWorkTypeList {
		PopupMenu.Add(popupmode, PopupHandler)
	}

	PopupHandler(ItemName, ItemPos, MyMenu) {
        Global General, MyGui

        General.MediaPopupArtWorkType := ItemName
        
        ; Uncheck all items using the source array
        for popupmode in General.MediaPopupArtWorkTypeList {
            MyMenu.Uncheck(popupmode)
        }
        
        ; Check the selected item
        MyMenu.Check(ItemName)
		SaveINI()
		MyGui.Destroy()
		MyGui := ""
		CreateMediaGui()

		if General.MediaPopupArtWorkType != "none" {
			Sleep(500)
			ShowMediaGUI()
		}
    }

	PopupMenu.Check(General.MediaPopupArtWorkType)

    TrayMenu.Insert("More", "Media Popup", PopupMenu)







    ; Custom items
/*
    ; INSERT AT POSITION
    TrayMenu.Insert("3&", "Sound Control Panel", (*) => Run("control mmsys.cpl sounds"))
    TrayMenu.Insert("4&", "Volume Mixer", (*) => Run("sndvol.exe"))
    TrayMenu.Insert("5&")
 */

    ; INSERT OVER 'More'
;    TrayMenu.Insert("More", "Sound Control Panel", (*) => Run("control mmsys.cpl sounds"))
;    TrayMenu.Insert("More", "Volume Mixer", (*) => Run("sndvol.exe"))
;    TrayMenu.Insert("More")

    ; Clean up Suspend and Pause
;    if (MoreMenu != "") {
;    try MoreMenu.Delete("4&")
;    try MoreMenu.Delete("Suspend")
;    try MoreMenu.Delete("Pause")
;    }
}

;A_TrayMenu.Delete()

