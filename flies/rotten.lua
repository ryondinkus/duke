local key = "FLY_ROTTEN"
local subType = HeartSubType.HEART_ROTTEN
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

local function ATTACK_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == attackFlySubType then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddPoison(EntityRef(f), 102, 1)
		end
	end
end

local function HEART_FLY_MC_PRE_FAMILIAR_COLLISION(_, f, e)
    if f.SubType == subType then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) and DukeHelpers.rng:RandomInt(3) == 0 then
            e:AddPoison(EntityRef(f), 32, 1)
		end
	end
end

local function HEART_FLY_PRE_SPAWN_CLEAN_AWARD()
    for _,entity in pairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_FAMILIAR
        and entity.Variant == DukeHelpers.FLY_VARIANT
        and entity.SubType == subType then
            for _ = 1,2 do
                local spawnedEntity = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, entity.Position, Vector.Zero, nil)
                spawnedEntity:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            end
        end
    end
end

return {
    key = key,
    spritesheet = "gfx/familiars/rotten_heart_fly.png",
    canAttack = true,
    subType = subType,
    fliesCount = 1,
	weight = 1,
    poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.20, 0),
    sfx = SoundEffect.SOUND_ROTTEN_HEART,
    callbacks = {
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
