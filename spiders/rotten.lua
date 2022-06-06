local key = "SPIDER_ROTTEN"
local pickupSubType = HeartSubType.HEART_ROTTEN
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
    if f.SubType == subType then
        if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
            e:AddPoison(EntityRef(f), 102, 1)
        end
    end
end

local function applyTearEffects(tear)
    local function tearCollision(_, t)
        if tear.InitSeed == t.InitSeed then
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, t.Position, Vector.Zero, t)
            dukeMod:RemoveCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, tearCollision, tear.Variant)
        end
    end

    dukeMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, tearCollision, tear.Variant)
end

return {
    key = key,
    spritesheet = "rotten_heart_spider.png",
    pickupSubType = pickupSubType,
    count = 1,
    weight = 1,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.20, 0),
    sfx = SoundEffect.SOUND_ROTTEN_HEART,
    callbacks = {
        {
            ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
            MC_PRE_FAMILIAR_COLLISION,
            FamiliarVariant.BLUE_SPIDER
        }
    },
    applyTearEffects = applyTearEffects,
    tearDamageMultiplier = 1.5
}
