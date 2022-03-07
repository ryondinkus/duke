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
			DukeHelpers.AddHeartFly(p, flyToSpawn)
		end
		DukeHelpers.sfx:Play(sfx)
		pickup:Remove()

		if pickup.Price > 0 then
			p:AddCoins(-pickup.Price)
		end

		return true
	end
end, PickupVariant.PICKUP_HEART)

dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()
	if p then
		local heartPrice = DukeHelpers.Find(DukeHelpers.Prices, function(v) return v.price == pickup.Price end)
		if heartPrice then
			if DukeHelpers.IsDuke(p) then
				local fliesData = p:GetData().heartFlies
				local hasEnough = true
				for subType, count in pairs(heartPrice.flies) do
					if DukeHelpers.CountByProperties(fliesData, { subType = subType }) < count then
						hasEnough = false
						break
					end
				end

				if hasEnough then
					for subType, count in pairs(heartPrice.flies) do
						local layer = DukeHelpers.OUTER
						for _ = 1, count do
							local foundFly

							while not foundFly do
								foundFly = DukeHelpers.Find(fliesData, function(fly)
									return fly.subType == subType and fly.layer == layer
								end)

								if not foundFly then
									layer = layer - 1
								end
							end

							DukeHelpers.RemoveHeartFly(DukeHelpers.GetEntityByInitSeed(foundFly.initSeed))
						end
					end

					return nil
				end

				return true
			else

			end
		end
	end
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, pickup)
	local pos = Isaac.WorldToScreen(pickup.Position)

	if pickup:GetData().showFliesPrice then
		local devilPrice = DukeHelpers.GetDukeDevilDealPrice(pickup)
		Isaac.RenderText(tostring(devilPrice.RED), pos.X - 12, pos.Y + 10, 1, 0, 0, 1)
		Isaac.RenderText(tostring(devilPrice.SOUL), pos.X + 6, pos.Y + 10, 0, 0, 1, 1)
	end
end)

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

dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if DukeHelpers.HasDuke() and pickup.Price < 0 then
		local closestPlayerDistance = nil
		local closestPlayer = nil

		DukeHelpers.ForEachPlayer(function(player)
			local distance = pickup.Position:Distance(player.Position)
			if not closestPlayer or distance < closestPlayerDistance then
				closestPlayer = player
				closestPlayerDistance = distance
			end
		end)

		if closestPlayer and DukeHelpers.IsDuke(closestPlayer) then
			pickup:GetData().showFliesPrice = true
			pickup.AutoUpdatePrice = false
			pickup.Price = pickup.Price + DukeHelpers.PRICE_OFFSET
		else
			pickup:GetData().showFliesPrice = nil
			if not pickup.AutoUpdatePrice then
				pickup.AutoUpdatePrice = true
			end
		end
	end
end)