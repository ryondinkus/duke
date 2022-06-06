function DukeHelpers.GetSpiderSubTypeByPickupSubType(subType)
    if subType then
        return DukeHelpers.SUBTYPE_OFFSET + subType
    end
end

function DukeHelpers.GetSpiderByPickupSubType(pickupSubType)
    return DukeHelpers.Find(DukeHelpers.Spiders, function(spider) return spider.pickupSubType == pickupSubType end)
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

function DukeHelpers.GetWeightedSpider(rng)
    return DukeHelpers.GetWeightedIndex(DukeHelpers.Spiders, "weight", nil, rng)
end

function DukeHelpers.SpawnSpiderWispBySubType(flySubType, pos, spawner, spawnSpiderOnDeath, lifeTime)
    local player = spawner:ToPlayer()
    if player then
        local wisp = spawner:ToPlayer():AddWisp(DukeHelpers.Items.dukeOfEyes.Id, pos)
        if wisp then
            local wispData = wisp:GetData()
            wispData.heartType = flySubType
            wispData.spawnFlyOnDeath = spawnSpiderOnDeath
            wispData.lifeTime = lifeTime
            return wisp
        end
    end
end
