local heart = DukeHelpers.Hearts.BLACK
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddFear(EntityRef(f), 150)
		end
	end
end

local function onRelease(player)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON)
end

return {
	spritesheet = "black_heart_spider.png",
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0, 0, 0, 1, 0, 0, 0),
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
		}
	},
	damageMultiplier = 1.3,
	tearDamageMultiplier = 2,
	tearColor = Color(0.2, 0.2, 0.2, 1, 0, 0, 0),
	uiHeart = {
		animationName = "BlackHeartHalf"
	},
	onRelease = onRelease
}
