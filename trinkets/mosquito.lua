local Names = {
    en_us = "Mosquito",
    spa = "Mosquito"
}
local Name = Names.en_us
local Tag = "mosquito"
local Id = Isaac.GetTrinketIdByName(Name)
local Descriptions = {
    en_us = "Enemies tagged as 'fly' or 'spider' will spawn red creep beneath themselves on death",
    spa = "Nom Nom Nom"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Nom Nom Nom")

local flyAndSpiderEnemies = {
    EntityType.ENTITY_FLY,
    EntityType.ENTITY_POOTER,
    EntityType.ENTITY_ATTACKFLY,
    EntityType.ENTITY_BOOMFLY,
    EntityType.ENTITY_SUCKER,
    EntityType.ENTITY_MOTER,
    EntityType.ENTITY_FLY_L2,
    EntityType.ENTITY_RING_OF_FLIES,
    EntityType.ENTITY_FULL_FLY,
    EntityType.ENTITY_DART_FLY,
    EntityType.ENTITY_SWARM,
    EntityType.ENTITY_HUSH_FLY,
    EntityType.ENTITY_WILLO,
    EntityType.ENTITY_FLY_BOMB,
    EntityType.ENTITY_WILLO_L2,
    EntityType.ENTITY_ARMYFLY,
    {
        Type = EntityType.ENTITY_BEAST,
        Variant = 11
    },
    {
        Type = EntityType.ENTITY_BEAST,
        Variant = 21
    },
    {
        Type = EntityType.ENTITY_BEAST,
        Variant = 23
    },
    {
        Type = EntityType.ENTITY_HOPPER,
        Variant = 1
    },
    EntityType.ENTITY_SPIDER,
    EntityType.ENTITY_BIGSPIDER,
    EntityType.ENTITY_BABY_LONG_LEGS,
    EntityType.ENTITY_CRAZY_LONG_LEGS,
    EntityType.ENTITY_SPIDER_L2,
    EntityType.ENTITY_WALL_CREEP,
    EntityType.ENTITY_RAGE_CREEP,
    EntityType.ENTITY_BLIND_CREEP,
    EntityType.ENTITY_RAGLING,
    EntityType.ENTITY_TICKING_SPIDER,
    EntityType.ENTITY_BLISTER,
    EntityType.ENTITY_THE_THING,
    EntityType.ENTITY_ROCK_SPIDER,
    EntityType.ENTITY_MIGRAINE,
    EntityType.ENTITY_SWARM_SPIDER
}

local validEnemies = {}

for _, enemy in pairs(flyAndSpiderEnemies) do
    local e = enemy

    if type(e) ~= "table" then
        e = {
            Type = enemy
        }
    end

    table.insert(validEnemies, e)
end

local function MC_POST_NPC_DEATH(_, entity)
    DukeHelpers.ForEachPlayer(function(player)
        if player:HasTrinket(Id) then
            local foundEnemy = DukeHelpers.Find(validEnemies, function(enemy)
                return entity.Type == enemy.Type and (not enemy.Variant or entity.Variant == enemy.Variant)
            end)

            if foundEnemy then
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, entity.Position, Vector.Zero,
                    entity)
            end
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
            ModCallbacks.MC_POST_NPC_DEATH,
            MC_POST_NPC_DEATH
        }
    },
    unlock = DukeHelpers.GetUnlock({
        DukeHelpers.Unlocks.ISAAC,
        DukeHelpers.Unlocks.BLUE_BABY,
        DukeHelpers.Unlocks.SATAN,
        DukeHelpers.Unlocks.THE_LAMB
    }, Tag, DukeHelpers.HUSK_NAME)
}
