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

function DukeHelpers.GetEntityByInitSeed(initSeed)
    local entities = Isaac.GetRoomEntities()

    for _, entity in pairs(entities) do
        if tostring(entity.InitSeed) == tostring(initSeed) then
            return entity
        end
    end
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

function DukeHelpers.IsActualEnemy(entity, includeBosses, includeInvulnerable)
    return DukeHelpers.IsInPartition(entity.Type, EntityPartition.ENEMY) and
        not DukeHelpers.Find(notEnemies, function(t) return t == entity.Type end) and
        (includeBosses or not entity:IsBoss()) and (includeInvulnerable or entity:IsVulnerableEnemy())
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

function DukeHelpers.GetNearestEnemy(pos, includeBosses, includeInvulnerable, filters)
    local dist
    local near
    local enemies = DukeHelpers.ListEnemiesInRoom(false, function(entity)
        return not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
            and (includeBosses or not entity:IsBoss())
            and (includeInvulnerable or entity:IsVulnerableEnemy())
            and (not filters or filters(entity))
    end)
    for _, ent in ipairs(enemies) do
        local distance = ent.Position:Distance(pos)
        if not dist or distance < dist then
            dist = distance
            near = ent
        end
    end

    return near
end
