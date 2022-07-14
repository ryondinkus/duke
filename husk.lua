-- Add flies on player startup
dukeMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if dukeMod.global.isInitialized and DukeHelpers.IsHusk(player) and
		(not player:GetData().duke or not player:GetData().duke.isInitialized) then
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
		DukeHelpers.FillRottenGulletSlot(p, heartKey, removedAmount)
	end
end, DukeHelpers.HUSK_ID)

-- Fill slots when a heart is collected
dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and DukeHelpers.IsHusk(p) and (pickup.Price <= 0 or p:GetNumCoins() >= pickup.Price) then
		local playerData = DukeHelpers.GetDukeData(p)

		local pickupKey = DukeHelpers.GetKeyFromPickup(pickup)

		if not pickupKey then
			return
		end

		local spider = DukeHelpers.Spiders[pickupKey]

		if DukeHelpers.IsPatchedHeart(pickup) then
			local leftoverSlots = spider.count
			if playerData.stuckSlots and playerData.stuckSlots > 0 then
				leftoverSlots = math.max(0, leftoverSlots - playerData.stuckSlots)
				if playerData.stuckSlots >= spider.count then
					playerData.stuckSlots = playerData.stuckSlots - spider.count
				else
					playerData.stuckSlots = 0
				end
			end

			DukeHelpers.FillRottenGulletSlot(p, pickupKey, leftoverSlots)
		else
			if DukeHelpers.LengthOfTable(DukeHelpers.GetFilledRottenGulletSlots(p)) >= DukeHelpers.GetMaxRottenGulletSlots(p) then
				return
			end
			DukeHelpers.FillRottenGulletSlot(p, pickupKey)
		end

		local sfx = SoundEffect.SOUND_BOSS2_BUBBLES

		if pickup then
			pickup:Remove()
			if spider.sfx then
				sfx = spider.sfx
			end

			DukeHelpers.sfx:Play(sfx)
			DukeHelpers.AnimateHeartPickup(pickup, p)

			if pickup.Price == PickupPrice.PRICE_SPIKES then
				p:TakeDamage(2, DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(nil), 0)
			end
		end

		return true
	end
end, PickupVariant.PICKUP_HEART)

-- Handles slot devil deals for Husk
dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and DukeHelpers.IsHusk(p) and DukeHelpers.IsFlyPrice(pickup.Price) and
		not p:HasTrinket(DukeHelpers.Trinkets.pocketOfFlies.Id) then
		local heartPrice = DukeHelpers.GetDukeDevilDealPrice(pickup)

		local removedSlots = DukeHelpers.RemoveRottenGulletSlots(p, heartPrice)

		if removedSlots == 0 then
			return true
		end
	end
end)

-- Renders slot devil deal prices
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, pickup)
	DukeHelpers.RenderCustomDevilDealPrice(pickup, "showSlotsPrice", "gfx/ui/slot_devil_deal_price.anm2")
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	if not DukeHelpers.AnyPlayerHasTrinket(TrinketType.TRINKET_YOUR_SOUL) and
		DukeHelpers.HasHusk() and
		((pickup.Price < 0 and
			pickup.Price > PickupPrice.PRICE_SPIKES) or
			(pickup.Price < DukeHelpers.PRICE_OFFSET and pickup.Price > DukeHelpers.PRICE_OFFSET + PickupPrice.PRICE_SPIKES)) then
		local closestPlayer = DukeHelpers.GetClosestPlayer(pickup.Position)

		if closestPlayer and DukeHelpers.IsHusk(closestPlayer) and
			not closestPlayer:HasTrinket(DukeHelpers.Trinkets.pocketOfFlies.Id) then
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
	DukeHelpers.FillRottenGulletSlot(player, DukeHelpers.Spiders.RED.key, 1)
	DukeHelpers.SpawnSpidersFromKey(DukeHelpers.Hearts.RED.key, player.Position, player, 2)
end

dukeMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
	DukeHelpers.ForEachHusk(function(p)
		local sprite = p:GetSprite()
		if sprite:IsPlaying("Death") and sprite:GetFrame() == 19 then
			DukeHelpers.PlayDukeDeath(p)
		end
	end)

	local foundEntities = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DEVIL, -1)

	for _, entity in pairs(foundEntities) do
		local sprite = entity:GetSprite()
		if sprite:GetFilename() == "gfx/characters/duke_b.anm2" and sprite:IsPlaying("Death") and sprite:GetFrame() == 19 then
			DukeHelpers.PlayDukeDeath(entity)
		end
	end
end)
