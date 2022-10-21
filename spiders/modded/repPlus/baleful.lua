local heart = DukeHelpers.Hearts.BALEFUL
local subType = DukeHelpers.OffsetIdentifier(heart)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART, 0, f.Position,
				Vector.Zero, f)
			DukeHelpers.sfx:Stop(SoundEffect.SOUND_FART)
			DukeHelpers.sfx:Play(SoundEffect.SOUND_DEMON_HIT)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, f.Position,
				Vector.Zero, f)
			explosion.Color = Color(1, 0, 0, 1, 0.2, 0, 0)
			local damage = 40
			local player = f.Player
			local radius = 75
			for _, enemy in ipairs(Isaac.FindInRadius(f.Position, radius, EntityPartition.ENEMY)) do
				enemy:TakeDamage(damage, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0)
			end
		end
	end
end

local function applyTearEffects(tear)
	tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)

	local function tearCollision(_, t, e)
		if tear.InitSeed == t.InitSeed and e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and
			not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			local purgatoryGhost = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PURGATORY, 1, t.Position, Vector.Zero, t)
			purgatoryGhost.CollisionDamage = t.BaseDamage / 1.25
			dukeMod:RemoveCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, tearCollision)
		end
	end

	dukeMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, tearCollision)
end

return {
	spritesheet = "baleful_heart_spider.png",
	heart = heart,
	count = 1,
	weight = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.78, 0.78),
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_SPIDER
		}
	},
	applyTearEffects = applyTearEffects,
	damageMultiplier = 1.3,
	tearDamageMultiplier = 2,
	tearColor = Color(1, 1, 1, 1, 0.78, 0.78, 0.78),
	uiHeart = {
		animationPath = "gfx/ui/ui_taintedhearts.anm2",
		animationName = "BalefulHeart"
	},
}
