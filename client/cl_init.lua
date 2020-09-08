surface.CreateFont("MainFont", {
    font = "Arial",
    size = 29,
    weight = 500,
})

local NPCINFO = ""
Check = 0
currLevel = "0"

sound.Add({
    name = "death",
    channel = CHAN_STATIC,
    volume = 120.0,
    level = 100,
    pitch = {95, 110},
    sound = "vehicles/enzo/cringe.wav"
})

sound.Add({
    name = "level",
    channel = CHAN_STATIC,
    volume = 120.0,
    level = 100,
    pitch = {95, 110},
    sound = "vehicles/enzo/levelup.wav"
})

hook.Add("HUDPaint", "DrawFull", function()
    draw.RoundedBox(20, 0, 0, 700, 50, Color(0, 0, 0, 250))
    --draw.SimpleText("Infos:", "MainFont", 15, 10, Color(255, 0, 0))
    draw.SimpleText("Kills: ", "MainFont", 15, 10, Color(192, 192, 192))
    draw.SimpleText("NPC: " .. NPCINFO, "MainFont", 140, 10, Color(192, 192, 192))
    -- draw.SimpleText("NPC Health: ", "MainFont", 275, 10, Color(144, 238, 144))
    draw.SimpleText("Ver. Zeit: ", "MainFont", 325, 10, Color(192, 192, 192))
    draw.SimpleText("Level: " .. currLevel, "MainFont", 545, 10, Color(192, 192, 192))
end)

net.Receive("openlogs", function(len)
    local f = file.Open("logsys/logs.txt", "r", "DATA")
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 430)
    frame:Center()
    frame:SetVisible(true)
    frame:MakePopup()
    frame:SetTitle("Logs")
    frame:ShowCloseButton(false)

    frame.Paint = function(s, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(10, 10, 10, 230))
        draw.RoundedBox(12, 2, 2, w - 4, h - 4, Color(0, 0, 0, 100))
    end

    local LogsList1 = vgui.Create("DScrollPanel", frame)
    LogsList1:Dock(FILL)
    local sbar = LogsList1:GetVBar() --ScrollBar Farben

    function sbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
    end

    function sbar.btnUp:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255))
    end

    function sbar.btnDown:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 255, 255))
    end

    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(10, 10, 10))
    end

    local Info = vgui.Create("DLabel", LogsList1)
    Info:SetPos(10, 10)
    Info:SetSize(700, 500)
    Info:SetTextColor(Color(255, 0, 0))
    Info:SetText(file.Read("logsys/logs.txt", "DATA"))
    local ClosButton = vgui.Create("DButton", frame)
    ClosButton:SetText("Close")
    ClosButton:SetPos(510, 6)
    ClosButton:SetSize(50, 30)

    ClosButton.DoClick = function()
        frame:Close()
        print(f:Read(f:Size()))
        f:Close()
    end

    if frame:OnClose() then
        print("Test")
        --surface.SetDrawColor(255, 0, 0, 255)
        --surface.DrawLine(0, 20, 50, 50)
    end
end)

zwischen = 0.0

function timee()
    print("drinne")

    if zwischen >= Time then
        print("Bei der operation drinne")

        hook.Add("HUDPaint", "DrawHighscore", function()
            draw.RoundedBox(20, ScrW() - 500, 0, 500, 50, Color(0, 0, 0, 250))
            draw.SimpleText("Aktuelle Bestzeit: " .. Time, "MainFont", ScrW() - 450, 10, Color(169, 169, 169))
        end)
    end
end

net.Receive("Eye", function(ply, ent)
    local Check = net.ReadBool()

    --local NPCHealth = net.ReadUInt(8) -- Nein
    if (Check) then
        Time = 0.0

        hook.Add("Think", "EyeSightThink", function()
            local EyeSight = LocalPlayer():GetEyeTrace()

            if EyeSight.Entity:GetClass() == "npc_kleiner" then
                NPCINFO = "kleiner"
            elseif EyeSight.Entity:GetClass() == "npc_vortigaunt" then
                NPCINFO = "alien"
            elseif EyeSight.Entity:GetClass() == "npc_eli" then
                NPCINFO = "eli"
            elseif EyeSight.Entity:GetClass() == "npc_gman" then
                NPCINFO = "gman"
            elseif EyeSight.Entity:GetClass() == "npc_breen" then
                NPCINFO = "breen"
            else
                NPCINFO = "none"
            end
        end)

        net.Receive("Kills", function(len)
            LocalPlayer():EmitSound("death")
            local KillCount = net.ReadUInt(4)
            local TimeStartString = net.ReadString()

            if KillCount == 1 then
                timer.Create("Timer0", 0.1, 0, function()
                    Time = Time + 0.1
                    zwischen = zwischen + 0.1
                end)
            end

            if TimeStartString == "TimeStart" then
                currLevel = "1/1"

                -- + 135 x-Achse
                hook.Add("HUDPaint", "DrawFull", function()
                    draw.RoundedBox(20, 0, 0, 700, 50, Color(0, 0, 0, 250))
                    -- draw.SimpleText("Infos:", "MainFont", ScrW() - 120, (ScrH() / 2) - 280, Color(255, 0, 0))
                    draw.SimpleText("Kills: " .. KillCount, "MainFont", 15, 10, Color(192, 192, 192))
                    draw.SimpleText("NPC: " .. NPCINFO, "MainFont", 140, 10, Color(192, 192, 192))
                    -- draw.SimpleText("NPC Health: " .. NPCHealth, "MainFont", 275, 10, Color(144, 238, 144))
                    draw.SimpleText("Ver. Zeit: " .. Time, "MainFont", 325, 10, Color(192, 192, 192))
                    draw.SimpleText("Level: " .. currLevel, "MainFont", 545, 10, Color(192, 192, 192))
                end)

                if KillCount == 6 then
                    timee(Time, zwischen)
                    LocalPlayer():EmitSound("level")
                    timer.Stop("Timer0")
                    net.Start("timeSend")
                    net.WriteFloat(Time)
                    net.SendToServer()
                    timer.Remove("Timer0")
                    KillCount = 0
                    currLevel = "0"
                end
            end
        end)
    end
end)

hook.Add("HUDPaint", "DrawHighscore", function()
    draw.RoundedBox(20, ScrW() - 500, 0, 500, 50, Color(0, 0, 0, 250))
    draw.SimpleText("Aktuelle Bestzeit: 0", "MainFont", ScrW() - 450, 10, Color(169, 169, 169))
end)

--draw.SimpleText("Aktuelle Bestzeit: " .. PreTime, "MainFont",
hook.Add("Initialize", "Datei", function()
    if not file.Exists("logsys", "DATA") then
        file.CreateDir("logsys")
        file.Write("logsys/logs.txt", "------------------------ Log System ------------------------\n")
    end
end)
