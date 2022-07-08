local Names = {
    en_us = "Tapeworm Card",
    spa = "Tarjeta de Tenia"
}
local Name = Names.en_us
local Tag = "tapewormCard"
local Id = Isaac.GetCardIdByName(Name)
local Descriptions = {
    en_us = "Yummy in YOUR tummy",
    spa = "Delicioso en TU barriga"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Yummy in YOUR tummy.")

local function MC_USE_CARD(_, card, player, flags)
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
