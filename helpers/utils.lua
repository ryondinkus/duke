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
    for x = 0, Game():GetNumPlayers() - 1 do
        local p = Isaac.GetPlayer(x)
        if (not collectibleId or (collectibleId and p:HasCollectible(collectibleId))) and DukeHelpers.IsDuke(p) then
            callback(p, p:GetData())
        end
    end
end

function DukeHelpers.IsDuke(player)
    return player:GetPlayerType() == DukeHelpers.DUKE_ID
end