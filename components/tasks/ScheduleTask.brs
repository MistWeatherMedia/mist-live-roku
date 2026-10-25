' Fetches one channel's schedule from the Mist Live API and returns it as clean, epoch-based program data.
' Usage: set channelId, observe "result", then set control = "run".
' result = { channelId, fetchedAt, programs: [ { title, subtitle, rating, startSecs, endSecs }, ... ] }
' A channel with no schedule (or a failed request) still returns a result, with an empty programs array.

sub Init()
    m.top.functionName = "FetchSchedule"
end sub

sub FetchSchedule()
    channelId = m.top.channelId
    programs = []

    xfer = CreateObject("roURLTransfer")
    xfer.SetCertificatesFile("common:/certs/ca-bundle.crt")
    xfer.InitClientCertificates()
    xfer.SetURL("https://api.mistlive.tv/api/v1.5/channel/" + xfer.Escape(channelId) + "/schedule")
    rsp = xfer.GetToString()

    if rsp <> invalid and rsp <> ""
        json = ParseJson(rsp)
        if json <> invalid and Type(json) = "roArray"
            dt = CreateObject("roDateTime")
            for each p in json
                if Type(p) = "roAssociativeArray"
                    ' bracket access: "end" is a reserved word in BrightScript
                    startSecs = ParseEPGTime(dt, p["start"])
                    endSecs = ParseEPGTime(dt, p["end"])
                    if startSecs > 0 and endSecs > startSecs
                        programs.Push({
                            title: EPGStr(p["title"]),
                            subtitle: EPGStr(p["subtitle"]),
                            rating: EPGStr(p["rating"]),
                            startSecs: startSecs,
                            endSecs: endSecs
                        })
                    end if
                end if
            end for
        end if
    end if

    print "[EPG] "; channelId; ": "; programs.Count(); " programs"
    m.top.result = {
        channelId: channelId,
        fetchedAt: CreateObject("roDateTime").AsSeconds(),
        programs: programs
    }
end sub

' "2026-10-25T17:58:56Z" -> epoch seconds (UTC); 0 if it can't be parsed
function ParseEPGTime(dt as Object, iso as Dynamic) as Integer
    if Type(iso) <> "roString" and Type(iso) <> "String" then return 0
    dt.FromISO8601String(iso)
    return dt.AsSeconds()
end function

function EPGStr(v as Dynamic) as String
    if Type(v) = "roString" or Type(v) = "String" then return v
    return ""
end function
