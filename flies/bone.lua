local heart = DukeHelpers.Hearts.BONE
local attackFlySubType = DukeHelpers.CalculateAttackFlySubType(heart)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
    if f.SubType == attackFlySubType then
        if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
            for i = 1, 8 do
                local tear = f:FireProjectile(Vector.FromAngle(i * 45))
                tear:ChangeVariant(TearVariant.BONE)
            end
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, f.Position, Vector.Zero, f)
            DukeHelpers.sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 0)
        end
    end
end

local function HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK(_, f)
    if f.SubType == heart.subType then
        if f.FrameCount == 6 then
            local data = DukeHelpers.GetDukeData(f)
            if data.hitPoints == nil then
                data.hitPoints = 2
            end
        end
    end
end

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
    if f.SubType == heart.subType then
        if e.Type == EntityType.ENTITY_PROJECTILE and
            not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
            DukeHelpers.sfx:Play(SoundEffect.SOUND_BONE_SNAP, 1, 0)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0, f.Position, Vector.Zero, nil)
        end
    end
end

return {
    spritesheet = "bone_heart_fly.png",
    canAttack = true,
    heart = heart,
    count = 1,
    weight = 1,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0.59, 0.59, 0.59),
    sacAltarQuality = 4,
    sfx = SoundEffect.SOUND_BONE_HEART,
    callbacks = {
        {
            ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
            ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION,
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
        }
    },
    heartFlyDamageMultiplier = 1.3,
    attackFlyDamageMultiplier = 1.3
}
