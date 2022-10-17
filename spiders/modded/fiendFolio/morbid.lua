local heart = DukeHelpers.Hearts.MORBID
local subType = DukeHelpers.OffsetIdentifier(heart)

local function onRelease(player)
	Isaac.Spawn(Isaac.GetEntityTypeByName("Morbid Chunk"), Isaac.GetEntityVariantByName("Morbid Chunk"), 2302, player.Position, Vector.Zero, player.Player)
end

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			FiendFolio.AddBruise(e, f.Player, 60, 1, f.Player.Damage / 4)
		end
	end
end

return {
	spritesheet = "morbid_heart_skuzz.png",
	heart = heart,
	count = 3,
	weight = 1,
    poofColor = Color(0.12, 0.82, 0.12, 1, 0, 0, 0),
	sacAltarQuality = 2,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			1026
		}
	},
	damageMultiplier = 1.3,
	tearDamageMultiplier = 2,
    tearColor = Color(0.12, 0.32, 0.12, 1, 0, 0, 0),
	uiHeart = {
		animationPath = "gfx/ui/morbid_hearts.anm2",
		animationName = "MorbidHeartFull"
	},
	variant = 1026,
	onRelease = onRelease
}
