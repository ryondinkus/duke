local function HEART_FLY_PRE_SPAWN_CLEAN_AWARD()
    if ComplianceImmortal then
        DukeHelpers.ForEachPlayer(function(player)
            local playerData = DukeHelpers.GetDukeData(player)
            local immortalFlies = DukeHelpers.CountByProperties(playerData.heartFlies,
                { key = DukeHelpers.Flies.IMMORTAL.key })
            if immortalFlies % 2 == 1 then
                DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.IMMORTAL, 1)
            end
        end)
    end
end

return {
    spritesheet = "immortal_heart_fly.png",
    canAttack = true,
    heart = DukeHelpers.Hearts.IMMORTAL,
    count = 2,
    weight = 0,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.78, 1),
    sacAltarQuality = 3,
    sfx = Isaac.GetSoundIdByName("immortal"),
    callbacks = {
        {
            ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
            HEART_FLY_PRE_SPAWN_CLEAN_AWARD
        }
    },
    heartFlyDamageMultiplier = 1.3,
    attackFlyDamageMultiplier = 1.3
}
