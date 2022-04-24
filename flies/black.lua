local key = "FLY_BLACK"
local subType = HeartSubType.HEART_BLACK
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

local function ATTACK_FLY_MC_FAMILIAR_UPDATE_ATTACK(_, f)
	if f.SubType == attackFlySubType then
		if f.FrameCount == 6 then
			f.CollisionDamage = f.CollisionDamage * 1.3
		end
	end
end

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddFear(EntityRef(f), 150)
		end
	end
end

local function HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK(_, f)
	if f.SubType == subType then
		f.CollisionDamage = f.CollisionDamage * 1.3
	end
end

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			local p = f.SpawnerEntity or Isaac.GetPlayer(0)
			p:ToPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM)
	    end
	end
end

return {
    key = key,
    spritesheet = "gfx/familiars/black_heart_fly.png",
    canAttack = true,
    subType = subType,
    fliesCount = 2,
	weight = 1,
	poofColor = Color(0, 0, 0, 1, 0, 0, 0),
	sacAltarQuality = 2,
    sfx = SoundEffect.SOUND_UNHOLY,
    callbacks = {
        {
            ModCallbacks.MC_FAMILIAR_UPDATE,
            ATTACK_FLY_MC_FAMILIAR_UPDATE_ATTACK,
            FamiliarVariant.BLUE_FLY
        },
		{
            ModCallbacks.MC_FAMILIAR_UPDATE,
            HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK,
            DukeHelpers.FLY_VARIANT
        },
		{
            ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
            MC_PRE_FAMILIAR_COLLISION,
            DukeHelpers.FLY_VARIANT
        },
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_FLY
		}
    }
}
