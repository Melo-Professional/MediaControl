;@region Setup
;@region Description
/************************************************************************
 * @description This is a template as a starting point for your AutoHotKey projects.
 * @author Melo (melo@meloprofessional.com)
 * @date 2026/08/27
 * @releasedate 2026/08/24
 * @version 1.0.0.115
 ***********************************************************************/

AppName := "Media Control"
;@Ahk2Exe-Let U_AppName = %A_PriorLine%
AppVersion := "1.0.0.115"
;@Ahk2Exe-Let U_Version = %A_PriorLine%
AppDescription := "This is a template as a starting point for your AutoHotKey projects. This is a template as a starting point for your AutoHotKey projects."
;@endregion

_bkpMode := "AppVersionAndMinutes"
_bkpMinutesThreshold := 5

;@region Directives
#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent()
SetWorkingDir(A_ScriptDir)
A_AllowMainWindow := 0
A_IconHidden := true
A_MenuMaskKey := "vkFF"
; --- Optimization Settings ---
;ProcessSetPriority("High")
ListLines(False)
KeyHistory(0)
;A_MaxHotkeysPerInterval := 5000
;A_HotkeyInterval := 1000
;@endregion

;@region Includes
#Include *i <_CompilerDirectives>
#Include *i <_Backup>
#Include *i <_SaveSettings>
#Include *i <_Config&Vars>
#Include *i <_HelperFuncs>
#Include *i <_MessageManager>
#Include *i <_TrayIconHandler>
#Include *i <_Theme>
#Include *i <_FrostedTheme>
#Include *i <_TitleBar>
#Include *i <_GuiTracker>
#Include *i <_ModernSlider>
;#Include *i <_Color_Picker_Dialog>
#Include *i <_HotkeysRecorder>
#Include *i <_ODColors>
#Include *i <_OSDCustom>
#Include *i <_AutoUpdater>
#Include *i <_SplashScreen>
;#Include *i <_SplashOSD>
#Include *i <_About>
#Include *i <_Help>
#Include *i <_Menu>

#Include *i <Vars_Custom>
#Include *i <Menu_Custom>
#Include <Notify>
#Include <WinRT\winrt>
#Include <WinRTMediaManager>
#Include <AudioSessions>
#Include <MediaGUI>

;@endregion


;@region Startup
if !A_Args.Length {
	if IsSet(SplashScreen) {
	    SplashScreen()
	} else if isSet(SplashScreenOSD) {
		SplashScreenOSD()
	}
}

IsSet(StartMenu) ? StartMenu() : 0
IsSet(Menu_Custom) ? Menu_Custom() : 0
IsSet(StartAutoUpdater) ? StartAutoUpdater() : 0
;@endregion
;@endregion

;@region Main
A_IconTip := ""

;@region Hotkeys
#HotIf !A_IsCompiled
^p::IsSet(ReloadClean) ? ReloadClean() : Reload()
#HotIf
;@endregion


#HotIf !A_IsCompiled
; --- HOTKEYS ---
;F1:: PlayPause()
;F2:: PreviousTrack()
;F3:: NextTrack()
F4:: ToggleMediaGUI()
;F6:: {
;    global MediaController
;    sessions := MediaController.GetAvailableSessions()
;
;    if (sessions.Length = 0) {
;        MsgBox("No active media sessions found.")
;        return
;    }
;
;    sessionMenu := Menu()
;    for index, item in sessions {
;        sessionMenu.Add(index . ". " . item.name, SelectAppMenu.Bind(item.appId))
;    }
;    sessionMenu.Show()
;}
#HotIf 



global MyGui := ""
global ShowingGui := false
global PicControl := ""
global TitleText := ""
global ArtistText := ""
global StatusText := ""
global PrevBtn := ""
global PlayPauseBtn := ""
global NextBtn := ""
global SessionDDL := ""
global VolSlider := ""
global VolText := ""
global AppMap := Map()
global CachedAudioSessions := Map()
global CurrentSessionList := ["No Active Apps"]
global CurrentSessionIndex := 1

