local key = "SPIDER_BONE"
local pickupSubType = HeartSubType.HEART_BONE
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

local function MC_POST_NPC_DEATH(_, e)
    if e.Variant == FamiliarVariant.BLUE_SPIDER and e.SubType == subType then
        Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_SPUR, 0, e.Position, Vector.Zero, e)
    end
end

return {
    key = key,
    spritesheet = "gfx/familiars/bone_heart_spider.png",
    pickupSubType = pickupSubType,
    count = 1,
    weight = 1,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0.59, 0.59, 0.59),
    sfx = SoundEffect.SOUND_BONE_HEART,
    callbacks = {
        {
            ModCallbacks.MC_POST_NPC_DEATH,
            MC_POST_NPC_DEATH,
            EntityType.ENTITY_FAMILIAR
        }
    },
    damageMultiplier = 1.3
}
