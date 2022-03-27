local key = "FLY_BROKEN"
local subType = 13 -- Not a valid heart pickup
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

local function HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK(_, f)
	if f.SubType == subType then
		f.CollisionDamage = 0
        f.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	end
end

return {
    key = key,
    spritesheet = "gfx/familiars/broken_heart_fly.png",
    canAttack = false,
    subType = subType,
    fliesCount = 2,
    poofColor = Color(0.62, 0, 0, 1, 0, 0, 0),
    callbacks = {
		{
            ModCallbacks.MC_FAMILIAR_UPDATE,
            HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK,
            DukeHelpers.FLY_VARIANT
        },
    }
}
