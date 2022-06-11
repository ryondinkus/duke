local json = include("json")

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

function DukeHelpers.IsDuke(player, tainted)
    return player and (
        (player:GetPlayerType() == DukeHelpers.DUKE_ID and not tainted)
            or (player:GetPlayerType() == DukeHelpers.HUSK_ID and tainted)
        )
end

function DukeHelpers.HasDuke()
    local found = false
    DukeHelpers.ForEachDuke(function() found = true end)
    return found
end

function DukeHelpers.HasHusk()
    local found = false
    DukeHelpers.ForEachPlayer(function(player)
        if player:GetPlayerType() == DukeHelpers.HUSK_ID then
            found = true
        end
    end)
    return found
end

function DukeHelpers.HasPocketOfFlies()
    local found = false
    DukeHelpers.ForEachPlayer(function(p)
        if p:HasTrinket(DukeHelpers.Trinkets.pocketOfFlies.Id) then
            found = true
        end
    end)
    return found
end

function DukeHelpers.ForEach(t, func)
    for k, v in pairs(t) do
        func(v, k)
    end
end

function DukeHelpers.Map(t, func)
    local mapped = {}
    for k, v in pairs(t) do
        mapped[k] = func(v, k)
    end

    return mapped
end

function DukeHelpers.Filter(t, func)
    local filtered = {}
    local isArray = DukeHelpers.IsArray(t)
    for k, v in pairs(t) do
        if func(v, k) then
            if isArray then
                table.insert(filtered, v)
            else
                filtered[k] = v
            end
        end
    end

    return filtered
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

function DukeHelpers.GetFlyCount(player, includeBroken)
    if not DukeHelpers.IsDuke(player) and not player:HasTrinket(DukeHelpers.Trinkets.pocketOfFlies.Id) then
        return
    end

    local playerData = DukeHelpers.GetDukeData(player)
    if playerData.heartFlies then
        local flyCount = DukeHelpers.LengthOfTable(playerData.heartFlies)
        if not includeBroken then
            flyCount = flyCount -
                DukeHelpers.CountByProperties(playerData.heartFlies,
                    { subType = DukeHelpers.Flies.BROKEN.heartFlySubType })
        end
        return flyCount
    end
end

function DukeHelpers.IsFlyPrice(x)
    return x <= PickupPrice.PRICE_ONE_HEART + DukeHelpers.PRICE_OFFSET and
        x >= PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS + DukeHelpers.PRICE_OFFSET
end

function DukeHelpers.GetDukeDevilDealPrice(collectible)
    return Isaac.GetItemConfig():GetCollectible(collectible.SubType).DevilPrice * 4
end

function DukeHelpers.IsArray(t)
    local i = 0
    for _ in pairs(t) do
        i = i + 1
        if t[i] == nil then return false end
    end
    return true
end

function DukeHelpers.GetTrueImmortalHearts(player)
    if ComplianceImmortal then
        return ComplianceImmortal.GetImmortalHearts(player)
    end

    return 0
end

function DukeHelpers.GetTrueWebHearts(player)
    if ARACHNAMOD then
        local webHearts = ARACHNAMOD:GetData(player).webHearts

        if webHearts then
            return webHearts * 2
        end
    end

    return 0
end

function DukeHelpers.GetTrueSoulHearts(player)
    return player:GetSoulHearts() - DukeHelpers.GetTrueBlackHearts(player) - DukeHelpers.GetTrueImmortalHearts(player) -
        DukeHelpers.GetTrueWebHearts(player)
end

function DukeHelpers.GetTrueBlackHearts(player)
    local binary = DukeHelpers.IntegerToBinary(player:GetBlackHearts())

    local count = select(2, binary:gsub("1", "")) * 2

    if player:GetSoulHearts() % 2 ~= 0 and binary:sub(-1) == "1" then
        count = count - 1
    end

    return count - DukeHelpers.GetTrueImmortalHearts(player) - DukeHelpers.GetTrueWebHearts(player)
end

function DukeHelpers.GetTrueRedHearts(player)
    return player:GetHearts() - (player:GetRottenHearts() * 2)
end

function DukeHelpers.IntegerToBinary(n)
    local binNum = ""
    if n ~= 0 then
        while n >= 1 do
            if n % 2 == 0 then
                binNum = binNum .. "0"
                n = n / 2
            else
                binNum = binNum .. "1"
                n = (n - 1) / 2
            end
        end
    else
        binNum = "0"
    end
    return binNum
end

