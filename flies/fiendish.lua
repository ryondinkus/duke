local key = "FLY_FIENDISH"
local subType = 102
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

local function MC_FAMILIAR_UPDATE(_, f)
	if f.SubType == subType then
		f.CollisionDamage = f.CollisionDamage * 1.5
	end
end

return {
    key = key,
    spritesheet = "gfx/familiars/fiendish_heart_fly.png",
    canAttack = false,
    subType = subType,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.68, 0.22, 0.90),
	sacAltarQuality = 6,
    callbacks = {
        {
            ModCallbacks.MC_FAMILIAR_UPDATE,
            MC_FAMILIAR_UPDATE,
            DukeHelpers.FLY_VARIANT
        }
    }
}
