local heart = DukeHelpers.Hearts.MISER
local attackFlySubType = DukeHelpers.OffsetIdentifier(heart)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, f.Position, Vector.FromAngle(DukeHelpers.rng:RandomInt(360)), f)
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_PROJECTILE_COLLISION(_, f, e)
	if f.SubType == heart.subType then
		if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			local p = f.SpawnerEntity:ToPlayer() or Isaac.GetPlayer(0)
			p:UseActiveItem(CollectibleType.COLLECTIBLE_D6, UseFlag.USE_NOANIM)
            DukeHelpers.sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY)
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_ENEMY_COLLISION(_, f, e)
	if f.SubType == heart.subType then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			local data = DukeHelpers.GetDukeData(f)
			if not data.miserCoinCountdown then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, f.Position, Vector.FromAngle(DukeHelpers.rng:RandomInt(360)), f)
				data.miserCoinCountdown = 30
			end
		end
	end
end

local function MC_FAMILIAR_UPDATE(_, f)
	local data = DukeHelpers.GetDukeData(f)
	if data.miserCoinCountdown then
		data.miserCoinCountdown = data.miserCoinCountdown - 1
		if data.miserCoinCountdown <= 0 then
			data.miserCoinCountdown = nil
		end
	end
end

local function MC_POST_PICKUP_INIT(_, pickup)
	if pickup.Price <= 0 then return end

    DukeHelpers.ForEachPlayer(function(player)
		local data = DukeHelpers.GetDukeData(player)
		local miserFlyCount =  DukeHelpers.CountByProperties(data.heartFlies, { key = DukeHelpers.Flies.MISER.key })
		
        pickup.Price = math.max(1, math.floor(pickup.Price * (1 - 0.1 * ((miserFlyCount + 1) // 2))))
        pickup.AutoUpdatePrice = false
    end)
end

return {
	spritesheet = "miser_heart_fly.png",
	canAttack = true,
	heart = heart,
	count = 2,
	weight = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.55, 0),
	sacAltarQuality = 4,
	sfx = SoundEffect.SOUND_GOLD_HEART,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION,
			FamiliarVariant.BLUE_FLY
		},
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			HEART_FLY_MC_PRE_FAMILIAR_PROJECTILE_COLLISION,
			DukeHelpers.FLY_VARIANT
		},
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			HEART_FLY_MC_PRE_FAMILIAR_ENEMY_COLLISION,
			DukeHelpers.FLY_VARIANT
		},
		{
			ModCallbacks.MC_FAMILIAR_UPDATE,
			MC_FAMILIAR_UPDATE,
			DukeHelpers.FLY_VARIANT
		},
		{
			ModCallbacks.MC_POST_PICKUP_INIT,
			MC_POST_PICKUP_INIT
		}
	},
	dropHeart = DukeHelpers.Hearts.MISER,
	dropHeartChance = 10
}
