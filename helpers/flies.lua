-- CONSTANTS

DukeHelpers.FLY_VARIANT = Isaac.GetEntityVariantByName("Red Heart Fly")

DukeHelpers.SUBTYPE_OFFSET = 903

DukeHelpers.INNER = 1
DukeHelpers.MIDDLE = 2
DukeHelpers.OUTER = 3
DukeHelpers.BIRTHRIGHT = 4

local INNER = DukeHelpers.INNER
local MIDDLE = DukeHelpers.MIDDLE
local OUTER = DukeHelpers.OUTER
local BIRTHRIGHT = DukeHelpers.BIRTHRIGHT

-- FUNCTIONS

function DukeHelpers.SpawnHeartFly(player, subType, layer)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, DukeHelpers.FLY_VARIANT, subType or 1, player.Position, Vector.Zero, player)
	fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	DukeHelpers.SpawnHeartFlyPoof(subType, player.Position, player)
	fly:GetData().layer = layer
	DukeHelpers.PositionHeartFly(fly, layer)
	return fly
end

function DukeHelpers.AddHeartFly(player, fly, specificAmount, applyInfestedHeart)
	if type(fly.heartFlySubType) == "table" then
		local continueInfestedHeart = true
		DukeHelpers.ForEach(fly.heartFlySubType, function(useFly)
			local shouldSpawn = true

			if shouldSpawn then
				local addedFlies = DukeHelpers.AddHeartFly(player, DukeHelpers.Flies[useFly.key], useFly.amount or 1, continueInfestedHeart)
				if DukeHelpers.LengthOfTable(addedFlies) > useFly.amount or 1 then
					continueInfestedHeart = false
				end
			end
		end)
		return
	end

	local playerData = DukeHelpers.GetDukeData(player)
	if not playerData.heartFlies then
		playerData.heartFlies = {}
	end

	local heartFlies = {}

	local startingI = 1;

	if (applyInfestedHeart or applyInfestedHeart == nil) and DukeHelpers.IsDuke(player) and DukeHelpers.Trinkets.infestedHeart.helpers.ShouldSpawnExtraFly(player) then
		startingI = startingI - 1;
	end

	for _ = startingI, specificAmount or fly.fliesCount or 1 do
		local layer

		if DukeHelpers.CountByProperties(playerData.heartFlies, { layer = INNER }) < 3 then
			layer = INNER
		elseif DukeHelpers.CountByProperties(playerData.heartFlies, { layer = MIDDLE }) < 9 then
			layer = MIDDLE
		elseif DukeHelpers.CountByProperties(playerData.heartFlies, { layer = OUTER }) < 12 then
			layer = OUTER
		elseif player:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and DukeHelpers.CountByProperties(playerData.heartFlies, { layer = BIRTHRIGHT }) < 18 then
			layer = BIRTHRIGHT
		else
			local replacableFly = DukeHelpers.Find(playerData.heartFlies, function(f)
				return f.subType ~= DukeHelpers.Flies.FLY_BROKEN.heartFlySubType
			end)
			if replacableFly then
				layer = replacableFly.layer
				DukeHelpers.RemoveHeartFly(DukeHelpers.GetEntityByInitSeed(replacableFly.initSeed))
			end
		end

		if layer then
			local heartFly = DukeHelpers.SpawnHeartFly(player, fly.heartFlySubType, layer)
			table.insert(heartFlies, heartFly)
			table.insert(playerData.heartFlies, {
				initSeed = heartFly.InitSeed,
				layer = layer,
				subType = fly.heartFlySubType
			})
		end
	end

	return heartFlies
end

function DukeHelpers.PositionHeartFly(fly, layer)
	fly:ToFamiliar():AddToOrbit(DukeHelpers.SUBTYPE_OFFSET + layer)
end

function DukeHelpers.GetFlyByHeartSubType(subType)
	return DukeHelpers.FindByProperties(DukeHelpers.Flies, { heartFlySubType = subType })
end

function DukeHelpers.GetFlyByAttackSubType(subType)
	return DukeHelpers.FindByProperties(DukeHelpers.Flies, { attackFlySubType = subType })
end

