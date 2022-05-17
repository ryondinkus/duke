local key = "FLY_IMMORTAL" -- From Team Compliance Immortal Heart Mod
local subType = HeartSubType.HEART_IMMORTAL
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

local function ATTACK_FLY_MC_FAMILIAR_UPDATE_ATTACK(_, f)
    if f.SubType == attackFlySubType then
        if f.FrameCount == 6 then
            f.CollisionDamage = f.CollisionDamage * 1.3
        end
    end
end

local function HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK(_, f)
    if f.SubType == subType then
        f.CollisionDamage = f.CollisionDamage * 1.3
    end
end

local function HEART_FLY_PRE_SPAWN_CLEAN_AWARD()
    DukeHelpers.ForEachPlayer(function(player)
        local playerData = DukeHelpers.GetDukeData(player)
        local immortalFlies = DukeHelpers.CountByProperties(playerData.heartFlies, { subType = DukeHelpers.Flies.FLY_IMMORTAL.heartFlySubType })
        if immortalFlies % 2 == 1 then
            DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.FLY_IMMORTAL, 1)
        end
    end)
end

return {
    key = key,
    spritesheet = "gfx/familiars/immortal_heart_fly.png",
    canAttack = true,
    subType = subType,
    fliesCount = 2,
    weight = 0,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.78, 1),
    sacAltarQuality = 3,
    sfx = Isaac.GetSoundIdByName("immortal"),
    callbacks = {
        {
            ModCallbacks.MC_FAMILIAR_UPDATE,
            ATTACK_FLY_MC_FAMILIAR_UPDATE_ATTACK,
            FamiliarVariant.BLUE_FLY
        },
        {
            ModCallbacks.MC_FAMILIAR_UPDATE,
            HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK,
            DukeHelpers.FLY_VARIANT
        },
        {
            ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
            HEART_FLY_PRE_SPAWN_CLEAN_AWARD
        }
    }
}