local notEnemies = {
    EntityType.ENTITY_BOMBDROP,
    EntityType.ENTITY_SHOPKEEPER,
    EntityType.ENTITY_FIREPLACE,
    EntityType.ENTITY_STONEHEAD,
    EntityType.ENTITY_POKY,
    EntityType.ENTITY_ETERNALFLY,
    EntityType.ENTITY_STONE_EYE,
    EntityType.ENTITY_CONSTANT_STONE_SHOOTER,
    EntityType.ENTITY_BRIMSTONE_HEAD,
    EntityType.ENTITY_WALL_HUGGER,
    EntityType.ENTITY_GAPING_MAW,
    EntityType.ENTITY_BROKEN_GAPING_MAW,
    EntityType.ENTITY_POOP,
    EntityType.ENTITY_MOVABLE_TNT,
    EntityType.ENTITY_QUAKE_GRIMACE,
    EntityType.ENTITY_BOMB_GRIMACE,
    EntityType.ENTITY_SPIKEBALL,
    EntityType.ENTITY_DUSTY_DEATHS_HEAD,
    EntityType.ENTITY_BALL_AND_CHAIN,
    EntityType.ENTITY_GENERIC_PROP,
    EntityType.ENTITY_FROZEN_ENEMY,
}

function DukeHelpers.FindInRadius(position, radius, filter)
    local enemies = DukeHelpers.ListEnemiesInRoom(true, filter)

    local inRadiusEnemies = {}
    for _, enemy in pairs(enemies) do
        if position:Distance(enemy.Position) < radius then
            table.insert(inRadiusEnemies, enemy)
        end
    end

    return inRadiusEnemies
end

function DukeHelpers.ListEnemiesInRoom(ignoreVulnerability, filter)
    local entities = Isaac.GetRoomEntities()
    local enemies = {}
    for _, entity in pairs(entities) do
        if DukeHelpers.Find(PartitionedEntities[EntityPartition.ENEMY], function(t) return t == entity.Type end) and
            not DukeHelpers.Find(notEnemies, function(t) return t == entity.Type end) and
            (ignoreVulnerability or entity:IsVulnerableEnemy()) and (not filter or filter(entity, entity:GetData())) then
            table.insert(enemies, entity)
        end
    end
    return enemies
end

function DukeHelpers.AreEnemiesInRoom()
    return #DukeHelpers.ListEnemiesInRoom(true, function(entity) return not EntityRef(entity).IsCharmed end) > 0
end

function DukeHelpers.PercentageChance(percent, max, rng)
    local value
    if percent > (max or 100) then
        value = max or 100
    else
        value = percent
    end

    if not rng then
        rng = DukeHelpers.rng
    end

    return rng:RandomInt(99) + 1 <= value
end

function DukeHelpers.GetClosestPlayer(position, filter)
    local closestPlayerDistance = nil
    local closestPlayer = nil

    DukeHelpers.ForEachPlayer(function(player)
        local distance = position:Distance(player.Position)
        if (not closestPlayer or distance < closestPlayerDistance) and (not filter or filter(player)) then
            closestPlayer = player
            closestPlayerDistance = distance
        end
    end)

    return closestPlayer
end

function DukeHelpers.GetWeightedIndex(t, weightTag, filters, rng)
    if not rng then
        rng = DukeHelpers.rng
    end

    local elements = DukeHelpers.Filter(t,
        function(element) return element[weightTag] and (not filters or filters(element)) end)

    if DukeHelpers.LengthOfTable(t) > 0 then
        local csum = 0
        local outcome = elements[1]
        for _, element in pairs(elements) do
            local weight = element[weightTag]
            local r = rng:RandomInt(csum + weight)

            if r >= csum then
                outcome = element
            end
            csum = csum + weight
        end
        return outcome
    end
end

function DukeHelpers.GetPlayerControllerIndex(player)
    local controllerIndexes = {}
    DukeHelpers.ForEachPlayer(function(p)
        for _, index in pairs(controllerIndexes) do
            if index == p.ControllerIndex then
                return
            end
        end
        table.insert(controllerIndexes, p.ControllerIndex)
    end)
    for i, index in pairs(controllerIndexes) do
        if index == player.ControllerIndex then
            return i - 1
        end
    end
end

