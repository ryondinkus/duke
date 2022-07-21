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

    if DukeHelpers.IsKeeper(player) then
        if player:GetHearts() >= 1 then
            fliesToSpawn[DukeHelpers.Flies.GOLDEN.key] = (player:GetHearts() / 2) - 1
            player:AddHearts(-(player:GetHearts() - 2))
        end

        goto keeper
    end

    if player:GetMaxHearts() >= 1 and (player:GetHearts() >= 1) then
        fliesToSpawn = DukeHelpers.RemoveUnallowedHearts(player, { RED = 1 }, true)
    elseif DukeHelpers.Hearts.SOUL.GetCount(player) >= 1 then
        fliesToSpawn = DukeHelpers.RemoveUnallowedHearts(player, { SOUL = 1 }, true)
    elseif DukeHelpers.Hearts.BLACK.GetCount(player) >= 1 then
        fliesToSpawn = DukeHelpers.RemoveUnallowedHearts(player, { BLACK = 1 }, true)
    elseif DukeHelpers.Hearts.BONE.GetCount(player) >= 1 then
        fliesToSpawn = DukeHelpers.RemoveUnallowedHearts(player, { BONE = 1 }, true)
    elseif DukeHelpers.Hearts.IMMORTAL.GetCount(player) >= 1 then
        fliesToSpawn = DukeHelpers.RemoveUnallowedHearts(player, { IMMORTAL = 1 }, true)
    elseif DukeHelpers.Hearts.WEB.GetCount(player) >= 1 then
        fliesToSpawn = DukeHelpers.RemoveUnallowedHearts(player, { WEB = 1 }, true)
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
                DukeHelpers.Hearts.BONE.Add(player, heartsToAdd[DukeHelpers.Hearts.BONE.key])
                heartsToAdd[DukeHelpers.Hearts.BONE.key] = nil
            end

            if heartsToAdd[DukeHelpers.Hearts.ROTTEN.key] then
                DukeHelpers.Hearts.ROTTEN.Add(player, heartsToAdd[DukeHelpers.Hearts.ROTTEN.key] * 2)
                heartsToAdd[DukeHelpers.Hearts.ROTTEN.key] = nil
            end

            DukeHelpers.ForEach(heartsToAdd, function(numHearts, pickupKey)
                local heart = DukeHelpers.Hearts[pickupKey]

                if pickupKey == DukeHelpers.Hearts.GOLDEN.key and DukeHelpers.IsKeeper(player) then
                    DukeHelpers.Hearts.RED.Add(player, numHearts * 2)
                    return
                end

                heart.Add(player, numHearts)

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
