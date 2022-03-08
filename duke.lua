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

	if p and DukeHelpers.IsDuke(p) and (pickup.Price <= 0 or p:GetNumCoins() >= pickup.Price) then
    local sfx = SoundEffect.SOUND_BOSS2_BUBBLES
		if pickup.SubType == HeartSubType.HEART_BLENDED then
			DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_RED, 1)
			DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_SOUL, 1)
		else
			local flyToSpawn = DukeHelpers.GetFlyByPickupSubType(pickup.SubType)
			if flyToSpawn.sfx then
				sfx = flyToSpawn.sfx
			end

			local amount
			if (pickup.SubType == HeartSubType.HEART_SOUL or pickup.SubType == HeartSubType.HEART_HALF_SOUL or pickup.SubType == HeartSubType.HEART_BLACK) and DukeHelpers.GetTrueSoulHearts(p) < DukeHelpers.MAX_HEALTH then
				local heartSlots = 2

				if pickup.SubType == HeartSubType.HEART_HALF_SOUL then
					heartSlots = 1
				end

				local heartsToGive = math.min(DukeHelpers.MAX_HEALTH - DukeHelpers.GetTrueSoulHearts(p), heartSlots)
				p:AddSoulHearts(heartsToGive)
				amount = flyToSpawn.fliesCount - heartsToGive
			end
			DukeHelpers.AddHeartFly(p, flyToSpawn, amount)
		end
		DukeHelpers.sfx:Play(sfx)
		pickup:Remove()

		if pickup.Price > 0 then
			p:AddCoins(-pickup.Price)
		end

		return true
	end
end, PickupVariant.PICKUP_HEART)

-- Adds flies when the player's health changes
dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, p)
	if DukeHelpers.GetBlackHearts(p) > 0 then
		local totalSoulHearts = DukeHelpers.GetTrueSoulHearts(p)
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_BLACK, DukeHelpers.GetBlackHearts(p))
		p:AddSoulHearts(-p:GetSoulHearts())
		p:AddSoulHearts(totalSoulHearts)
	end

	if p:GetBoneHearts() > 0 then
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_BONE, p:GetBoneHearts())
		p:AddBoneHearts(-p:GetBoneHearts())
	end
	
	if p:GetBrokenHearts() > 0 then
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_BROKEN, p:GetBrokenHearts())
		p:AddBrokenHearts(-p:GetBrokenHearts())
		if DukeHelpers.GetTrueSoulHearts(p) < DukeHelpers.MAX_HEALTH then
			p:AddSoulHearts(DukeHelpers.MAX_HEALTH)
		end
	end

	if p:GetEternalHearts() > 0 then
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_ETERNAL, p:GetEternalHearts())
		p:AddEternalHearts(-p:GetEternalHearts())
	end

	if p:GetGoldenHearts() > 0 then
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_GOLDEN, p:GetGoldenHearts())
		p:AddGoldenHearts(-p:GetGoldenHearts())
	end

	if p:GetHearts() > 0 then
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_RED, p:GetHearts())
		p:AddHearts(-p:GetHearts())
	end

	if p:GetMaxHearts() > 0 then
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_RED, p:GetMaxHearts())
		p:AddMaxHearts(-p:GetMaxHearts(), true)
	end

	if p:GetRottenHearts() > 0 then
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_ROTTEN, p:GetRottenHearts())
		p:AddRottenHearts(-p:GetRottenHearts())
		p:AddHearts(p:GetRottenHearts())
	end

	if DukeHelpers.GetTrueSoulHearts(p) > DukeHelpers.MAX_HEALTH then
		local fliesToSpawn = DukeHelpers.GetTrueSoulHearts(p) - DukeHelpers.MAX_HEALTH
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_SOUL, fliesToSpawn)
		p:AddSoulHearts(-fliesToSpawn)
	end
end, DukeHelpers.DUKE_ID)
