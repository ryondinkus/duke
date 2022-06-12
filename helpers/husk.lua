DukeHelpers.MAX_ROTTEN_GULLET_COUNT = 24

function DukeHelpers.GetFilledRottenGulletSlots(player)
    local data = DukeHelpers.GetDukeData(player)
    if data then
        if not data.rottenGulletSlots then
            data.rottenGulletSlots = {}
        end

        return data.rottenGulletSlots
    end
end

function DukeHelpers.FillRottenGulletSlot(player, pickupSubType, amount)
    local slotSpider = DukeHelpers.GetSpiderByPickupSubType(pickupSubType)

    if not slotSpider then
        return
    end

    if slotSpider.sticksInSlot then
        local data = DukeHelpers.GetDukeData(player)

        data.stuckSlots = (data.stuckSlots or 0) + math.floor((slotSpider.count * (amount) / 2))

        DukeHelpers.SpawnPickupPoof(player, DukeHelpers.Spiders.BROKEN.pickupSubType)

        if data.stuckSlots >= DukeHelpers.MAX_ROTTEN_GULLET_COUNT then
            player:Kill()
        end
        return
    end

    local slotsToFill = {}

    if type(slotSpider.subType) == "table" then
        DukeHelpers.ForEach(slotSpider.subType, function(used)
            local usedSpider = DukeHelpers.Spiders[used.key]
            for _ = 1, amount or used.count do
                table.insert(slotsToFill, usedSpider.pickupSubType)
            end
        end)
    else
        for _ = 1, amount or slotSpider.count do
            table.insert(slotsToFill, pickupSubType)
        end
    end

    DukeHelpers.ForEach(slotsToFill, function(slotPickupSubType)
        local filledSlots = DukeHelpers.GetFilledRottenGulletSlots(player)
        local numberOfFilledSlots = DukeHelpers.LengthOfTable(filledSlots)

        if DukeHelpers.GetTrueSoulHearts(player) < DukeHelpers.MAX_HEALTH and
            (
            slotPickupSubType == HeartSubType.HEART_SOUL or slotPickupSubType == HeartSubType.HEART_HALF_SOUL or
                slotPickupSubType == HeartSubType.HEART_BLACK) then
            player:AddSoulHearts(1)
            return
        end

        if numberOfFilledSlots + 1 <= DukeHelpers.GetMaxRottenGulletSlots(player) then
            table.insert(filledSlots, slotPickupSubType)

            DukeHelpers.SpawnPickupPoof(player, slotPickupSubType)
        end
    end)
end

function DukeHelpers.ReleaseRottenGulletSlots(player, amount)
    if not amount then
        amount = 1
    end

    local filledSlots = DukeHelpers.GetFilledRottenGulletSlots(player)
    local numberOfFilledSlots = DukeHelpers.LengthOfTable(filledSlots)

    if amount > numberOfFilledSlots then
        amount = numberOfFilledSlots
    end

    local releasedSlots = {}

    for _ = 1, amount do
        table.insert(releasedSlots, filledSlots[1])

        local spider = DukeHelpers.GetSpiderByPickupSubType(filledSlots[1])
        if spider and spider.onRelease then
            spider.onRelease(player)
        end

        table.remove(filledSlots, 1)
    end

    return releasedSlots
end

function DukeHelpers.GetMaxRottenGulletSlots(player)
    return DukeHelpers.MAX_ROTTEN_GULLET_COUNT - (DukeHelpers.GetDukeData(player).stuckSlots or 0)
end

function DukeHelpers.SpawnPickupPoof(player, pickupSubType)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player)

    local color = DukeHelpers.GetSpiderByPickupSubType(pickupSubType).poofColor

    if color then
        poof.Color = color
    end

    return poof
end
