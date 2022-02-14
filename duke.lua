-- Adds flies on startup
dukeMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	DukeHelpers.ForEachDuke(function(p)
		for i=1, 3 do
			print('running this')
			DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_RED)
		end
	end)
end)

-- Allows the player to fly
dukeMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, f)
	if DukeHelpers.IsDuke(p) then
		p.CanFly = true
	end
end, CacheFlag.CACHE_FLYING)

-- Adds flies when a heart is spawned
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	local isDone = false
	DukeHelpers.ForEachDuke(function(p)
		if not isDone then
			DukeHelpers.AddHeartFly(p, DukeHelpers.GetFlyByPickupSubType(pickup.SubType))
			pickup:Remove()
			isDone = true
		end
	end)
end, PickupVariant.PICKUP_HEART)

-- Adds flies when the player's health changes
dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, p)
	while p:GetBlackHearts() > 0 do
		p:AddBlackHearts(-1)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_BLACK)
	end
	while p:GetBoneHearts() > 0 do
		p:AddBoneHearts(-1)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_BONE)
	end
	if p:GetBrokenHearts() > 0 then
		while p:GetBrokenHearts() > 0 do
			p:AddBrokenHearts(-1)
			DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_BROKEN)
		end
		if p:GetMaxHearts() < 2 then
			p:AddMaxHearts(2)
			p:AddHearts(2)
		end
	end
	while p:GetEternalHearts() > 0 do
		p:AddEternalHearts(-1)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_ETERNAL)
	end
	while p:GetGoldenHearts() > 0 do
		p:AddGoldenHearts(-1)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_GOLDEN)
	end
	while p:GetHearts() > 2 do
		p:AddHearts(-1)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_RED)
	end
	while p:GetMaxHearts() > 2 do
		p:AddMaxHearts(-1, true)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_RED)
	end
	while p:GetRottenHearts() > 0 do
		p:AddRottenHearts(-1)
		p:AddHearts(1)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_ROTTEN)
	end
	while p:GetSoulHearts() > 0 do
		p:AddSoulHearts(-1)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_SOUL)
	end
end, DukeHelpers.DUKE_ID)