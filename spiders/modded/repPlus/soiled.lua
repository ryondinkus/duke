local heart = DukeHelpers.Hearts.SOILED
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddPoison(EntityRef(f), 102, 1)
		end
	end
end

local function applyTearEffects(tear)
	local function tearCollision(_, t)
		if tear.InitSeed == t.InitSeed then
			tear.SpawnerEntity:ToPlayer():AddFriendlyDip(0, tear.Position)
			dukeMod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, tearCollision)
		end
	end

	dukeMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, tearCollision)
end

return {
	spritesheet = "soiled_heart_spider.png",
	heart = heart,
	count = 1,
	weight = 1,
	poofColor = Color(2, 1, 1, 1, 0, 0, 0),
	sfx = SoundEffect.SOUND_ROTTEN_HEART,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
		}
	},
	applyTearEffects = applyTearEffects,
	tearDamageMultiplier = 1.5,
	tearColor = Color(0.5, 0.3, 0.1, 1, 0, 0, 0),
	uiHeart = {
		animationPath = "gfx/ui/ui_taintedhearts.anm2",
		animationName = "SoiledHeart"
	},
}
