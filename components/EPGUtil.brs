' Shared EPG helpers. Imported by MainScene.xml (video overlay) and GridScreen.xml (details panel).
' <script type="text/brightscript" uri="pkg:/components/EPGUtil.brs" />

function ScheduleNowNext(programs as Object, nowSecs as Integer) as Object
    found = { nowProg: invalid, upNext: invalid }
    for each p in programs
        if p.endSecs > nowSecs
            if p.startSecs <= nowSecs
                if found.nowProg = invalid then found.nowProg = p
            else
                found.upNext = p
                exit for
            end if
        end if
    end for
    return found
end function

function EPGLines(programs as Object, nowSecs as Integer) as Object
    epg = { nowText: "", nextText: "" }
    nn = ScheduleNowNext(programs, nowSecs)

    if nn.nowProg <> invalid
        label = nn.nowProg.title
        if nn.nowProg.subtitle <> "" and nn.nowProg.subtitle <> nn.nowProg.title
            label = label + ": " + nn.nowProg.subtitle
        end if
        epg.nowText = "Now: " + label + "  (until " + FormatEPGTime(nn.nowProg.endSecs) + ")"
    end if

    if nn.upNext <> invalid
        epg.nextText = "Next: " + nn.upNext.title + "  (" + FormatEPGTime(nn.upNext.startSecs) + ")"
    end if

    return epg
end function

function FormatEPGTime(secs as Integer) as String
    dt = CreateObject("roDateTime")
    dt.FromSeconds(secs)
    dt.ToLocalTime()
    hours = dt.GetHours()
    suffix = "AM"
    if hours >= 12 then suffix = "PM"
    hours = hours MOD 12
    if hours = 0 then hours = 12
    mins = dt.GetMinutes()
    minStr = mins.ToStr()
    if mins < 10 then minStr = "0" + minStr
    return hours.ToStr() + ":" + minStr + " " + suffix
end function
