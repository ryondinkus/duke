local Name = "Lil Duke"
local Tag = "lilDuke"
local Id = Isaac.GetEntityVariantByName(Name)

local STATE = {
	IDLE = 1,
	ATTACK = 2
}

local function MC_FAMILIAR_INIT(_, f)
	f.OrbitDistance = Vector(20, 20)
	f.OrbitSpeed = 0.045
	f:AddToOrbit(0)
end

local function MC_FAMILIAR_UPDATE(_, f)
	local data = f:GetData()
	local sprite = f:GetSprite()
	if f.FrameCount == 6 then
		sprite:Play("Float", true)
		data.State = STATE.IDLE
	end
	f.Velocity = f:GetOrbitPosition(f.Player.Position + f.Player.Velocity) - f.Position
	if data.State == STATE.ATTACK then
		if sprite:IsEventTriggered("Barf") then
			DukeHelpers.sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0, false, 1.5)
		    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, f.Position, Vector.Zero, nil)
		    effect.Color = Color(0,0,0,1)
			effect.SpriteScale = Vector(0.5, 0.5)
		    for _= 1, DukeHelpers.rng:RandomInt(2) + 1 do
		        local flyToSpawn = DukeHelpers.GetWeightedFly(rng)
		        local attackFly = DukeHelpers.SpawnAttackFlyBySubType(flyToSpawn.heartFlySubType, f.Position, f.Player)
				if f.Player and f.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and not f.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
					attackFly:GetData().bffs = true
					attackFly.CollisionDamage = attackFly.CollisionDamage * 2
				end
		    end
		end
		if sprite:IsFinished("Attack") then
			sprite:Play("Float", true)
			data.State = STATE.IDLE
		end
	end
end

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
		e:Die()

		local data = f:GetData()
		local sprite = f:GetSprite()

		if data.State ~= STATE.ATTACK then
			sprite:Play("Attack", true)
			data.State = STATE.ATTACK
		end
    end
end

return {
    Name = Name,
    Tag = Tag,
	Id = Id,
    callbacks = {
        {
            ModCallbacks.MC_FAMILIAR_INIT,
            MC_FAMILIAR_INIT,
            Id
        },
		{
            ModCallbacks.MC_FAMILIAR_UPDATE,
            MC_FAMILIAR_UPDATE,
            Id
        },
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
            MC_PRE_FAMILIAR_COLLISION,
            Id
		}
    }
}
