local heart = DukeHelpers.Hearts.ROTTEN
local subType = DukeHelpers.OffsetIdentifier(heart)

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
            dukeMod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, tearCollision)
        end
    end

    dukeMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, tearCollision)
end

return {
    spritesheet = "rotten_heart_spider.png",
    heart = heart,
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
    tearDamageMultiplier = 1.5,
    tearColor = Color(1, 0.2, 0.2, 1, 0, 0.1, 0),
    uiHeart = {
        animationName = "RottenHeartFull"
    }
}