; 1. Build GUI first
CreateMediaGui()

; 2. Instantiate Manager with event listener callback
global MediaController := WinRTMediaManager(UpdateGuiDisplay)

; 3. Initial display refresh and audio cache population
RefreshAudioCache()
UpdateGuiDisplay()

A_TrayMenu.ClickCount := 2

TrayHandler := TrayIconHandler()
;TrayHandler.HoverDelay					:= 600
;TrayHandler.LeaveDelay					:= 200
TrayHandler.OnHover						:= (*) => ShowMediaGUI()
TrayHandler.OnLeftClick					:= (*) => PlayPause()
TrayHandler.OnRightClick				:= (*) => A_TrayMenu.Show()
TrayHandler.OnDoubleClick				:= (*) => PreviousTrack()
TrayHandler.OnRightDoubleClick			:= (*) => NextTrack()
TrayHandler.OnMiddleClick				:= (*) => OpenCurrentPlayer()
TrayHandler.OnMiddleDoubleClick			:= (*) => MuteUnmute()
TrayHandler.OnLeave						:= (*) => TrayLeave()
TrayHandler.OnWheelUp					:= (*) => Volume_Up()
TrayHandler.OnWheelDown					:= (*) => Volume_Down()

TrayLeave(*) {
	if !tracker.isMouseOverGui {
		HideMediaGUI()
	}
}

; --- HIGH-SPEED AUDIO CACHING ---
RefreshAudioCache() {
    global CachedAudioSessions
    CachedAudioSessions := Map()
    devices := PopulatePlaybackDevices()
    
    for deviceName in devices {
        if DeviceMap.Has(deviceName) {
            devicePtr := DeviceMap[deviceName]
            sessions := GetAudioSessionsForDevice(devicePtr)
            for sess in sessions {
                CachedAudioSessions[sess.ProgName] := sess
            }
        }
    }
    return CachedAudioSessions
}

GetCachedAppVolume(appName) {
    global CachedAudioSessions
    cleanSearchName := StrLower(appName)
    
    for progName, sessionObj in CachedAudioSessions {
        if (InStr(StrLower(progName), cleanSearchName) || InStr(cleanSearchName, StrLower(progName))) {
            return sessionObj.Volume
        }
    }
    
    ; If not found in cache, perform a single refresh pass
    RefreshAudioCache()
    for progName, sessionObj in CachedAudioSessions {
        if (InStr(StrLower(progName), cleanSearchName) || InStr(cleanSearchName, StrLower(progName))) {
            return sessionObj.Volume
        }
    }
    return -1
}

SetCachedAppVolume(appName, targetVol) {
    global CachedAudioSessions
    cleanSearchName := StrLower(appName)

    ; Instant direct modification using saved SimpleVol pointer
    for progName, sessionObj in CachedAudioSessions {
        if (InStr(StrLower(progName), cleanSearchName) || InStr(cleanSearchName, StrLower(progName))) {
            SetAppVolume(sessionObj.SimpleVol, targetVol)
            sessionObj.Volume := targetVol
            return true
        }
    }

    ; Fallback: Only rebuild COM devices if application was not found initially
    RefreshAudioCache()
    for progName, sessionObj in CachedAudioSessions {
        if (InStr(StrLower(progName), cleanSearchName) || InStr(cleanSearchName, StrLower(progName))) {
            SetAppVolume(sessionObj.SimpleVol, targetVol)
            sessionObj.Volume := targetVol
            return true
        }
    }
    return false
}

; --- GUI CALLBACKS ---
OnVolumeChanged(ctrl, *) {
    global VolText, MediaController
    newVol := ctrl.Value
    VolText.Value := newVol

    sess := MediaController.GetSession()
    if sess {
        appName := MediaController.CleanAppName(sess.SourceAppUserModelId)
        SetCachedAppVolume(appName, newVol)
    }
}

