local Names = {
    en_us = "Super Infestation",
    spa = "Súper infestación"
}
local Name = Names.en_us
local Tag = "superInfestation"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "When taking damage, any health lost will turn into Heart Orbital Flies",
    spa = "Ryan ha infestado mi puta vida"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "When taking damage, any health lost will turn into Heart Orbital Flies.",
    },
    {
        "Interactions",
        "Keeper and Tainted Keeper will gain a Gold Heart Fly for each coin heart taken."
    },
    {
        "Trivia",
        "Super Infestation parallels the original Infestation, which spawns friendly Blue Flies when taking damage.",
    }
})

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

        local updatedHearts = dukeData.health

        if not dukeData.previousHealth then
            return
        end

        if playersTakenDamage[tostring(player.InitSeed)] then
            if DukeHelpers.IsKeeper(player) then
                local totalFliesToSpawn = 0

                DukeHelpers.ForEach(dukeData.previousHealth, function(value, key)
                    totalFliesToSpawn = totalFliesToSpawn + (value - updatedHearts[key])
                end)

                totalFliesToSpawn = math.floor(totalFliesToSpawn / 2)

                DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.GOLDEN, totalFliesToSpawn)
            else
                for heartKey, amount in pairs(updatedHearts) do
                    DukeHelpers.AddHeartFly(player, DukeHelpers.Flies[heartKey],
                        dukeData.previousHealth[heartKey] - amount)
                end
            end

            playersTakenDamage[tostring(player.InitSeed)] = nil
        end
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
