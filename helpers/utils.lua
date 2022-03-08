function DukeHelpers.FindByProperties(t, props)
    local found
    for _, value in pairs(t) do
        local notEquals = false
        for propKey, propValue in pairs(props) do
            if value[propKey] ~= propValue then
                notEquals = true
                break
            end
        end
        
        if not notEquals then
            found = value
            break
        end
    end
    
    return found
end

function DukeHelpers.CountByProperties(t, props)
    local found = 0
    for _, value in pairs(t) do
        local notEquals = false
        for propKey, propValue in pairs(props) do
            if value[propKey] ~= propValue then
                notEquals = true
                break
            end
        end
        
        if not notEquals then
            found = found + 1
        end
    end
    
    return found
end

function DukeHelpers.ForEachEntityInRoom(callback, entityType, entityVariant, entitySubType, extraFilters)
    local filters = {
        Type = entityType,
        Variant = entityVariant,
        SubType = entitySubType
    }

    local initialEntities = Isaac.GetRoomEntities()
    for _, entity in ipairs(initialEntities) do
        local shouldReturn = true
        for entityKey, filter in pairs(filters) do
            if not shouldReturn then
                break
            end

            if filter ~= nil then
                if type(filter) == "function" then
                    shouldReturn = filter(entity[entityKey])
                else
                    shouldReturn = entity[entityKey] == filter
                end
            end
        end

        if shouldReturn and extraFilters ~= nil then
            shouldReturn = extraFilters(entity)
        end

        if shouldReturn then
            callback(entity)
        end
	end
end

function DukeHelpers.ForEachDuke(callback, collectibleId)
    DukeHelpers.ForEachPlayer(function(player, playerData)
        if DukeHelpers.IsDuke(player) then
            callback(player, DukeHelpers.GetDukeData(player))
        end
    end, collectibleId)
end

function DukeHelpers.ForEachPlayer(callback, collectibleId)
    for x = 0, Game():GetNumPlayers() - 1 do
        local p = Isaac.GetPlayer(x)
        if (not collectibleId or (collectibleId and p:HasCollectible(collectibleId))) then
            callback(p, p:GetData())
        end
    end
end

function DukeHelpers.IsDuke(player)
    return player:GetPlayerType() == DukeHelpers.DUKE_ID
end

function DukeHelpers.HasDuke()
    local found = false
    DukeHelpers.ForEachDuke(function() found = true end)
    return found
end

function DukeHelpers.Map(t, func)
    local mapped = {}
    for k, v in pairs(t) do
        mapped[k] = func(v, k)
    end

    return mapped
end

function DukeHelpers.GetEntityByInitSeed(initSeed)
    local entities = Isaac.GetRoomEntities()

    for _, entity in pairs(entities) do
        if tostring(entity.InitSeed) == tostring(initSeed) then
            return entity
        end
    end
end

function DukeHelpers.Find(t, func)
    for k, v in pairs(t) do
        if func(v, k) then
            return v
        end
    end
end

function DukeHelpers.LengthOfTable(t)
    local num = 0
    for _ in pairs(t) do
        num = num + 1
    end
    return num
end

function DukeHelpers.GetFlyCounts()
    local flyCounts = {}

    DukeHelpers.ForEachDuke(function(duke, dukeData)
        if dukeData.heartFlies then
            local flyCount = {}
            flyCount.RED = DukeHelpers.CountByProperties(dukeData.heartFlies, { subType = DukeHelpers.Flies.FLY_RED.heartFlySubType }) + (DukeHelpers.CountByProperties(dukeData.heartFlies, { subType = DukeHelpers.Flies.FLY_BONE.heartFlySubType }) * 2) + (DukeHelpers.CountByProperties(dukeData.heartFlies, { subType = DukeHelpers.Flies.FLY_ROTTEN.heartFlySubType }) * 2)
            flyCount.SOUL = DukeHelpers.CountByProperties(dukeData.heartFlies, { subType = DukeHelpers.Flies.FLY_SOUL.heartFlySubType }) + DukeHelpers.CountByProperties(dukeData.heartFlies, { subType = DukeHelpers.Flies.FLY_BLACK.heartFlySubType })
            flyCounts[tostring(duke.InitSeed)] = flyCount
        end
    end)

    return flyCounts
