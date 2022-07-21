DukeHelpers.MAX_ROTTEN_GULLET_COUNT = 24

function DukeHelpers.IsHusk(player)
    return DukeHelpers.IsDuke(player, true)
end

function DukeHelpers.ForEachHusk(callback, collectibleId)
    DukeHelpers.ForEachPlayer(function(player)
        if DukeHelpers.IsHusk(player) then
            callback(player, DukeHelpers.GetDukeData(player))
        end
    end, collectibleId)
end

function DukeHelpers.HasHusk()
    local found = false
    DukeHelpers.ForEachHusk(function() found = true end)
    return found
end

function DukeHelpers.GetFilledRottenGulletSlots(player)
    local data = DukeHelpers.GetDukeData(player)
    if data then
        if not data.rottenGulletSlots then
            data.rottenGulletSlots = {}
        end

        return data.rottenGulletSlots
    end
end

function DukeHelpers.FillRottenGulletSlot(player, pickupKey, amount)
    local slotSpider = DukeHelpers.Spiders[pickupKey]

    if not slotSpider then
        return
    end

    if slotSpider.sticksInSlot then
        local data = DukeHelpers.GetDukeData(player)

        data.stuckSlots = (data.stuckSlots or 0) + math.floor((slotSpider.count * (amount) / 2))

        DukeHelpers.SpawnPickupPoof(player, DukeHelpers.Spiders.BROKEN.key)

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
                table.insert(slotsToFill, usedSpider.key)
            end
        end)
    else
        for _ = 1, amount or slotSpider.count do
            table.insert(slotsToFill, pickupKey)
        end
    end

    DukeHelpers.ForEach(slotsToFill, function(slotPickupKey)
        local filledSlots = DukeHelpers.GetFilledRottenGulletSlots(player)
        local numberOfFilledSlots = DukeHelpers.LengthOfTable(filledSlots)

        if DukeHelpers.Hearts.SOUL.GetCount(player) < DukeHelpers.MAX_HEALTH and
            (
            slotPickupKey == DukeHelpers.Hearts.SOUL.key or slotPickupKey == DukeHelpers.Hearts.HALF_SOUL.key or
                slotPickupKey == DukeHelpers.Hearts.BLACK.key) then
            DukeHelpers.Hearts.SOUL.Add(player, 1)
            return
        end

        if numberOfFilledSlots + 1 <= DukeHelpers.GetMaxRottenGulletSlots(player) then
            table.insert(filledSlots, slotPickupKey)

            DukeHelpers.SpawnPickupPoof(player, slotPickupKey)
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

        DukeHelpers.ReleaseRottenGulletSlot(player, filledSlots[1])

        table.remove(filledSlots, 1)
    end

    return releasedSlots
end

function DukeHelpers.ReleaseRottenGulletSlot(player, pickupKey)
    local spider = DukeHelpers.Spiders[pickupKey]
    if spider and spider.onRelease then
        spider.onRelease(player)
    end
end

function DukeHelpers.GetMaxRottenGulletSlots(player)
    return DukeHelpers.MAX_ROTTEN_GULLET_COUNT - (DukeHelpers.GetDukeData(player).stuckSlots or 0)
end

function DukeHelpers.SpawnPickupPoof(player, pickupKey)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, player)

    local color = DukeHelpers.Spiders[pickupKey].poofColor

    if color then
        poof.Color = color
    end

    return poof
end

function DukeHelpers.RemoveRottenGulletSlots(player, amount, force)
    local playerSlots = DukeHelpers.GetFilledRottenGulletSlots(player)
    local playerSlotCount = DukeHelpers.LengthOfTable(playerSlots)

    if not playerSlotCount or (not force and playerSlotCount < amount) then
        return 0
    end

    for _ = 1, math.min(amount, playerSlotCount) do
        table.remove(playerSlots, 1)
    end

    return math.min(amount, playerSlotCount)
end
