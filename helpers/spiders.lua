function DukeHelpers.GetSpiderSubTypeByPickupSubType(subType)
    if subType then
        return DukeHelpers.SUBTYPE_OFFSET + subType
    end
end

function DukeHelpers.SpawnSpidersFromPickupSubType(pickupSubType, position, spawnerEntity, specificAmount)
    local foundSpider = DukeHelpers.Find(DukeHelpers.Spiders, function(spider) return spider.pickupSubType == pickupSubType end)

    local spawnedSpiders = {}

    if foundSpider then
        if type(foundSpider.subType) == "table" then
            DukeHelpers.ForEach(foundSpider.subType, function(usedSpider)
                local addedSpiders = DukeHelpers.SpawnSpidersFromPickupSubType(DukeHelpers.Flies[usedSpider.key].subType, position, spawnerEntity, usedSpider.count)

                for _, spider in pairs(addedSpiders) do
                    table.insert(spawnedSpiders, spider)
                end
            end)
        else
            for _ = 1, specificAmount or foundSpider.count or 1 do
                table.insert(spawnedSpiders, Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, foundSpider.subType, position, Vector.Zero, spawnerEntity))
            end
        end
    end

    return spawnedSpiders
end
