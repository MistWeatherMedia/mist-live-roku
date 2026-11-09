sub ShowChannelIdDialog(message as String, prefill as String)
    dlg = CreateObject("roSGNode", "StandardKeyboardDialog")
    dlg.title = "Enter channel ID"
    if message <> ""
        dlg.message = [message]
    else
        dlg.message = ["Type a channel's ID to watch a private channel."]
    end if
    dlg.text = prefill
    dlg.buttons = ["Watch", "Cancel"]
    dlg.ObserveFieldScoped("buttonSelected", "OnChannelIdDialogButton")
    dlg.ObserveFieldScoped("wasClosed", "OnChannelIdDialogClosed")
    m.channelIdDialog = dlg
    m.top.dialog = dlg
end sub

sub OnChannelIdDialogButton()
    dlg = m.channelIdDialog
    if dlg = invalid then return

    if dlg.buttonSelected = 0
        raw = dlg.text
        if raw = invalid then raw = ""
        dlg.close = true
        SubmitChannelId(raw)
    else
        dlg.close = true
    end if
end sub

sub OnChannelIdDialogClosed()
    topScreen = m.screenStack.Peek()
    if topScreen <> invalid
        if topScreen.IsSameNode(m.GridScreen) then m.GridScreen.SetFocus(true)
    end if
end sub

sub SubmitChannelId(raw as String)
    channelId = LCase(raw.Trim())

    rx = CreateObject("roRegex", "^[a-z0-9_-]+$", "")
    if channelId = "" or not rx.IsMatch(channelId)
        ShowChannelIdDialog("Channel IDs only use letters, numbers, - and _.", raw)
        return
    end if

    idx = FindGridChannelIndex(channelId)
    if idx >= 0
        ShowVideoScreen(m.GridScreen.content.GetChild(0), idx)
        return
    end if

    m.loadingIndicator.visible = true
    m.channelCheckTask = CreateObject("roSGNode", "ChannelCheckTask")
    m.channelCheckTask.channelId = channelId
    m.channelCheckTask.ObserveField("result", "OnChannelCheckResult")
    m.channelCheckTask.control = "run"
end sub

sub OnChannelCheckResult(event as Object)
    m.loadingIndicator.visible = false
    r = event.GetData()
    if r = invalid then return

    if r.ok = true
        PlayPrivateChannel(r.channelId)
    else
        ShowChannelIdDialog("No channel found for '" + r.channelId + "'. Check the ID and try again.", r.channelId)
    end if
end sub

sub PlayPrivateChannel(channelId as String)
    item = CreateObject("roSGNode", "ContentNode")
    item.Update({
        id: channelId,
        title: channelId,
        description: "Private channel",
        icon: "pkg:/images/fallback_icon.png",
        url: "https://watch.mistlive.tv/hls/" + channelId + "/playlist.m3u8",
        streamFormat: "hls"
    }, true)
    PlayStream(item.url)
    BuildVideoOverlay(item)
end sub

function FindGridChannelIndex(channelId as String) as Integer
    if m.GridScreen = invalid then return -1
    if m.GridScreen.content = invalid then return -1
    row = m.GridScreen.content.GetChild(0)
    if row = invalid then return -1
    for i = 0 to row.GetChildCount() - 1
        if LCase(row.GetChild(i).id) = channelId then return i
    end for
    return -1
end function
