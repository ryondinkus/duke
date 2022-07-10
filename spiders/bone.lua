local heart = DukeHelpers.Hearts.BONE
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_POST_ENTITY_REMOVE(_, e)
    if e.Variant == FamiliarVariant.BLUE_SPIDER and e.SubType == subType then
        Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_SPUR, 0, e.Position, Vector.Zero, e)
    end
end

local function applyTearEffects(tear)
    tear:ChangeVariant(TearVariant.BONE)
    tear:AddTearFlags(TearFlags.TEAR_BONE)
end

return {
    spritesheet = "bone_heart_spider.png",
    heart = heart,
    count = 1,
    weight = 1,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0.59, 0.59, 0.59),
    sfx = SoundEffect.SOUND_BONE_HEART,
    callbacks = {
        {
            ModCallbacks.MC_POST_ENTITY_REMOVE,
            MC_POST_ENTITY_REMOVE,
            EntityType.ENTITY_FAMILIAR
        }
    },
    damageMultiplier = 1.3,
    applyTearEffects = applyTearEffects,
    tearDamageMultiplier = 2,
    uiHeart = {
        animationName = "BoneHeartEmpty"
    }
}
