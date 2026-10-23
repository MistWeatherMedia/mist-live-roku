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

    bottomShade = CreateObject("roSGNode", "Poster")
    bottomShade.uri = "pkg:/images/shade_bottom.png"
    bottomShade.translation = [0, 540]
    bottomShade.width = 1280
    bottomShade.height = 180
    bottomShade.loadDisplayMode = "scaleToFill"
    m.videoOverlay.AppendChild(bottomShade)

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
    m.videoOverlay.AppendChild(desc)

    ' clocl
    m.overlayClock = CreateObject("roSGNode", "Label")
    m.overlayClock.translation = [1016, 36]
    m.overlayClock.width = 200
    m.overlayClock.horizAlign = "right"
    m.overlayClock.color = "0xFFFFFFFF"
    m.overlayClock.font = titleFont
    m.videoOverlay.AppendChild(m.overlayClock)
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
    if m.overlayShown = true
        m.overlayIdle = m.overlayIdle + 1
        if m.overlayIdle >= 4 ' fadeout timer
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
    end if
    m.videoOverlay.opacity = opacity
end sub

sub TeardownVideoOverlay()
    m.overlayShown = false
    m.videoOverlayActive = false
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
    m.overlayClock.text = hours.ToStr() + ":" + minStr + " " + suffix
end sub
