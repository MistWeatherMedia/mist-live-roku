' Copyright (c) 2020 Roku, Inc. All rights reserved.

sub Init()
    poster = m.top.FindNode("poster")
    poster.ObserveField("loadStatus", "OnPosterLoadStatusChange")
end sub

sub OnContentSet()
    content = m.top.itemContent
    ' set poster uri if content is valid
    if content <> invalid 
        m.top.FindNode("poster").uri = content.icon
        m.top.FindNode("divider").visible = (content.dividerBefore = true)
    end if
end sub

sub OnPosterLoadStatusChange()
    poster = m.top.FindNode("poster")
    if poster.loadStatus = "failed"
        poster.uri = "pkg:/images/fallback_icon.png"
    end if
end sub