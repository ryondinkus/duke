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
	fly:ToFamiliar():AddToOrbit(DukeHelpers.ATTACK_FLY_STARTING_SUBTYPE + layer)
	return fly
end

function DukeHelpers.AddHeartFly(player, fly, specificAmount)
	local playerData = player:GetData()
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

function DukeHelpers.RemoveHeartFly(heartFly)
	local p = heartFly.SpawnerEntity
	local playerData = p:GetData()
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
    local foundFly = DukeHelpers.GetFlyByHeartSubType(subType)

    if foundFly then
        return foundFly.spritesheet
    else
        foundFly = DukeHelpers.GetFlyByAttackSubType(subType)
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
    local fly = DukeHelpers.GetFlyByHeartSubType(heartFly.SubType)
	local attackFly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, fly.attackFlySubType, heartFly.Position, Vector.Zero, heartFly.SpawnerEntity)
	local sprite = attackFly:GetSprite()
	sprite:ReplaceSpritesheet(0, DukeHelpers.GetFlySpritesheet(heartFly.SubType))
	sprite:LoadGraphics()
	sprite:Play("Attack", true)
	attackFly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	return attackFly
end

function DukeHelpers.RemoveHeartFly(heartFly)
	local p = heartFly.SpawnerEntity
	if p then
		local playerData = p:GetData()
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

function DukeHelpers.GetAttackFlySubTypeBySubType(subType)
	if subType then
    	return DukeHelpers.ATTACK_FLY_STARTING_SUBTYPE + subType
	end
end