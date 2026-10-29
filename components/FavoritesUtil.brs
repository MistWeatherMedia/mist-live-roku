' Imported by MainScene.xml (player overlay toggles favorites) and MainLoaderTask.xml (grid ordering):
'   <script type="text/brightscript" uri="FavoritesUtil.brs" />   (path relative to that XML file)

function IsFavorite(channelId as String) as Boolean
    if channelId = "" then return false
    sec = CreateObject("roRegistrySection", "favorites")
    return sec.Exists(channelId)
end function

sub SetFavorite(channelId as String, isOn as Boolean)
    if channelId = "" then return
    sec = CreateObject("roRegistrySection", "favorites")
    if isOn
        sec.Write(channelId, "1")
    else
        sec.Delete(channelId)
    end if
    sec.Flush()
end sub
