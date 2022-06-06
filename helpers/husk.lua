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
    if not amount then
        amount = 1
    end

    local slotSpider = DukeHelpers.GetSpiderByPickupSubType(pickupSubType)

    if slotSpider and slotSpider.count then
        amount = amount * slotSpider.count
    end

    local filledSlots = DukeHelpers.GetFilledRottenGulletSlots(player)
    local numberOfFilledSlots = DukeHelpers.LengthOfTable(filledSlots)

    if numberOfFilledSlots + amount > DukeHelpers.MAX_ROTTEN_GULLET_COUNT then
        amount = DukeHelpers.MAX_ROTTEN_GULLET_COUNT - numberOfFilledSlots
    end

    for _ = 1, amount do
        table.insert(filledSlots, pickupSubType)
    end
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
        table.remove(filledSlots, 1)
    end

    return releasedSlots
end
