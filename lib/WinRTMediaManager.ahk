#Requires AutoHotkey v2.0

class WinRTMediaManager {
    Manager := ""
    TargetSession := ""
    
    OnMediaChanged := ""
    IsFetching := false
    
    ArtToggle := false
    LastTitle := ""
    LastArtSize := 0 ; Added to track artwork changes
    PollCount := 0

    PropToken := 0
    PlaybackToken := 0

    __New(changeCallback := "") {
        this.OnMediaChanged := changeCallback
        this.InitWinRT()
    }

    InitWinRT() {
        try {
            DllCall("combase\RoInitialize", "uint", 1)

            ManagerStatics := WinRT("Windows.Media.Control.GlobalSystemMediaTransportControlsSessionManager")
            asyncOp := ManagerStatics.RequestAsync()
            
            Loop 100 {
                try {
                    if (asyncOp.Status = 1 || String(asyncOp.Status) = "Completed") {
                        this.Manager := asyncOp.GetResults()
                        break
                    }
                }
                Sleep 20
            }

            if this.Manager {
                try this.Manager.add_SessionsChanged((*) => this.OnSessionsChanged())
                this.BindTargetSession()
            }
        }
    }

    OnSessionsChanged() {
        if this.BindTargetSession()
            this.HandleMediaChange()
    }

    BindTargetSession(appIdFilter := "") {
        if !this.Manager
            return false

        this.UnbindSessionListeners()
        this.TargetSession := ""

        try {
            sessions := this.Manager.GetSessions()
            
            if (appIdFilter != "") {
                loop sessions.Size {
                    sess := sessions.GetAt(A_Index - 1)
                    if (sess.SourceAppUserModelId = appIdFilter || InStr(StrLower(sess.SourceAppUserModelId), StrLower(appIdFilter))) {
                        this.TargetSession := sess
                        break
                    }
                }
            }

            if !this.TargetSession {
                try this.TargetSession := this.Manager.GetCurrentSession()
            }

            if !this.TargetSession && sessions.Size > 0 {
                this.TargetSession := sessions.GetAt(0)
            }

            if this.TargetSession {
                try this.PropToken := this.TargetSession.add_MediaPropertiesChanged((*) => this.HandleMediaChange())
                try this.PlaybackToken := this.TargetSession.add_PlaybackInfoChanged((*) => this.HandleMediaChange())
            }
        }

        return this.TargetSession != ""
    }

    UnbindSessionListeners() {
        if this.TargetSession {
            if this.PropToken {
                try this.TargetSession.remove_MediaPropertiesChanged(this.PropToken)
                this.PropToken := 0
            }
            if this.PlaybackToken {
                try this.TargetSession.remove_PlaybackInfoChanged(this.PlaybackToken)
                this.PlaybackToken := 0
            }
        }
    }

    HandleMediaChange() {
        if (this.IsFetching)
            return

        if HasMethod(this.OnMediaChanged) {
            this.IsFetching := true
            try {
                info := this.GetMediaInfo()

                currentArtSize := 0
                if (info.artPath != "" && FileExist(info.artPath))
                    currentArtSize := FileGetSize(info.artPath)

                ; Reset polling counter on new track/video
                if (info.title != this.LastTitle) {
                    this.LastTitle := info.title
                    this.PollCount := 0
                }
                
                this.LastArtSize := currentArtSize
                this.OnMediaChanged.Call(info)

                ; Poll periodically if media is playing (catches delayed browser web art)
                if (info.isPlaying && this.PollCount < 5) {
                    SetTimer(() => this.PollForUpdatedArt(), -800)
                }
            } finally {
                this.IsFetching := false
            }
        }
    }

    PollForUpdatedArt() {
        if (this.IsFetching)
            return

        this.PollCount++
        if HasMethod(this.OnMediaChanged) {
            this.IsFetching := true
            try {
                info := this.GetMediaInfo()
                
                currentArtSize := 0
                if (info.artPath != "" && FileExist(info.artPath))
                    currentArtSize := FileGetSize(info.artPath)

                ; ONLY update GUI if the title changed or the artwork file size changed
                if (info.title != this.LastTitle || currentArtSize != this.LastArtSize) {
                    this.LastTitle := info.title
                    this.LastArtSize := currentArtSize
                    this.OnMediaChanged.Call(info)
                }

                ; Keep polling quietly in the background if limit isn't reached
                if (info.isPlaying && this.PollCount < 5) {
                    SetTimer(() => this.PollForUpdatedArt(), -800)
                }
            } finally {
                this.IsFetching := false
            }
        }
    }

