local heart = DukeHelpers.Hearts.EMPTY
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
		end
	end
end

local function onRelease(player)
	Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.ABYSS_LOCUST, 7, player.Position, Vector.Zero, player) -- subtype 7 makes the locust persist between rooms for some fucked up evil reason
end

return {
	spritesheet = "empty_heart_spider.png",
	heart = heart,
	count = 1,
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
	tearColor = Color(0.1, 0.2, 0, 1, 0.1, 0.1, 0.1),
	uiHeart = {
		animationPath = "gfx/ui/ui_taintedhearts.anm2",
		animationName = "EmptyHeart"
	},
	onRelease = onRelease
}
