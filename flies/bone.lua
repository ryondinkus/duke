local key = "FLY_BONE"
local spritesheet = "gfx/familiars/bone_heart_fly.png"
local canAttack = true
local subType = HeartSubType.HEART_BONE
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)
local fliesCount = 1

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
			for i = 1,8 do
                local tear = f:FireProjectile(Vector.FromAngle(i * 45))
                tear:ChangeVariant(TearVariant.BONE)
			end
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, f.Position, Vector.Zero, f)
            DukeHelpers.sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 0)
		end
	end
end

local function HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK(_, f)
	if f.SubType == subType then
        if f.FrameCount == 6 then
            local data = f:GetData()
            if data.hitPoints == nil then
                data.hitPoints = 2
            end
        end
		f.CollisionDamage = f.CollisionDamage * 1.3
	end
end

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
            DukeHelpers.sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 0)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, f.Position, Vector.Zero, nil)
	    end
	end
end

return {
    key = key,
    spritesheet = spritesheet,
    canAttack = canAttack,
    subType = subType,
    fliesCount = fliesCount,
    callbacks = {
        {
            ModCallbacks.MC_FAMILIAR_UPDATE,
            ATTACK_FLY_MC_FAMILIAR_UPDATE_ATTACK,
            FamiliarVariant.BLUE_FLY
        },
        {
            ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
            ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION,
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
        }
    }
}