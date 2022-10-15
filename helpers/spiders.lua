function DukeHelpers.GetSpiderByPickupSubType(pickupSubType)
    return DukeHelpers.Find(DukeHelpers.Spiders, function(spider) return spider.pickupSubType == pickupSubType end)
end

function DukeHelpers.GetSpiderBySubType(subType)
    return DukeHelpers.Find(DukeHelpers.Spiders, function(spider) return spider.subType == subType end)
end

function DukeHelpers.GetSpiderSpritesheetFromSubType(subType)
    local foundSpider = DukeHelpers.GetSpiderBySubType(subType)
    if foundSpider then
        return foundSpider.spritesheet
    end
    return DukeHelpers.Spiders.RED.spritesheet
end

function DukeHelpers.IsHeartSpider(spiderEntity)
    return not
        not
        DukeHelpers.Find(DukeHelpers.Spiders,
            function(spider) return (spider.variant and spider.variant == spiderEntity.Variant) or
                    (not spider.variant and spider.subType == spiderEntity.SubType)
            end)
end

function DukeHelpers.InitializeHeartSpider(spider)
    local sprite = spider:GetSprite()
    sprite:ReplaceSpritesheet(0, DukeHelpers.GetSpiderSpritesheetFromSubType(spider.SubType))
    sprite:LoadGraphics()
end

function DukeHelpers.SpawnSpidersFromKey(pickupKey, position, spawnerEntity, specificAmount, noPoof)
    local foundSpider = DukeHelpers.Spiders[pickupKey]

    local spawnedSpiders = {}

    if foundSpider then
        if type(foundSpider.subType) == "table" then
            DukeHelpers.ForEach(foundSpider.subType, function(usedSpider)
                local addedSpiders = DukeHelpers.SpawnSpidersFromKey(usedSpider.key, position,
                    spawnerEntity, usedSpider.count)

                for _, spider in pairs(addedSpiders) do
                    table.insert(spawnedSpiders, spider)
                end
            end)
        else
            for i = 1, specificAmount or foundSpider.count or 1 do
                table.insert(spawnedSpiders,
                    Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, foundSpider.subType,
                        Game():GetRoom():FindFreeTilePosition(position, 0),
                        Vector.Zero, spawnerEntity))
                DukeHelpers.InitializeHeartSpider(spawnedSpiders[i])
                if noPoof then
                    spawnedSpiders[i]:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                end
            end
        end
    end

    return spawnedSpiders
end

function DukeHelpers.GetWeightedSpider(rng)
    return DukeHelpers.GetWeightedIndex(DukeHelpers.Spiders, "weight", nil, rng)
end

function DukeHelpers.SpawnSpiderWisp(wisp, pos, spawner, lifeTime, spawnOnDeath)
    return DukeHelpers.SpawnWisp(wisp, pos, spawner, spawnOnDeath and "spawnSpiderOnDeath" or nil, lifeTime,
        DukeHelpers.Items.dukeOfEyes.Id)
end
