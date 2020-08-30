--chat.PlaySound()
local NPCINFO = ""
Check = 0


net.Receive("Eye", function(ply, ent)
    local Check = net.ReadBool()
    local NPCHealth = net.ReadUInt(8)

    if (Check) then
        Time = 0

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

        hook.Add("HUDPaint", "DrawFull", function()
            draw.RoundedBox(10, (ScrW() - ScrW()) + 30, (ScrH() / 2) - 300, 100, 150, Color(0, 0, 0, 250))
            draw.SimpleText("Infos:", "Default", (ScrW() - ScrW()) + 65, (ScrH() / 2) - 280, Color(255, 0, 0))
            draw.SimpleText("Kills: 0 ", "Default", (ScrW() - ScrW()) + 40, (ScrH() / 2) - 250, Color(144, 238, 144))
            draw.SimpleText("NPC: " .. NPCINFO, "Default", (ScrW() - ScrW()) + 40, (ScrH() / 2) - 230, Color(144, 238, 144))
            draw.SimpleText("NPC Health: ", "Default", (ScrW() - ScrW()) + 40, (ScrH() / 2) - 210, Color(144, 238, 144))
            draw.SimpleText("Ver. Zeit: 0 ", "Default", (ScrW() - ScrW()) + 40, (ScrH() / 2) - 190, Color(144, 238, 144))
            draw.SimpleText("Level: 1/2 ", "Default", (ScrW() - ScrW()) + 40, (ScrH() / 2) - 170, Color(144, 238, 144))
        end)

        net.Receive("Kills", function()
            local KillCount = net.ReadUInt(4)
            local TimeStartString = net.ReadString()

            timer.Create("Timer0", 0.7, 0, function()
                Time = Time + 1
            end)

            if TimeStartString == "TimeStart" then
                hook.Add("HUDPaint", "DrawFull", function()
                    draw.RoundedBox(10, (ScrW() - ScrW()) + 30, (ScrH() / 2) - 300, 100, 150, Color(0, 0, 0, 250))
                    draw.SimpleText("Kills: " .. KillCount, "Default", (ScrW() - ScrW()) + 40, (ScrH() / 2) - 250, Color(144, 238, 144))
                    draw.SimpleText("Infos:", "Default", (ScrW() - ScrW()) + 65, (ScrH() / 2) - 280, Color(255, 0, 0))
                    draw.SimpleText("NPC: " .. NPCINFO, "Default", (ScrW() - ScrW()) + 40, (ScrH() / 2) - 230, Color(144, 238, 144))
                    draw.SimpleText("NPC Health: " .. NPCHealth, "Default", (ScrW() - ScrW()) + 40, (ScrH() / 2) - 210, Color(144, 238, 144))
                    draw.SimpleText("Ver. Zeit: " .. Time, "Default", (ScrW() - ScrW()) + 40, (ScrH() / 2) - 190, Color(144, 238, 144))
                    draw.SimpleText("Level: 1/2 ", "Default", (ScrW() - ScrW()) + 40, (ScrH() / 2) - 170, Color(144, 238, 144))
                end)

                if KillCount == 6 then
                    timer.Stop("Timer0")
                    net.Start("timeSend")
                    net.WriteUInt(Time, 4)
                    net.SendToServer()
                    timer.Remove("Timer0")
                end
            end
        end)
    end

    return
end)