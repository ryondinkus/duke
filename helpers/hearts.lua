function DukeHelpers.IsHeart(pickup, heart)
    if not heart then
        return DukeHelpers.IsSupportedHeart(pickup)
    else
        return pickup.Variant == heart.variant and pickup.SubType == heart.subType
    end
end

function DukeHelpers.ForEachHeartVariant(callback)
    callback(PickupVariant.PICKUP_HEART)
    for _, heart in pairs(DukeHelpers.Hearts) do
        if heart.variant ~= PickupVariant.PICKUP_HEART then
            callback(heart.variant)
        end
    end
end

function DukeHelpers.GetKeyFromPickup(pickup)
    if pickup and pickup.Type == EntityType.ENTITY_PICKUP then
        local foundHeart = DukeHelpers.Find(DukeHelpers.Hearts, function(heart)
            return pickup.Variant == heart.variant and pickup.SubType == heart.subType and not heart.notCollectible
        end)
        return foundHeart and foundHeart.key
    end
end

function DukeHelpers.IsSupportedHeart(pickup)
    return not not DukeHelpers.GetKeyFromPickup(pickup)
end

function DukeHelpers.IsMoonlightHeart(pickup)
    return DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.MOONLIGHT)
end

function DukeHelpers.IsImmortalHeart(pickup)
    return DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.IMMORTAL)
end

function DukeHelpers.IsPatchedHeart(pickup)
    return DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.PATCHED) or
        DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.DOUBLE_PATCHED)
end

function DukeHelpers.IsWebHeart(pickup)
    return DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.WEB)
end

function DukeHelpers.IsDoubleWebHeart(pickup)
    return DukeHelpers.IsHeart(pickup, DukeHelpers.Hearts.DOUBLE_WEB)
end

function DukeHelpers.GetTrueImmortalHearts(player)
    if ComplianceImmortal then
        return ComplianceImmortal.GetImmortalHearts(player)
    end

    return 0
end

function DukeHelpers.GetTrueWebHearts(player)
    if ARACHNAMOD then
        local webHearts = ARACHNAMOD:GetData(player).webHearts

        if webHearts then
            return webHearts * 2
        end
    end

    return 0
end

function DukeHelpers.GetTrueSoulHearts(player)
    return player:GetSoulHearts() - DukeHelpers.GetTrueBlackHearts(player) - DukeHelpers.GetTrueImmortalHearts(player) -
        DukeHelpers.GetTrueWebHearts(player)
end

function DukeHelpers.GetTrueBlackHearts(player)
    local binary = DukeHelpers.IntegerToBinary(player:GetBlackHearts())

    local count = select(2, binary:gsub("1", "")) * 2

    if player:GetSoulHearts() % 2 ~= 0 and binary:sub(-1) == "1" then
        count = count - 1
    end

    return count - DukeHelpers.GetTrueImmortalHearts(player) - DukeHelpers.GetTrueWebHearts(player)
end

function DukeHelpers.GetTrueRedHearts(player)
    return player:GetHearts() - (player:GetRottenHearts() * 2)
end

function DukeHelpers.GetTrueMoonlightHearts(player)
    return player:GetData().moons or Isaac.GetPlayer(0):GetData().moons or 0
end

local function getLeftHeartAmount(leftHearts, key)
    return leftHearts[key] or 0
end

local function minZero(num)
    return math.max(num, 0)
end

