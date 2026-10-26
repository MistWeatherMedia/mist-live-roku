' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainScene.xml using relative path.

' invoked from the grid: plays the selected item of the given row
sub ShowVideoScreen(content as Object, itemIndex as Integer)
    if content = invalid then return
    selectedItem = content.GetChild(itemIndex)
    if selectedItem = invalid or selectedItem.url = invalid then return
    PlayStream(selectedItem.url)
    BuildVideoOverlay(selectedItem)
end sub

' shared by the grid and deep links
sub PlayStream(url as String)
    if m.videoPlayer <> invalid and m.screenStack.Peek() <> invalid
        if m.screenStack.Peek().IsSameNode(m.videoPlayer) then CloseScreen(m.videoPlayer)
    end if

    m.videoPlayer = CreateObject("roSGNode", "Video")

    node = CreateObject("roSGNode", "ContentNode")
    node.url = url
    node.streamFormat = "hls"
    node.live = true
    m.videoPlayer.content = node
    m.videoPlayer.contentIsPlaylist = false

    ShowScreen(m.videoPlayer)
    m.videoPlayer.control = "play"
    m.videoPlayer.ObserveField("state", "OnVideoPlayerStateChange")
    m.videoPlayer.ObserveField("visible", "OnVideoVisibleChange")
    m.videoPlayer.ObserveField("availableSubtitleTracks", "OnSubtitleTracksChanged")

    ' memory check timer every 15 minutes (created once)
    if m.memTimer = invalid
        m.memTimer = CreateObject("roSGNode", "Timer")
        m.memTimer.duration = 900
        m.memTimer.repeat = true
        m.memTimer.ObserveField("fire", "OnMemCheck")
        m.memTimer.control = "start"
    end if
end sub

sub OnMemCheck()
    now = CreateObject("roDateTime")
    timestamp = now.GetHours().ToStr() + ":" + now.GetMinutes().ToStr() + ":" + now.GetSeconds().ToStr()
    memLevel = CreateObject("roDeviceInfo").GetGeneralMemoryLevel()
    state = "n/a"
    if m.videoPlayer <> invalid then state = m.videoPlayer.state
    print "[MEMCHECK "; timestamp; "] Memory level: "; memLevel; " | Video state: "; state
end sub

sub OnVideoPlayerStateChange()
    if m.videoPlayer = invalid then return
    state = m.videoPlayer.state
    memLevel = CreateObject("roDeviceInfo").GetGeneralMemoryLevel()
    print "Video state changed to: "; state; " | Memory level: "; memLevel
    if state = "error"
        print "Video error code: "; m.videoPlayer.errorCode
        print "Video error message: "; m.videoPlayer.errorMsg
    end if
    if state = "error" or state = "finished"
        CloseScreen(m.videoPlayer)
    end if
end sub

sub OnVideoVisibleChange()
    if m.videoPlayer = invalid then return
    if m.videoPlayer.visible = false and m.top.visible = true
        m.videoPlayer.control = "stop"
        m.videoPlayer.content = invalid
        m.GridScreen.SetFocus(true)
        m.lastDeepLinkId = invalid
        TeardownVideoOverlay()
    end if
end sub

