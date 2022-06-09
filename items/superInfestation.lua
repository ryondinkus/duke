local Names = {
    en_us = "Super Infestation",
    spa = "Súper infestación"
}
local Name = Names.en_us
local Tag = "superInfestation"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Ryan has infested my fucking life",
    spa = "Ryan ha infestado mi puta vida"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Ryan has infested my fucking life.")

local playersTakenDamage = {}

local function MC_ENTITY_TAKE_DMG(_, entity, amount, f)
    local player = entity:ToPlayer()
    if f & DamageFlag.DAMAGE_FAKE == 0 and player and player:HasCollectible(Id) and amount >= 0 then
        playersTakenDamage[tostring(player.InitSeed)] = true
    end
end

local function MC_POST_PLAYER_UPDATE(_, player)
    if player:HasCollectible(Id) then
        local dukeData = DukeHelpers.GetDukeData(player)

        local updatedHearts = {
            RED = player:GetHearts(),
            BLACK = DukeHelpers.GetBlackHearts(player),
            SOUL = DukeHelpers.GetTrueSoulHearts(player),
            BONE = player:GetBoneHearts(),
            ETERNAL = player:GetEternalHearts(),
            GOLDEN = player:GetGoldenHearts(),
            ROTTEN = player:GetRottenHearts()
        }

        if not dukeData[Tag] then
            dukeData[Tag] = updatedHearts
            return
        end

        if playersTakenDamage[tostring(player.InitSeed)] then
            if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
                local totalFliesToSpawn = 0

                DukeHelpers.ForEach(dukeData[Tag], function(value, key)
                    totalFliesToSpawn = totalFliesToSpawn + (value - updatedHearts[key])
                end)

                totalFliesToSpawn = math.floor(totalFliesToSpawn / 2)

                DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.GOLDEN, totalFliesToSpawn)
            else
                local redSpawnAmount = dukeData[Tag].RED - updatedHearts.RED
                local rottenSpawnAmount = dukeData[Tag].ROTTEN - updatedHearts.ROTTEN

                redSpawnAmount = redSpawnAmount - (rottenSpawnAmount * 2)

                DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.RED, redSpawnAmount)
                DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.BLACK, dukeData[Tag].BLACK - updatedHearts.BLACK)
                DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.SOUL, dukeData[Tag].SOUL - updatedHearts.SOUL)
                DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.BONE, dukeData[Tag].BONE - updatedHearts.BONE)
                DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.ETERNAL, dukeData[Tag].ETERNAL - updatedHearts.ETERNAL)
                DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.GOLDEN, dukeData[Tag].GOLDEN - updatedHearts.GOLDEN)
                DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.ROTTEN, rottenSpawnAmount)
            end

            playersTakenDamage[tostring(player.InitSeed)] = nil
        end

        dukeData[Tag] = updatedHearts
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
            ModCallbacks.MC_ENTITY_TAKE_DMG,
            MC_ENTITY_TAKE_DMG,
            EntityType.ENTITY_PLAYER
        },
        {
            ModCallbacks.MC_POST_PLAYER_UPDATE,
            MC_POST_PLAYER_UPDATE
        }
    }
}
