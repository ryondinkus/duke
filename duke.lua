-- Add flies on player startup
dukeMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if dukeMod.global.isInitialized and DukeHelpers.IsDuke(player) and (not player:GetData().duke or not player:GetData().duke.isInitialized) then
		DukeHelpers.InitializeDuke(player)
		DukeHelpers.AddStartupFlies(player)
	end
end)

-- Allows the player to fly
dukeMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, f)
	if DukeHelpers.IsDuke(p) then
		p.CanFly = true
	end
end, CacheFlag.CACHE_FLYING)

-- Adds flies when a heart is collected
dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and DukeHelpers.IsDuke(p) and (pickup.Price <= 0 or p:GetNumCoins() >= pickup.Price) then
		local playerData = DukeHelpers.GetDukeData(p)
		if (pickup.SubType == 3320 or pickup.SubType == 3321) then
			local patchedFly = DukeHelpers.GetFlyByPickupSubType(pickup.SubType)
			for i = 1, patchedFly.count do
				if DukeHelpers.CountByProperties(playerData.heartFlies, { subType = DukeHelpers.Flies.BROKEN.heartFlySubType }) > 0 then
					local removedFlies = DukeHelpers.RemoveHeartFlyBySubType(p, DukeHelpers.Flies.BROKEN.heartFlySubType, 1)

					DukeHelpers.SpawnHeartFlyPoof(DukeHelpers.Flies.BROKEN.heartFlySubType, removedFlies[1].Position, p)
				else
					DukeHelpers.AddHeartFly(p, patchedFly, patchedFly.count - i + 1)
					break
				end
			end
			pickup:Remove()
		else
			DukeHelpers.SpawnPickupHeartFly(p, pickup)
		end
		return true
	end
end, PickupVariant.PICKUP_HEART)


-- Handles fly devil deals for Duke
dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and (DukeHelpers.IsDuke(p) or p:HasTrinket(DukeHelpers.Trinkets.pocketOfFlies.Id)) and DukeHelpers.IsFlyPrice(pickup.Price) then
		local heartPrice = DukeHelpers.GetDukeDevilDealPrice(pickup)

		local playerFlyCount = DukeHelpers.GetFlyCount(p)

		if not playerFlyCount or playerFlyCount < heartPrice then
			return true
		end

		DukeHelpers.RemoveOutermostHeartFlies(p, heartPrice)
	end
end)

-- Renders fly devil deal prices
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, pickup)
	DukeHelpers.RenderCustomDevilDealPrice(pickup, "showFliesPrice", "gfx/ui/fly_devil_deal_price.anm2")
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if (DukeHelpers.HasDuke() or DukeHelpers.HasPocketOfFlies()) and pickup.Price < 0 then
		local closestPlayer = DukeHelpers.GetClosestPlayer(pickup.Position)

		if closestPlayer and (DukeHelpers.IsDuke(closestPlayer) or closestPlayer:HasTrinket(DukeHelpers.Trinkets.pocketOfFlies.Id)) then
			pickup:GetData().showFliesPrice = true
			pickup.AutoUpdatePrice = false
			pickup.Price = (pickup.Price % DukeHelpers.PRICE_OFFSET) + DukeHelpers.PRICE_OFFSET
		else
			pickup:GetData().showFliesPrice = nil
			if not pickup.AutoUpdatePrice then
				pickup.AutoUpdatePrice = true
			end
		end
	elseif pickup:GetData().showFliesPrice == true then
		pickup:GetData().showFliesPrice = nil
		if not pickup.AutoUpdatePrice then
			pickup.AutoUpdatePrice = true
		end
	end
end)

-- Adds flies when the player's health changes
dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, p)
	local removedHearts = DukeHelpers.RemoveUnallowedHearts(p)

	-- if DukeHelpers.LengthOfTable(removedHearts) > 0 then
	-- 	DukeHelpers.PrintJson(removedHearts)
	-- end

	for heartKey, removedAmount in pairs(removedHearts) do
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies[heartKey], removedAmount)
	end

	DukeHelpers.KillAtMaxBrokenFlies(p)
end, DukeHelpers.DUKE_ID)

function DukeHelpers.GetDukeData(p)
	local data = p:GetData()
	if not data.duke then
		data.duke = {
			heartFlies = {}
		}
	end

	return data.duke
end

function DukeHelpers.InitializeDuke(p, continued)
	local dukeData = DukeHelpers.GetDukeData(p)
	local sprite = p:GetSprite()
	sprite:Load("gfx/characters/duke.anm2", true)
	if not continued then
		p:SetPocketActiveItem(DukeHelpers.Items.dukesGullet.Id)
		Game():GetItemPool():RemoveCollectible(DukeHelpers.Items.othersGullet.Id)
	end
	dukeData.isInitialized = true
end

dukeMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	DukeHelpers.ForEachDuke(function(p)
		local sprite = p:GetSprite()
		if sprite:IsPlaying("Death") and sprite:GetFrame() == 19 then
			local fliesData = DukeHelpers.GetDukeData(p).heartFlies
			if fliesData then
				for i = #fliesData, 1, -1 do
					local fly = fliesData[i]
					local f = DukeHelpers.GetEntityByInitSeed(fly.initSeed)
					DukeHelpers.SpawnAttackFly(f)
					DukeHelpers.RemoveHeartFly(f)
				end
			end
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, p.Position, Vector.Zero, p)
			DukeHelpers.sfx:Play(SoundEffect.SOUND_ROCKET_BLAST_DEATH)
		end
	end)
end)

dukeMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flags)
	if DukeHelpers.IsDuke(player) and player:GetData().duke and not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		local heartFlies = DukeHelpers.GetDukeData(player).heartFlies
		if heartFlies then
			for i = #heartFlies, 1, -1 do
				local fly = heartFlies[i]
				local f = DukeHelpers.GetEntityByInitSeed(fly.initSeed)
				if f:GetData().layer == DukeHelpers.BIRTHRIGHT then
					DukeHelpers.RemoveHeartFly(f)
					DukeHelpers.SpawnAttackFly(f)
				end
			end
		end
	end
end)