end

function DukeHelpers.IsFlyPrice(x)
    return x <= PickupPrice.PRICE_ONE_HEART + DukeHelpers.PRICE_OFFSET and x >= PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS + DukeHelpers.PRICE_OFFSET
end

function DukeHelpers.GetDukeDevilDealPrice(collectible)
    local flyCounts = DukeHelpers.GetFlyCounts()

    return DukeHelpers.CalculateDevilDealPrice(collectible, flyCounts)
end

function DukeHelpers.CalculateDevilDealPrice(collectible, counts)
    if not dukeMod.global.floorDevilDealChance then
        dukeMod.global.floorDevilDealChance = DukeHelpers.rng:RandomInt(99)
    end
    
    local devilPrice = Isaac.GetItemConfig():GetCollectible(collectible.SubType).DevilPrice

    local canAffordSouls = DukeHelpers.Find(counts, function(player) return player.SOUL >= 6 end)

    if devilPrice == 1 then
        local canAffordReds = DukeHelpers.Find(counts, function(player) return player.RED >= 4 end)

        if canAffordReds and canAffordSouls then
            -- 4 red flies or 6 soul flies for Duke
            if dukeMod.global.floorDevilDealChance < 75 then
                return {
                    RED = 4,
                    SOUL = 0
                }
            else
                return {
                    RED = 0,
                    SOUL = 6
                }
            end
        elseif not canAffordReds and canAffordSouls then
            -- 6 soul flies for Duke
            return {
                RED = 0,
                SOUL = 6
            }
        else
            -- 4 red flies for Duke
            return {
                RED = 4,
                SOUL = 0
            }
        end
    else
        local canAffordReds = DukeHelpers.Find(counts, function(player) return player.RED >= 8 end)

        if canAffordReds and canAffordSouls then
            -- 8 red flies or 6 soul flies for Duke
            if dukeMod.global.floorDevilDealChance < 75 then
                return {
                    RED = 4,
                    SOUL = 0
                }
            else
                return {
                    RED = 0,
                    SOUL = 6
                }
            end
        elseif DukeHelpers.Find(counts, function(player) return player.RED >= 4 end) and DukeHelpers.Find(counts, function(player) return player.SOUL >= 4 end) then
            -- 4 red flies and 4 soul flies for Duke
            return {
                RED = 4,
                SOUL = 4
            }
        elseif not canAffordReds and canAffordSouls then
            -- 6 soul flies for Duke
            return {
                RED = 0,
                SOUL = 6
            }
        else
            -- 8 red flies for Duke
            return {
                RED = 8,
                SOUL = 0
            }
        end
    end
end

function DukeHelpers.IsArray(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

function DukeHelpers.GetTrueSoulHearts(player)
    return player:GetSoulHearts() - DukeHelpers.GetBlackHearts(player)
end

function DukeHelpers.GetBlackHearts(player)
    local binary = DukeHelpers.IntegerToBinary(player:GetBlackHearts())

    local count = select(2, binary:gsub("1", "")) * 2

    if player:GetSoulHearts() % 2 ~= 0 and binary:sub(-1) == "1" then
        count = count - 1
    end

    return count
end

function DukeHelpers.IntegerToBinary(n)
	local binNum = ""
	if n ~= 0 then
		while n >= 1 do
			if n % 2 == 0 then
				binNum = binNum.."0"
				n = n / 2
			else
				binNum = binNum.."1"
				n = (n-1)/2
			end
		end
	else
		binNum = "0"
	end
	return binNum
end