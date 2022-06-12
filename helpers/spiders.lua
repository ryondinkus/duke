function DukeHelpers.GetSpiderSubTypeByPickupSubType(subType)
    if subType then
        return DukeHelpers.SUBTYPE_OFFSET + subType
    end
end

function DukeHelpers.GetSpiderByPickupSubType(pickupSubType)
    return DukeHelpers.Find(DukeHelpers.Spiders, function(spider) return spider.pickupSubType == pickupSubType end)
end

function DukeHelpers.GetSpiderSpritesheet(subType)
    local foundSpider = DukeHelpers.GetSpiderByPickupSubType(subType - 903)
    if foundSpider then
        return foundSpider.spritesheet
    end
    return DukeHelpers.Spiders.RED.spritesheet
end

function DukeHelpers.InitializeHeartSpider(spider)
    local sprite = spider:GetSprite()
    sprite:ReplaceSpritesheet(0, DukeHelpers.GetSpiderSpritesheet(spider.SubType))
    sprite:LoadGraphics()
end

function DukeHelpers.SpawnSpidersFromPickupSubType(pickupSubType, position, spawnerEntity, specificAmount)
    local foundSpider = DukeHelpers.Find(DukeHelpers.Spiders,
        function(spider) return spider.pickupSubType == pickupSubType end)

    local spawnedSpiders = {}

    if foundSpider then
        if type(foundSpider.subType) == "table" then
            DukeHelpers.ForEach(foundSpider.subType, function(usedSpider)
                local addedSpiders = DukeHelpers.SpawnSpidersFromPickupSubType(DukeHelpers.Flies[usedSpider.key].subType
                    , position, spawnerEntity, usedSpider.count)

                for _, spider in pairs(addedSpiders) do
                    table.insert(spawnedSpiders, spider)
                end
            end)
        else
            for i = 1, specificAmount or foundSpider.count or 1 do
                table.insert(spawnedSpiders,
                    Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, foundSpider.subType, position,
                        Vector.Zero, spawnerEntity))
                DukeHelpers.InitializeHeartSpider(spawnedSpiders[i])
            end
        end
    end

    return spawnedSpiders
end

function DukeHelpers.GetWeightedSpider(rng)
    return DukeHelpers.GetWeightedIndex(DukeHelpers.Spiders, "weight", nil, rng)
end

function DukeHelpers.SpawnSpiderWispBySubType(flySubType, pos, spawner, spawnSpiderOnDeath, lifeTime)
    return DukeHelpers.SpawnAttackFlyWispBySubType(flySubType, pos, spawner, spawnSpiderOnDeath, lifeTime, true)
end
