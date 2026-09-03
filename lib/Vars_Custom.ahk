/************************************************************************
 * @description Vars_Custom
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/08/16
 * @version 1.4.0
 ***********************************************************************/

;@region VARS
; CUSTOM VARIABLES
App.GitHubRepo			:= "https://github.com/Melo-Professional/MediaControl"
;App.NameCutted			:= "Template`nBigName"

/*
*/
;ResetSettings			:= Settings.Clone()
;ResetGeneral			:= General.Clone()
;ResetOSDSettings		:= OSDSettings.Clone()
;Settings.DesiredTheme	:= "Light"
;Settings.SplashScreen	:= "Icon"
Debug					:= false
;@endregion

Global TriggerMap := Map(
    "OnLeftClick",         "Left Click",
    "OnRightClick",        "Right Click",
    "OnLeftDoubleClick",   "Left Double Click",
    "OnRightDoubleClick",  "Right Double Click",
    "OnMiddleClick",       "Middle Click",
    "OnMiddleDoubleClick", "Middle Double Click",
    "OnWheelUp",           "Wheel Up",
    "OnWheelDown",         "Wheel Down"
)

Global ActionMap := Map(
    "None",           (*) => false, ; Do nothing
    "Play Pause",     PlayPause,
    "App Menu",       (*) => A_TrayMenu.Show(), ; Fat arrow used for built-in methods
    "Previous Track", PreviousTrack,
    "Next Track",     NextTrack,
    "Open Player",    OpenCurrentPlayer,
    "Mute Unmute",    MuteUnmute,
    "Volume Up",      Volume_Up,
    "Volume Down",    Volume_Down
)

Global General := {
    UseOSD:							true,
    MediaPopupArtWorkTypeList:		["Artwork framed", "Artwork full", "None"],
	MediaPopupArtWorkType:			"Artwork full",
;	TrayActionsList:				["None", 0, "Play Pause", PlayPause(), "App Menu", A_TrayMenu.Show(), "Previous Track", PreviousTrack(), "Next Track", NextTrack(), "Open Player", OpenCurrentPlayer(), "Mute Unmute", MuteUnmute(), "Volume Up", Volume_Up(), "Volume Down", Volume_Down()],
	OnLeftClick: "Play Pause",
    OnRightClick: "App Menu",
    OnLeftDoubleClick: "Previous Track",
    OnRightDoubleClick: "Next Track",
    OnMiddleClick: "Open Player",
    OnMiddleDoubleClick: "Mute Unmute",
    OnWheelUp: "Volume Up",
    OnWheelDown: "Volume Down"
}


;"General.OnLeftClick", "General.OnRightClick", "General.OnLeftDoubleClick", "General.OnRightDoubleClick", "General.OnMiddleClick", "General.OnMiddleDoubleClick", "General.OnWheelUp", "General.OnWheelDown" 


;@region INI
SaveToINI := []
SaveToINI.Push(
				"General.UseOSD", "General.MediaPopUpArtWorkType", "General.OnLeftClick",
				"General.OnRightClick", "General.OnLeftDoubleClick", "General.OnRightDoubleClick",
				"General.OnMiddleClick", "General.OnMiddleDoubleClick", "General.OnWheelUp",
				"General.OnWheelDown", "General.HDR"
				)

if App.HasOwnProp("GitHubRepo")
	SaveToINI.Push("App.UpdateAuto", "App.UpdateFrequencyDays", "App.UpdateLastCheck")
if (IsSet(INIManager) && (SaveToINI != [])) {
	IsSet(RegisterArrayItems) ? RegisterArrayItems(SaveToINI) : 0
	IsSet(LoadINI) ? LoadINI() : 0
}
;@endregion
