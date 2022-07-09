local Names = {
    en_us = "Duke's Tooth",
    spa = "Diente de Duque"
}
local Name = Names.en_us
local Tag = "dukesTooth"
local Id = Isaac.GetTrinketIdByName(Name)
local Descriptions = {
    en_us = "Spawns a Heart Attack Fly of a random type when entering an active room#Flies can be one of six random types: {{Heart}}Red, {{SoulHeart}}Soul, {{BlackHeart}}Black, {{GoldenHeart}}Gold, {{EmptyBoneHeart}}Bone, or {{RottenHeart}}Rotten",
    spa = "Nom Nom Nom"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Nom Nom Nom")

local function MC_POST_NEW_ROOM()
    if DukeHelpers.AreEnemiesInRoom() then
        DukeHelpers.ForEachPlayer(function(player)
            if player:HasTrinket(Id) then
                for i = 1, player:GetTrinketMultiplier(Id) do
                    DukeHelpers.SpawnAttackFlyBySubType(DukeHelpers.GetWeightedFly(DukeHelpers.rng, true).heartFlySubType, player.Position, player)
                end
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
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.ISAAC, Tag, DukeHelpers.DUKE_NAME)
}
