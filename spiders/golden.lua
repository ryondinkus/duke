local key = "SPIDER_GOLDEN"
local pickupSubType = HeartSubType.HEART_GOLDEN
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddMidasFreeze(EntityRef(f), 150)
		end
	end
end

local function MC_POST_NPC_DEATH(_, e)
	if e.Variant == FamiliarVariant.BLUE_SPIDER and e.SubType == subType then
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, e.Position, Vector.Zero, e)
	end
end

return {
	key = key,
	spritesheet = "gfx/familiars/gold_heart_spider.png",
	pickupSubType = pickupSubType,
	count = 1,
	weight = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.55, 0),
	sfx = SoundEffect.SOUND_GOLD_HEART,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
		},
		{
			ModCallbacks.MC_POST_NPC_DEATH,
			MC_POST_NPC_DEATH,
			EntityType.ENTITY_FAMILIAR
		}
	}
}
