function DukeHelpers.ForEachPlayer(callback, collectibleId)
    for x = 0, Game():GetNumPlayers() - 1 do
        local p = Isaac.GetPlayer(x)
        if (not collectibleId or (collectibleId and p:HasCollectible(collectibleId))) then
            callback(p, p:GetData())
        end
    end
end

function DukeHelpers.GetClosestPlayer(position, filter)
    local closestPlayerDistance = nil
    local closestPlayer = nil

    DukeHelpers.ForEachPlayer(function(player)
        local distance = position:Distance(player.Position)
        if (not closestPlayer or distance < closestPlayerDistance) and (not filter or filter(player)) then
            closestPlayer = player
            closestPlayerDistance = distance
        end
    end)

    return closestPlayer
end

function DukeHelpers.GetPlayerControllerIndex(player)
    local controllerIndexes = {}
    DukeHelpers.ForEachPlayer(function(p)
        for _, index in pairs(controllerIndexes) do
            if index == p.ControllerIndex then
                return
            end
        end
        table.insert(controllerIndexes, p.ControllerIndex)
    end)
    for i, index in pairs(controllerIndexes) do
        if index == player.ControllerIndex then
            return i - 1
        end
    end
end

function DukeHelpers.AnimateHeartPickup(pickup, p)
    if type(pickup) == "userdata" then
        if pickup.Price == 0 then
            pickup:GetSprite():Play("Collect")
            local function removePickupCallback()
                pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                if pickup:GetSprite():IsFinished("Collect") then
                    pickup:Remove()
                    dukeMod:RemoveCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, removePickupCallback)
                end
            end

            dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, removePickupCallback)
        else
            pickup:Remove()
        end

        if pickup.Price > 0 then
            p:AnimatePickup(pickup:GetSprite())
            p:AddCoins(-pickup.Price)
        end
    end
end

function DukeHelpers.AnyPlayerHasTrinket(trinketId)
    local hasTrinket = false
    DukeHelpers.ForEachPlayer(function(player)
        if not hasTrinket then
            hasTrinket = player:HasTrinket(trinketId)
        end
    end)

    return hasTrinket
end

function DukeHelpers.AnyPlayerHasItem(collectibleId)
    local hasItem = false
    DukeHelpers.ForEachPlayer(function()
        hasItem = true
    end, collectibleId)

    return hasItem
end

function DukeHelpers.PlayCustomDeath(e)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, e.Position, Vector.Zero, e)
    DukeHelpers.sfx:Play(SoundEffect.SOUND_ROCKET_BLAST_DEATH)
end

function DukeHelpers.IsKeeper(player)
    return player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B
end

function DukeHelpers.IsLost(player)
    return player:GetPlayerType() == PlayerType.PLAYER_LOST or player:GetPlayerType() == PlayerType.PLAYER_LOST_B
end

function DukeHelpers.OnItemPickup(player, collectible, tag, callback)
    local data = DukeHelpers.GetDukeData(player)

    if data and data[tag] then
        if player:IsExtraAnimationFinished() then
            callback()
            data[tag] = nil
        end
    else
        local targetItem = player.QueuedItem.Item
        if (not targetItem) or targetItem.ID ~= collectible then
            return
        end
        data[tag] = true
    end
end
