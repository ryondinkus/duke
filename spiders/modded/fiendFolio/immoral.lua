local heart = DukeHelpers.Hearts.IMMORAL
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_POST_NEW_ROOM()
	DukeHelpers.ForEachEntityInRoom(function(entity)
		entity:Remove()
	end, EntityType.ENTITY_FAMILIAR, 1026, subType)
end

local function onRelease(player)
	local minion = Isaac.Spawn(EntityType.ENTITY_PICKUP, Isaac.GetEntityVariantByName("Fiend Minion (Half Immoral)"), 3,
		player.Position, Vector.Zero, player)
	minion:GetSprite():Play("Drop")
end

return {
	spritesheet = "immoral_heart_skuzz.png",
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.28, 0, 0.50),
	callbacks = {
		{
			ModCallbacks.MC_POST_NEW_ROOM,
			MC_POST_NEW_ROOM
		}
	},
	damageMultiplier = 1.5,
	tearDamageMultiplier = 2,
	tearColor = Color(0.62, 0.62, 0.62, 1, 0.28, 0, 0.50),
	uiHeart = {
		animationPath = "gfx/ui/immoral_hearts.anm2",
		animationName = "ImmoralHeartHalf"
	},
	variant = 1026,
	onRelease = onRelease
}
