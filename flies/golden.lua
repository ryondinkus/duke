local key = "FLY_GOLDEN"
local subType = HeartSubType.HEART_GOLDEN
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddMidasFreeze(EntityRef(f), 150)
			for _ = 0, DukeHelpers.rng:RandomInt(8) do
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, f.Position, Vector.FromAngle(DukeHelpers.rng:RandomInt(360)), f)
			end
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKED_ORB_POOF, 0, f.Position, Vector.Zero, f)
			local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, f.Position, Vector.Zero, f)
			effect.Color = Color(1,1,1,0,1,0.7,0)
			effect:GetSprite().Scale = Vector(0.5,0.5)
			DukeHelpers.sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 1, 0)
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
    if f.SubType == subType then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) and DukeHelpers.rng:RandomInt(3) == 0 then
			e:AddMidasFreeze(EntityRef(f), 30)
		end
	end
end

return {
    key = key,
    spritesheet = "gfx/familiars/gold_heart_fly.png",
    canAttack = true,
    subType = subType,
    fliesCount = 1,
	weight = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.55, 0),
    sfx = SoundEffect.SOUND_GOLD_HEART,
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
        }
    }
}