sub BuildVideoOverlay(item as Object)
    TeardownVideoOverlay()

    titleFont = CreateObject("roSGNode", "Font")
    titleFont.uri = "pkg:/fonts/TASAOrbiter-Bold.ttf"
    titleFont.size = 30

    descFont = CreateObject("roSGNode", "Font")
    descFont.uri = "pkg:/fonts/Geist-Regular.ttf"
    descFont.size = 18

    m.videoOverlay = CreateObject("roSGNode", "Group")
    topShade = CreateObject("roSGNode", "Poster")
    topShade.uri = "pkg:/images/shade_top.png"
    topShade.translation = [0, 0]
    topShade.width = 1280
    topShade.height = 180
    topShade.loadDisplayMode = "scaleToFill"
    m.videoOverlay.AppendChild(topShade)

    cornerShade = CreateObject("roSGNode", "Poster")
    cornerShade.uri = "pkg:/images/shade_bottom_right.png"
    cornerShade.translation = [0, 0]
    cornerShade.width = 1280
    cornerShade.height = 720
    cornerShade.loadDisplayMode = "scaleToFill"
    m.videoOverlay.AppendChild(cornerShade)

    m.overlayIcon = CreateObject("roSGNode", "Poster")
    m.overlayIcon.translation = [64, 32]
    m.overlayIcon.width = 72
    m.overlayIcon.height = 72
    m.overlayIcon.loadDisplayMode = "scaleToFit"
    m.overlayIcon.uri = item.icon
    m.overlayIcon.ObserveField("loadStatus", "OnOverlayIconStatus")
    m.videoOverlay.AppendChild(m.overlayIcon)

    title = CreateObject("roSGNode", "Label")
    title.translation = [152, 36]
    title.width = 820
    title.color = "0xFFFFFFFF"
    title.font = titleFont
    title.text = item.title
    m.videoOverlay.AppendChild(MakeShadowLabel(title)) ' shadow first so it draws behind
    m.videoOverlay.AppendChild(title)

    descText = item.description
    if descText = invalid then descText = ""
    descText = descText.Replace(Chr(13), " ")
    descText = descText.Replace(Chr(10), " ")
    desc = CreateObject("roSGNode", "Label")
    desc.translation = [152, 78]
    desc.width = 820
    desc.wrap = false
    desc.numLines = 1
    desc.color = "0xDDDDDDFF"
    desc.font = descFont
    desc.text = descText
    m.videoOverlay.AppendChild(MakeShadowLabel(desc))
    m.videoOverlay.AppendChild(desc)

    ' clocl
    m.overlayClock = CreateObject("roSGNode", "Label")
    m.overlayClock.translation = [1016, 36]
    m.overlayClock.width = 200
    m.overlayClock.horizAlign = "right"
    m.overlayClock.color = "0xFFFFFFFF"
    m.overlayClock.font = titleFont
    m.overlayClockShadow = MakeShadowLabel(m.overlayClock)
    m.videoOverlay.AppendChild(m.overlayClockShadow)
    m.videoOverlay.AppendChild(m.overlayClock)

    m.epgNowLabel = CreateObject("roSGNode", "Label")
    m.epgNowLabel.translation = [152, 108]
    m.epgNowLabel.width = 820
    m.epgNowLabel.wrap = false
    m.epgNowLabel.numLines = 1
    m.epgNowLabel.color = "0xFFFFFFFF"
    m.epgNowLabel.font = descFont
    m.epgNowShadow = MakeShadowLabel(m.epgNowLabel)
    m.videoOverlay.AppendChild(m.epgNowShadow)
    m.videoOverlay.AppendChild(m.epgNowLabel)

    m.epgNextLabel = CreateObject("roSGNode", "Label")
    m.epgNextLabel.translation = [152, 132]
    m.epgNextLabel.width = 820
    m.epgNextLabel.wrap = false
    m.epgNextLabel.numLines = 1
    m.epgNextLabel.color = "0xBBBBBBFF"
    m.epgNextLabel.font = descFont
    m.epgNextShadow = MakeShadowLabel(m.epgNextLabel)
    m.videoOverlay.AppendChild(m.epgNextShadow)
    m.videoOverlay.AppendChild(m.epgNextLabel)

    m.captionStatus = CreateObject("roSGNode", "Label")
    m.captionStatus.translation = [816, 598]
    m.captionStatus.width = 400
    m.captionStatus.horizAlign = "right"
    m.captionStatus.color = "0xFFFFFFFF"
    m.captionStatus.font = descFont
    m.captionStatusShadow = MakeShadowLabel(m.captionStatus)
    m.videoOverlay.AppendChild(m.captionStatusShadow)
    m.videoOverlay.AppendChild(m.captionStatus)

    m.captionOff = AddOverlayButton("pkg:/images/caption.png", 1116, 630, 80, 70)
    m.captionOn = AddOverlayButton("pkg:/images/caption-select.png", 1116, 630, 80, 70)
    m.settingsOff = AddOverlayButton("pkg:/images/settings-cog.png", 1170, 632, 66, 66)
    m.settingsOn = AddOverlayButton("pkg:/images/settings-cog-select.png", 1170, 632, 66, 66)
    m.overlayFocus = 0 ' 0 = nothing highlighted, 1 = captions, 2 = settings
    UpdateOverlayButtons()

    m.top.AppendChild(m.videoOverlay)

    m.videoPlayer.enableUI = false
    m.videoPlayer.enableTrickPlay = false
    m.top.SetFocus(true)
    m.videoOverlayActive = true

    UpdateOverlayClock()
    m.clockTimer = CreateObject("roSGNode", "Timer")
    m.clockTimer.duration = 1
    m.clockTimer.repeat = true
    m.clockTimer.ObserveField("fire", "OnOverlaySecond")
    m.clockTimer.control = "start"
    m.fadeTimer = CreateObject("roSGNode", "Timer")
    m.fadeTimer.duration = 0.05
    m.fadeTimer.repeat = true
    m.fadeTimer.ObserveField("fire", "OnFadeStep")

    m.overlayTick = 0
    m.overlayPrograms = invalid
    m.overlayChannelId = ""
    if item.id <> invalid and item.id <> "" then RequestOverlaySchedule(item.id)

    ShowVideoOverlay()
