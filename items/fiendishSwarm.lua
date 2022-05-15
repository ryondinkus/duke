local Names = {
    en_us = "Fiendish Swarm",
    spa = "Enjambre Diabólico"
}
local Name = Names.en_us
local Tag = "fiendishSwarm"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Ryan has infested my fucking life",
    spa = "Ryan ha infestado mi puta vida"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Ryan has infested my fucking life.")

local function MC_USE_ITEM(_, type, rng, player, f)
    local dukeData = DukeHelpers.GetDukeData(player)

    local fliesToSpawn = {}

    if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
        if player:GetHearts() >= 1 then
            fliesToSpawn[DukeHelpers.Flies.FLY_GOLDEN.heartFlySubType] = (player:GetHearts() / 2) - 1
            player:AddHearts(-(player:GetHearts() - 2))
        end

        goto keeper
    end

    fliesToSpawn[DukeHelpers.Flies.FLY_ROTTEN.heartFlySubType] = player:GetRottenHearts()
    player:AddRottenHearts(-player:GetRottenHearts() * 2)

    if player:GetMaxHearts() >= 1 and (player:GetHearts() >= 1) then --or tempRottenHearts > 0) then
        fliesToSpawn[DukeHelpers.Flies.FLY_RED.heartFlySubType] = player:GetHearts() - (player:GetRottenHearts() * 2) - 1

        player:AddHearts(-(player:GetHearts() - 1))

        fliesToSpawn[DukeHelpers.Flies.FLY_SOUL.heartFlySubType] = DukeHelpers.GetTrueSoulHearts(player)
        fliesToSpawn[DukeHelpers.Flies.FLY_BLACK.heartFlySubType] = DukeHelpers.GetBlackHearts(player)
        fliesToSpawn[DukeHelpers.Flies.FLY_BONE.heartFlySubType] = player:GetBoneHearts()

        player:AddSoulHearts(-player:GetSoulHearts())
        player:AddBoneHearts(-player:GetBoneHearts())
    elseif player:GetSoulHearts() >= 1 then
        fliesToSpawn[DukeHelpers.Flies.FLY_SOUL.heartFlySubType] = DukeHelpers.GetTrueSoulHearts(player)
        if DukeHelpers.GetBlackHearts(player) > 0 then
            fliesToSpawn[DukeHelpers.Flies.FLY_BLACK.heartFlySubType] = DukeHelpers.GetBlackHearts(player) - 1
        else
            fliesToSpawn[DukeHelpers.Flies.FLY_SOUL.heartFlySubType] = fliesToSpawn[DukeHelpers.Flies.FLY_SOUL.heartFlySubType] - 1
        end

        player:AddSoulHearts(-(player:GetSoulHearts() - 1))

        fliesToSpawn[DukeHelpers.Flies.FLY_RED.heartFlySubType] = player:GetHearts() - (player:GetRottenHearts() * 2)
        fliesToSpawn[DukeHelpers.Flies.FLY_BONE.heartFlySubType] = player:GetBoneHearts()

        player:AddBoneHearts(-player:GetBoneHearts())
    elseif player:GetBoneHearts() >= 1 then
        fliesToSpawn[DukeHelpers.Flies.FLY_SOUL.heartFlySubType] = DukeHelpers.GetTrueSoulHearts(player)
        fliesToSpawn[DukeHelpers.Flies.FLY_BLACK.heartFlySubType] = DukeHelpers.GetBlackHearts(player)
        fliesToSpawn[DukeHelpers.Flies.FLY_RED.heartFlySubType] = player:GetHearts() - (player:GetRottenHearts() * 2)

        fliesToSpawn[DukeHelpers.Flies.FLY_BONE.heartFlySubType] = player:GetBoneHearts() - 1

        player:AddBoneHearts(-(player:GetBoneHearts() - 1))
        player:AddSoulHearts(-player:GetSoulHearts())
        player:AddHearts(-player:GetHearts())
    end

    fliesToSpawn[DukeHelpers.Flies.FLY_BROKEN.heartFlySubType] = player:GetBrokenHearts() * 2
    player:AddBrokenHearts(-player:GetBrokenHearts())

    fliesToSpawn[DukeHelpers.Flies.FLY_ETERNAL.heartFlySubType] = player:GetEternalHearts()
    player:AddEternalHearts(-player:GetEternalHearts())

    fliesToSpawn[DukeHelpers.Flies.FLY_GOLDEN.heartFlySubType] = player:GetGoldenHearts()
    player:AddGoldenHearts(-player:GetGoldenHearts())

    if player:GetMaxHearts() >= 1 and player:GetHearts() <= 0 then
        player:AddHearts(1)
    end

    ::keeper::
    local addedFlies = {}

    DukeHelpers.ForEach(fliesToSpawn, function(numFlies, flyId)
        DukeHelpers.ForEach(DukeHelpers.AddHeartFly(player, DukeHelpers.FindByProperties(DukeHelpers.Flies, { heartFlySubType = flyId }), numFlies), function(addedFly)
            table.insert(addedFlies, addedFly.InitSeed)
        end)
    end)

    dukeData[Tag] = addedFlies
end

local function MC_POST_NEW_ROOM()
    DukeHelpers.ForEachPlayer(function(player)
        local data = DukeHelpers.GetDukeData(player)

        if data[Tag] then
            local heartsToAdd = {}

            DukeHelpers.ForEach(data[Tag], function(flyInitSeed)
                local foundFly = DukeHelpers.GetEntityByInitSeed(flyInitSeed)

                if foundFly then
                    local heartFly = DukeHelpers.FindByProperties(DukeHelpers.Flies, { heartFlySubType = foundFly.SubType, baseFly = true })

                    if heartsToAdd[heartFly.pickupSubType] then
                        heartsToAdd[heartFly.pickupSubType] = heartsToAdd[heartFly.pickupSubType] + 1
                    else
                        heartsToAdd[heartFly.pickupSubType] = 1
                    end
                    DukeHelpers.RemoveHeartFly(foundFly)
                end
            end)

            if heartsToAdd[HeartSubType.HEART_BONE] then
                player:AddBoneHearts(heartsToAdd[HeartSubType.HEART_BONE])
                heartsToAdd[HeartSubType.HEART_BONE] = nil
            end

            if heartsToAdd[HeartSubType.HEART_ROTTEN] then
                player:AddRottenHearts(heartsToAdd[HeartSubType.HEART_ROTTEN] * 2)
                heartsToAdd[HeartSubType.HEART_ROTTEN] = nil
            end

            DukeHelpers.ForEach(heartsToAdd, function(numHearts, pickupSubType)
                if pickupSubType == HeartSubType.HEART_FULL then
                    player:AddHearts(numHearts)
                elseif pickupSubType == HeartSubType.HEART_SOUL then
                    player:AddSoulHearts(numHearts)
                elseif pickupSubType == HeartSubType.HEART_ETERNAL then
                    player:AddEternalHearts(numHearts)
                elseif pickupSubType == HeartSubType.HEART_BLACK then
                    player:AddBlackHearts(numHearts)
                elseif pickupSubType == HeartSubType.HEART_GOLDEN then
                    if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
                        player:AddHearts(numHearts * 2)
                    else
                        player:AddGoldenHearts(numHearts)
                    end
                end
            end)
            data[Tag] = nil
        end
    end)
end

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
    Id = Id,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    callbacks = {
        {
            ModCallbacks.MC_USE_ITEM,
            MC_USE_ITEM,
            Id
        },
        {
            ModCallbacks.MC_POST_NEW_ROOM,
            MC_POST_NEW_ROOM
        }
    }
}
