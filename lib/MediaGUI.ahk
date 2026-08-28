CreateMediaGui() {
    global MyGui, PicControl, TitleText, ArtistText, StatusText, PrevBtn, PlayPauseBtn, NextBtn, SessionDDL, VolSlider, VolText

    MyGui := Gui("+AlwaysOnTop +ToolWindow", "Now Playing")

    MyGuiTitle := "Now Playing"
    MyGuiOptions := "+LastFound -SysMenu +AlwaysOnTop -Caption +ToolWindow"
    ;MyGuiOptions := "+LastFound -SysMenu +AlwaysOnTop -Caption +Owner"
    MyGui := Gui(MyGuiOptions, MyGuiTitle)
    MyGui.SetFont("s" Settings.GuiFontSizeMedium, Settings.GuiFontName)
	DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", MyGui.Hwnd, "UInt", 33, "Int*", 2, "UInt", 4)
    offset := 10

    if (UseAcrylicGUI := IsSet(FrostedTheme))
        offset := 10


    ; Color Constants

	if UseAcrylicGUI {
		TextNormalColor			:= "CCCCCC"
		TextHoverColor			:= "FFFFFF"
		BGroundNormalColor		:= "000000"
		BGroundHoverColor		:= "0c0c0c"
		BGroundHoverColor		:= "242424"
		GitNormalColor			:= "5865F2"
		GitHoverColor			:= "5896f2"
	}

    ; Layout
    global MediaGUIWidth      := 460
    global MediaGUIWidth      := 600
    global MediaGUIWidth      := 280
    global MediaGUIWidth      := 300
    MyGui.MarginX := 35
    MyGui.MarginY := 10


    ; Album Art Viewport
	;global FullBackground := true
	global FullBackground := General.MediaPopupArtWorkType == "Artwork full"
	if FullBackground {

		PicControl := MyGui.AddPicture("x-" MediaGUIWidth * 0.25 " y0 Center Valign AltSubmit BackgroundTrans w" MediaGUIWidth * 1.5 " h-1 ", "")
		WinSetTransparent(35,PicControl.Hwnd)
		PosY := MyGui.MarginY

	} else {
		PosY := MyGui.MarginY + 20 
		;ArtWidtht := MediaGUIWidth * 0.8
		global ArtHeight := MediaGUIWidth * 0.3
		;PicControl := MyGui.AddPicture("x" (MediaGUIWidth - ArtWidtht) / 2 " y" PosY " Center Valign AltSubmit BackgroundTrans w-1 h" (MediaGUIWidth * 0.3), "")
		;PicControl := MyGui.AddPicture("x" (MediaGUIWidth - ArtWidtht) / 2 " y" PosY " Center Valign AltSubmit BackgroundTrans w-1 h120", "")
		PicControl := MyGui.AddPicture("y" PosY " Center Valign AltSubmit BackgroundTrans", "")
    	PosY += (MediaGUIWidth * 0.3) + 20
		;PicControl.GetPos(, , , &PicHeight)
		;PosY += PicHeight
	}

;	PicControl.Redraw()

	; Navigation buttons and active session text display

	MyGui.SetFont("s8 w100 q5", "Segoe UI")
;	global SessionText := MyGui.AddText("xm y" PosY " w" MediaGUIWidth - (MyGui.MarginX * 2) " Center +0x200 h23 Background" BGroundNormalColor, "No Active Apps")
	;global SessionText := MyGui.AddText("xm y" PosY " w" MediaGUIWidth - (MyGui.MarginX) " Center +0x200 h23 Background" BGroundNormalColor, "No Active Apps")
;	global SessionText := MyGui.AddText("x" (MediaGUIWidth / 2 ) - 50 " y" PosY " w100 Center +0x200 h23 Background" BGroundNormalColor, "No Active Apps")
	global SessionText := MyGui.AddText("x0 y" PosY " w" MediaGUIWidth " Center +0x200 h23 BackgroundTrans" , "No Active Apps")


	MyGui.SetFont("s8 w1000 q5", "Segoe UI")
	PrevAppBtn := MyGui.AddText("xm y" PosY " w23 Center +0x200 h23 Background" BGroundNormalColor, "<")

	MyGui.SetFont("s8 w1000 q5", "Segoe UI")
	NextAppBtn := MyGui.AddText("x" (MediaGUIWidth - MyGui.MarginX - 23) " y" PosY " w23 Center +0x200 h23", ">")

	PosY += 30
    ; Track Title
    ;MyGui.AddText("xm ym+150 w" GuiWidth - (MyGui.MarginX * 2) " h200 Background000000", " ")
    MyGui.SetFont("s13 w100 q5", "Calibri Light")
    TitleText := MyGui.AddText("xm y" PosY " w" MediaGUIWidth - (MyGui.MarginX * 2) " r2 BackgroundTrans", "No Track Playing")

	PosY += 50
    ; Artist
    MyGui.SetFont("s8 w500 q5", "Segoe UI")
    ArtistText := MyGui.AddText("xm y" PosY " w" MediaGUIWidth - (MyGui.MarginX * 2) " BackgroundTrans", "-")

	PosY += 20
    ; Status
	MyGui.SetFont("s7 Norm w1000 q5", "Arial")
    ;StatusText := MyGui.AddText("xm y+8 w" GuiWidth - (MyGui.MarginX * 2) " BackgroundTrans", "Status: Unknown")
    ;StatusText := MyGui.AddText("xm y+16 w" GuiWidth - (MyGui.MarginX * 2) " BackgroundTrans", "Status: Unknown")
    StatusText := MyGui.AddText("xm y" PosY " w" MediaGUIWidth - (MyGui.MarginX * 2) " BackgroundTrans", "Status: Unknown")


;	MyGui.AddText("x-60 y-60 w" GuiWidth - (MyGui.MarginX * 2) "0 h2000 Background2b2b2b", " ")


	PosY += 50
    ; --- CONTROL BUTTONS ROW ---
    MyGui.SetFont("s11 w1000 q5", "Segoe UI")
    PrevBtn := MyGui.AddText("x" (MediaGUIWidth /2) - 15 - 50 " y" PosY " w30 h30 Center +0x200 Background" BGroundNormalColor, "❮❮")

    MyGui.SetFont("s16 w1000 q5", "Segoe UI")
    PlayPauseBtn := MyGui.AddText("x" (MediaGUIWidth /2) - 15 " yp w30 h30 Center +0x200 Background" BGroundNormalColor, "▶︎")

    MyGui.SetFont("s11 w1000 q5", "Segoe UI")
    NextBtn := MyGui.AddText("x" (MediaGUIWidth /2) - 15 + 50 " yp w30 h30 Center +0x200 Background" BGroundNormalColor, "❯❯")

;	PosY := 187
	PosY += 40

	sliderwidth := (MediaGUIWidth // 2)
    MyGui.SetFont("s11 w100 q5", "Segoe UI Emoji") ; 🎛️🎚️🎚️🎛️
    MyGui.AddText("x" (MediaGUIWidth /2) - (sliderwidth /2) - 5 - 20 " y" PosY " w20 h30 Right +0x200", "🔈")

    ; --- VOLUME SLIDER CONTROL ---
    MyGui.SetFont("s8 Norm q5", "Segoe UI")
;	lightPalette := ["9333EA", "959596", "8008f0"]
	;lightPalette := ["9333EA", "a77fcc", "8008f0"]
	lightPalette := ["9333EA", "bbadc7", "8008f0"]
	darkPalette  := ["9333EA", "5A2A85", "a341ff"]
	;VolSlider := ModernSlider(MyGui, "x52 y130 w190 h24", 100, 0, 100, OnSliderChange, "Auto", lightPalette, darkPalette)
	;VolSlider := ModernSlider(MyGui, "x52 y" PosY +3 " w190 h24", 100, 0, 100, OnSliderChange, "Auto", lightPalette, darkPalette)
	;VolSlider := ModernSlider(MyGui, "x" ((GuiWidth // 2) - 95) " y" PosY +3 " w190 h24", 100, 0, 100, OnSliderChange, "Auto", lightPalette, darkPalette)
	VolSlider := ModernSlider(MyGui, "x" ((MediaGUIWidth // 2) - (sliderwidth//2)) " y" PosY +3 " w" sliderwidth " h24", 100, 0, 100, OnSliderChange, "Auto", lightPalette, darkPalette)

    MyGui.SetFont("s8 w800 q5", "Calibri")
    VolText := MyGui.AddText("x" (MediaGUIWidth /2) + (sliderwidth /2) + 15 " y" PosY " w20 h30 Left +0x200", "100")
	;VolText.Visible := false

/* 
    ; App Session Dropdown
    MyGui.SetFont("s8 Norm q5", "Segoe UI")
    SessionDDL := MyGui.AddDropDownList("xm y+8 w" GuiWidth - (MyGui.MarginX * 2) " Choose1", ["No Active Apps"])
    SessionDDL.OnEvent("Change", OnSessionSelected)
	SessionDDL.Visible := false
 */



	OnSliderChange(newVal, sliderObj := "") {
		global VolText, MediaController
		VolText.Value := newVal

		sess := MediaController.GetSession()
		if sess {
			appName := MediaController.CleanAppName(sess.SourceAppUserModelId)
			SetCachedAppVolume(appName, newVal)
		}
	}

	global tracker := GuiTracker()
	tracker.AddGui := MyGui
	tracker.RegisterGui(Map(
		"OnLeave", (*) => SetTimer(HideMediaGUI, -1000),
		"OnEnter", (*) => SetTimer(HideMediaGUI, 0)
	))

	hoverEvents := Map(
		"OnEnter", (ctrl) => (
			ctrl.SetFont("c" TextHoverColor),
			ctrl.Opt("+Background" BGroundHoverColor)
		),
		"OnLeave", (ctrl) => (
			ctrl.SetFont("c" TextNormalColor),
			ctrl.Opt("+Background" BGroundNormalColor)
		)
	)


	PrevAppBtn.OnEvent("Click", (*) => NavigateSession(-1))
	NextAppBtn.OnEvent("Click", (*) => NavigateSession(1))
    PrevBtn.OnEvent("Click", (*) => MediaController.Previous())
    PlayPauseBtn.OnEvent("Click", (*) => MediaController.TogglePlayPause())
    NextBtn.OnEvent("Click", (*) => MediaController.Next())

	tracker.RegisterControl(PrevBtn, hoverEvents)
	tracker.RegisterControl(PlayPauseBtn, hoverEvents)
	tracker.RegisterControl(NextBtn, hoverEvents)
	tracker.RegisterControl(PrevAppBtn, hoverEvents)
	tracker.RegisterControl(NextAppBtn, hoverEvents)

    ; Apply Themes
    if UseAcrylicGUI {
        IsSet(ApplyThemeToGui) ? ApplyThemeToGui(MyGui, "Dark") : 0
        IsSet(FrostedTheme) ? FrostedTheme.Apply(MyGui) : 0
    } else {
        IsSet(ApplyThemeToGui) ? ApplyThemeToGui(MyGui) : 0
        IsSet(WatchedGUIs) ? WatchedGUIs.Push(MyGui) : 0
    }
}

; --- EVENT-DRIVEN GUI UPDATER ---
UpdateGuiDisplay(mediaInfo := "") {
    global PicControl, TitleText, ArtistText, StatusText, PlayPauseBtn, VolSlider, VolText, MediaController

    if (mediaInfo == "") {
        mediaInfo := MediaController.GetMediaInfo()
	}

	global CurrentStatus := mediaInfo

    TitleText.Value := (mediaInfo.title == "-") ? "No Track Playing" : mediaInfo.title
    ArtistText.Value := (mediaInfo.artist == "-") ? "No Artist" : mediaInfo.artist
    StatusText.Value := "Status: " . mediaInfo.status

    ; Toggle Play/Pause button text state
    if mediaInfo.isPlaying {
        ;PlayPauseBtn.Text := "⏸"
        PlayPauseBtn.Text := "❚❚"
    } else {
        PlayPauseBtn.Text := "▶︎"
    }

    ; Update Album Art
    if (mediaInfo.artPath != "") {

		if FullBackground {
        PicControl.Value := " *h-1 " . mediaInfo.artPath
		} else {
		; 1. Load the image with fixed height and proportional width (w-1)
        PicControl.Value := " *w-1 *h" ArtHeight " " . mediaInfo.artPath
        
        ; 2. Query the actual rendered width of the control
        PicControl.GetPos(, , &actualW)
        
        ; 3. Calculate centered X coordinate and reposition the control
        centerX := (MediaGUIWidth - actualW) / 2
        PicControl.Move(centerX, MyGui.MarginY + 20 , actualW, ArtHeight)
    }
    } else {
        PicControl.Value := ""
    }

    ; Sync active app's volume level to slider
    if (mediaInfo.currentApp != "") {
        currentVol := GetCachedAppVolume(mediaInfo.currentApp)
        if (currentVol != -1) {
            VolSlider.Value := currentVol
            VolText.Value := currentVol
        }
    }

    ; Refresh Session Dropdown
    RefreshSessionDropdown()
}