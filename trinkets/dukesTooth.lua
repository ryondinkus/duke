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
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "Grants the player a random Heart Attack Fly at the start of each active room.",
        "- Heart Attack Flies can be one of six types: Red, Soul, Black, Gold, Bone, and Rotten. Red and Soul flies are twice as likely to be selected.",
    },
    {
        "Synergies",
        "Hive Mind: Heart Attack Flies spawned will deal 2x damage.",
    },
    {
        "Trivia",
        "This would've been the only wiki page to not have trivia, but I added this just now."
    }
})

local function MC_POST_NEW_ROOM()
    if DukeHelpers.Trinkets.dukesTooth.IsUnlocked() then
        if DukeHelpers.AreEnemiesInRoom() then
            DukeHelpers.ForEachPlayer(function(player)
                if player:HasTrinket(Id) then
                    for i = 1, player:GetTrinketMultiplier(Id) do
                        DukeHelpers.SpawnAttackFlyFromHeartFly(DukeHelpers.GetWeightedFly(DukeHelpers.rng, true),
                            player.Position, player)
                    end
                end
            end)
        end
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
