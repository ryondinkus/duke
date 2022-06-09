local key = "WEB"
local pickupSubType = 2000
local subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(pickupSubType)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddSlowing(EntityRef(f), 150, 0.5, Color(1, 1, 1, 1, 0.5, 0.5, 0.5))
		end
	end
end

return {
	key = key,
	spritesheet = "web_heart_spider.png",
	pickupSubType = pickupSubType,
	count = 1,
	weight = 0,
	poofColor = Color(1, 1, 1, 1, 1, 1, 1),
	sfx = SoundEffect.SOUND_SPIDER_SPIT_ROAR,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
		}
	},
	uiHeart = {
		animationPath = "gfx/web_heart_ui.anm2",
		animationName = "UI"
	}
}