function DukeHelpers.RemoveUnallowedHearts(player)
    local playerData = DukeHelpers.GetDukeData(player)
    local removedHearts = {}

    local skippedBlackHearts = playerData.removedWebHearts or 0

    local gottenBlackHearts = DukeHelpers.GetTrueBlackHearts(player)
    local blackHearts = gottenBlackHearts - skippedBlackHearts

    local immortalHearts = DukeHelpers.GetTrueImmortalHearts(player)
    if immortalHearts > 0 then
        removedHearts[DukeHelpers.HeartKeys.IMMORTAL] = immortalHearts
        ComplianceImmortal.AddImmortalHearts(player, -immortalHearts)
        blackHearts = blackHearts - immortalHearts
    end

    local webHearts = DukeHelpers.GetTrueWebHearts(player)
    if webHearts and webHearts > 0 then
        removedHearts[DukeHelpers.HeartKeys.WEB] = webHearts / 2

        local totalSoulHearts = DukeHelpers.GetTrueSoulHearts(player)
        addWebHearts(-webHearts / 2, player)
        local soulHeartsRemoved = totalSoulHearts - DukeHelpers.GetTrueSoulHearts(player)
        player:AddSoulHearts(soulHeartsRemoved)
        blackHearts = blackHearts - soulHeartsRemoved

        playerData.removedWebHearts = soulHeartsRemoved
    elseif skippedBlackHearts > 0 and blackHearts > 0 then
        playerData.removedWebHearts = nil
    end

    if blackHearts > 0 then
        removedHearts[DukeHelpers.HeartKeys.BLACK] = blackHearts
    end

    if blackHearts > 0 or skippedBlackHearts > 0 then
        local totalSoulHearts = DukeHelpers.GetTrueSoulHearts(player)
        player:AddSoulHearts(-player:GetSoulHearts())
        player:AddSoulHearts(totalSoulHearts)
    end

    local boneHearts = player:GetBoneHearts()
    if boneHearts > 0 then
        removedHearts[DukeHelpers.HeartKeys.BONE] = boneHearts
        player:AddBoneHearts(-boneHearts)
    end

    local brokenHearts = player:GetBrokenHearts()
    if brokenHearts > 0 then
        removedHearts[DukeHelpers.HeartKeys.BROKEN] = brokenHearts * 2
        player:AddBrokenHearts(-brokenHearts)

        if DukeHelpers.GetTrueSoulHearts(player) < DukeHelpers.MAX_HEALTH then
            player:AddSoulHearts(DukeHelpers.MAX_HEALTH)
        end
    end

    local eternalHearts = player:GetEternalHearts()
    if eternalHearts > 0 then
        removedHearts[DukeHelpers.HeartKeys.ETERNAL] = eternalHearts
        player:AddEternalHearts(-eternalHearts)
    end

    local goldenHearts = player:GetGoldenHearts()
    if goldenHearts > 0 then
        removedHearts[DukeHelpers.HeartKeys.GOLDEN] = goldenHearts
        player:AddGoldenHearts(-goldenHearts)
    end

    local rottenHearts = player:GetRottenHearts()
    if rottenHearts > 0 then
        removedHearts[DukeHelpers.HeartKeys.ROTTEN] = rottenHearts
        player:AddRottenHearts(-rottenHearts * 2)
    end

    local redHearts = player:GetHearts() + player:GetMaxHearts()
    if redHearts > 0 then
        removedHearts[DukeHelpers.HeartKeys.RED] = redHearts
        player:AddHearts(-player:GetHearts())
        player:AddMaxHearts(-player:GetMaxHearts())
    end

    local soulHearts = DukeHelpers.GetTrueSoulHearts(player)
    if soulHearts > DukeHelpers.MAX_HEALTH then
        local removedAmount = soulHearts - DukeHelpers.MAX_HEALTH
        removedHearts[DukeHelpers.HeartKeys.SOUL] = removedAmount
        player:AddSoulHearts(-removedAmount)
    end

    local moonHearts = player:GetData().moons
    if moonHearts and moonHearts > 0 then
        removedHearts[DukeHelpers.HeartKeys.MOONLIGHT] = moonHearts
        player:GetData().moons = 0
    end

    return removedHearts
end

function DukeHelpers.PrintJson(obj)
    print(json.encode(obj))
end

function DukeHelpers.RenderCustomDevilDealPrice(pickup, key, animationPath)
    local pos = Isaac.WorldToScreen(pickup.Position)

    if pickup:GetData()[key] then
        local devilPrice = DukeHelpers.GetDukeDevilDealPrice(pickup)

        local priceSprite = Sprite()
        priceSprite:Load(animationPath)
        priceSprite:Play(tostring(devilPrice))
        priceSprite:Render(Vector(pos.X, pos.Y + 10), Vector.Zero, Vector.Zero)
    end
end

function DukeHelpers.Sign(x)
    return x > 0 and 1 or x < 0 and -1 or 0
end

function DukeHelpers.CountOccurencesInTable(table, value)
    local found = 0

    for _, v in pairs(table) do
        local notEquals = false
        if v == value then
			found = found + 1
		end
    end

    return found
end
