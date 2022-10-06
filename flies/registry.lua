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
    include("flies/blended"),

    include("flies/modded/repPlus/broken"),
    include("flies/modded/repPlus/dauntless"),
    include("flies/modded/repPlus/hoarded"),
    include("flies/modded/repPlus/soiled"),
    include("flies/modded/repPlus/curdled"),
    include("flies/modded/repPlus/baleful"),
    include("flies/modded/repPlus/harlot"),
    include("flies/modded/repPlus/miser"),
    include("flies/modded/repPlus/empty"),
    include("flies/modded/repPlus/zealot"),
    include("flies/modded/repPlus/deserted"),
    include("flies/modded/repPlus/halfDauntless"),

    include("flies/modded/fiendFolio/halfBlack"),
    include("flies/modded/fiendFolio/blendedBlack"),
    include("flies/modded/fiendFolio/immoral"),
    include("flies/modded/fiendFolio/halfImmoral"),
    include("flies/modded/fiendFolio/blendedImmoral"),
    include("flies/modded/fiendFolio/morbid"),
    include("flies/modded/fiendFolio/thirdMorbid"),
    include("flies/modded/fiendFolio/twoThirdsMorbid"),

}

-- Registers the flies
for _, fly in pairs(flies) do
    if fly.heart then
        if not fly.key then
            fly.key = fly.heart.key
        end

        fly.pickupVariant = fly.heart.variant
        fly.pickupSubType = fly.heart.subType

        if fly.pickupVariant ~= PickupVariant.PICKUP_HEART then
            fly.heartFlySubType = fly.pickupVariant
        else
            fly.heartFlySubType = fly.pickupSubType
        end

        fly.attackFlySubType = DukeHelpers.OffsetIdentifier(fly.heart)
    else
        fly.heartFlySubType = fly.subType
        fly.attackFlySubType = DukeHelpers.OffsetIdentifier({ subType = fly.subType })
    end

    fly.isBase = not fly.use and not fly.uses

    if fly.use then
        local existingFly = DukeHelpers.Flies[fly.use.key or fly.use.heart.key]
        fly.spritesheet = existingFly.spritesheet
        fly.canAttack = existingFly.canAttack
        fly.heartFlySubType = existingFly.heartFlySubType
        fly.attackFlySubType = existingFly.attackFlySubType
        fly.poofColor = existingFly.poofColor
        fly.sacAltarQuality = existingFly.sacAltarQuality
    end

    if fly.spritesheet and fly.isBase then
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
end
