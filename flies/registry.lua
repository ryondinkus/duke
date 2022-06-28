DukeHelpers.Flies = {}

local flies = {
    include("flies/red"),
    include("flies/soul"),
    include("flies/eternal"),
    include("flies/black"),
    include("flies/golden"),
    include("flies/bone"),
    include("flies/rotten"),
    include("flies/broken"),
    include("flies/ultra"),
    include("flies/fiendish"),
    -- modded
    include("flies/modded/immortal"),
    include("flies/modded/moonlight"),
    include("flies/modded/web"),
    include("flies/modded/doubleWeb"),
    include("flies/modded/patched"),
    include("flies/modded/doublePatched"),
    -- Make sure any fly types that are used by other heart types are registered first
    include("flies/halfRed"),
    include("flies/doubleRed"),
    include("flies/halfSoul"),
    include("flies/scared"),
    include("flies/blended")
}

-- Registers the flies
for _, fly in pairs(flies) do
    fly.pickupSubType = fly.subType
    fly.heartFlySubType = fly.subType
    fly.attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(fly.subType)
    fly.isBase = true

    if fly.use then
        local existingFly = DukeHelpers.Flies[fly.use]
        fly.spritesheet = existingFly.spritesheet
        fly.canAttack = existingFly.canAttack
        fly.heartFlySubType = existingFly.heartFlySubType
        fly.attackFlySubType = existingFly.attackFlySubType
        fly.poofColor = existingFly.poofColor
        fly.sacAltarQuality = existingFly.sacAltarQuality
        fly.isBase = false
    end

    if fly.spritesheet and not fly.use then
        fly.spritesheet = "gfx/familiars/flies/" .. fly.spritesheet
    end

    if fly.uses then
        fly.heartFlySubType = fly.uses
    end

    if fly.callbacks then
        for _, callback in pairs(fly.callbacks) do
            dukeMod:AddCallback(table.unpack(callback))
        end
    end

    if fly.heartFlyDamageMultiplier then
        dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
            if f.SubType == fly.heartFlySubType then
                f.CollisionDamage = f.CollisionDamage * fly.heartFlyDamageMultiplier
            end
        end, DukeHelpers.FLY_VARIANT)
    end

    if fly.attackFlyDamageMultiplier then
        dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
            if f.SubType == fly.attackFlySubType and f.FrameCount == 6 then
                f.CollisionDamage = f.CollisionDamage * fly.attackFlyDamageMultiplier
            end
        end, FamiliarVariant.BLUE_FLY)
    end

    DukeHelpers.Flies[fly.key] = fly

    if not DukeHelpers.HeartKeys[fly.key] then
        DukeHelpers.HeartKeys[fly.key] = fly.key
    end
end
