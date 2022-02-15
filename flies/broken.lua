local key = "FLY_BROKEN"
local spritesheet = "gfx/familiars/broken_heart_fly.png"
local canAttack = false
local subType = 13 -- Not a valid heart pickup
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)
local fliesCount = 2

local function HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK(_, f)
	if f.SubType == subType then
		f.CollisionDamage = 0
        f.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
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
            HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK,
            DukeHelpers.FLY_VARIANT
        },
    }
}