function DukeHelpers.RemoveUnallowedHearts(player, leftHearts, ignoreContainers)
    if not leftHearts then
        leftHearts = { SOUL = 4 }
    end

    local playerData = DukeHelpers.GetDukeData(player)
    local removedHearts = {}

    local skippedBlackHearts = playerData.removedWebHearts or 0

    local gottenBlackHearts = DukeHelpers.GetTrueBlackHearts(player)
    local blackHearts = minZero(gottenBlackHearts - skippedBlackHearts -
        getLeftHeartAmount(leftHearts, DukeHelpers.Hearts.BLACK.key))

    local initialSoulHearts = DukeHelpers.GetTrueSoulHearts(player)

    local immortalHearts = minZero(DukeHelpers.GetTrueImmortalHearts(player) -
        getLeftHeartAmount(leftHearts, DukeHelpers.Hearts.IMMORTAL.key))
    if immortalHearts > 0 then
        removedHearts[DukeHelpers.Hearts.IMMORTAL.key] = immortalHearts
        ComplianceImmortal.AddImmortalHearts(player, -immortalHearts)
    end

    local webHearts = minZero(DukeHelpers.GetTrueWebHearts(player) -
        getLeftHeartAmount(leftHearts, DukeHelpers.Hearts.WEB.key))
    if webHearts and webHearts > 0 then
        removedHearts[DukeHelpers.Hearts.WEB.key] = webHearts / 2

        local tempSoulHearts = initialSoulHearts
        addWebHearts(-webHearts / 2, player)
        playerData.removedWebHearts = tempSoulHearts - DukeHelpers.GetTrueSoulHearts(player)
    elseif skippedBlackHearts > 0 and blackHearts > 0 then
        playerData.removedWebHearts = nil
    end

    local soulHeartsRemoved = initialSoulHearts - DukeHelpers.GetTrueSoulHearts(player)
    player:AddSoulHearts(soulHeartsRemoved)

    if blackHearts > 0 then
        removedHearts[DukeHelpers.Hearts.BLACK.key] = blackHearts
    end

    if DukeHelpers.GetTrueBlackHearts(player) > 0 or skippedBlackHearts > 0 then
        local totalSoulHearts = DukeHelpers.GetTrueSoulHearts(player)
        player:AddSoulHearts(-player:GetSoulHearts())
        player:AddSoulHearts(totalSoulHearts)
    end

    local boneHearts = minZero(player:GetBoneHearts() - getLeftHeartAmount(leftHearts, DukeHelpers.Hearts.BONE.key))
    if boneHearts > 0 then
        removedHearts[DukeHelpers.Hearts.BONE.key] = boneHearts
        player:AddBoneHearts(-boneHearts)
    end

    local brokenHearts = minZero(player:GetBrokenHearts() - getLeftHeartAmount(leftHearts, DukeHelpers.Hearts.BROKEN.key))
    if brokenHearts > 0 then
        removedHearts[DukeHelpers.Hearts.BROKEN.key] = brokenHearts * 2
        player:AddBrokenHearts(-brokenHearts)
    end

    local eternalHearts = minZero(player:GetEternalHearts() -
        getLeftHeartAmount(leftHearts, DukeHelpers.Hearts.ETERNAL.key))
    if eternalHearts > 0 then
        removedHearts[DukeHelpers.Hearts.ETERNAL.key] = eternalHearts
        player:AddEternalHearts(-eternalHearts)
    end

    local goldenHearts = minZero(player:GetGoldenHearts() - getLeftHeartAmount(leftHearts, DukeHelpers.Hearts.GOLDEN.key))
    if goldenHearts > 0 then
        removedHearts[DukeHelpers.Hearts.GOLDEN.key] = goldenHearts
        player:AddGoldenHearts(-goldenHearts)
    end

    local rottenHearts = minZero(player:GetRottenHearts() - getLeftHeartAmount(leftHearts, DukeHelpers.Hearts.ROTTEN.key))
    if rottenHearts > 0 then
        removedHearts[DukeHelpers.Hearts.ROTTEN.key] = rottenHearts
        player:AddRottenHearts(-rottenHearts * 2)
    end

    local redHearts = player:GetHearts()
    if not ignoreContainers then
        redHearts = redHearts + player:GetMaxHearts()
    end

    redHearts = minZero(redHearts -
        getLeftHeartAmount(leftHearts, DukeHelpers.Hearts.RED.key))

    if redHearts > 0 then
        removedHearts[DukeHelpers.Hearts.RED.key] = redHearts
        player:AddHearts(-player:GetHearts())

        if not ignoreContainers then
            player:AddMaxHearts(-player:GetMaxHearts())
        end
    end

    local soulHearts = minZero(DukeHelpers.GetTrueSoulHearts(player) -
        getLeftHeartAmount(leftHearts, DukeHelpers.Hearts.SOUL.key))
    if soulHearts > 0 then
        removedHearts[DukeHelpers.Hearts.SOUL.key] = soulHearts
        player:AddSoulHearts(-soulHearts)
    end

    local moonHearts = minZero(DukeHelpers.GetTrueMoonlightHearts(player) -
        getLeftHeartAmount(leftHearts, DukeHelpers.Hearts.MOONLIGHT.key))
    if moonHearts and moonHearts > 0 then
        removedHearts[DukeHelpers.Hearts.MOONLIGHT.key] = moonHearts
        DukeHelpers.AddMoonlightHearts(player, -moonHearts)
    end

    return removedHearts
