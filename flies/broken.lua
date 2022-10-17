local heart = DukeHelpers.Hearts.BROKEN

local function HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK(_, f)
    if f.SubType == heart.subType then
        f.CollisionDamage = 0
        f.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end
end

return {
    spritesheet = "broken_heart_fly.png",
    heart = heart,
    count = 2,
    poofColor = Color(0.62, 0, 0, 1, 0, 0, 0),
    sacAltarQuality = 0,
    callbacks = {
        {
            ModCallbacks.MC_FAMILIAR_UPDATE,
            HEART_FLY_MC_FAMILIAR_UPDATE_ATTACK,
            DukeHelpers.FLY_VARIANT
        },
    },
    isInvincible = true
}
