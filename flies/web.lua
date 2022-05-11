local key = "FLY_WEB"
local subType = 2000
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
            e:AddSlowing(EntityRef(f), 150, 0.5, Color(1,1,1,1,0.5,0.5,0.5))
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
    if f.SubType == subType then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) and DukeHelpers.rng:RandomInt(3) == 0 then
			e:AddSlowing(EntityRef(f), 30, 0.5, Color(1,1,1,1,0.5,0.5,0.5))
		end
	end
end

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			local p = f.SpawnerEntity:ToPlayer() or Isaac.GetPlayer(0)
			for _ = 0, DukeHelpers.rng:RandomInt(6) do
                local nearPos = Isaac.GetFreeNearPosition(p.Position + Vector(math.random(-100, 100), math.random(-100, 100)), 50)
                p:ThrowBlueSpider(f.Position, nearPos)
            end
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 0, p.Position, Vector.Zero, p):ToEffect()
			poof:GetSprite().Color = Color(0, 1, 1, 0.5, 1, 1, 1)
			poof.DepthOffset = 250
			poof:Update()
			local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, p.Position, Vector.Zero, p):ToEffect()
			explosion:GetSprite().Color = Color(0, 1, 1, 0.5, 1, 1, 1)
			explosion.DepthOffset = 250
			explosion:Update()
			game:SpawnParticles(p.Position, 5, math.random(5, 10), 4, Color(1, 1, 1, 1, 1, 1, 1))
			sfx:Play(SoundEffect.SOUND_MEATY_DEATHS , 0.8, 0, false, 1.25)
			sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 1)
	    end
	end
end

return {
    key = key,
    spritesheet = "gfx/familiars/web_heart_fly.png",
    canAttack = true,
    subType = subType,
    fliesCount = 1,
	weight = 0,
	poofColor = Color(1, 1, 1, 1, 1, 1, 1),
	sacAltarQuality = 4,
    sfx = SoundEffect.SOUND_SPIDER_SPIT_ROAR,
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
    }
}
