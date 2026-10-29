' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' entry point of MainScene
' Note that we need to import this file in MainScene.xml using relative path.
sub Init()
    m.top.backgroundUri = "pkg:/images/background.jpg"
    m.loadingIndicator = m.top.FindNode("loadingIndicator")

    InitScreenStack()
    ShowGridScreen()
    RunContentTask()

    if m.top.deepLinkArgs <> invalid
        OnLaunchArgsChanged()
    end if
end sub

' invoked when the app is launched with, or already running and receives, deep link parameters
sub OnLaunchArgsChanged()
    args = m.top.deepLinkArgs
    if args = invalid or args.contentId = invalid then return

    contentId = args.contentId.ToStr()
    if contentId = "" then return

    ' de-dupe: this can fire from both the field change and OnMainContentLoaded
    if m.lastDeepLinkId = contentId then return
    m.lastDeepLinkId = contentId

    ' the stream URL is derived from the channel id, so no need to wait for the grid
    PlayStream("https://watch.mistlive.tv/hls/" + contentId + "/playlist.m3u8")
end sub

function OnkeyEvent(key as String, press as Boolean) as Boolean
    result = false
    if press
        if key = "back"
            if m.sleepWarningOn = true
                SetSleepTimer(0) ' Back during the sleep countdown cancels it
                result = true
            else if m.videoOverlayActive = true and m.settingsOpen = true
                CloseSettingsPanel()
                result = true
            else
                numberOfScreens = m.screenStack.Count()
                if numberOfScreens > 1
                    CloseScreen(invalid)
                    result = true
                end if
            end if
        else if m.videoOverlayActive = true
            HandleOverlayKey(key)
            result = true
        end if
    end if
    return result
end function