function DukeHelpers.GetFlyByPickupSubType(subType)
	return DukeHelpers.FindByProperties(DukeHelpers.Flies, { pickupSubType = subType }) or DukeHelpers.Flies.FLY_RED
end

function DukeHelpers.GetFlySpritesheet(subType)
	local foundFly = DukeHelpers.GetFlyByHeartSubType(subType) or DukeHelpers.GetFlyByAttackSubType(subType)

	if foundFly then
		return foundFly.spritesheet
	end

	return DukeHelpers.Flies.FLY_RED.spritesheet
end

function DukeHelpers.CanBecomeAttackFly(fly)
	local foundFly = DukeHelpers.GetFlyByHeartSubType(fly.SubType)

	if foundFly then
		return foundFly.canAttack
	end

	return false
end

function DukeHelpers.SpawnAttackFly(heartFly)
	return DukeHelpers.SpawnAttackFlyBySubType(heartFly.SubType, heartFly.Position, heartFly.SpawnerEntity)
end

function DukeHelpers.IsAttackFly(fly)
	return not not DukeHelpers.Find(DukeHelpers.Flies, function(f) return f.attackFlySubType == fly.SubType end)
end

function DukeHelpers.InitializeAttackFly(fly)
	local sprite = fly:GetSprite()
	sprite:ReplaceSpritesheet(0, DukeHelpers.GetFlySpritesheet(fly.SubType))
	sprite:LoadGraphics()
	sprite:Play("Attack", true)
end

function DukeHelpers.SpawnAttackFlyBySubType(subType, position, spawnerEntity)
	local fly = DukeHelpers.GetFlyByHeartSubType(subType)
	local attackFly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, fly.attackFlySubType, position, Vector.Zero, spawnerEntity)
	DukeHelpers.InitializeAttackFly(attackFly)
	attackFly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	return attackFly
end

function DukeHelpers.RemoveHeartFly(heartFly)
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

function DukeHelpers.RemoveHeartFlyBySubType(player, subType, amount)
	if not amount then
		amount = 1
	end

	if type(subType) == "number" then
		subType = { subType }
	end

	local fliesData = DukeHelpers.GetDukeData(player).heartFlies

	local layer = DukeHelpers.OUTER
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		layer = DukeHelpers.BIRTHRIGHT
	end

	local removedFlies = {}

	for i = 1, amount do
		local foundFly

		while not foundFly do
			foundFly = DukeHelpers.Find(fliesData, function(fly)
				return (not not DukeHelpers.Find(subType, function(st)
					if type(st) == "table" then
						i = i + st.count - 1
						return st.subType == fly.subType
					else
						return st == fly.subType
					end
				end)) and fly.layer == layer
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
			DukeHelpers.RemoveHeartFly(flyToRemove)
			table.insert(removedFlies, flyToRemove)
		end
	end

	return removedFlies
end

function DukeHelpers.GetAttackFlySubTypeBySubType(subType)
	if subType then
		return DukeHelpers.SUBTYPE_OFFSET + subType
	end
end

function DukeHelpers.GetWeightedFly(rng, attack)
	return DukeHelpers.GetWeightedIndex(DukeHelpers.Flies, "weight", function(fly) return not attack or DukeHelpers.CanBecomeAttackFly(fly) end, rng)
end

function DukeHelpers.IsFlyOfPlayer(fly, player)
	if fly.SpawnerEntity and fly.SpawnerEntity.InitSeed == player.InitSeed then
		if fly.Variant == FamiliarVariant.BLUE_FLY then
			local attackFlySubTypes = DukeHelpers.Map(DukeHelpers.Flies, function(f) return f.attackFlySubType end)
			return not not DukeHelpers.Find(attackFlySubTypes, function(subType)
				return subType == fly.SubType
			end)
		elseif fly.Variant == DukeHelpers.FLY_VARIANT then
			local heartFlySubTypes = DukeHelpers.Map(DukeHelpers.Flies, function(f) return f.heartFlySubType end)
			return not not DukeHelpers.Find(heartFlySubTypes, function(subType)
				return subType == fly.SubType
			end)
		end
	end

	return false
end

function DukeHelpers.AddStartupFlies(p)
	DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_RED, 3)
