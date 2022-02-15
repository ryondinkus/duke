-- Adds flies on startup
dukeMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	DukeHelpers.ForEachDuke(function(p)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_RED, 3)
		local sprite = p:GetSprite()
		sprite:Load("gfx/characters/duke.anm2", true)
		p:SetPocketActiveItem(DukeHelpers.Items.dukesGullet.Id)
		Game():GetItemPool():RemoveCollectible(DukeHelpers.Items.othersGullet.Id)
	end)
end)

-- Allows the player to fly
dukeMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, f)
	if DukeHelpers.IsDuke(p) then
		p.CanFly = true
	end
end, CacheFlag.CACHE_FLYING)

-- Adds flies when a heart is spawned
dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()

	if p and DukeHelpers.IsDuke(p) then
		if pickup.SubType == HeartSubType.HEART_BLENDED then
			DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_RED, 1)
			DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_SOUL, 1)
		else
			DukeHelpers.AddHeartFly(p, DukeHelpers.GetFlyByPickupSubType(pickup.SubType))
		end

		pickup:Remove()
		return true
	end
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
		if p:GetSoulHearts() < 4 then
			p:AddSoulHearts(4)
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
	while p:GetHearts() > 0 do
		p:AddHearts(-1)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_RED)
	end
	while p:GetMaxHearts() > 0 do
		p:AddMaxHearts(-1, true)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_RED)
	end
	while p:GetRottenHearts() > 0 do
		p:AddRottenHearts(-1)
		p:AddHearts(1)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_ROTTEN)
	end
	while p:GetSoulHearts() > 4 do
		p:AddSoulHearts(-1)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_SOUL)
	end
end, DukeHelpers.DUKE_ID)