end sub

sub ShowVideoOverlay()
    if m.videoOverlay = invalid then return
    m.fadeTimer.control = "stop"
    m.videoOverlay.opacity = 1.0
    m.videoOverlay.visible = true
    m.overlayShown = true
    m.overlayIdle = 0
end sub

sub OnOverlaySecond()
    if m.videoOverlay = invalid then return
    UpdateOverlayClock()

    m.overlayTick = m.overlayTick + 1
    if m.overlayTick MOD 30 = 0 then RefreshOverlayEPG()
    if m.overlayTick MOD 1800 = 0 then RequestOverlaySchedule(m.overlayChannelId)

    if m.overlayShown = true
        m.overlayIdle = m.overlayIdle + 1
        if m.overlayIdle >= 4
            m.overlayShown = false
            m.fadeTimer.control = "start"
        end if
    end if
end sub

sub OnFadeStep()
    if m.videoOverlay = invalid
        m.fadeTimer.control = "stop"
        return
    end if
    opacity = m.videoOverlay.opacity - 0.1
    if opacity <= 0.05
        opacity = 0
        m.videoOverlay.visible = false
        m.fadeTimer.control = "stop"
        m.overlayFocus = 0
        UpdateOverlayButtons()
        SetCaptionStatus("")
    end if
    m.videoOverlay.opacity = opacity
end sub

sub TeardownVideoOverlay()
    m.overlayShown = false
    m.videoOverlayActive = false
    m.overlayFocus = 0
    m.overlayPrograms = invalid
    if m.clockTimer <> invalid then m.clockTimer.control = "stop"
    if m.fadeTimer <> invalid then m.fadeTimer.control = "stop"
    if m.videoOverlay <> invalid
        m.top.RemoveChild(m.videoOverlay)
        m.videoOverlay = invalid
    end if
end sub

sub OnOverlayIconStatus()
    if m.overlayIcon = invalid then return
    if m.overlayIcon.loadStatus = "failed"
        m.overlayIcon.uri = "pkg:/images/fallback_icon.png"
    end if
end sub

sub UpdateOverlayClock()
    if m.overlayClock = invalid then return
    dt = CreateObject("roDateTime")
    dt.ToLocalTime()
    hours = dt.GetHours()
    suffix = "AM"
    if hours >= 12 then suffix = "PM"
    hours = hours MOD 12
    if hours = 0 then hours = 12
    mins = dt.GetMinutes()
    if mins < 10
        minStr = "0" + mins.ToStr()
    else
        minStr = mins.ToStr()
    end if
    clockText = hours.ToStr() + ":" + minStr + " " + suffix
    m.overlayClock.text = clockText
    if m.overlayClockShadow <> invalid then m.overlayClockShadow.text = clockText
end sub

function AddOverlayButton(uri as String, x as Integer, y as Integer, w as Integer, h as Integer) as Object
    btn = CreateObject("roSGNode", "Poster")
    btn.uri = uri
    btn.translation = [x, y]
    btn.width = w
    btn.height = h
    btn.loadDisplayMode = "scaleToFit"
    m.videoOverlay.AppendChild(btn)
    return btn
end function

sub UpdateOverlayButtons()
    if m.captionOff = invalid then return
    m.captionOn.visible = (m.overlayFocus = 1)
    m.captionOff.visible = (m.overlayFocus <> 1)
    m.settingsOn.visible = (m.overlayFocus = 2)
    m.settingsOff.visible = (m.overlayFocus <> 2)
end sub

