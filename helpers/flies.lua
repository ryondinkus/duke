-- CONSTANTS

DukeHelpers.FLY_VARIANT = Isaac.GetEntityVariantByName("Red Heart Fly")

DukeHelpers.ATTACK_FLY_STARTING_SUBTYPE = 903

DukeHelpers.INNER = 1
DukeHelpers.MIDDLE = 2
DukeHelpers.OUTER = 3

local INNER = DukeHelpers.INNER
local MIDDLE = DukeHelpers.MIDDLE
local OUTER = DukeHelpers.OUTER

DukeHelpers.Flies = {}

-- FUNCTIONS

function DukeHelpers.SpawnHeartFly(player, subType, layer)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, DukeHelpers.FLY_VARIANT, subType or 1, player.Position, Vector.Zero, player)
	fly:GetData().layer = layer
	DukeHelpers.PositionHeartFly(fly, layer)
	return fly
end

function DukeHelpers.AddHeartFly(player, fly, specificAmount)
	local playerData = DukeHelpers.GetDukeData(player)
	if not playerData.heartFlies then
		playerData.heartFlies = {}
	end

	local heartFlies = {}

	for i = 1, specificAmount or fly.fliesCount or 1 do
		local layer

		if DukeHelpers.CountByProperties(playerData.heartFlies, { layer = INNER }) < 3 then
			layer = INNER
		elseif DukeHelpers.CountByProperties(playerData.heartFlies, { layer = MIDDLE }) < 9 then
			layer = MIDDLE
		elseif DukeHelpers.CountByProperties(playerData.heartFlies, { layer = OUTER }) < 12 then
			layer = OUTER
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
	fly:ToFamiliar():AddToOrbit(DukeHelpers.ATTACK_FLY_STARTING_SUBTYPE + layer)
end

function DukeHelpers.RemoveHeartFly(heartFly)
	local p = heartFly.SpawnerEntity
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

function DukeHelpers.GetFlyByHeartSubType(subType)
    return DukeHelpers.FindByProperties(DukeHelpers.Flies, { heartFlySubType = subType })
end

function DukeHelpers.GetFlyByAttackSubType(subType)
    return DukeHelpers.FindByProperties(DukeHelpers.Flies, { attackFlySubType = subType })
end

function DukeHelpers.GetFlyByPickupSubType(subType)
    return DukeHelpers.FindByProperties(DukeHelpers.Flies, { pickupSubType = subType })
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

function DukeHelpers.GetAttackFlySubTypeBySubType(subType)
	if subType then
    	return DukeHelpers.ATTACK_FLY_STARTING_SUBTYPE + subType
	end
end

function DukeHelpers.GetWeightedFly(rng, attack)
	if not rng then
		rng = DukeHelpers.rng
	end

    local flies = {}
    for _, fly in pairs(DukeHelpers.Flies) do
        if fly.weight and (not attack or fly.attackFlySubType) then
			table.insert(flies, fly)
		end
    end

    if DukeHelpers.LengthOfTable(flies) > 0 then
        local csum = 0
        local outcome = flies[1]
        for _, fly in pairs(flies) do
            local weight = fly.weight
            local r = rng:RandomInt(csum + weight)

            if r >= csum then
                outcome = fly
            end
            csum = csum + weight
        end
        return outcome
    end
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

function DukeHelpers.SpawnPickupHeartFly(player, pickup)
	local sfx = SoundEffect.SOUND_BOSS2_BUBBLES
	if pickup.SubType == HeartSubType.HEART_BLENDED then
		DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.FLY_RED, 1)
		DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.FLY_SOUL, 1)
	else
		local flyToSpawn = DukeHelpers.GetFlyByPickupSubType(pickup.SubType)
		if flyToSpawn.sfx then
			sfx = flyToSpawn.sfx
		end

		local amount = flyToSpawn.fliesCount

		if DukeHelpers.IsDuke(player) then
			if (pickup.SubType == HeartSubType.HEART_SOUL or pickup.SubType == HeartSubType.HEART_HALF_SOUL or pickup.SubType == HeartSubType.HEART_BLACK) and DukeHelpers.GetTrueSoulHearts(player) < DukeHelpers.MAX_HEALTH then
				local heartSlots = 2

				if pickup.SubType == HeartSubType.HEART_HALF_SOUL then
					heartSlots = 1
				end

				local heartsToGive = math.min(DukeHelpers.MAX_HEALTH - DukeHelpers.GetTrueSoulHearts(player), heartSlots)
				player:AddSoulHearts(heartsToGive)
				amount = flyToSpawn.fliesCount - heartsToGive
			end

			DukeHelpers.Trinkets.hollowHeart.helpers.RandomlySpawnHeartFlyFromPickup(player, pickup)
		end
		DukeHelpers.AddHeartFly(player, flyToSpawn, amount)
	end
	DukeHelpers.sfx:Play(sfx)
	pickup:Remove()

	if pickup.Price > 0 then
		player:AddCoins(-pickup.Price)
	end
end