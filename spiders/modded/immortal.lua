local function MC_PRE_SPAWN_CLEAN_AWARD()
	if ComplianceImmortal then
		DukeHelpers.ForEachPlayer(function(player)
			if DukeHelpers.IsDuke(player, true) then
				local filledSlots = DukeHelpers.GetFilledRottenGulletSlots(player)
				local immortalHearts = DukeHelpers.CountOccurencesInTable(filledSlots, DukeHelpers.Spiders.IMMORTAL.pickupSubType)
				if immortalHearts % 2 == 1 then
					DukeHelpers.FillRottenGulletSlot(player, DukeHelpers.Spiders.IMMORTAL.key, 1)
				end
			end
		end)
	end
end

return {
	spritesheet = "immortal_heart_spider.png",
	heart = DukeHelpers.Hearts.IMMORTAL,
	count = 2,
	weight = 0,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.78, 1),
	sfx = Isaac.GetSoundIdByName("immortal"),
	callbacks = {
		{
			ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
			MC_PRE_SPAWN_CLEAN_AWARD
		}
	},
	damageMultiplier = 1.3,
	tearDamageMultiplier = 2,
	tearColor = Color(0.8, 0.8, 1, 1, 0.5, 0.5, 0.9),
	uiHeart = {
		animationPath = "gfx/ui/ui_remix_hearts.anm2",
		animationName = "ImmortalHeartHalf"
	}
}