end

function DukeHelpers.CanPickMoonlightHearts(player)
    return DukeHelpers.GetTrueMoonlightHearts(player) < 12
end

function DukeHelpers.CanPickImmortalHearts(player)
    local hearts = DukeHelpers.GetTrueImmortalHearts(player)

    return hearts and hearts < (player:GetHeartLimit() - player:GetEffectiveMaxHearts())
end

function DukeHelpers.CanPickPatchedHearts(player)
    return PATCH_GLOBAL and (player:CanPickRedHearts() or player:GetBrokenHearts() > 0)
end

function DukeHelpers.CanPickWebHeart(player, double)
    if not ARACHNAMOD or DukeHelpers.GetPlayerControllerIndex(player) ~= 0 then
        return false
    end

    local playerType = player:GetPlayerType()
    if (
        playerType == PlayerType.PLAYER_KEEPER or playerType == PlayerType.PLAYER_KEEPER_B or
            playerType == PlayerType.PLAYER_LOST or playerType == PlayerType.PLAYER_LOST_B)
        or (not player:CanPickSoulHearts()) then
        return false
    end

    player = playerType == PlayerType.PLAYER_THESOUL_B and player:GetMainTwin() or player
    player = playerType == PlayerType.PLAYER_THEFORGOTTEN and player:GetSubPlayer() or player

    local webHeartAmount = ARACHNAMOD:GetData(player).webHearts

    local maxHP = player:GetHeartLimit()
    local healthAmount = maxHP
    if webHeartAmount then
        healthAmount = player:GetSoulHearts() + getRedContainers(player)
    end
    if healthAmount < maxHP and (not double or healthAmount < maxHP - 2) then
        return true
    end
    return false
end

function DukeHelpers.CanPickUpHeart(player, pickup)
    if pickup.Variant == PickupVariant.PICKUP_HEART then
        if pickup.SubType == HeartSubType.HEART_ETERNAL then
            return true
        end
        if pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_HALF or
            pickup.SubType == HeartSubType.HEART_DOUBLEPACK or pickup.SubType == HeartSubType.HEART_SCARED then
            return player:CanPickRedHearts()
        elseif pickup.SubType == HeartSubType.HEART_SOUL or pickup.SubType == HeartSubType.HEART_HALF_SOUL then
            return player:CanPickSoulHearts()
        elseif pickup.SubType == HeartSubType.HEART_BLACK then
            return player:CanPickBlackHearts()
        elseif pickup.SubType == HeartSubType.HEART_BONE then
            return player:CanPickBoneHearts()
        elseif pickup.SubType == HeartSubType.HEART_ROTTEN then
            return player:CanPickRottenHearts()
        elseif pickup.SubType == HeartSubType.HEART_GOLDEN then
            return player:CanPickGoldenHearts()
        elseif pickup.SubType == HeartSubType.HEART_BLENDED then
            return player:CanPickRedHearts() or player:CanPickSoulHearts()
        elseif DukeHelpers.IsImmortalHeart(pickup) then
            return DukeHelpers.CanPickImmortalHearts(player)
        elseif DukeHelpers.IsPatchedHeart(pickup) then
            return DukeHelpers.CanPickPatchedHearts(player)
        end
    elseif DukeHelpers.IsMoonlightHeart(pickup) then
        return DukeHelpers.CanPickMoonlightHearts(player)
    elseif DukeHelpers.IsWebHeart(pickup) then
        return DukeHelpers.CanPickWebHeart(player)
    elseif DukeHelpers.IsDoubleWebHeart(pickup) then
        return DukeHelpers.CanPickWebHeart(player, true)
    end

    return false
end

function DukeHelpers.AddMoonlightHearts(player, amount)
    local data = player:GetData()

    if not data.moons then
        data = Isaac.GetPlayer(0):GetData()
    end

    data.moons = math.max(data.moons + amount, 0)
end
