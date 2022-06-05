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

return {
    key = key,
    spritesheet = "gfx/familiars/rotten_heart_spider.png",
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
    }
}
