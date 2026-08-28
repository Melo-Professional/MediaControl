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
;Debug					:= true
;@endregion

Global General := {
    UseOSD:							true,
    MediaPopupArtWorkTypeList:		["Artwork framed", "Artwork full", "None"],
	MediaPopupArtWorkType:			"Artwork full"
}

;@region INI
SaveToINI := []
SaveToINI.Push("General.UseOSD", "General.MediaPopUpArtWorkType" )

if App.HasOwnProp("GitHubRepo")
	SaveToINI.Push("App.UpdateAuto", "App.UpdateFrequencyDays", "App.UpdateLastCheck")
if (IsSet(INIManager) && (SaveToINI != [])) {
	IsSet(RegisterArrayItems) ? RegisterArrayItems(SaveToINI) : 0
	IsSet(LoadINI) ? LoadINI() : 0
}
;@endregion
