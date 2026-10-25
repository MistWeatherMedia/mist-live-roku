' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

sub Init()
    m.rowList = m.top.FindNode("rowList")
    m.rowList.SetFocus(true)
    m.thumbnailImage = m.top.FindNode("thumbnailimage")
    m.top.ObserveField("visible", "OnVisibleChange")
    m.rowList.ObserveField("rowItemFocused", "OnItemFocused")
    m.thumbnailImage.ObserveField("loadStatus", "OnThumbnailLoadStatusChange")

    titleFont = CreateObject("roSGNode", "Font")
    titleFont.uri = "pkg:/fonts/Geist-Bold.ttf"
    titleFont.size = 28

    viewershipFont = CreateObject("roSGNode", "Font")
    viewershipFont.uri = "pkg:/fonts/Geist-Bold.ttf"
    viewershipFont.size = 20

    descriptionFont = CreateObject("roSGNode", "Font")
    descriptionFont.uri = "pkg:/fonts/Geist-Regular.ttf"
    descriptionFont.size = 20

    m.titleLabel = CreateObject("roSGNode", "Label")
    m.titleLabel.translation = [128, 270]
    m.titleLabel.width = 650
    m.titleLabel.color = "0xFFFFFFFF"
    m.titleLabel.font = titleFont
    m.top.AppendChild(m.titleLabel)

    m.viewershipLabel = CreateObject("roSGNode", "Label")
    m.viewershipLabel.translation = [1060, 268]
    m.viewershipLabel.width = 110
    m.viewershipLabel.color = "0xAAAAAAFF"
    m.viewershipLabel.font = viewershipFont
    m.top.AppendChild(m.viewershipLabel)

    ' description stays below the thumbnail, unchanged position
    m.descriptionLabel = CreateObject("roSGNode", "Label")
    m.descriptionLabel.translation = [810, 315]
    m.descriptionLabel.width = 360
    m.descriptionLabel.wrap = true
    m.descriptionLabel.numLines = 7 ' dropped to 7 from 10 for the schedule, prolly gonna move it later but this is fine for now
    m.descriptionLabel.color = "0xFFFFFFFF"
    m.descriptionLabel.font = descriptionFont
    m.top.AppendChild(m.descriptionLabel)

    m.epgCache = {}
    m.focusedChannelId = ""

    epgFont = CreateObject("roSGNode", "Font")
    epgFont.uri = "pkg:/fonts/Geist-Regular.ttf"
    epgFont.size = 18

    m.epgNowLabel = CreateObject("roSGNode", "Label")
    m.epgNowLabel.translation = [810, 590]
    m.epgNowLabel.width = 360
    m.epgNowLabel.wrap = false
    m.epgNowLabel.numLines = 1
    m.epgNowLabel.color = "0xFFFFFFFF"
    m.epgNowLabel.font = epgFont
    m.top.AppendChild(m.epgNowLabel)

    m.epgNextLabel = CreateObject("roSGNode", "Label")
    m.epgNextLabel.translation = [810, 620]
    m.epgNextLabel.width = 360
    m.epgNextLabel.wrap = false
    m.epgNextLabel.numLines = 1
    m.epgNextLabel.color = "0xBBBBBBFF"
    m.epgNextLabel.font = epgFont
    m.top.AppendChild(m.epgNextLabel)

    m.epgDebounce = CreateObject("roSGNode", "Timer")
    m.epgDebounce.duration = 0.35
    m.epgDebounce.repeat = false
    m.epgDebounce.ObserveField("fire", "OnEPGDebounce")
end sub

sub UpdateGridEPG()
    entry = m.epgCache[m.focusedChannelId]
    if entry <> invalid
        ApplyGridEPG()
        age = CreateObject("roDateTime").AsSeconds() - entry.fetchedAt
        if age < 600 then return
    else
        m.epgNowLabel.text = ""
        m.epgNextLabel.text = ""
    end if
    m.epgDebounce.control = "stop"
    m.epgDebounce.control = "start"
end sub

sub OnEPGDebounce()
    if m.focusedChannelId = "" then return
    m.gridScheduleTask = CreateObject("roSGNode", "ScheduleTask")
    m.gridScheduleTask.channelId = m.focusedChannelId
    m.gridScheduleTask.ObserveField("result", "OnGridScheduleLoaded")
    m.gridScheduleTask.control = "run"
end sub

sub OnGridScheduleLoaded(event as Object)
    r = event.GetData()
    if r = invalid then return
    m.epgCache[r.channelId] = { programs: r.programs, fetchedAt: r.fetchedAt }
    if r.channelId = m.focusedChannelId then ApplyGridEPG()
end sub

sub ApplyGridEPG()
    entry = m.epgCache[m.focusedChannelId]
    if entry = invalid then return
    epg = EPGLines(entry.programs, CreateObject("roDateTime").AsSeconds())
    m.epgNowLabel.text = epg.nowText
    m.epgNextLabel.text = epg.nextText
end sub

sub OnThumbnailLoadStatusChange()
    if m.thumbnailImage.loadStatus = "failed"
        m.thumbnailImage.uri = "https://file.garden/anfFhGxO-geaMQ6-/thumbnailfail.png"
    end if
end sub

sub OnVisibleChange()
    if m.top.visible = true
        m.rowList.SetFocus(true)
    end if
end sub

sub OnItemFocused()
    if m.rowList.content = invalid then return
    focusedIndex = m.rowList.rowItemFocused
    if focusedIndex = invalid or focusedIndex.Count() < 2 then return
    row = m.rowList.content.GetChild(focusedIndex[0])
    if row = invalid then return
    item = row.GetChild(focusedIndex[1])
    if item = invalid then return

    m.descriptionLabel.text = item.description
    m.titleLabel.text = item.title
    m.thumbnailImage.uri = item.hdPosterUrl

    if item.viewership <> invalid
        if item.viewership = 1
            m.viewershipLabel.text = "1 viewer"
        else
            m.viewershipLabel.text = item.viewership.ToStr() + " viewers"
        end if
    else
        m.viewershipLabel.text = ""
    end if
    m.focusedChannelId = item.id
    UpdateGridEPG()
end sub

function GetTime(length as Integer) as String
    minutes = (length \ 60).ToStr()
    seconds = length MOD 60
    if seconds < 10
       seconds = "0" + seconds.ToStr()
    else
       seconds = seconds.ToStr()
    end if
    return minutes + ":" + seconds
end function