    GetSession() {
        if this.TargetSession
            return this.TargetSession
        this.BindTargetSession()
        return this.TargetSession
    }

    GetAvailableSessions() {
        if !this.Manager
            return []

        appList := []
        try {
            sessions := this.Manager.GetSessions()
            loop sessions.Size {
                sess := sessions.GetAt(A_Index - 1)
                rawId := sess.SourceAppUserModelId
                cleanName := this.CleanAppName(rawId)
                appList.Push({ appId: rawId, name: cleanName })
            }
        }
        return appList
    }

    CleanAppName(appId) {
        if !appId
            return "Unknown App"
        
        if InStr(appId, "\") {
            SplitPath(appId, &filename)
            appId := filename
        }

        if InStr(appId, ".") {
            parts := StrSplit(appId, ".")
            appId := parts[1]
        }

        if (StrLower(appId) = "chrome")
            return "Google Chrome"
        if (StrLower(appId) = "msedge")
            return "Microsoft Edge"
        if (StrLower(appId) = "spotify")
            return "Spotify"

        return Format("{:T}", appId)
    }

    GetMediaInfo() {
        result := { title: "-", artist: "-", status: "Stopped", artPath: "", isPlaying: false, currentApp: "" }
        
        session := this.GetSession()
        if !session
            return result

        result.currentApp := this.CleanAppName(session.SourceAppUserModelId)

        propsAsync := session.TryGetMediaPropertiesAsync()
        props := ""
        Loop 30 {
            try {
                if (propsAsync.Status = 1 || String(propsAsync.Status) = "Completed") {
                    props := propsAsync.GetResults()
                    break
                }
            }
            Sleep 10
        }

        info := session.GetPlaybackInfo()

        if props {
            result.title := props.Title != "" ? props.Title : "Unknown Title"
            result.artist := props.Artist != "" ? props.Artist : "Unknown Artist"
            
            this.ArtToggle := !this.ArtToggle
            currentArtPath := A_Temp . "\ahk_album_art_" . (this.ArtToggle ? "1" : "2") . ".png"

            if props.Thumbnail && this.SaveThumbnailToFile(props.Thumbnail, currentArtPath) {
                result.artPath := currentArtPath
            }
        }

        if info {
            statusStr := String(info.PlaybackStatus)
            result.status := statusStr
            result.isPlaying := (statusStr = "Playing" || statusStr = "4")
        }

        return result
    }

    SaveThumbnailToFile(thumbRef, outputPath) {
        try {
            streamAsync := thumbRef.OpenReadAsync()
            stream := ""
            Loop 30 {
                try {
                    if (streamAsync.Status = 1 || String(streamAsync.Status) = "Completed") {
                        stream := streamAsync.GetResults()
                        break
                    }
                }
                Sleep 10
            }

            if (!stream || stream.Size == 0)
                return false

            reader := WinRT("Windows.Storage.Streams.DataReader")(stream)
            loadAsync := reader.LoadAsync(stream.Size)
            Loop 30 {
                if (loadAsync.Status = 1 || String(loadAsync.Status) = "Completed")
                    break
                Sleep 10
            }

            if FileExist(outputPath) {
                try FileDelete(outputPath)
            }

            file := FileOpen(outputPath, "w")
            loop stream.Size {
                file.WriteUChar(reader.ReadByte())
            }
            file.Close()

            return true
        } catch {
            return false
        }
    }

    TogglePlayPause() {
        info := this.GetMediaInfo()
        if info.isPlaying {
            this.Pause()
        } else {
            this.Play()
        }
    }

    Play() {
        if (sess := this.GetSession())
            sess.TryPlayAsync()
    }

    Pause() {
        if (sess := this.GetSession())
            sess.TryPauseAsync()
    }

    Next() {
        if (sess := this.GetSession())
            sess.TrySkipNextAsync()
    }

    Previous() {
        if (sess := this.GetSession())
            sess.TrySkipPreviousAsync()
    }

    Cleanup() {
        this.UnbindSessionListeners()
        try FileDelete(A_Temp . "\ahk_album_art_1.png")
        try FileDelete(A_Temp . "\ahk_album_art_2.png")
    }
}