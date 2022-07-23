local Names = {
    en_us = "Tapeworm Card",
    spa = "Tarjeta de Tenia"
}
local Name = Names.en_us
local Tag = "tapewormCard"
local Id = Isaac.GetCardIdByName(Name)
local Descriptions = {
    en_us = "Turns all enemies in the room into random Heart Orbital Flies#Flies can be one of six random types: {{Heart}}Red, {{SoulHeart}}Soul, {{BlackHeart}}Black, {{GoldenHeart}}Gold, {{EmptyBoneHeart}}Bone, or {{RottenHeart}}Rotten",
    spa = "Delicioso en TU barriga"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "On use, turns all enemies in the room into random Heart Orbital Flies. These types can be Red, Soul, Black, Golden, Bone, and Rotten, with Red and Blue being twice as likely to spawn."
    }
})

local function MC_USE_CARD(_, card, player, flags)
    if DukeHelpers.Cards.tapewormCard.IsUnlocked() then
        local enemies = DukeHelpers.ListEnemiesInRoom(true,
            function(entity) return not EntityRef(entity).IsCharmed and not entity:IsBoss() end)

        for _, enemy in pairs(enemies) do
            local randomFly = DukeHelpers.GetWeightedFly()
            DukeHelpers.AddHeartFly(player, randomFly, 1)
            DukeHelpers.SpawnHeartFlyPoof(randomFly, enemy.Position, player)
            enemy:Remove()
        end
        DukeHelpers.sfx:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0)
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
            ModCallbacks.MC_USE_CARD,
            MC_USE_CARD,
            Id
        }
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.GREED, Tag, DukeHelpers.DUKE_NAME)
}
