-- CONSTANTS

DukeHelpers.FLY_VARIANT = Isaac.GetEntityVariantByName("Red Heart Fly")

DukeHelpers.INNER = 1
DukeHelpers.MIDDLE = 2
DukeHelpers.OUTER = 3
DukeHelpers.BIRTHRIGHT = 4

local INNER = DukeHelpers.INNER
local MIDDLE = DukeHelpers.MIDDLE
local OUTER = DukeHelpers.OUTER
local BIRTHRIGHT = DukeHelpers.BIRTHRIGHT

-- FUNCTIONS

function DukeHelpers.SpawnHeartFly(player, fly, layer)
	local heartFlyEntity = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, DukeHelpers.FLY_VARIANT, fly.heartFlySubType or 1,
		player.Position, Vector.Zero
		, player)
	heartFlyEntity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	DukeHelpers.SpawnHeartFlyPoof(fly, player.Position, player)
	DukeHelpers.GetDukeData(heartFlyEntity).layer = layer
	DukeHelpers.PositionHeartFly(heartFlyEntity, layer)
	return heartFlyEntity
end

function DukeHelpers.AddHeartFly(player, fly, specificAmount, applyInfestedHeart)
	if type(fly.heartFlySubType) == "table" then
		local continueInfestedHeart = true
		DukeHelpers.ForEach(fly.heartFlySubType, function(useFly)
			local shouldSpawn = true

			if shouldSpawn then
				local addedFlies = DukeHelpers.AddHeartFly(player, DukeHelpers.Flies[useFly.key], useFly.count or 1,
					continueInfestedHeart)
				if DukeHelpers.LengthOfTable(addedFlies) > useFly.count or 1 then
					continueInfestedHeart = false
				end
			end
		end)
		return {}
	end

	local playerData = DukeHelpers.GetDukeData(player)

	local heartFlies = {}

	local startingI = 1

	if (applyInfestedHeart or applyInfestedHeart == nil) and DukeHelpers.IsDuke(player) and
		DukeHelpers.Trinkets.infestedHeart.helpers.ShouldSpawnExtraFly(player) then
		startingI = startingI - 1
	end

	for _ = startingI, specificAmount or fly.count or 1 do
		local layer

		if DukeHelpers.CountByProperties(playerData.heartFlies, { layer = INNER }) < 3 then
			layer = INNER
		elseif DukeHelpers.CountByProperties(playerData.heartFlies, { layer = MIDDLE }) < 9 then
			layer = MIDDLE
		elseif DukeHelpers.CountByProperties(playerData.heartFlies, { layer = OUTER }) < 12 then
			layer = OUTER
		elseif player:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and
			DukeHelpers.CountByProperties(playerData.heartFlies, { layer = BIRTHRIGHT }) < 18 then
			layer = BIRTHRIGHT
		else
			local replacableFly = DukeHelpers.Find(playerData.heartFlies, function(f)
				return f.key ~= DukeHelpers.Flies.BROKEN.key
			end)
			if replacableFly then
				layer = replacableFly.layer
				DukeHelpers.RemoveHeartFlyEntity(DukeHelpers.GetEntityByInitSeed(replacableFly.initSeed))
			end
		end

		if layer then
			local heartFly = DukeHelpers.SpawnHeartFly(player, fly, layer)
			table.insert(heartFlies, heartFly)
			table.insert(playerData.heartFlies, {
				initSeed = heartFly.InitSeed,
				layer = layer,
				key = fly.key
			})
		end
	end

	return heartFlies
end

function DukeHelpers.PositionHeartFly(fly, layer)
	fly:ToFamiliar():AddToOrbit(DukeHelpers.SUBTYPE_OFFSET + layer)
end

function DukeHelpers.GetHeartFlyByHeartFlySubType(heartFlySubType)
	return DukeHelpers.FindByProperties(DukeHelpers.Flies, { heartFlySubType = heartFlySubType, isBase = true })
end

function DukeHelpers.GetHeartFlyByAttackFlySubType(attackFlySubType)
	return DukeHelpers.FindByProperties(DukeHelpers.Flies, { attackFlySubType = attackFlySubType, isBase = true })
end

function DukeHelpers.GetFlySpritesheetFromEntity(flyHeartEntity)
	local foundFly = DukeHelpers.GetHeartFlyFromFlyEntity(flyHeartEntity)

	if foundFly then
		return foundFly.spritesheet
	end

	return DukeHelpers.Flies.RED.spritesheet
end

