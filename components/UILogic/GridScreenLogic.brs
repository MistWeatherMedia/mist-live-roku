' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Note that we need to import this file in MainScene.xml using relative path.

sub ShowGridScreen()
    m.GridScreen = CreateObject("roSGNode", "GridScreen")
    m.GridScreen.ObserveField("rowItemSelected", "OnGridScreenItemSelected")
    ShowScreen(m.GridScreen) ' show GridScreen
end sub

sub OnGridScreenItemSelected(event as Object)
    grid = event.GetRoSGNode()
    m.selectedIndex = event.GetData()
    rowContent = grid.content.GetChild(m.selectedIndex[0])
    itemIndex = m.selectedIndex[1]

    chosen = rowContent.GetChild(itemIndex)
    if chosen <> invalid and chosen.id = "__add__"
        ShowChannelIdDialog("", "")
        return
    end if

    ShowVideoScreen(rowContent, itemIndex)
end sub