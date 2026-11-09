sub Init()
    m.top.functionName = "CheckChannel"
end sub

sub CheckChannel()
    channelId = m.top.channelId
    ok = false

    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.InitClientCertificates()
    xfer.SetURL("https://watch.mistlive.tv/hls/" + xfer.Escape(channelId) + "/playlist.m3u8")
    rsp = xfer.GetToString()

    if rsp <> invalid and rsp <> ""
        if Instr(1, Left(rsp, 64), "#EXTM3U") > 0 then ok = true
    end if

    print "[PRIVATE] check "; channelId; " -> "; ok
    m.top.result = { channelId: channelId, ok: ok }
end sub
