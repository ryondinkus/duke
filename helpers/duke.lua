function DukeHelpers.IsDuke(player, tainted)
    return player and (
        (player:GetPlayerType() == DukeHelpers.DUKE_ID and not tainted)
            or (player:GetPlayerType() == DukeHelpers.HUSK_ID and tainted)
        )
end

function DukeHelpers.ForEachDuke(callback, collectibleId)
    DukeHelpers.ForEachPlayer(function(player)
        if DukeHelpers.IsDuke(player) then
            callback(player, DukeHelpers.GetDukeData(player))
        end
    end, collectibleId)
end

function DukeHelpers.HasDuke()
    local found = false
    DukeHelpers.ForEachDuke(function() found = true end)
    return found
end

function DukeHelpers.GetFlyCount(player, includeBroken)
    if not DukeHelpers.IsDuke(player) and not DukeHelpers.Trinkets.pocketOfFlies.helpers.HasPocketOfFlies(player) then
        return
    end

    local playerData = DukeHelpers.GetDukeData(player)
    if playerData.heartFlies then
        local flyCount = DukeHelpers.LengthOfTable(playerData.heartFlies)
        if not includeBroken then
            flyCount = flyCount -
                DukeHelpers.CountByProperties(playerData.heartFlies, { key = DukeHelpers.Flies.BROKEN.key })
        end
        return flyCount
    end
end

function DukeHelpers.AddStartupFlies(p)
    DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.RED, 3)
end
