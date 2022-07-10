local heart = DukeHelpers.Hearts.WEB
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddSlowing(EntityRef(f), 150, 0.5, Color(1, 1, 1, 1, 0.5, 0.5, 0.5))
		end
	end
end

local function applyTearEffects(tear)
	local function tearCollision(_, t)
		if tear.InitSeed == t.InitSeed then
			Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, 0, t.Position, Vector.Zero, t)
			dukeMod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, tearCollision)
		end
	end

	dukeMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, tearCollision)
end

return {
	spritesheet = "web_heart_spider.png",
	heart = heart,
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
	applyTearEffects = applyTearEffects,
	tearDamageMultiplier = 1.5,
	tearColor = Color(1, 1, 1, 1, 1, 1, 1),
	uiHeart = {
		animationPath = "gfx/web_heart_ui.anm2",
		animationName = "UI"
	}
}