sub HandleOverlayKey(key as String)
    if m.videoOverlay = invalid then return

    wasShown = (m.overlayShown = true)
    ShowVideoOverlay()
    if wasShown = false then return

    if key = "down"
        if m.overlayFocus = 0 then m.overlayFocus = 1
    else if key = "up"
        m.overlayFocus = 0
    else if key = "left"
        if m.overlayFocus = 2 or m.overlayFocus = 0 then m.overlayFocus = 1
    else if key = "right"
        if m.overlayFocus = 1
            m.overlayFocus = 2
        else if m.overlayFocus = 0
            m.overlayFocus = 1
        end if
    else if key = "OK"
        if m.overlayFocus = 1 then OnCaptionsSelected()
        if m.overlayFocus = 2 then OnSettingsSelected()
    end if

    UpdateOverlayButtons()
end sub

sub OnCaptionsSelected()
    if m.videoPlayer = invalid then return

    tracks = m.videoPlayer.availableSubtitleTracks
    if tracks = invalid then tracks = []

    choices = []
    for each t in tracks
        label = ""
        if t.Description <> invalid then label = t.Description
        if label = "" and t.Language <> invalid then label = t.Language
        if label = "" then label = t.TrackName
        choices.Push({ track: t.TrackName, label: label })
    end for
    if choices.Count() = 0
        print "[CAPTIONS] stream reported no tracks - trying in-band CC1 (eia608/1)"
        choices.Push({ track: "eia608/1", label: "CC1" })
    end if

    cur = -1
    if m.videoPlayer.globalCaptionMode = "On"
        cur = 0
        for i = 0 to choices.Count() - 1
            if choices[i].track = m.videoPlayer.subtitleTrack then cur = i
        end for
    end if

    nextIdx = cur + 1
    if nextIdx >= choices.Count() then nextIdx = -1

    if nextIdx = -1
        m.videoPlayer.globalCaptionMode = "Off"
        SetCaptionStatus("Captions: Off")
        print "[CAPTIONS] off"
    else
        m.videoPlayer.subtitleTrack = choices[nextIdx].track
        m.videoPlayer.globalCaptionMode = "On"
        SetCaptionStatus("Captions: " + choices[nextIdx].label)
        print "[CAPTIONS] on -> "; choices[nextIdx].track
    end if
end sub

sub OnSettingsSelected()
    print "[OVERLAY] Settings button selected (no action wired up yet)"
end sub

function MakeShadowLabel(src as Object) as Object
    SHADOW_OFFSET = 2
    shadow = CreateObject("roSGNode", "Label")
    shadow.font = src.font
    shadow.width = src.width
    shadow.wrap = src.wrap
    shadow.numLines = src.numLines
    shadow.horizAlign = src.horizAlign
    shadow.text = src.text
    shadow.color = "0x000000AA"
    srcPos = src.translation
    shadow.translation = [srcPos[0] + SHADOW_OFFSET, srcPos[1] + SHADOW_OFFSET]
    return shadow
end function

sub RequestOverlaySchedule(channelId as String)
    if channelId = "" then return
    m.overlayChannelId = channelId
    m.scheduleTask = CreateObject("roSGNode", "ScheduleTask")
    m.scheduleTask.channelId = channelId
    m.scheduleTask.ObserveField("result", "OnOverlayScheduleLoaded")
    m.scheduleTask.control = "run"
end sub

sub OnOverlayScheduleLoaded(event as Object)
    if m.videoOverlay = invalid then return
    r = event.GetData()
    if r = invalid then return
    if r.channelId <> m.overlayChannelId then return
    m.overlayPrograms = r.programs
    RefreshOverlayEPG()
end sub

sub RefreshOverlayEPG()
    if m.videoOverlay = invalid then return
    if m.epgNowLabel = invalid then return
    nowText = ""
    nextText = ""
    if m.overlayPrograms <> invalid
        epg = EPGLines(m.overlayPrograms, CreateObject("roDateTime").AsSeconds())
        nowText = epg.nowText
        nextText = epg.nextText
    end if
    m.epgNowLabel.text = nowText
    m.epgNowShadow.text = nowText
    m.epgNextLabel.text = nextText
    m.epgNextShadow.text = nextText
end sub

sub OnSubtitleTracksChanged()
    if m.videoPlayer = invalid then return
    tracks = m.videoPlayer.availableSubtitleTracks
    if tracks = invalid then return
    print "[CAPTIONS] "; tracks.Count(); " track(s) reported | captionMode = "; m.videoPlayer.globalCaptionMode
    for each t in tracks
        print "[CAPTIONS]   TrackName="; t.TrackName; "  Language="; t.Language; "  Description="; t.Description
    end for
end sub

sub SetCaptionStatus(text as String)
    if m.captionStatus = invalid then return
    m.captionStatus.text = text
    m.captionStatusShadow.text = text
end sub