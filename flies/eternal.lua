local key = "FLY_ETERNAL"
local spritesheet = "gfx/familiars/eternal_heart_fly.png"
local canAttack = false
local subType = HeartSubType.HEART_ETERNAL
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)
local fliesCount = 1

local function MC_FAMILIAR_UPDATE(_, f)
	if f.SubType == subType then
		if f.FrameCount == 6 then
			DukeHelpers.ForEachEntityInRoom(function(entity)
				for i=1, 4 do
					DukeHelpers.AddHeartFly(f.SpawnerEntity, DukeHelpers.Flies.FLY_RED)
					DukeHelpers.RemoveHeartFly(entity)
					DukeHelpers.RemoveHeartFly(f)
				end
			end, EntityType.ENTITY_FAMILIAR, DukeHelpers.FLY_VARIANT, subType,
			function(entity)
				return entity.SpawnerEntity.InitSeed == f.SpawnerEntity.InitSeed and entity.InitSeed ~= f.InitSeed
			end)
		end
		f.CollisionDamage = f.CollisionDamage * 1.5
	end
end

return {
    key = key,
    spritesheet = spritesheet,
    canAttack = canAttack,
    subType = subType,
    fliesCount = fliesCount,
    callbacks = {
        {
            ModCallbacks.MC_FAMILIAR_UPDATE,
            MC_FAMILIAR_UPDATE,
            DukeHelpers.FLY_VARIANT
        }
    }
}