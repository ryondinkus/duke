local key = "SPIDER_BLACK"
local pickupSubType = HeartSubType.HEART_BLACK
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddFear(EntityRef(f), 150)
		end
	end
end

return {
	key = key,
	spritesheet = "black_heart_spider.png",
	pickupSubType = pickupSubType,
	count = 2,
	weight = 1,
	poofColor = Color(0, 0, 0, 1, 0, 0, 0),
	sfx = SoundEffect.SOUND_UNHOLY,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
		}
	},
	damageMultiplier = 1.3,
	tearDamageMultiplier = 2
}
