/************************************************************************
 * @description Settings GUI
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/08/01
 * @version 1.0.0
 ***********************************************************************/

#Requires AutoHotkey v2.0

ShowSettingsGUI() {
    static MyGui := ""
 
	if MyGui
		return WinActivate(MyGui)

    MyGuiTitle := "Settings"
    MyGuiOptions := "-Caption -SysMenu"
    MyGui := Gui(MyGuiOptions, MyGuiTitle)
    MyGui.SetFont("Norm s" Settings.GuiFontSizeMedium, Settings.GuiFontName)
	DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", MyGui.Hwnd, "UInt", 33, "Int*", 2, "UInt", 4)
    offset := 10

    if IsSet(CustomTitleBar) {
        MyGui.Opt("-Caption")
        titlebar := CustomTitleBar.Attach(MyGui, {
            Title: "",
            ShowIcon: false,
            Min: false,
            Max: false,
            Close: true
        })
        offset := 60
    }

    if (UseAcrylicGUI := IsSet(FrostedTheme))
        offset := 60

    ; Color Constants
	TextNormalColor				:= Settings.Theme.%CurrentActualTheme%.TextSmooth
	TextHoverColor				:= Settings.Theme.%CurrentActualTheme%.TextDefault
	BGroundNormalColor			:= Settings.Theme.%CurrentActualTheme%.Bg
	BGroundHoverColor			:= Settings.Theme.%CurrentActualTheme%.BgHover
	GitNormalColor				:= "5865F2"
	GitHoverColor				:= "5896f2"

	if UseAcrylicGUI {
		TextNormalColor			:= "CCCCCC"
		TextHoverColor			:= "FFFFFF"
		BGroundNormalColor		:= "1b1b1b"
		BGroundHoverColor		:= "313131"
		GitNormalColor			:= "5865F2"
		GitHoverColor			:= "5896f2"
	}

    ; 1. Initialize the custom drawing class
    OD_Colors.Init()
    OD_Colors.SetFont("c" TextNormalColor " s" Settings.GuiFontSizeMedium, Settings.GuiFontName)

    GuiWidth     := 760
    GuiWidth     := 460
    MyGui.MarginX := 85
    MyGui.MarginY := 40
	BtnWidth      := 90
    ContentWidth := GuiWidth - (MyGui.MarginX * 2)


	Col1_W := 130
	Col2_W := 180
    Col1_X := MyGui.MarginX
    Col2_X := MyGui.MarginX + Col1_W
    Col3_X := GuiWidth - MyGui.MarginX - Col1_W - Col2_W
    Col4_X := Col3_X + Col1_W
	Rows_Gap := 26

	; 1. Header Section
	MyGui.Add("Picture", "w32 h-1 x" GuiWidth - MyGui.MarginX - 32 " ym+8", App.Icon)

    MyGui.SetFont("s16 w800", Settings.GuiFontName)
    MyGui.Add("Text", "xm5 y" (MyGui.MarginY + 8), "Tray Icon Actions")

    ; Divider Line
    MyGui.Add("Text", "xm y+24 w" ContentWidth " h1 Background333333")

	; Icon Actions
    MyGui.SetFont("s" Settings.GuiFontSizeMedium " w100", Settings.GuiFontName)
    ; Extract and sort action choices directly from ActionMap
    RawList := ""
    for actionName, _ in ActionMap {
        RawList .= actionName "`n"
    }
    ActionChoices := StrSplit(Sort(RTrim(RawList, "`n")), "`n")

    Global DdlControls := {}

    for propName, displayLabel in TriggerMap {
        MyGui.Add("Text", "xm y+35 +0x0200 BackgroundTrans w130", displayLabel ":")
        
        currentValue := General.%propName%
        currentIndex := 1
        for index, choice in ActionChoices {
            if (choice == currentValue) {
                currentIndex := index
                break
            }
        }

        DdlControls.%propName% := MyGui.Add("DropDownList", "x+10 yp-" DPIScale(7) " r20 +0x0210 w150 Choose" currentIndex, ActionChoices)

        DdlControls.%propName%.OwnerDraw := {
            CB: 0x1b1b1b,  ; background
            CT: 0xF3F3F3,  ; text
            SB: 0x363636,  ; background highlight on hover
            ST: 0xF3F3F3   ; text on hover
        }

		SendMessage(0x0153, -1, 24, DdlControls.%propName%)
		SendMessage(0x0153, 0, 30, DdlControls.%propName%)

    }

    ; 4. Button
;	btnX := MyGui.MarginX ; left
	btnX := (GuiWidth - BtnWidth) // 2 ; center
;	btnX := GuiWidth - MyGui.MarginX - BtnWidth ; right


    if UseAcrylicGUI {
        MyGui.SetFont("s" Settings.GuiFontSizeBig " CWhite w700", Settings.GuiFontName)
        btnSave := MyGui.Add("Text", "x" btnX " y+45 w" BtnWidth " h30 Center 0x0200 Background" BGroundNormalColor " +Border", "Save")
        btnSave.BypassTheme := true

    } else {
        MyGui.SetFont("s" Settings.GuiFontSizeMedium " w300", Settings.GuiFontName)
        btnSave := MyGui.AddButton("x" btnX " y+45 w" BtnWidth " h30 Default", "&OK")
    }

    btnSave.OnEvent("Click", (*) => SaveSettings())
    MyGui.OnEvent("Close", CleanDestroy)
    MyGui.OnEvent("Escape", CleanDestroy)

	if IsSet(GuiTracker) {
		tracker := GuiTracker()
		tracker.AddGui := MyGui

		tracker.RegisterControl(btnSave, Map(
			"OnEnter", (ctrl) => (ctrl.SetFont("c" TextHoverColor), ctrl.Opt("+Background" BGroundHoverColor)),
			"OnLeave", (ctrl) => (ctrl.SetFont("c" TextNormalColor), ctrl.Opt("+Background" BGroundNormalColor))
		))
	}

    if UseAcrylicGUI {
        IsSet(ApplyThemeToGui) ? ApplyThemeToGui(MyGui, "Dark") : 0
        IsSet(FrostedTheme) ? FrostedTheme.Apply(MyGui) : 0
        ApplyHDRFontQuality(MyGui)
    } else {
        IsSet(ApplyThemeToGui) ? ApplyThemeToGui(MyGui) : 0
        IsSet(WatchedGUIs) ? WatchedGUIs.Push(MyGui) : 0
    }


    ;MyGui.Show("w" GuiWidth)
    MyGui.Show()

    SaveSettings() {
        for propName, _ in TriggerMap {
            General.%propName% := DdlControls.%propName%.Text
        }
		SaveINI()
        CleanDestroy()
    }


    CleanDestroy(*) {
		try MyGui.Destroy()
		try MyGui := ""
    }
}
