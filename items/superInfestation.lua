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
            RED = DukeHelpers.GetTrueRedHearts(player),
            BLACK = DukeHelpers.GetTrueBlackHearts(player),
            SOUL = DukeHelpers.GetTrueSoulHearts(player),
            BONE = player:GetBoneHearts(),
            ETERNAL = player:GetEternalHearts(),
            GOLDEN = player:GetGoldenHearts(),
            ROTTEN = player:GetRottenHearts(),
            WEB = DukeHelpers.GetTrueWebHearts(player) / 2,
            IMMORTAL = DukeHelpers.GetTrueImmortalHearts(player),
            MOONLIGHT = DukeHelpers.GetTrueMoonlightHearts(player)
        }

        if not dukeData[Tag] then
            goto skip
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
                for heartKey, amount in pairs(updatedHearts) do
                    DukeHelpers.AddHeartFly(player, DukeHelpers.Flies[heartKey],
                        dukeData[Tag][heartKey] - amount)
                end
            end

            playersTakenDamage[tostring(player.InitSeed)] = nil
        end

        ::skip::
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
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.HUSH, Tag, DukeHelpers.DUKE_NAME)
}
