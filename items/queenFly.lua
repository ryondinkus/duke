local Names = {
    en_us = "Queen Fly",
    spa = "Mosca Reina"
}
local Name = Names.en_us
local Tag = "queenFly"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Any blue flies spawned will convert into Heart Attack Flies of a random type#Any 'basic' fly enemies will spawn a random Heart Attack Fly on death",
    spa = "Perra total"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "Any friendly Blue Flies spawned by the player will convert into Heart Attack Flies of a random type.",
        "- These types include: Red, Soul, Black, Gold, Bone and Rotten. Red and Soul are twice as likely to spawn.",
        "Any ''basic'' fly enemies will spawn a random Heart Attack Fly on death.",
        "- The same rules for random fly generation apply",
        "- ''Basic'' fly enemies include:",
        "-- Fly",
        "-- Attack Fly",
        "-- Ring Fly",
        "-- Moter",
        "-- Eternal Fly",
        "-- Dart Fly",
        "-- Swarm Fly",
        "-- Hush Fly",
        "-- Army Fly",
        "-- Willo",
        "-- Ultra Famine Fly",
        "-- Ultra Pestilence Fly"
    },
    {
        "Synergies",
        "Guppy's Head: Spawns 2-4 random Heart Attack Flies, basically making it a stronger Duke's Gullet."
    },
    {
        "Trivia",
        "No one knows what Queen Fly is the queen of. Awareness of an absence of knowledge counts as trivia.",
    }
})

local flyEnemies = {
    {
        entityType = 13
    },
    {
        entityType = 18
    },
    {
        entityType = 222
    },
    {
        entityType = 80
    },
    {
        entityType = 96
    },
    {
        entityType = 256
    },
    {
        entityType = 281
    },
    {
        entityType = 296
    },
    {
        entityType = 868
    },
    {
        entityType = 808
    },
    {
        entityType = 951,
        variant = 11
    },
    {
        entityType = 951,
        variant = 21
    }
}

local function MC_POST_NPC_DEATH(_, entity)
    if not
        DukeHelpers.Find(flyEnemies,
            function(enemy) return enemy.entityType == entity.Type and
                    (not enemy.variant or enemy.variant == entity.Variant)
            end) then
        return
    end
    local closestPlayer = DukeHelpers.GetClosestPlayer(entity.Position, function(p) return p:HasCollectible(Id) end)

    if closestPlayer then
        local flyToSpawn = DukeHelpers.GetWeightedFly(DukeHelpers.rng, true)

        DukeHelpers.SpawnAttackFlyFromHeartFly(flyToSpawn, entity.Position, closestPlayer)
        entity:Remove()
    end
end

local function MC_FAMILIAR_UPDATE(_, entity)
    if entity.FrameCount == 1 then
        local player = entity.SpawnerEntity

        if player and player:ToPlayer() and player:ToPlayer():HasCollectible(Id) and entity.SubType == 0 then
            local flyToSpawn = DukeHelpers.GetWeightedFly(DukeHelpers.rng, true)

            DukeHelpers.SpawnAttackFlyFromHeartFly(flyToSpawn, entity.Position, player)
            entity:Remove()
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
            ModCallbacks.MC_POST_NPC_DEATH,
            MC_POST_NPC_DEATH
        },
        {
            ModCallbacks.MC_FAMILIAR_UPDATE,
            MC_FAMILIAR_UPDATE,
            FamiliarVariant.BLUE_FLY
        }
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.BEAST, Tag, DukeHelpers.DUKE_NAME)
}
