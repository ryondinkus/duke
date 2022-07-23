local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
	{
		"Start Data",
		"Items:",
		"- Rotten Gullet",
		"Stats:",
		"- HP: 2 Soul Hearts",
		"- Speed: 1.00",
		"- Tear Rate: 2.73",
		"- Damage: 3.50",
		"- Range: 6.50",
		"- Shot Speed: 1.00",
		"- Luck: 0.00",
		"- Flight"
	},
	{
		"Traits",
		"Any hearts Tainted Duke picks up or gains via items go into the Rotten Gullet as charges. Rotten Gullet has 24 slots for charges.",
		"Using Rotten Gullet will consume the oldest charge, dealing damage and knockback in a small radius near Tainted Duke and firing 8 large tears in all directions.",
		"When the tears land, they have a 50% chance of spawning Heart Spiders.",
		"Charges and spiders that Tainted Duke gains have special attributes based on the heart type that Tainted Duke picks up. For more information on specific fly effects, see Heart Spiders.",
	},
	{
		"Notes",
		"If Tainted Duke is below 2 Soul Hearts, picking up Soul Hearts will replenish his health bar instead of turning into Rotten Gullet charges.",
		"- Black Hearts picked up this way will turn into Soul Hearts.",
		"Tainted Duke is able to pay for Devil Deals with his Rotten Gullet charges.",
		"- 1 Heart deals cost 4 charges, and 2 Heart deals cost 8 charges.",
		"- The charge type is irrelevant to the price.",
		"Tainted Duke is able to open the Mausoleum door at a cost of 2 Rotten Gullet charges per hit.",
		"- If he has no Rotten Gullet charges, the door will deal damage like normal.",
		"If Tainted Duke has all 24 Rotten Gullet charges filled, he won't be able to pick up more hearts. Hearts gained directly via items when the Rotten Gullet is full will simply be ignored.",
		"Broken Hearts decrease the capacity of Tainted Duke's Rotten Gullet by 2. If all 24 slots of Rotten Gullet get removed, he will die."
	},
	{
		"Birthright",
		"Tainted Duke's Rotten Gullet fires 12 tears in a circle instead of 8."
	},
	{
		"Interactions",
		"Book of Virtues: Gain a corresponding Heart Spider wisp for every Heart Spider spawned by Rotten Gullet. Heart Spider wisps have different tear effects depending on the type of Heart Spider spawned.",
		"Hive Mind: Increases size and damage of Heart Spiders.",
		"Sacrificial Altar: Heart Spiders will turn into pennies when sacrificed."
	},
	{
		"Trivia",
		"Tainted Duke is based on The Husk, the posthumous version of The Duke of Flies boss.",
		"- Tainted Duke's focus on Heart Spiders and bullets instead of flies is a reference to The Husk's attacks using more spiders and bullets.",
		"- Tainted Duke's alternate name ''The Husk'' is an obvious reference to this.",
	}
})

if Encyclopedia then
	if Encyclopedia.characters_bTable and
		Encyclopedia.characters_bTable.modded and DukeHelpers.FindByProperties(Encyclopedia.characters_bTable.modded,
			{ CharacterId = DukeHelpers.HUSK_ID }) then
		Encyclopedia.UpdateCharacterTainted(DukeHelpers.HUSK_ID, {
			ModName = "Duke",
			Name = "Tainted Duke",
			ID = DukeHelpers.HUSK_ID,
			Sprite = Encyclopedia.RegisterSprite(dukeMod.path .. "content/gfx/characterportraitsalt.anm2", "DukeB", 0),
			WikiDesc = WikiDescription
		})
	else
		Encyclopedia.AddCharacterTainted({
			ModName = "Duke",
			Name = "Tainted Duke",
			ID = DukeHelpers.HUSK_ID,
			Sprite = Encyclopedia.RegisterSprite(dukeMod.path .. "content/gfx/characterportraitsalt.anm2", "DukeB", 0),
			WikiDesc = WikiDescription
		})
	end
end


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
		local heart = DukeHelpers.Hearts[heartKey]
		if not
			DukeHelpers.Trinkets.infestedHeart.helpers.RandomlySpawnHeartFlyFromPickup(p,
				{ Type = EntityType.ENTITY_PICKUP, Variant = heart.variant, SubType = heart.subType, Price = 0 }) then
			DukeHelpers.FillRottenGulletSlot(p, heartKey, removedAmount)
		end
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

		if DukeHelpers.Trinkets.infestedHeart.helpers.RandomlySpawnHeartFlyFromPickup(p, pickup) then
			goto final
		end

		if DukeHelpers.Hearts.PATCHED.IsHeart(pickup) or DukeHelpers.Hearts.DOUBLE_PATCHED.IsHeart(pickup) then
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

		::final::
		local sfx = SoundEffect.SOUND_BOSS2_BUBBLES

		if pickup then
			DukeHelpers.PickupFlyHeart(pickup)
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
	if p and DukeHelpers.IsHusk(p) and DukeHelpers.IsCustomPrice(pickup.Price) and
		not p:HasTrinket(DukeHelpers.Trinkets.pocketOfFlies.Id) then
		local heartPrice = DukeHelpers.GetCustomDevilDealPrice(pickup)

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
			DukeHelpers.PlayCustomDeath(p)
		end
	end)

	local foundEntities = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DEVIL, -1)

	for _, entity in pairs(foundEntities) do
		local sprite = entity:GetSprite()
		if sprite:GetFilename() == "gfx/characters/duke_b.anm2" and sprite:IsPlaying("Death") and sprite:GetFrame() == 19 then
			DukeHelpers.PlayCustomDeath(entity)
		end
	end
end)

if EID then
	EID:addBirthright(DukeHelpers.HUSK_ID, "Tainted Duke's Rotten Gullet now fires 12 tears per charge", "Tainted Duke")
end
