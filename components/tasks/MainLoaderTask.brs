' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainLoaderTask.xml using relative path.
sub Init()
    m.top.functionName = "GetContent"
end sub

sub GetContent()
    rsp = FetchString("https://api.mistlive.tv/api/v1.5/channels")
    descRsp = FetchString("https://api.mistlive.tv/api/public-channels")

    descriptions = {}
    descJson = ParseJson(descRsp)
    if type(descJson) = "roArray"
        for each entry in descJson
            if type(entry) = "roAssociativeArray" and entry.channel_id <> invalid and entry.channel_description <> invalid
                descriptions[entry.channel_id] = entry.channel_description
            end if
        end for
    end if

    timestamp = CreateObject("roDateTime")
    cacheBuster = timestamp.GetYear().ToStr() + timestamp.GetMonth().ToStr() + timestamp.GetDayOfMonth().ToStr() + timestamp.GetHours().ToStr() + timestamp.GetMinutes().ToStr() + timestamp.GetSeconds().ToStr()

    ' parse the flat channel array
    json = ParseJson(rsp)
    items = []
    if type(json) = "roArray"
        for each channel in json
            ' skip malformed entries and channels that are currently offline
            if type(channel) = "roAssociativeArray" and channel.id <> invalid and channel.title <> invalid
                if channel.online = true
                    items.Push(GetItemData(channel, descriptions, cacheBuster))
                end if
            end if
        end for

        'allphabeticallyj
        items = SortItemsByTitle(items)
        favItems = []
        for each it in items
            if IsFavorite(it.id)
                favCopy = {}
                favCopy.Append(it) ' a separate copy, so the divider flag below can't leak onto it
                favItems.Push(favCopy)
            end if
        end for
        if favItems.Count() > 0 and items.Count() > 0 then items[0].dividerBefore = true
        combined = []
        combined.Append(favItems)
        combined.Append(items)
        items = combined
        else
        print "ParseJson failed - response was not a valid JSON array"
    end if

    row = {}
    row.title = "All Channels"
    row.children = items

    ' set up a root ContentNode to represent rowList on the GridScreen
    ' (always set, even when empty, so the loading indicator is dismissed)
    contentNode = CreateObject("roSGNode", "ContentNode")
    contentNode.Update({
        children: [row]
    }, true)
    m.top.content = contentNode
end sub

function FetchString(url as String) as String
    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.InitClientCertificates()
    xfer.SetURL(url)
    rsp = xfer.GetToString()
    if rsp = invalid then return ""
    return rsp
end function

function SortItemsByTitle(items as Object) as Object
    ' simple bubble sort by title, case-insensitive
    n = items.Count()
    for i = 0 to n - 2
        for j = 0 to n - 2 - i
            if LCase(items[j].title) > LCase(items[j + 1].title)
                temp = items[j]
                items[j] = items[j + 1]
                items[j + 1] = temp
            end if
        end for
    end for
    return items
end function

' markdown stripper
function StripMarkdown(text as Dynamic) as String
    if text = invalid or type(text) <> "roString" and type(text) <> "String" then return ""
    if text = "" then return ""

    result = text

    result = result.Replace("**", "")
    result = result.Replace("__", "")
    result = result.Replace("*", "")
    result = result.Replace("_", "")
    result = result.Replace("#", "")
    result = result.Replace("`", "")
    result = result.Replace("~~", "")

    guard = 0
    while result.Instr("[") > -1 and result.Instr("](") > -1 and guard < 50
        guard = guard + 1
        startBracket = result.Instr("[")
        midBracket = result.Instr(startBracket, "](")
        if midBracket = -1 then exit while
        endParen = result.Instr(midBracket, ")")
        if endParen = -1 then exit while
        linkText = result.Mid(startBracket + 1, midBracket - startBracket - 1)
        before = result.Left(startBracket)
        after = result.Mid(endParen + 1)
        result = before + linkText + after
    end while

    return result
end function

function GetItemData(channel as Object, descriptions as Object, cacheBuster as String) as Object
    item = {}
    item.title = channel.title
    item.id = channel.id
    item.viewership = channel.viewership

    ' pull the description from the lookup map, if available
    if descriptions[channel.id] <> invalid
        item.description = StripMarkdown(descriptions[channel.id])
    else
        item.description = ""
    end if

    item.hdPosterURL = "https://capture.mistlive.tv/" + channel.id + ".hq.webp?v=" + cacheBuster
    item.icon = ResolveIconUrl(channel.icon)

    ' resolve background UUID if present
    if channel.background <> invalid
        item.backgroundImageUrl = "https://api.mistlive.tv/api/v1.5/image/" + channel.background
    end if

    ' build the HLS stream URL - playlist.m3u8 handles rendition selection automatically
    item.url = "https://watch.mistlive.tv/hls/" + channel.id + "/playlist.m3u8"
    item.streamFormat = "m3u8"

    return item
end function

function ResolveIconUrl(iconUuid as Dynamic) as String
    if iconUuid = invalid then return "pkg:/images/fallback_icon.png"

    url = "https://api.mistlive.tv/api/v1.5/image/" + iconUuid + "?width=256&height=256&fit=inside&format=png"

    rsp = FetchString(url)

    if Len(rsp) > 5
        firstChars = LCase(Left(rsp, 5))
        if firstChars = "<?xml" or firstChars = "<svg "
            return "pkg:/images/fallback_icon.png"
        end if
    end if

    return url
end function
