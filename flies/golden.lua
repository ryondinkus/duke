local heart = DukeHelpers.Hearts.GOLDEN
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddMidasFreeze(EntityRef(f), 150)
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == heart.subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) and
			DukeHelpers.rng:RandomInt(3) == 0 then
			e:AddMidasFreeze(EntityRef(f), 30)
		end
	end
end

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == heart.subType then
		if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			for _ = 0, DukeHelpers.rng:RandomInt(8) do
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, f.Position,
					Vector.FromAngle(DukeHelpers.rng:RandomInt(360)), f)
			end
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKED_ORB_POOF, 0, f.Position, Vector.Zero, f)
			local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, f.Position, Vector.Zero, f)
			effect.Color = Color(1, 1, 1, 0, 1, 0.7, 0)
			effect:GetSprite().Scale = Vector(0.5, 0.5)
			DukeHelpers.sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 1, 0)
		end
	end
end

return {
	spritesheet = "gold_heart_fly.png",
	canAttack = true,
	heart = heart,
	count = 1,
	weight = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.55, 0),
	sacAltarQuality = 4,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_FLY
		},
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			HEART_FLY_MC_PRE_FAMILIAR_COLLISION,
			DukeHelpers.FLY_VARIANT
		},
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			DukeHelpers.FLY_VARIANT
		}
	},
	dropHeart = DukeHelpers.Hearts.GOLDEN,
	dropHeartChance = 10
}