OpenCurrentPlayer() {
    global MediaController

    sess := MediaController.GetSession()
    if !sess
        return

    rawAppId := sess.SourceAppUserModelId
    cleanName := MediaController.CleanAppName(rawAppId)
    
    exeName := ""
    if InStr(rawAppId, "\") {
        SplitPath(rawAppId, &exeName)
    } else if InStr(rawAppId, ".exe") {
        exeName := rawAppId
    } else {
        exeName := cleanName . ".exe"
    }

    DetectHiddenWindows(true)
    targetHwnd := 0

    ; Search all windows owned by the foobar process
    winList := WinGetList("ahk_exe " . exeName)
    
    for hwnd in winList {
        try {
            title := WinGetTitle(hwnd)
            
            ; 1. Skip decoy windows like "GDI+ Window", "uninteresting", or empty message handles
            if (title == "" || InStr(title, "GDI+") || InStr(title, "uninteresting"))
                continue
                
            ; 2. Match the main window
            if InStr(title, "foobar2000") || InStr(title, cleanName) {
                targetHwnd := hwnd
                break
            }
        }
    }

    if (targetHwnd) {
        ; Send SC_RESTORE to handle foobar's internal tray-unhide message
        SendMessage(0x0112, 0xF120, 0,, targetHwnd)
        
        WinShow(targetHwnd)
        
        if (WinGetMinMax(targetHwnd) == -1) {
            WinRestore(targetHwnd)
        }
        
        ; Restores focus on whichever monitor foobar was originally placed
        WinActivate(targetHwnd)
    }
    
    DetectHiddenWindows(false)
}


RefreshSessionDropdown() {
    global AppMap, MediaController, SessionText, CurrentSessionList, CurrentSessionIndex

    sessions := MediaController.GetAvailableSessions()
    currentSess := MediaController.GetSession()
    currentAppId := currentSess ? currentSess.SourceAppUserModelId : ""

    AppMap := Map()
    displayItems := []
    selectedIdx := 1

    for idx, item in sessions {
        displayName := item.name
        
        if AppMap.Has(displayName) {
            displayName .= " (" . idx . ")"
        }

        AppMap[displayName] := item.appId
        displayItems.Push(displayName)

        if (currentAppId != "" && item.appId == currentAppId) {
            selectedIdx := idx
        }
    }

    if (displayItems.Length == 0) {
        displayItems := ["No Active Apps"]
        selectedIdx := 1
    }

    ; Update state memory
    CurrentSessionList := displayItems
    CurrentSessionIndex := selectedIdx

    ; Render UI text directly
    SessionText.Value := CurrentSessionList[CurrentSessionIndex]
}

NavigateSession(direction) {
    global CurrentSessionList, CurrentSessionIndex

    if (CurrentSessionList.Length <= 1)
        return

    ; Step forward or backward with wrap-around boundary logic
    CurrentSessionIndex += direction
    if (CurrentSessionIndex > CurrentSessionList.Length)
        CurrentSessionIndex := 1
    else if (CurrentSessionIndex < 1)
        CurrentSessionIndex := CurrentSessionList.Length

    ; Apply selection
    ApplySessionSelection(CurrentSessionList[CurrentSessionIndex])
}

ApplySessionSelection(selectedName) {
    global AppMap, MediaController, SessionText

    SessionText.Value := selectedName

    if AppMap.Has(selectedName) {
        MediaController.BindTargetSession(AppMap[selectedName])
        RefreshAudioCache()
        UpdateGuiDisplay()
    }
}


OnSessionSelected(ctrl, *) {
    global AppMap, MediaController
    selectedName := ctrl.Text
    if AppMap.Has(selectedName) {
        MediaController.BindTargetSession(AppMap[selectedName])
        RefreshAudioCache() ; Refresh pointers when user changes media app
        UpdateGuiDisplay()
    }
}

; Instant Volume Hotkeys
Volume_Up() {
    sess := MediaController.GetSession()
    if !sess
        return

    appName := MediaController.CleanAppName(sess.SourceAppUserModelId)
    currentVol := GetCachedAppVolume(appName)
    if (currentVol != -1) {
        newVol := Min(100, currentVol + 5)
        SetCachedAppVolume(appName, newVol)
        VolSlider.Value := newVol
        VolText.Value := newVol
		OSD_Volume( newVol, appName " Volume")
    }
}

