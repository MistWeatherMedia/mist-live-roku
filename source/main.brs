' ********** Copyright 2020 Roku Corp.  All Rights Reserved. **********

' Channel entry point

sub Main(args as Dynamic) as Void
    ShowChannelRSGScreen(args)
end sub

sub ShowChannelRSGScreen(args as Dynamic)
    ' The roSGScreen object is a SceneGraph canvas that displays the contents of a Scene node instance
    screen = CreateObject("roSGScreen")
    ' message port is the place where events are sent
    m.port = CreateObject("roMessagePort")
    ' sets the message port which will be used for events from the screen
    screen.SetMessagePort(m.port)

    ' roInput object is required to receive roInputEvent (deep-link/ECP) events
    input = CreateObject("roInput")
    input.SetMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    scene.ObserveField("exitApp", m.port) ' the sleep timer sets this to close the channel
    screen.Show() ' Init method in MainScene.brs is invoked
    scene.signalBeacon("AppLaunchComplete")

    if args <> invalid
        if args.contentId <> invalid or args.mediaType <> invalid
            scene.deepLinkArgs = args
        end if
    end if

    ' event loop
    while(true)
        ' waiting for events from screen
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.IsScreenClosed() then return
        else if msgType = "roSGNodeEvent"
            ' the scene asked to close the channel (sleep timer)
            if msg.GetField() = "exitApp" then return
        else if msgType = "roInputEvent"
            if msg.IsInput()
                info = msg.GetInfo()
                if info <> invalid and info.contentId <> invalid
                    scene.deepLinkArgs = info
                end if
            end if
        end if
    end while
end sub
