surface.CreateFont("MainFont", {
    font = "Tahoma",
    size = 29,
    weight = 500,
})

local NPCinfoServer = ""
Check = 0
currLevel = "0"
local TimeString = os.date("%d.%m.%Y - %H:%M:%S", Timestamp)

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

hook.Add("Initialize", "Datei", function()
    if not file.Exists("logsys", "DATA") then
        file.CreateDir("logsys")
        file.Write("logsys/serverlogs.txt", "------------------------ Server Logs ------------------------\n")
        file.Write("logsys/playerlogs.txt", "------------------------ Player Logs ------------------------\n")
    end
end)

hook.Add("HUDPaint", "DrawFull", function()
    draw.RoundedBox(20, 0, 0, 700, 50, Color(0, 0, 0, 250))
    --draw.SimpleText("infoServers:", "MainFont", 15, 10, Color(255, 0, 0))
    draw.SimpleText("Kills: ", "MainFont", 15, 10, Color(192, 192, 192))
    draw.SimpleText("NPC: " .. NPCinfoServer, "MainFont", 140, 10, Color(192, 192, 192))
    -- draw.SimpleText("NPC Health: ", "MainFont", 275, 10, Color(144, 238, 144))
    draw.SimpleText("Ver. Zeit: ", "MainFont", 325, 10, Color(192, 192, 192))
    draw.SimpleText("Level: " .. currLevel, "MainFont", 545, 10, Color(192, 192, 192))
end)

net.Receive("openlogs", function(len)
    local f = file.Open("logsys/serverlogs.txt", "r", "DATA") --- neues file öffnen und schließen
    local f2 = file.Open("logsys/playerlogs.txt", "r", "DATA")
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

    local MainSheet = vgui.Create("DPropertySheet", frame)
    MainSheet:Dock(FILL)

    MainSheet.Paint = function(s, w, h)
        surface.SetDrawColor(105, 105, 105, 230)
        surface.DrawRect(12, 0, 0, w, h)
    end

    local LogsList1 = vgui.Create("DScrollPanel", frame)
    LogsList1:Dock(FILL)
    local LogsList2 = vgui.Create("DScrollPanel", frame)
    LogsList2:Dock(FILL)
    local sbar = LogsList1:GetVBar() --ScrollBar Farben
    MainSheet:AddSheet("ServerLogs", LogsList1, "icon16/book.png", false, false, "Server Logs")
    MainSheet:AddSheet("PlayerLogs", LogsList2, "icon16/book.png", false, false, "Player Things")

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

    local infoServer = vgui.Create("DLabel", LogsList1)
    infoServer:SetPos(10, -190)
    infoServer:SetSize(700, 900)
    infoServer:SetTextColor(Color(192, 192, 192))
    infoServer:SetText(f:Read(f:Size()))

    infoServer.OnDepressed = function(s)
        LogsList1:CopySelected()
    end

    local infoPly = vgui.Create("DLabel", LogsList2)
    infoPly:SetPos(10, -190)
    infoPly:SetSize(700, 900)
    infoPly:SetTextColor(Color(192, 192, 192))
    infoPly:SetText(f2:Read(f2:Size()))

    infoPly.OnDepressed = function(s)
        LogsList2:CopySelected()
    end

    local ClosButton = vgui.Create("DButton", frame)
    ClosButton:SetText("Close")
    ClosButton:SetPos(510, 6)
    ClosButton:SetSize(50, 30)

    ClosButton.DoClick = function()
        frame:Close()
        print(f:Read(f:Size()))
        print(f2:Read(f2:Size()))
        f:Close()
        f2:Close()
    end

    if frame:OnClose() then
        print("Test")
        --surface.SetDrawColor(255, 0, 0, 255)
        --surface.DrawLine(0, 20, 50, 50)
    end
end)

zwischen = 0.0

net.Receive("SendLogs", function(len, ply)
    local str = net.ReadString()

    if str == "PlayerInitial" then
        file.Append("logsys/playerlogs.txt", "\n[ " .. TimeString .. "] " .. LocalPlayer():Name() .. "" .. " (" .. LocalPlayer():SteamID() .. ") hat sich auf den Server verbunden.\n")
    elseif str == "NPCSpawns" then
        file.Append("logsys/serverlogs.txt", "[ " .. TimeString .. "] NPC Spawned\n")
    elseif str == "PropSpawn" then
        file.Append("logsys/serverlogs.txt", "[ " .. TimeString .. "] Prop successfully Spawned\n")
    elseif str == "PlayerDC" then
        file.Append("logsys/playerlogs.txt", LocalPlayer():Name() .. "Hat den Server verlassen")
    end
end)

net.Receive("Eye", function(ply, len, ent)
    local Check = net.ReadBool()

    --local NPCHealth = net.ReadUInt(8) -- Nein
    if (Check) then
        Time = 0.0

        hook.Add("Think", "EyeSightThink", function()
            local EyeSight = LocalPlayer():GetEyeTrace()

            if EyeSight.Entity:GetClass() == "npc_kleiner" then
                NPCinfoServer = "kleiner"
            elseif EyeSight.Entity:GetClass() == "npc_vortigaunt" then
                NPCinfoServer = "alien"
            elseif EyeSight.Entity:GetClass() == "npc_eli" then
                NPCinfoServer = "eli"
            elseif EyeSight.Entity:GetClass() == "npc_gman" then
                NPCinfoServer = "gman"
            elseif EyeSight.Entity:GetClass() == "npc_breen" then
                NPCinfoServer = "breen"
            else
                NPCinfoServer = "none"
            end
        end)

        net.Receive("Kills", function(len)
            LocalPlayer():EmitSound("death")
            local KillCount = net.ReadUInt(4)
            local TimeStartString = net.ReadString()

            if KillCount == 1 then
                timer.Create("Timer0", 0.1, 0, function()
                    Time = Time + 0.1
                end)
            end

            if TimeStartString == "TimeStart" then
                currLevel = "1/1"

                -- + 135 x-Achse
                hook.Add("HUDPaint", "DrawFull", function()
                    draw.RoundedBox(20, 0, 0, 700, 50, Color(0, 0, 0, 250))
                    -- draw.SimpleText("infoServers:", "MainFont", ScrW() - 120, (ScrH() / 2) - 280, Color(255, 0, 0))
                    draw.SimpleText("Kills: " .. KillCount, "MainFont", 15, 10, Color(192, 192, 192))
                    draw.SimpleText("NPC: " .. NPCinfoServer, "MainFont", 140, 10, Color(192, 192, 192))
                    -- draw.SimpleText("NPC Health: " .. NPCHealth, "MainFont", 275, 10, Color(144, 238, 144))
                    draw.SimpleText("Ver. Zeit: " .. Time, "MainFont", 325, 10, Color(192, 192, 192))
                    draw.SimpleText("Level: " .. currLevel, "MainFont", 545, 10, Color(192, 192, 192))
                end)

                if KillCount == 6 then
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
