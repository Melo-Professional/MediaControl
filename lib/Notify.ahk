
imagePlay :=				A_IsCompiled ? A_ScriptFullPath ", 209" : A_ScriptDir ".\resources\play.png"
imagePause :=				A_IsCompiled ? A_ScriptFullPath ", 210" : A_ScriptDir ".\resources\pause.png"
imageNext :=				A_IsCompiled ? A_ScriptFullPath ", 211" : A_ScriptDir ".\resources\next.png"
imagePrevious :=			A_IsCompiled ? A_ScriptFullPath ", 212" : A_ScriptDir ".\resources\previous.png"
imageMute :=				A_IsCompiled ? A_ScriptFullPath ", 213" : A_ScriptDir ".\resources\mute.png"
imageUnmute :=				A_IsCompiled ? A_ScriptFullPath ", 214" : A_ScriptDir ".\resources\unmute.png"
IconStop :=					A_IsCompiled ? A_ScriptFullPath ", 215" : A_ScriptDir ".\resources\stop.png"
IconMinus :=				A_IsCompiled ? A_ScriptFullPath ", 216" : A_ScriptDir ".\resources\minus.png"
IconPlus :=					A_IsCompiled ? A_ScriptFullPath ", 217" : A_ScriptDir ".\resources\plus.png"

Global OSDGeneral           := OSDCustom()
OSDGeneral.Monitor 	        := 1
OSDGeneral.RowGap			:= 5
OSDGeneral.MinWidth         := 160
OSDGeneral.MarginX          := 8
OSDGeneral.MarginY          := 5
OSDGeneral.Position         := "x0.95 y0.90"
OSDGeneral.TimeOut          := 1800
OSDGeneral.Opacity          := 255
OSDGeneral.FontSize         := 9
OSDGeneral.FontName         := "Segoe UI"

Global OSDVolume			:= OSDCustom()
OSDVolume.Monitor			:= 1
OSDVolume.RowGap			:= 5
OSDVolume.MinWidth			:= 160
OSDVolume.MarginX			:= 8
OSDVolume.MarginY			:= 5
OSDVolume.Position			:= "x0.95 y0.90"
OSDVolume.TimeOut			:= 1800
OSDVolume.Opacity			:= 255
OSDVolume.FontSize			:= 9
OSDVolume.FontName			:= "Segoe UI"
OSDVolume.ProgressFgLight	:= "9333EA"
;OSDVolume.ProgressBgLight	:= "959596"
OSDVolume.ProgressBgLight	:= "bbadc7"
OSDVolume.ProgressFgDark	:= "9333EA"
OSDVolume.ProgressBgDark	:= "5A2A85"


Global OSDCP				:= OSDCustom()
OSDCP.Monitor				:= 1
OSDCP.MinWidth				:= 360
OSDCP.MaxWidth				:= 360
OSDCP.MarginX				:= 20
OSDCP.MarginY				:= 10
OSDCP.Position				:= "x0.87 y0.90"
OSDCP.TimeOut				:= 7000
OSDCP.Opacity				:= 255
OSDCP.FontSize				:= 9
OSDCP.FontName				:= "Segoe UI"
OSDCP.ProgressBarHeight		:= 9
OSDCP.ProgressFgLight		:= "9333EA"
OSDCP.ProgressBgLight		:= "959596"
OSDCP.ProgressFgDark		:= "9333EA"
OSDCP.ProgressBgDark		:= "5A2A85"



;@region OSD
OSD_General(image, label){
    if !(General.UseOSD)
        return

    Global OSD_General
    if OSDGeneral.IsVisible{
        try OSDGeneral.UpdateImageObject( generalimage, image)
        OSDGeneral.UpdateTextObject( generallabel, label, 2000)
        return
    }

    try OSDVolume.Destroy()
    try OSD_CP.Destroy()

    OSDGeneral.ClearCells()
    OSDGeneral.SetCellImage( 1, 1, App.Icon, "Left", 12)
    OSDGeneral.SetCellText( 1, 1, App.Name, "Center", {FontSize: 7, FontWeight: 300},2)
    try Global generalimage := OSDGeneral.SetCellImage( 1, 2, image, "Center", 60, 2, 1)
    Global generallabel := OSDGeneral.SetCellText( 1, 3, label, "Center", {FontSize: 8, FontWeight: 800}, 2, 2)
    OSDGeneral.SetCellText( 2, 4, " ", "Center", {FontSize: 1})

    OSDGeneral.Show()
}

