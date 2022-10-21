local heart = DukeHelpers.Hearts.ETERNAL

local function MC_FAMILIAR_UPDATE(_, f)
	if f.SubType == heart.subType and f.FrameCount == 6 and f.SpawnerEntity and not f:GetData().eternalMerge then
		local player = f.SpawnerEntity:ToPlayer()

		local otherEternalHeartFlies = DukeHelpers.GetOutermostFlies(player, DukeHelpers.Flies.ETERNAL, 1, f.InitSeed)

		if #otherEternalHeartFlies > 0 then
			local combineWithHeartFly = otherEternalHeartFlies[1]

			DukeHelpers.PlayGiantBook("Appear", nil, Color(1, 1, 1, 1),
				Color(1, 1, 1, 0), Color(1, 1, 1, 0), nil, nil, "gfx/ui/giantbook/giantbook_eternalfly.anm2")
			for _ = 1, 2 do
				DukeHelpers.AddHeartFly(f.SpawnerEntity:ToPlayer(), DukeHelpers.Flies.RED)
			end

			combineWithHeartFly:GetData().eternalMerge = true

			DukeHelpers.RemoveHeartFlyEntity(combineWithHeartFly)
			DukeHelpers.RemoveHeartFlyEntity(f)
		end
	end
end

return {
	spritesheet = "eternal_heart_fly.png",
	heart = heart,
	count = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.78, 0.78),
	sacAltarQuality = 6,
	callbacks = {
		{
			ModCallbacks.MC_FAMILIAR_UPDATE,
			MC_FAMILIAR_UPDATE,
			DukeHelpers.FLY_VARIANT
		}
	},
	heartFlyDamageMultiplier = 1.5,
	isInvincible = true
}
