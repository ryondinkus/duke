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
            fliesToSpawn[DukeHelpers.Flies.GOLDEN.key] = (player:GetHearts() / 2) - 1
            player:AddHearts(-(player:GetHearts() - 2))
        end

        goto keeper
    end

    if player:GetMaxHearts() >= 1 and (player:GetHearts() >= 1) then --or tempRottenHearts > 0) then
        fliesToSpawn = DukeHelpers.RemoveUnallowedHearts(player, { RED = 1 }, true)
    elseif player:GetSoulHearts() >= 1 then
        fliesToSpawn = DukeHelpers.RemoveUnallowedHearts(player, { SOUL = 1 }, true)
    elseif player:GetBoneHearts() >= 1 then
        fliesToSpawn = DukeHelpers.RemoveUnallowedHearts(player, { BONE = 1 }, true)
    end

    if player:GetMaxHearts() >= 1 and player:GetHearts() <= 0 then
        player:AddHearts(1)
    end

    ::keeper::
    fliesToSpawn[DukeHelpers.Flies.FIENDISH.key] = 1

    local addedFlies = {}
    local addedWisps = {}

    DukeHelpers.ForEach(fliesToSpawn, function(numFlies, flyKey)
        DukeHelpers.ForEach(DukeHelpers.AddHeartFly(player,
            DukeHelpers.Flies[flyKey], numFlies),
            function(addedFly)
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) and DukeHelpers.Wisps[flyKey] then
                    local wisp = DukeHelpers.SpawnAttackFlyWisp(DukeHelpers.Wisps[flyKey], player.Position,
                        player)
                    table.insert(addedWisps, wisp.InitSeed)
                end
                table.insert(addedFlies, addedFly.InitSeed)
            end)
    end)

    if dukeData[Tag] then
        for _, id in ipairs(addedFlies) do
            table.insert(dukeData[Tag], id)
        end
    else
        dukeData[Tag] = addedFlies
    end

    if dukeData[Tag .. "Wisps"] then
        for _, id in ipairs(addedWisps) do
            table.insert(dukeData[Tag .. "Wisps"], id)
        end
    else
        dukeData[Tag .. "Wisps"] = addedWisps
    end
end

local function MC_POST_NEW_ROOM()
    DukeHelpers.ForEachPlayer(function(player)
        local data = DukeHelpers.GetDukeData(player)

        if data[Tag] then

            local heartsToAdd = {}

            DukeHelpers.ForEach(data[Tag], function(flyInitSeed)
                local foundFly = DukeHelpers.GetEntityByInitSeed(flyInitSeed)

                if foundFly then
                    local heartFly = DukeHelpers.GetHeartFlyByHeartFlySubType(foundFly.SubType)
                    if heartFly.key ~= DukeHelpers.Flies.FIENDISH.key then
                        if heartsToAdd[heartFly.key] then
                            heartsToAdd[heartFly.key] = heartsToAdd[heartFly.key] + 1
                        else
                            heartsToAdd[heartFly.key] = 1
                        end
                    end
                    DukeHelpers.RemoveHeartFlyEntity(foundFly)
                end
            end)

            if heartsToAdd[DukeHelpers.Hearts.BONE.key] then
                player:AddBoneHearts(heartsToAdd[DukeHelpers.Hearts.BONE.key])
                heartsToAdd[DukeHelpers.Hearts.BONE.key] = nil
            end

            if heartsToAdd[DukeHelpers.Hearts.ROTTEN.key] then
                player:AddRottenHearts(heartsToAdd[DukeHelpers.Hearts.ROTTEN.key] * 2)
                heartsToAdd[DukeHelpers.Hearts.ROTTEN.key] = nil
            end

            DukeHelpers.ForEach(heartsToAdd, function(numHearts, pickupKey)
                if pickupKey == DukeHelpers.Hearts.RED.key then
                    player:AddHearts(numHearts)
                elseif pickupKey == DukeHelpers.Hearts.SOUL.key then
                    player:AddSoulHearts(numHearts)
                elseif pickupKey == DukeHelpers.Hearts.ETERNAL.key then
                    player:AddEternalHearts(numHearts)
                elseif pickupKey == DukeHelpers.Hearts.BLACK.key then
                    player:AddBlackHearts(numHearts)
                elseif pickupKey == DukeHelpers.Hearts.GOLDEN.key then
                    if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or
                        player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
                        player:AddHearts(numHearts * 2)
                    else
                        player:AddGoldenHearts(numHearts)
                    end
                elseif pickupKey == DukeHelpers.Hearts.BROKEN.key then
                    player:AddBrokenHearts(numHearts / 2)
                elseif pickupKey == DukeHelpers.Hearts.MOONLIGHT.key then
                    DukeHelpers.AddMoonlightHearts(player, numHearts)
                elseif pickupKey == DukeHelpers.Hearts.IMMORTAL.key then
                    ComplianceImmortal.AddImmortalHearts(player, numHearts)
                elseif pickupKey == DukeHelpers.Hearts.WEB.key then
                    addWebHearts(numHearts, player)
                end

            end)
            data[Tag] = nil
        end
        if data[Tag .. "Wisps"] then
            DukeHelpers.ForEach(data[Tag .. "Wisps"], function(wispInitSeed)
                local foundWisp = DukeHelpers.GetEntityByInitSeed(wispInitSeed)
                if foundWisp then
                    foundWisp:Remove()
                end
            end)
            data[Tag] = nil
        end
    end)
end

local function MC_FAMILIAR_INIT(_, familiar)
    if familiar.SubType == Id then
        familiar:Remove()
    end
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
        },
        {
            ModCallbacks.MC_FAMILIAR_INIT,
            MC_FAMILIAR_INIT,
            FamiliarVariant.WISP
        }
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.MOTHER, Tag, DukeHelpers.DUKE_NAME)
}
