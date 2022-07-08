local Name = "Lil Husk"
local Tag = "lilHusk"
local Id = Isaac.GetEntityVariantByName(Name)

local DIRECTION = {
	[0] = "Left",
	[1] = "Up",
	[2] = "Right",
	[3] = "Down"
}

local fireCooldown = 19
local lullabyFireCooldown = 7
local spiderLimit = 1
local superSpiderLimit = 2

local function MC_FAMILIAR_INIT(_, familiar)
	familiar:AddToFollowers()
end

local function MC_FAMILIAR_UPDATE(_, familiar)
	local data = DukeHelpers.GetDukeData(familiar)
	local sprite = familiar:GetSprite()
	local player = familiar.Player
	local fireDirection = player:GetFireDirection()
	local fireDirectionSprite = DIRECTION[fireDirection]

	if familiar.FrameCount >= 6 and not data.canSpawnSpider then
		data.fireCooldown = 0
		data.canSpawnSpider = spiderLimit
	end

	if fireDirection == Direction.NO_DIRECTION then
		sprite:Play("FloatDown", false)
	else
		if not data.fireCooldown or data.fireCooldown <= 0 then
			if data.canSpawnSpider > 0 then
				sprite:Play("Shoot" .. fireDirectionSprite, false)
			end
		else
			local frame = sprite:GetFrame()
			sprite:Play("Float" .. fireDirectionSprite, false)
			sprite:SetFrame(frame)
		end
	end

	if sprite:IsEventTriggered("Barf") then
		DukeHelpers.sfx:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, 1.5)
		local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, nil)
		effect.Color = Color(0, 0, 0, 1)
		effect.SpriteScale = Vector(0.5, 0.5)

		local spider = DukeHelpers.GetWeightedSpider(DukeHelpers.rng)
		local spawnedSpiders = DukeHelpers.SpawnSpidersFromPickupSubType(spider.pickupSubType, familiar.Position, familiar, 1,
			true)
		local spawnedFly = nil

		spawnedSpiders[1]:GetData().spawnerEntityInitSeed = familiar.InitSeed

		if Sewn_API and Sewn_API:IsUltra(familiar:GetData()) then
			spawnedFly = DukeHelpers.SpawnAttackFlyFromHeartFly(DukeHelpers.Flies[spider.key], familiar.Position, familiar.Player)
		end

		if familiar.Player and familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and
			not familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
			DukeHelpers.GetDukeData(spawnedSpiders[1]).bffs = true
			spawnedSpiders[1].CollisionDamage = spawnedSpiders[1].CollisionDamage * 2
			if spawnedFly then
				DukeHelpers.GetDukeData(spawnedFly).bffs = true
				spawnedFly.CollisionDamage = spawnedFly.CollisionDamage * 2
			end
		end

		if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
			data.fireCooldown = lullabyFireCooldown
		else
			data.fireCooldown = fireCooldown
		end

		data.canSpawnSpider = data.canSpawnSpider - 1
	end

	if data.canSpawnSpider and data.canSpawnSpider > 0 and data.fireCooldown > 0 then
		data.fireCooldown = data.fireCooldown - 1
	end

	familiar:FollowParent()
end

local function MC_POST_ENTITY_REMOVE(_, e)
	if e.Variant == FamiliarVariant.BLUE_SPIDER then
		local actualParentEntityInitSeed = e:GetData().spawnerEntityInitSeed
		if actualParentEntityInitSeed then
			local parentEntity = DukeHelpers.GetEntityByInitSeed(e:GetData().spawnerEntityInitSeed)

			if parentEntity and parentEntity.Type == EntityType.ENTITY_FAMILIAR and
				parentEntity.Variant == Id then
				local parentEntityData = DukeHelpers.GetDukeData(parentEntity)
				parentEntityData.canSpawnSpider = (parentEntityData.canSpawnSpider or 0) +
					1
			end
		end
	end
end

local function MC_SPIDER_FAMILIAR_UPDATE(_, familiar)
	if DukeHelpers.GetDukeData(familiar).bffs then
		familiar.SpriteScale = Vector(1.2, 1.2)
	end
end

if Sewn_API then
	Sewn_API:MakeFamiliarAvailable(Id, DukeHelpers.Items.lilHusk.Id)
	Sewn_API:AddCallback(Sewn_API.Enums.ModCallbacks.ON_FAMILIAR_UPGRADED, function(_, familiar)
		local familiarData = DukeHelpers.GetDukeData(familiar)
		if familiarData then
			familiarData.canSpawnSpider = superSpiderLimit
		end
	end, Id)
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
			ModCallbacks.MC_POST_ENTITY_REMOVE,
			MC_POST_ENTITY_REMOVE,
			EntityType.ENTITY_FAMILIAR
		},
		{
			ModCallbacks.MC_FAMILIAR_UPDATE,
			MC_SPIDER_FAMILIAR_UPDATE,
			FamiliarVariant.BLUE_SPIDER
		}
	}
}