function DukeHelpers.GetFlyByPickup(pickup)
	if pickup then
		return DukeHelpers.FindByProperties(DukeHelpers.Flies,
			{ pickupSubType = pickup.SubType, pickupVariant = pickup.Variant })
	end
end

function DukeHelpers.GetHeartFlyFromFlyEntity(entity)
	if entity then
		if entity.Variant == DukeHelpers.FLY_VARIANT then
			return DukeHelpers.GetHeartFlyByHeartFlySubType(entity.SubType)
		elseif entity.Variant == FamiliarVariant.BLUE_FLY then
			return DukeHelpers.GetHeartFlyByAttackFlySubType(entity.SubType)
		end
	end
end

function DukeHelpers.SpawnAttackFlyFromHeartFly(heartFly, position, spawnerEntity, allowAny)
	if heartFly and (allowAny or heartFly.canAttack) then
		local attackFly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, heartFly.attackFlySubType, position
			, Vector.Zero, spawnerEntity)
		DukeHelpers.InitializeAttackFly(attackFly)
		attackFly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		return attackFly
	end
end

function DukeHelpers.SpawnAttackFlyFromHeartFlyEntity(heartFlyEntity, allowAny)
	if not heartFlyEntity then
		return nil
	end
	return DukeHelpers.SpawnAttackFlyFromHeartFly(DukeHelpers.GetHeartFlyFromFlyEntity(heartFlyEntity),
		heartFlyEntity.Position, heartFlyEntity.SpawnerEntity, allowAny)
end

function DukeHelpers.IsAttackFly(fly)
	return fly.Variant == FamiliarVariant.BLUE_FLY and
		not not DukeHelpers.Find(DukeHelpers.Flies, function(f) return f.attackFlySubType == fly.SubType end)
end

function DukeHelpers.InitializeAttackFly(fly)
	local sprite = fly:GetSprite()
	sprite:ReplaceSpritesheet(0, DukeHelpers.GetFlySpritesheetFromEntity(fly))
	sprite:LoadGraphics()
	sprite:Play("Attack", true)
end

function DukeHelpers.RemoveHeartFlyEntity(heartFly)
	if heartFly then
		local p = heartFly.SpawnerEntity
		if p then
			local playerData = DukeHelpers.GetDukeData(p)
			if playerData.heartFlies then
				for i, fly in pairs(playerData.heartFlies) do
					if fly.initSeed == heartFly.InitSeed then
						table.remove(playerData.heartFlies, i)
						heartFly:Remove()
						return
					end
				end
			end
		end
	end
end

function DukeHelpers.RemoveOutermostHeartFlies(player, amount, removeBroken)
	if not amount then
		amount = 1
	end

	local fliesData = DukeHelpers.GetDukeData(player).heartFlies

	local layer = DukeHelpers.OUTER
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		layer = DukeHelpers.BIRTHRIGHT
	end

	local removedFlies = {}

	for _ = 1, amount do
		local foundFly

		while not foundFly do
			foundFly = DukeHelpers.Find(fliesData, function(fly)
				return (removeBroken or fly.key ~= DukeHelpers.Flies.BROKEN.key) and fly.layer == layer
			end)

			if not foundFly then
				layer = layer - 1
				if layer < DukeHelpers.INNER then
					break
				end
			end
		end

		if foundFly then
			local flyToRemove = DukeHelpers.GetEntityByInitSeed(foundFly.initSeed)
			DukeHelpers.RemoveHeartFlyEntity(flyToRemove)
			table.insert(removedFlies, flyToRemove)
		end
	end

	return removedFlies
end

function DukeHelpers.RemoveHeartFly(player, heartFlies, amount)
	if not amount then
		amount = 1
	end

	if not DukeHelpers.IsArray(heartFlies) then
		heartFlies = { heartFlies }
	end

	local fliesData = DukeHelpers.GetDukeData(player).heartFlies

	local layer = DukeHelpers.OUTER
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		layer = DukeHelpers.BIRTHRIGHT
	end

	local removedFlies = {}

	for _ = 1, amount do
		local foundFly

		while not foundFly do
			foundFly = DukeHelpers.Find(fliesData, function(savedHeartFly)
				return (not not DukeHelpers.Find(heartFlies, function(heartFly)
					return savedHeartFly.key == heartFly.key
				end)) and savedHeartFly.layer == layer
			end)

			if not foundFly then
				layer = layer - 1
				if layer < DukeHelpers.INNER then
					break
				end
			end
		end

		if foundFly then
			local flyToRemove = DukeHelpers.GetEntityByInitSeed(foundFly.initSeed)
			DukeHelpers.RemoveHeartFlyEntity(flyToRemove)
			table.insert(removedFlies, flyToRemove)
		end
	end

	return removedFlies
