AddCSLuaFile("cl_gamemode.lua")
--resource.AddWorkshop("128089118") --M9K Weapons
local roundStat = 0
--local Currt = CurTime()
local IsSpawning = false
local NpcCount = 5
local NPCSpawnPos = Vector(-291.418976, -370.939667, -83.968750)

hook.Add("PlayerSay", "StartCommand", function(ply, text, ent)
    if string.lower(text) == "!s" and ply:Team() ~= TEAM_SHOOTER then
        ply:changeTeam(TEAM_SHOOTER, true)
        roundStat = 1
        IsSpawning = true
        ply:ChatPrint("Das Spiel geht los!")
        ply:SelectWeapon("weapon_acr")
    elseif ply:Team() == TEAM_SHOOTER then
        roundStat = 1
        IsSpawning = true
        ply:ChatPrint("Das Spiel geht los!")
        ply:SelectWeapon("weapon_acr")
    end

    --table.Count(team.GetPlayers(11))
    --print(roundStat .. "")
    function Start()
        if roundStat == 1 and IsSpawning then
            timer.Create("NpcSpawn", 1, 5, function()
                ply:ChatPrint("NPC Spawned")
                local NPC = ents.Create("npc_kleiner")
                NPC:SetPos(NPCSpawnPos)
                NPC:DropToFloor()
                NPC:Spawn()
                NpcCount = NpcCount - 1
            end)

            if NpcCount == 0 then
                ply:ChatPrint("Aus")
                IsSpawning = false
                roundStat = 0
                timer.Remove("NpcSpawn")
            end
        end
    end

    Start()
end)