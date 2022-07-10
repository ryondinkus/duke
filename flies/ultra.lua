local key = "ULTRA"
local subType = 101
local attackFlySubType = DukeHelpers.OffsetIdentifier({ subType = subType })

local function ATTACK_FLY_MC_FAMILIAR_UPDATE_ATTACK(_, f)
    if f.SubType == attackFlySubType then
        if f.FrameCount == 6 then
            f.CollisionDamage = f.CollisionDamage * 2
        end
    end
end

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
    if f.SubType == attackFlySubType then
        if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
            local effect = DukeHelpers.rng:RandomInt(3)
            if effect == 0 then
                e:AddFear(EntityRef(f), 150)
            elseif effect == 1 then
                e:AddMidasFreeze(EntityRef(f), 150)
            else
                e:AddPoison(EntityRef(f), 102, 1)
            end
            for i = 1, 8 do
                local tear = f:FireProjectile(Vector.FromAngle(i * 45))
                tear:ChangeVariant(TearVariant.BONE)
            end
            for _ = 0, DukeHelpers.rng:RandomInt(8) do
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, f.Position,
                    Vector.FromAngle(DukeHelpers.rng:RandomInt(360)), f)
            end
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKED_ORB_POOF, 0, f.Position, Vector.Zero, f)
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, f.Position, Vector.Zero, f)
            effect.Color = Color(1, 1, 1, 0, 1, 0.7, 0)
            effect:GetSprite().Scale = Vector(0.5, 0.5)
            DukeHelpers.sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 1, 0)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, f.Position, Vector.Zero, f)
            DukeHelpers.sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 0)
        end
    end
end

local function HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK(_, f)
    if f.SubType == subType then
        if f.FrameCount == 6 then
            local data = DukeHelpers.GetDukeData(f)
            if data.hitPoints == nil then
                data.hitPoints = 2
            end
        end
        f.CollisionDamage = f.CollisionDamage * 2
    end
end

local function HEART_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
    if f.SubType == subType then
        if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) and DukeHelpers.rng:RandomInt(3) == 0 then
            if DukeHelpers.rng:RandomInt(2) == 1 then
                e:AddMidasFreeze(EntityRef(f), 30)
            else
                e:AddPoison(EntityRef(f), 32, 1)
            end
        end
    end
end

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
    if f.SubType == subType then
        if e.Type == EntityType.ENTITY_PROJECTILE and
            not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
            local p = f.SpawnerEntity or Isaac.GetPlayer(0)
            p:ToPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM)
            DukeHelpers.sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 0)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, f.Position, Vector.Zero, nil)
        end
    end
end

local function HEART_FLY_PRE_SPAWN_CLEAN_AWARD()
    for _, entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_FAMILIAR
            and entity.Variant == DukeHelpers.FLY_VARIANT
            and entity.SubType == subType then
            for _ = 1, 2 do
                local spawnedEntity = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0,
                    entity.Position, Vector.Zero, entity.SpawnerEntity)
                spawnedEntity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            end
        end
    end
end

return {
    key = key,
    spritesheet = "ultra_heart_fly.png",
    canAttack = true,
    subType = subType,
    count = 1,
    weight = 0,
    poofColor = Color(1, 1, 1, 1, 1, 1, 1),
    sacAltarQuality = 6,
    callbacks = {
        {
            ModCallbacks.MC_FAMILIAR_UPDATE,
            ATTACK_FLY_MC_FAMILIAR_UPDATE_ATTACK,
            FamiliarVariant.BLUE_FLY
        },
        {
            ModCallbacks.MC_FAMILIAR_UPDATE,
            HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK,
            DukeHelpers.FLY_VARIANT
        },
        {
            ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
            MC_PRE_FAMILIAR_COLLISION,
            DukeHelpers.FLY_VARIANT
        },
        {
            ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
            ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION,
            FamiliarVariant.BLUE_FLY
        },
        {
            ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
            HEART_FLY_MC_PRE_FAMILIAR_COLLISION,
            DukeHelpers.FLY_VARIANT
        },
        {
            ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
            HEART_FLY_PRE_SPAWN_CLEAN_AWARD
        }
    }
}
