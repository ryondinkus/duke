local heart = DukeHelpers.Hearts.ETERNAL

local function MC_FAMILIAR_UPDATE(_, f)
	if f.SubType == heart.subType then
		if f.FrameCount == 6 then
			DukeHelpers.ForEachEntityInRoom(function(entity)
				DukeGiantBookAPI.playDukeGiantBook("Appear", nil, "gfx/ui/giantbook/giantbook_eternalfly.anm2", Color(1, 1, 1, 1),
					Color(1, 1, 1, 0), Color(1, 1, 1, 0))
				for i = 1, 2 do
					DukeHelpers.AddHeartFly(f.SpawnerEntity:ToPlayer(), DukeHelpers.Flies.RED)
					DukeHelpers.RemoveHeartFlyEntity(entity)
					DukeHelpers.RemoveHeartFlyEntity(f)
				end
			end, EntityType.ENTITY_FAMILIAR, DukeHelpers.FLY_VARIANT, heart.subType,
				function(entity)
					return entity.SpawnerEntity.InitSeed == f.SpawnerEntity.InitSeed and entity.InitSeed ~= f.InitSeed
				end)
		end
	end
end

return {
	spritesheet = "eternal_heart_fly.png",
	heart = heart,
	count = 1,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.78, 0.78, 0.78),
	sacAltarQuality = 6,
	sfx = SoundEffect.SOUND_SUPERHOLY,
	callbacks = {
		{
			ModCallbacks.MC_FAMILIAR_UPDATE,
			MC_FAMILIAR_UPDATE,
			DukeHelpers.FLY_VARIANT
		}
	},
	heartFlyDamageMultiplier = 1.5
}
