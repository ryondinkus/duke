local Names = {
    en_us = "Duke's Tooth",
    spa = "Diente de Duque"
}
local Name = Names.en_us
local Tag = "dukesTooth"
local Id = Isaac.GetTrinketIdByName(Name)
local Descriptions = {
    en_us = "Nom Nom Nom",
    spa = "Nom Nom Nom"
}
local WikiDescription = "Nom Nom Nom"--helper.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function MC_POST_NEW_ROOM()
    if DukeHelpers.AreEnemiesInRoom() then
        DukeHelpers.ForEachPlayer(function(player)
            if player:HasTrinket(Id) then
                DukeHelpers.SpawnAttackFlyBySubType(DukeHelpers.GetWeightedFly(DukeHelpers.rng, true).heartFlySubType, player.Position, player)
            end
        end)
    end
end

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
	Id = Id,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    callbacks = {
        {
            ModCallbacks.MC_POST_NEW_ROOM,
            MC_POST_NEW_ROOM
        }
    }
}
