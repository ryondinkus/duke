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
    -- Make sure any fly types that are used by other heart types are registered first
    include("flies/halfRed"),
    include("flies/doubleRed"),
    include("flies/halfSoul"),
    include("flies/scared"),
    include("flies/blended"),
    --modded
    include("flies/modded/patched"),
    include("flies/modded/doublePatched")
}

-- Registers the flies
for _, fly in pairs(flies) do
    local newFly = {
        key = fly.key,
        spritesheet = fly.spritesheet,
        canAttack = fly.canAttack,
        pickupSubType = fly.subType,
        heartFlySubType = fly.subType,
        attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(fly.subType),
        fliesCount = fly.fliesCount,
        weight = fly.weight,
        sfx = fly.sfx,
        poofColor = fly.poofColor,
        sacAltarQuality = fly.sacAltarQuality,
        baseFly = true
    }

    if fly.useFly then
        local existingFly = DukeHelpers.Flies[fly.useFly]
        newFly.spritesheet = existingFly.spritesheet
        newFly.canAttack = existingFly.canAttack
        newFly.heartFlySubType = existingFly.heartFlySubType
        newFly.attackFlySubType = existingFly.attackFlySubType
        newFly.poofColor = existingFly.poofColor
        newFly.sacAltarQuality = existingFly.sacAltarQuality
        newFly.baseFly = false
    end

    if fly.spritesheet then
        newFly.spritesheet = "gfx/familiars/flies/" .. fly.spritesheet
        print(fly.spritesheet)
    end

    if fly.useFlies then
        newFly.heartFlySubType = fly.useFlies
    end

    if fly.callbacks then
        for _, callback in pairs(fly.callbacks) do
            dukeMod:AddCallback(table.unpack(callback))
        end
    end

    DukeHelpers.Flies[fly.key] = newFly
end
