local Name = "Love Poop"
local Tag = "lovePoop"
local Id = Isaac.GetEntityVariantByName(Name)

local function MC_NPC_UPDATE(_, entity)
    if entity.Variant == Id then
        local sprite = entity:GetSprite()
        local data = entity:GetData()

        if entity.FrameCount == 0 then
            entity.EntityCollisionClass = EntityCollisionClass.EntityCollisionClass.ENTCOLL_NONE
        end

        if not entity:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
            entity:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
            data.timer = 300
            sprite:ReplaceSpritesheet(0, "gfx/familiars/love_poop.png")
            sprite:LoadGraphics()
        end

        if sprite:IsFinished("Appear") or sprite:IsEventTriggered("Primed") then
            entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            data.state = 1
        end

        if entity.HitPoints < 500 then
            entity.HitPoints = 999
        end

        if data.state and data.state >= 0 then
            data.timer = data.timer - 1

            if data.timer % 30 == 0 then
                data.state = data.state + 1
                DukeHelpers.ForEachPlayer(function(player)
                    player:ThrowFriendlyDip(332, entity.Position, Vector.Zero)
                end, CollectibleType.COLLECTIBLE_DIRTY_MIND)
            end

            sprite:Play("State" .. data.state)

            local enemies = DukeHelpers.ListEnemiesInRoom(true)
            for _, enemy in pairs(enemies) do
                if data.state < 5 then
                    enemy.Target = entity
                else
                    enemy.Target = nil
                end
            end

            if data.state >= 5 then
                local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART, 0, entity.Position,
                    Vector.Zero, entity)
                explosion.Color = Color(1, 1, 1, 1, 0.59, 0, 0.39)
                local damage = 40
                local player = entity.SpawnerEntity:ToFamiliar().Player:ToPlayer()
                if player and (player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND)
                    or player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
                    damage = damage * 2
                end
                local radius = 75
                if Sewn_API and Sewn_API:IsSuper(entity.SpawnerEntity:GetData()) then
                    radius = radius * 2
                    explosion.SpriteScale = explosion.SpriteScale * 2
                end
                for i, enemy in ipairs(Isaac.FindInRadius(entity.Position, radius, EntityPartition.ENEMY)) do
                    enemy:TakeDamage(damage, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0)
                end
                entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                data.state = -1
            end
        end
        if data.state == -1 and not sprite:IsPlaying("Appear") then
            sprite:Play("State5")
        end
    end
end

local function MC_PRE_TEAR_COLLISION(_, tear, collider)
    if collider.Type == EntityType.ENTITY_POOP and collider.Variant == Id then
        return false
    end
end

return {
    Name = Name,
    Tag = Tag,
    Id = Id,
    callbacks = {
        {
            ModCallbacks.MC_NPC_UPDATE,
            MC_NPC_UPDATE,
            EntityType.ENTITY_POOP
        },
        {
            ModCallbacks.MC_PRE_TEAR_COLLISION,
            MC_PRE_TEAR_COLLISION
        }
    }
}
