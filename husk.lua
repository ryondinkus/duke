-- Add flies on player startup
dukeMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if dukeMod.global.isInitialized and DukeHelpers.IsHusk(player) and (not player:GetData().duke or not player:GetData().duke.isInitialized) then
		DukeHelpers.InitializeHusk(player)
		DukeHelpers.AddStartupSpiders(player)
	end
end)

-- Allows the player to fly
dukeMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, f)
	if DukeHelpers.IsHusk(p) then
		p.CanFly = true
	end
end, CacheFlag.CACHE_FLYING)

-- Fill slots when the player's health changes
dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, p)
	local removedHearts = DukeHelpers.RemoveUnallowedHearts(p)

	for heartKey, removedAmount in pairs(removedHearts) do
		DukeHelpers.FillRottenGulletSlot(p, DukeHelpers.Spiders[heartKey].pickupSubType, removedAmount)
	end
end, DukeHelpers.HUSK_ID)

-- Fill slots when a heart is collected
dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and DukeHelpers.IsHusk(p) and (pickup.Price <= 0 or p:GetNumCoins() >= pickup.Price) then
		local playerData = DukeHelpers.GetDukeData(p)

		local spider = DukeHelpers.GetSpiderByPickupSubType(pickup.SubType)

		if (pickup.SubType == 3320 or pickup.SubType == 3321) then
			local leftoverSlots = spider.count
			if playerData.stuckSlots and playerData.stuckSlots > 0 then
				leftoverSlots = math.max(0, leftoverSlots - playerData.stuckSlots)
				if playerData.stuckSlots >= spider.count then
					playerData.stuckSlots = playerData.stuckSlots - spider.count
				else
					playerData.stuckSlots = 0
				end
			end

			DukeHelpers.FillRottenGulletSlot(p, spider.pickupSubType, leftoverSlots)
		else
			DukeHelpers.FillRottenGulletSlot(p, pickup.SubType)
		end

		local sfx = SoundEffect.SOUND_BOSS2_BUBBLES

		if pickup then
			if spider.sfx then
				sfx = spider.sfx
			end

			DukeHelpers.sfx:Play(sfx)
			pickup:Remove()

			if pickup.Price > 0 then
				p:AnimatePickup(pickup:GetSprite())
				p:AddCoins(-pickup.Price)
			end
		end

		return true
	end
end, PickupVariant.PICKUP_HEART)

-- Handles slot devil deals for Husk
dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and DukeHelpers.IsHusk(p) and DukeHelpers.IsFlyPrice(pickup.Price) then
		local heartPrice = DukeHelpers.GetDukeDevilDealPrice(pickup)

		local playerSlots = DukeHelpers.GetFilledRottenGulletSlots(p)
		local playerSlotCount = DukeHelpers.LengthOfTable(DukeHelpers.GetFilledRottenGulletSlots(p))

		if not playerSlotCount or playerSlotCount < heartPrice then
			return true
		end

		for _ = 1, heartPrice do
			table.remove(playerSlots, 1)
		end
	end
end)

-- Renders slot devil deal prices
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, pickup)
	DukeHelpers.RenderCustomDevilDealPrice(pickup, "showSlotsPrice", "gfx/ui/slot_devil_deal_price.anm2")
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if DukeHelpers.HasHusk() and pickup.Price < 0 then
		local closestPlayer = DukeHelpers.GetClosestPlayer(pickup.Position)

		if closestPlayer and DukeHelpers.IsHusk(closestPlayer) then
			pickup:GetData().showSlotsPrice = true
			pickup.AutoUpdatePrice = false
			pickup.Price = (pickup.Price % DukeHelpers.PRICE_OFFSET) + DukeHelpers.PRICE_OFFSET
		else
			pickup:GetData().showSlotsPrice = nil
			if not pickup.AutoUpdatePrice then
				pickup.AutoUpdatePrice = true
			end
		end
	elseif pickup:GetData().showSlotsPrice == true then
		pickup:GetData().showSlotsPrice = nil
		if not pickup.AutoUpdatePrice then
			pickup.AutoUpdatePrice = true
		end
	end
end)

function DukeHelpers.IsHusk(player)
	return DukeHelpers.IsDuke(player, true)
end

function DukeHelpers.InitializeHusk(p, continued)
	local dukeData = DukeHelpers.GetDukeData(p)
	local sprite = p:GetSprite()
	sprite:Load("gfx/characters/duke_b.anm2", true)
	if not continued then
		p:SetPocketActiveItem(DukeHelpers.Items.rottenGullet.Id)
		Game():GetItemPool():RemoveCollectible(DukeHelpers.Items.othersRottenGullet.Id)
		p:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/character_duke_b_scars.anm2"))
	end
	dukeData.isInitialized = true
end

function DukeHelpers.AddStartupSpiders(player)
	DukeHelpers.SpawnSpidersFromPickupSubType(HeartSubType.HEART_FULL, player.Position, player, 2)
end