Volume_Down() {
    sess := MediaController.GetSession()
    if !sess
        return

    appName := MediaController.CleanAppName(sess.SourceAppUserModelId)
    currentVol := GetCachedAppVolume(appName)
    if (currentVol != -1) {
        newVol := Max(0, currentVol - 5)
        SetCachedAppVolume(appName, newVol)
        VolSlider.Value := newVol
        VolText.Value := newVol
		OSD_Volume( newVol, appName " Volume")
    }
}


; Instant Mute / Unmute Hotkey
MuteUnmute() {
    static AppSavedVolumes := Map() ; Key: appName, Value: savedVolume
    
    sess := MediaController.GetSession()
    if !sess
        return

    appName := MediaController.CleanAppName(sess.SourceAppUserModelId)
    currentVol := GetCachedAppVolume(appName)

    ; Check if app is currently unmuted (volume > 0)
    if (currentVol > 0) {
        ; Save the active volume state before muting
        AppSavedVolumes[appName] := currentVol
        
        SetCachedAppVolume(appName, 0)
        VolSlider.Value := 0
        VolText.Value := "0"
        OSD_General(imageMute, appName " Muted")
    } else {
        ; Restore saved volume, defaulting to 50 if muted initially or unrecorded
        restoreVol := AppSavedVolumes.Has(appName) ? AppSavedVolumes[appName] : 50
        
        SetCachedAppVolume(appName, restoreVol)
        VolSlider.Value := restoreVol
        VolText.Value := String(restoreVol)
        OSD_General(imageUnmute, appName " Unmuted")
    }
}

PlayPause() {
	MediaController.TogglePlayPause()
	state := CurrentStatus.isPlaying ? imagePause : imagePlay
	label := CurrentStatus.isPlaying ? "Pause" : "Play"
	OSD_General( state, label)
;	UpdateGuiDisplay()
}

PreviousTrack() {
	MediaController.Previous()
	OSD_General( imagePrevious, "Previous")
	UpdateGuiDisplay()
}

NextTrack() {
	MediaController.Next()
	OSD_General( imageNext, "Next")
;	UpdateGuiDisplay()
}

ToggleMediaGUI() {
    global ShowingGui

	if (General.MediaPopUpArtWorkType == "None") {
		return
	}

    if (!ShowingGui) {
		;MyGui.Show("x-99999 y-99999 w300 h168 Hide NoActivate")
		;MyGui.Show("x-99999 y-99999 w300 h238 Hide NoActivate")
		MyGui.Show("x-99999 y-99999 w" MediaGUIWidth " Hide NoActivate")
		UpdateGuiDisplay()
		GuiAtTray(MyGui, TrayHandler,&spawnX, &spawnY, &w, &h)
		MyGui.Move(spawnX, spawnY)
	} else {
		MyGui.Hide()
	}
	ShowingGui := !ShowingGui
}

ShowMediaGUI() {
    global ShowingGui

	if (General.MediaPopUpArtWorkType == "None") || ShowingGui {
		return
	}

	;MyGui.Show("x-99999 y-99999 w300 h168 Hide NoActivate")
	;MyGui.Show("x-99999 y-99999 w300 h238 Hide NoActivate")
	MyGui.Show("x-99999 y-99999 w" MediaGUIWidth " Hide NoActivate")
	UpdateGuiDisplay()
	GuiAtTray(MyGui, TrayHandler,&spawnX, &spawnY, &w, &h)
	MyGui.Move(spawnX, spawnY)
	ShowingGui := true
}


HideMediaGUI() {
    global ShowingGui

	if !ShowingGui || TrayHandler.IsMouseOver {
		return
	}
	MyGui.Hide()
	ShowingGui := false
}

SelectAppMenu(appId, *) {
    global MediaController
    MediaController.BindTargetSession(appId)
    RefreshAudioCache()
    UpdateGuiDisplay()
}

OnExit((*) => MediaController.Cleanup())