OSD_Volume(value, label){
    if !(General.UseOSD)
        return

    Global OSDVolume
    if OSDVolume.IsVisible{
        OSDVolume.UpdateTextObject(volumelabel, label)
        OSDVolume.UpdateProgressObject(volumeprogress,value)
        OSDVolume.UpdateTextObject(volumevalue, value, 2000)
        return
    }

    try OSDGeneral.Destroy()
    try OSD_CP.Destroy()


;    OSDVolume.ClearCells()
;    OSDVolume.SetCellImage( 1, 1, App.Icon, "Left", 12)
;    OSDVolume.SetCellText( 1, 1, App.Name, "Center", {FontSize: 7, FontWeight: 300},2)
;    Global volumevalue := OSDVolume.SetCellText( 1, 2, value, "Center", {FontName: "Calibri", FontSize: 24, FontWeight: 700}, 2, 1)
;    Global volumeprogress := OSDVolume.SetCellProgress( 1, 3, value, "Center",, 2, 1)
;    Global volumelabel := OSDVolume.SetCellText( 1, 4, label, "Center", {FontWeight: 800}, 2, 2)
;    OSDVolume.SetCellText( 1, 5, " ", "Center", {FontSize: 1, FontWeight: 300})

    OSDVolume.ClearCells()
    OSDVolume.SetCellImage( 1, 1, App.Icon, "Left", 12)
    OSDVolume.SetCellText( 1, 1, App.Name, "Center", {FontSize: 7, FontWeight: 300},2)
    Global volumevalue := OSDVolume.SetCellText( 1, 2, value, "Center", {FontName: "Calibri", FontSize: 24, FontWeight: 700}, 1, 2)
    Global volumeprogress := OSDVolume.SetCellProgress( 1, 3, value, "Center",, 2, 1)
    Global volumelabel := OSDVolume.SetCellText( 1, 4, label, "Center", {FontSize: 8, FontWeight: 800}, 2, 2)
    OSDVolume.SetCellText( 1, 5, " ", "Center", {FontSize: 1, FontWeight: 300})

    OSDVolume.Show()
}


OSD_CP(track, artist, time, percent){
    if !(General.UseOSD)
        return

    Global OSDVolume
    if OSDCP.IsVisible{
        OSDCP.UpdateTextObject(cpplaying, track)
        OSDCP.UpdateTextObject(cpartist, artist)
        OSDVolume.UpdateProgressObject(cpprogress,percent)
        OSDCP.UpdateTextObject(cpplaytime, time, 10000)
        return
    }

    try OSDGeneral.Destroy()
    try OSD_Volume.Destroy()

    OSDCP.ClearCells()
    displayTrack := (StrLen(track) > 27) ? SubStr(track, 1, 30) "..." : track

    OSDCP.SetCellImage( 1, 1, App.Icon, "Left", 20, 1, 1)
    OSDCP.SetCellText( 2, 1, App.Name, "Center",, 99, 1)
    OSDCP.SetCellText( 1, 2, "Playing: ", "Left", {FontSize: 8, FontWeight: 300}, 1, 2)
    Global cpplaying := OSDCP.SetCellText(2, 2, displayTrack, "Right", {FontSize: 11, FontWeight: 700}, 1, 2)
    OSDCP.SetCellText( 2, 3, " ", "Center", {FontSize: 1})
    OSDCP.SetCellText( 1, 4, "Artist: ", "Left", {FontSize: 8, FontWeight: 300})
    Global cpartist := OSDCP.SetCellText( 2, 4, artist, "Right", {FontSize: 10, FontWeight: 300}, 1)
    OSDCP.SetCellText( 1, 5, "Time: ", "Left", {FontSize: 8, FontWeight: 300})
    Global cpplaytime := OSDCP.SetCellText( 2, 5, time, "Right", {FontSize: 10, FontWeight: 300})
    Global cpprogress := OSDCP.SetCellProgress( 1, 6, percent, "Center",,,)
    OSDCP.SetCellText( 2, 7, " ", "Center", {FontSize: 1})

    OSDCP.Show()
}



;@endregion