end

function DukeHelpers.SpawnPickupHeartFly(player, pickup, overriddenSubType, amount, applyInfestedHeart)
	if not overriddenSubType then
		overriddenSubType = pickup.SubType
	end
	local sfx = SoundEffect.SOUND_BOSS2_BUBBLES

	local flyToSpawn = DukeHelpers.GetFlyByPickupSubType(overriddenSubType)

	local spawnedFlies = {}

	if type(flyToSpawn.heartFlySubType) == "table" then
		local continueInfestedHeart = true
		DukeHelpers.ForEach(flyToSpawn.heartFlySubType, function(useFly)
			local addedFlies = DukeHelpers.SpawnPickupHeartFly(player, nil, DukeHelpers.Flies[useFly.key].pickupSubType, useFly.amount, continueInfestedHeart)
			if DukeHelpers.LengthOfTable(addedFlies) > useFly.amount or 1 then
				continueInfestedHeart = false
			end
		end)
	else
		local amountToSpawn = (amount or flyToSpawn.fliesCount)

		if DukeHelpers.IsDuke(player) and (overriddenSubType == HeartSubType.HEART_SOUL or overriddenSubType == HeartSubType.HEART_HALF_SOUL or overriddenSubType == HeartSubType.HEART_BLACK) and DukeHelpers.GetTrueSoulHearts(player) < DukeHelpers.MAX_HEALTH then
			local heartSlots = 2

			if overriddenSubType == HeartSubType.HEART_HALF_SOUL then
				heartSlots = 1
			end

			local heartsToGive = math.min(DukeHelpers.MAX_HEALTH - DukeHelpers.GetTrueSoulHearts(player), heartSlots)
			player:AddSoulHearts(heartsToGive)

			amountToSpawn = amountToSpawn - heartsToGive
		end
		spawnedFlies = DukeHelpers.AddHeartFly(player, flyToSpawn, amountToSpawn, applyInfestedHeart)
	end

	if pickup then
		if flyToSpawn.sfx then
			sfx = flyToSpawn.sfx
		end

		DukeHelpers.sfx:Play(sfx)
		pickup:Remove()

		if pickup.Price > 0 then
			player:AnimatePickup(pickup:GetSprite())
			player:AddCoins(-pickup.Price)
		end
	end

	return spawnedFlies
end

function DukeHelpers.SpawnHeartFlyPoof(flySubType, pos, spawner)
	local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, spawner)

	local color = DukeHelpers.GetFlyByHeartSubType(flySubType).poofColor

	if color then
		poof.Color = color
	end
end

function DukeHelpers.KillAtMaxBrokenFlies(player)
	if DukeHelpers.IsDuke(player) and player:GetData().duke then
		local heartFlies = DukeHelpers.GetDukeData(player).heartFlies
		local brokenFlyCount = 0
		if heartFlies then
			for i = #heartFlies, 1, -1 do
				local fly = heartFlies[i]
				if fly.subType == DukeHelpers.Flies.FLY_BROKEN.heartFlySubType then
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

function DukeHelpers.SpawnAttackFlyWispBySubType(flySubType, pos, spawner, spawnFlyOnDeath, lifeTime, spawnSpiderOnDeath)
	local player = spawner:ToPlayer()
	if player then
		local id = DukeHelpers.Items.thePrinces.Id
		if spawnSpiderOnDeath then
			id = DukeHelpers.Items.dukeOfEyes.Id
		end
		local wisp = spawner:ToPlayer():AddWisp(id, pos)
		if wisp then
			local wispData = wisp:GetData()
			wispData.heartType = flySubType
			wispData.spawnFlyOnDeath = spawnFlyOnDeath
			wispData.spawnSpiderOnDeath = spawnSpiderOnDeath
			wispData.lifeTime = lifeTime
			return wisp
		end
	end
end

function DukeHelpers.IsValidCustomWisp(familiar)
	if (familiar.Variant == FamiliarVariant.WISP) then
		if (familiar.SubType == DukeHelpers.Items.dukeOfEyes.Id) or (familiar.SubType == DukeHelpers.Items.thePrinces.Id) then
			return true
		end
	end
	return false
end