end

function DukeHelpers.GetWeightedFly(rng, attack, specialOnly)
	return DukeHelpers.GetWeightedIndex(DukeHelpers.Flies, "weight",
		function(fly) return (not attack or fly.canAttack) and (not specialOnly or fly.weight < 2) end, rng)
end

function DukeHelpers.IsFlyOfPlayer(fly, player)
	if fly.SpawnerEntity and fly.SpawnerEntity.InitSeed == player.InitSeed then
		if fly.Variant == FamiliarVariant.BLUE_FLY then
			return not not DukeHelpers.GetHeartFlyByAttackFlySubType(fly.SubType)
		elseif fly.Variant == DukeHelpers.FLY_VARIANT then
			return not not DukeHelpers.GetHeartFlyByHeartFlySubType(fly.SubType)
		end
	end

	return false
end

function DukeHelpers.SpawnPickupHeartFly(player, pickup, overriddenKey, amount, applyInfestedHeart)
	local sfx = SoundEffect.SOUND_BOSS2_BUBBLES

	local pickupKey = overriddenKey or DukeHelpers.GetKeyFromPickup(pickup)

	if not pickupKey then
		return
	end

	local flyToSpawn = DukeHelpers.Flies[pickupKey]
	local heart = DukeHelpers.Hearts[pickupKey]

	local spawnedFlies = {}

	if not flyToSpawn then
		return
	end

	if type(flyToSpawn.heartFlySubType) == "table" then
		local continueInfestedHeart = true
		DukeHelpers.ForEach(flyToSpawn.heartFlySubType, function(useFly)
			local addedFlies = DukeHelpers.SpawnPickupHeartFly(player, nil, useFly.key, useFly.count, continueInfestedHeart)
			if DukeHelpers.LengthOfTable(addedFlies) > useFly.count or 1 then
				continueInfestedHeart = false
			end
		end)
	else
		local amountToSpawn = (amount or flyToSpawn.count)
		if DukeHelpers.IsDuke(player) and heart.variant == PickupVariant.PICKUP_HEART and
			(
			heart.subType == HeartSubType.HEART_SOUL or heart.subType == HeartSubType.HEART_HALF_SOUL) and
			DukeHelpers.Hearts.SOUL.GetCount(player) < DukeHelpers.MAX_HEALTH then
			local heartSlots = 2

			if heart.subType == HeartSubType.HEART_HALF_SOUL then
				heartSlots = 1
			end

			local heartsToGive = math.min(DukeHelpers.MAX_HEALTH - DukeHelpers.Hearts.SOUL.GetCount(player), heartSlots)
			DukeHelpers.Hearts.SOUL.Add(player, heartsToGive)

			amountToSpawn = amountToSpawn - heartsToGive
		end
		spawnedFlies = DukeHelpers.AddHeartFly(player, flyToSpawn, amountToSpawn, applyInfestedHeart)
	end

	if pickup then
		if flyToSpawn.sfx then
			sfx = flyToSpawn.sfx
		end

		DukeHelpers.sfx:Play(sfx)
		DukeHelpers.AnimateHeartPickup(pickup, player)
	end

	return spawnedFlies
end

function DukeHelpers.SpawnHeartFlyPoof(fly, pos, spawner)
	local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, spawner)

	if fly.poofColor then
		poof.Color = fly.poofColor
	end
end

function DukeHelpers.KillAtMaxBrokenFlies(player)
	if DukeHelpers.IsDuke(player) and player:GetData().duke then
		local heartFlies = DukeHelpers.GetDukeData(player).heartFlies
		local brokenFlyCount = 0
		if heartFlies then
			for i = #heartFlies, 1, -1 do
				local fly = heartFlies[i]
				if fly.key == DukeHelpers.Flies.BROKEN.key then
					brokenFlyCount = brokenFlyCount + 1
				end
			end
		end
		local brokenFlyLimit = 24
		if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			brokenFlyLimit = 42
		end
		if brokenFlyCount >= brokenFlyLimit then
			player:Kill()
		end
	end
end

function DukeHelpers.SpawnAttackFlyWisp(wisp, pos, spawner, lifeTime, spawnOnDeath)
	return DukeHelpers.SpawnWisp(wisp, pos, spawner, spawnOnDeath and "spawnFlyOnDeath" or nil, lifeTime,
		DukeHelpers.Items.thePrinces.Id)
end
