CreateMediaGui() {
    global MyGui, PicControl, TitleText, ArtistText, StatusText, PrevBtn, PlayPauseBtn, NextBtn, SessionDDL, VolSlider, VolText
    
    ; Layout Constants (In logical pixels; AHK scales these automatically via +DPIScale)
    global MediaGUIWidth := 300
    global FullBackground := General.MediaPopupArtWorkType == "Artwork full"
    global ArtHeight := MediaGUIWidth * 0.3
    global ArtWidth := MediaGUIWidth * 1.5

    MyGuiTitle := "Now Playing"
    MyGuiOptions := "+LastFound -SysMenu +AlwaysOnTop -Caption +ToolWindow"
    MyGui := Gui(MyGuiOptions, MyGuiTitle)
    MyGui.SetFont("s" Settings.GuiFontSizeMedium, Settings.GuiFontName)
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", MyGui.Hwnd, "UInt", 33, "Int*", 2, "UInt", 4)

    UseAcrylicGUI := IsSet(FrostedTheme)

    ; Color Constants
    if UseAcrylicGUI {
        TextNormalColor    := "CCCCCC"
        TextHoverColor     := "FFFFFF"
        BGroundNormalColor := "000000"
        BGroundHoverColor  := "242424"
    } else {
        TextNormalColor    := "FFFFFF"
        TextHoverColor     := "FFFFFF"
        BGroundNormalColor := "000000"
        BGroundHoverColor  := "1A1A1A"
    }

    MyGui.MarginX := 35
    MyGui.MarginY := 10

    ; Album Art Viewport
    if FullBackground {
        ; Simplified initial creation; size and position are handled in UpdateGuiDisplay
        PicControl := MyGui.AddPicture("x0 y0 AltSubmit BackgroundTrans", "")
        WinSetTransparent(35, PicControl.Hwnd)
        PosY := MyGui.MarginY
    } else {
        PosY := MyGui.MarginY + 20
        PicControl := MyGui.AddPicture("y" PosY " Center Valign AltSubmit BackgroundTrans", "")
        PosY += ArtHeight + 10
    }

    ; Navigation buttons and active session text display
    MyGui.SetFont("s10 w100 q5", "Segoe UI")
    global SessionText := MyGui.AddText("x0 y" PosY " w" MediaGUIWidth " Center +0x200 h23 BackgroundTrans", "No Active Apps")

    MyGui.SetFont("s10 w1000 q5", "Segoe UI")
    PrevAppBtn := MyGui.AddText("xm y" PosY " w23 Center +0x200 h23 Background" BGroundNormalColor, "<")
    NextAppBtn := MyGui.AddText("x" (MediaGUIWidth - MyGui.MarginX - 23) " y" PosY " w23 Center +0x200 h23", ">")

    PosY += 30

    ; Track Title
    MyGui.SetFont("s13 w100 q5", "Calibri Light")
    TitleText := MyGui.AddText("xm y" PosY " w" (MediaGUIWidth - MyGui.MarginX * 2) " r2 BackgroundTrans", "No Track Playing")

    PosY += 50

    ; Artist
    MyGui.SetFont("s9 w500 q5", "Segoe UI")
    ArtistText := MyGui.AddText("xm y" PosY " w" (MediaGUIWidth - MyGui.MarginX * 2) " BackgroundTrans", "-")

    PosY += 20

    ; Status
    MyGui.SetFont("s9 Norm w1000 q5", "Arial")
    StatusText := MyGui.AddText("xm y" PosY " w" (MediaGUIWidth - MyGui.MarginX * 2) " BackgroundTrans", "Status: Unknown")

    PosY += 50

    ; Control Buttons Row
    MyGui.SetFont("s11 w1000 q5", "Segoe UI")
    PrevBtn := MyGui.AddText("x" (MediaGUIWidth / 2 - 15 - 50) " y" PosY " w30 h30 Center +0x200 Background" BGroundNormalColor, "❮❮")

    MyGui.SetFont("s16 w1000 q5", "Segoe UI")
    PlayPauseBtn := MyGui.AddText("x" (MediaGUIWidth / 2 - 15) " yp w30 h30 Center +0x200 Background" BGroundNormalColor, "▶︎")

    MyGui.SetFont("s11 w1000 q5", "Segoe UI")
    NextBtn := MyGui.AddText("x" (MediaGUIWidth / 2 - 15 + 50) " yp w30 h30 Center +0x200 Background" BGroundNormalColor, "❯❯")

    PosY += 40

    ; Volume Slider Row
    sliderwidth := MediaGUIWidth // 2
    MyGui.SetFont("s11 w100 q5", "Segoe UI Emoji")
    ;MyGui.SetFont("s9 w100 q5", "Segoe UI")
    MyGui.AddText("x" (MediaGUIWidth / 2 - sliderwidth / 2 - 25) " y" PosY " w20 h40 Right +0x200", "🔈")

    MyGui.SetFont("s9 Norm q5", "Segoe UI")
    lightPalette := ["9333EA", "bbadc7", "8008f0"]
    darkPalette  := ["9333EA", "5A2A85", "a341ff"]
    
    ;VolSlider := ModernSlider(MyGui, "x" ((MediaGUIWidth // 2) - (sliderwidth // 2)) " y" PosY " w" DPIScale(sliderwidth) " h40 +0x200", 100, 0, 100, OnSliderChange, "Auto", lightPalette, darkPalette)
    ;VolSlider := ModernSlider(MyGui, "x" ((MediaGUIWidth // 2) - (sliderwidth // 2)) " y" PosY + ((DPIScale(1) > 1) ? DPIScale(1) : 0) " w" sliderwidth " h40 +0x200", 100, 0, 100, OnSliderChange, "Auto", lightPalette, darkPalette)
    VolSlider := ModernSlider(MyGui, "x" ((MediaGUIWidth // 2) - (sliderwidth // 2)) " y" PosY " w" sliderwidth " h40 +0x200", 100, 0, 100, OnSliderChange, "Auto", lightPalette, darkPalette)

    MyGui.SetFont("s9 w800 q5", "Calibri")
    MyGui.SetFont("s9 w800 q5", "Segoe UI")
    ;VolText := MyGui.AddText("x" (MediaGUIWidth / 2 + sliderwidth / 2 + 15) " y" PosY " w20 h40 Left +0x200", "100")
    VolText := MyGui.AddText("x" (MediaGUIWidth / 2 + sliderwidth / 2 + 15) " y" PosY " w20 h40 Right +0x200", "100")

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

    if UseAcrylicGUI {
        IsSet(ApplyThemeToGui) ? ApplyThemeToGui(MyGui, "Dark") : 0
        IsSet(FrostedTheme) ? FrostedTheme.Apply(MyGui) : 0
        ApplyHDRFontQuality(MyGui)
    } else {
        IsSet(ApplyThemeToGui) ? ApplyThemeToGui(MyGui) : 0
        IsSet(WatchedGUIs) ? WatchedGUIs.Push(MyGui) : 0
    }
}

; --- EVENT-DRIVEN GUI UPDATER ---
UpdateGuiDisplay(mediaInfo := "") {
    global MyGui, PicControl, TitleText, ArtistText, StatusText, PlayPauseBtn, VolSlider, VolText, MediaController, FullBackground, MediaGUIWidth, ArtWidth, ArtHeight

    if (mediaInfo == "") {
        mediaInfo := MediaController.GetMediaInfo()
    }

    global CurrentStatus := mediaInfo

    TitleText.Value  := (mediaInfo.title == "-") ? "No Track Playing" : mediaInfo.title
    ArtistText.Value := (mediaInfo.artist == "-") ? "No Artist" : mediaInfo.artist
    StatusText.Value := "Status: " . mediaInfo.status

    if mediaInfo.isPlaying {
        PlayPauseBtn.Text := "❚❚"
    } else {
        PlayPauseBtn.Text := "▶︎"
    }

    scaleFactor := A_ScreenDPI / 96

    if (mediaInfo.artPath != "") {
        if FullBackground {
            ; Get dynamic GUI bounds ensuring we cover the whole window space
            MyGui.GetClientPos(,, &GuiW, &GuiH)
            
            ; Prevent UI flickering during dimension calculations
            PicControl.Opt("-Redraw")
            
            ; Peek at original dimensions safely via memory (Fast, flicker-free)
            hbm := LoadPicture(mediaInfo.artPath, "", &imgType)
            if hbm {
                ; Generate a struct mapped for 32/64 bit OS bounds to read BITMAP info
                bm := Buffer(A_PtrSize = 8 ? 32 : 24)
                DllCall("GetObject", "Ptr", hbm, "Int", bm.Size, "Ptr", bm)
                origW := NumGet(bm, 4, "Int")
                origH := NumGet(bm, 8, "Int")
                DllCall("DeleteObject", "Ptr", hbm)
                
                if (origW > 0 && origH > 0 && GuiW > 0 && GuiH > 0) {
                    ; Convert Target bounds to physical pixels
                    TargetPhysW := GuiW * scaleFactor
                    TargetPhysH := GuiH * scaleFactor
                    
                    ; 1. Calculate zoom required to cover ALL of the Gui (X and Y)
                    ScaleX := TargetPhysW / origW
                    ScaleY := TargetPhysH / origH
                    Scale := Max(ScaleX, ScaleY) ; Using Max() forces "Cover/Zoom-to-fill" layout
                    
                    ; 2. New Physical bounds to dictate high-quality render
                    PhysW := Round(origW * Scale)
                    PhysH := Round(origH * Scale)
                    
                    ; 3. Logical bounds to offset/crop center with Move()
                    LogiW := PhysW / scaleFactor
                    LogiH := PhysH / scaleFactor
                    
                    OffX := (GuiW - LogiW) / 2
                    OffY := (GuiH - LogiH) / 2
                    
                    ; Load directly scaling physically (Keeps high quality pixel rendering)
                    PicControl.Value := "*w" PhysW " *h" PhysH " " mediaInfo.artPath
                    
                    ; Move cuts off the overflowing edges outside the GUI bound keeping the center anchored
                    PicControl.Move(Round(OffX), Round(OffY), Round(LogiW), Round(LogiH))
                }
            } else {
                PicControl.Value := ""
            }
            PicControl.Opt("+Redraw")
            
        } else {
            ; Normal mode untouched
            physArtHeight := Round(ArtHeight * scaleFactor)
            PicControl.Value := "*w-1 *h" physArtHeight " " . mediaInfo.artPath
            PicControl.GetPos(, , &actualW)
            centerX := (MediaGUIWidth - actualW) / 2
            PicControl.Move(centerX, MyGui.MarginY + 20, actualW, Round(ArtHeight))
        }
    } else {
        PicControl.Value := ""
    }

    if (mediaInfo.currentApp != "") {
        currentVol := GetCachedAppVolume(mediaInfo.currentApp)
        if (currentVol != -1) {
            VolSlider.Value := currentVol
            VolText.Value := currentVol
        }
    }

    RefreshSessionDropdown()
}