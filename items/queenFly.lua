local Names = {
    en_us = "Queen Fly",
    spa = "Mosca Reina"
}
local Name = Names.en_us
local Tag = "queenFly"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Total bitch",
    spa = "Perra total"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Total bitch.")

local function MC_POST_NPC_INIT(_, entity)
    local closestPlayer = DukeHelpers.GetClosestPlayer(entity.Position, function(p) return p:HasCollectible(Id) end)

    if closestPlayer then
        DukeHelpers.AddHeartFly(closestPlayer, DukeHelpers.GetWeightedFly(DukeHelpers.rng), 1)
        entity:Remove()
    end
end

local function MC_FAMILIAR_UPDATE(_, entity)
    if entity.FrameCount == 1 then
        local player = entity.SpawnerEntity

        if player and player:ToPlayer() and player:ToPlayer():HasCollectible(Id) and entity.SubType == 0 then
            local flyToSpawn = DukeHelpers.GetWeightedFly(DukeHelpers.rng, true)

            DukeHelpers.SpawnAttackFlyBySubType(flyToSpawn.heartFlySubType, entity.Position, player)
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
            ModCallbacks.MC_POST_NPC_INIT,
            MC_POST_NPC_INIT,
            EntityType.ENTITY_FLY
        },
        {
            ModCallbacks.MC_FAMILIAR_UPDATE,
            MC_FAMILIAR_UPDATE,
            FamiliarVariant.BLUE_FLY
        }
    }
}
