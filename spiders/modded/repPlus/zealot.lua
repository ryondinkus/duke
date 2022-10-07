local heart = DukeHelpers.Hearts.ZEALOT
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddEntityFlags(EntityFlag.FLAG_ICE)
		end
	end
end

local function onRelease(player)
	player:AddItemWisp(Game():GetItemPool():GetCollectible(DukeHelpers.rng:RandomInt(ItemPoolType.NUM_ITEMPOOLS)), player.Position, true)
end

local function applyTearEffects(tear)
	tear:AddTearFlags(TearFlags.TEAR_ICE)
end

return {
	spritesheet = "zealot_heart_spider.png",
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.58, 0.12, 0.80),
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
		}
	},
	damageMultiplier = 1.3,
	tearDamageMultiplier = 2,
	tearColor = Color(0.62, 0.62, 0.52, 1, 0.58, 0.12, 0.50),
	uiHeart = {
		animationPath = "gfx/ui/ui_taintedhearts.anm2",
		animationName = "ZealotHeartHalf"
	},
	onRelease = onRelease,
	applyTearEffects = applyTearEffects,
}
