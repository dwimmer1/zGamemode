--chat.PlaySound()
net.Receive("Eye", function()
    local ply = LocalPlayer()
    local EyeSight = ply:GetEyeTrace()

    if EyeSight.Entity:GetClass() == "npc_kleiner" then
        ply:ChatPrint("KLEINER ANGESCHAUT")
    end
end)
--print( Entity( 1 ):GetEyeTrace().Entity )