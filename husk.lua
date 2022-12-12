local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
	{
		"Start Data",
		"Items:",
		"- Rotten Gullet",
		"Stats:",
		"- HP: 3 Soul Hearts",
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
		"If Tainted Duke is below 3 Soul Hearts, picking up Soul Hearts will replenish his health bar instead of turning into Rotten Gullet charges.",
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


-- Add spiders on player startup
dukeMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if dukeMod.global.isInitialized and DukeHelpers.IsHusk(player) and not player:IsCoopGhost() then
		if not player:GetData().duke or not player:GetData().duke.isInitialized then
			DukeHelpers.InitializeHusk(player)
		end
		if not player:GetData().duke or not player:GetData().duke.hasStartupSpiders then
			DukeHelpers.AddStartupSpiders(player)
		end
	end
	if player:IsCoopGhost() then
		player:GetData().duke.isInitialized = false
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
	local data = DukeHelpers.GetDukeData(p)
	local removedHearts = DukeHelpers.RemoveUnallowedHearts(p)
	data.previousSoulHearts = DukeHelpers.Hearts.SOUL.GetCount(p)

	for heartKey, removedAmount in pairs(removedHearts) do
		local heart = DukeHelpers.Hearts[heartKey]
		if not
			DukeHelpers.Trinkets.infestedHeart.helpers.RandomlySpawnHeartFlyFromPickup(p,
				{ Type = EntityType.ENTITY_PICKUP, Variant = heart.variant, SubType = heart.subType, Price = 0 }) then
			DukeHelpers.FillRottenGulletSlot(p, heartKey, removedAmount)
		end
	end
end, DukeHelpers.HUSK_ID)

local function OnHeartCollision(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and DukeHelpers.IsHusk(p) and (pickup.Price <= 0 or p:GetNumCoins() >= pickup.Price) then
		local playerData = DukeHelpers.GetDukeData(p)

		local pickupKey = DukeHelpers.GetKeyFromPickup(pickup)

		if not pickupKey then
			return
		end

		local heart = DukeHelpers.Hearts[pickupKey]

		if heart and heart.ignore then
			if heart.OnPickup then
				heart.OnPickup(p, pickup)
			end

			return
		end

		local spider = DukeHelpers.Spiders[pickupKey]
		local playSfx = true

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
				DukeHelpers.sfx:Play(Isaac.GetSoundIdByName("PATCHED_HEART_HEAL"))
				playSfx = false
			else
				DukeHelpers.PlayHeartPickupSfx(heart)
			end

			DukeHelpers.FillRottenGulletSlot(p, pickupKey, leftoverSlots)
		else
			if DukeHelpers.LengthOfTable(DukeHelpers.GetFilledRottenGulletSlots(p)) >= DukeHelpers.GetMaxRottenGulletSlots(p) then
				return
			end
			DukeHelpers.FillRottenGulletSlot(p, pickupKey)
		end

		::final::
		if pickup then
			DukeHelpers.PickupFlyHeart(pickup)
			pickup:Remove()

			if playSfx then
				DukeHelpers.PlayHeartPickupSfx(heart)
			end
			DukeHelpers.AnimateHeartPickup(pickup, p)

			if pickup.Price == PickupPrice.PRICE_SPIKES then
				p:TakeDamage(2, DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(nil), 0)
			end

			if heart and heart.OnPickup then
				heart.OnPickup(p, pickup)
			end


			if pickup.OptionsPickupIndex ~= 0 then
				DukeHelpers.ForEachEntityInRoom(function(entity)
					if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex then
						Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, entity)
						entity:Remove()
					end
				end, EntityType.ENTITY_PICKUP)
			end
		end

		return true
	end
end

-- Fill slots when a heart is collected
DukeHelpers.ForEachHeartVariant(function(variant)
	dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, OnHeartCollision, variant)
end)


-- Handles slot devil deals for Husk
dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and DukeHelpers.IsHusk(p) and DukeHelpers.IsCustomPrice(pickup.Price) and
		not DukeHelpers.Trinkets.pocketOfFlies.helpers.HasPocketOfFlies(p) then
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
		DukeHelpers.HasHusk() and (DukeHelpers.IsReplaceablePrice(pickup.Price) or DukeHelpers.IsCustomPrice(pickup.Price)) then
		local closestPlayer = DukeHelpers.GetClosestPlayer(pickup.Position)

		if closestPlayer and DukeHelpers.IsHusk(closestPlayer) and
			not DukeHelpers.Trinkets.pocketOfFlies.helpers.HasPocketOfFlies(closestPlayer) then
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
	local dukeData = DukeHelpers.GetDukeData(player)
	DukeHelpers.FillRottenGulletSlot(player, DukeHelpers.Spiders.RED.key, 1)
	DukeHelpers.SpawnSpidersFromKey(DukeHelpers.Hearts.RED.key, player.Position, player, 2)
	dukeData.hasStartupSpiders = true
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

dukeMod:AddPriorityCallback(ModCallbacks.MC_USE_CARD, CallbackPriority.EARLY, function(_, card, player)
	if FiendFolio and card == Card.JACK_OF_HEARTS and DukeHelpers.IsHusk(player) then
		local data = DukeHelpers.GetDukeData(player)
		data.jackOfHearts = DukeHelpers.Hearts.SOUL.GetCount(player)
	end
end)

dukeMod:AddPriorityCallback(ModCallbacks.MC_USE_CARD, CallbackPriority.LATE, function(_, card, player)
	if FiendFolio and card == Card.JACK_OF_HEARTS and DukeHelpers.IsHusk(player) then
		local data = DukeHelpers.GetDukeData(player)

		local immoralHeartsToAdd = data.jackOfHearts - 1

		DukeHelpers.Hearts.IMMORAL.Remove(player, DukeHelpers.Hearts.IMMORAL.GetCount(player))

		DukeHelpers.Hearts.SOUL.Add(player, 1)

		local gulletSlots = DukeHelpers.GetFilledRottenGulletSlots(player)

		for i = 1, #gulletSlots do
			local gulletSlot = gulletSlots[i]
			if gulletSlot == DukeHelpers.Hearts.SOUL.key or gulletSlot == DukeHelpers.Hearts.BLACK.key then
				gulletSlots[i] = DukeHelpers.Hearts.IMMORAL.key
			end
		end

		DukeHelpers.FillRottenGulletSlot(player, DukeHelpers.Hearts.IMMORAL.key, immoralHeartsToAdd)
		data.jackOfHearts = nil
	end
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	DukeHelpers.OnItemPickup(player, CollectibleType.COLLECTIBLE_ABADDON, "DukeAbaddonPickup", function()
		local gulletSlots = DukeHelpers.GetFilledRottenGulletSlots(player)

		for i, slot in pairs(gulletSlots) do
			if slot == DukeHelpers.Hearts.RED.key then
				gulletSlots[i] = DukeHelpers.Hearts.BLACK.key
			end
		end
	end)
end, DukeHelpers.HUSK_ID)

dukeMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player)
	if DukeHelpers.IsHusk(player) then
		DukeHelpers.FillRottenGulletSlot(player, DukeHelpers.Spiders.RED.key, 2)
	end
end, CollectibleType.COLLECTIBLE_YUM_HEART)

dukeMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player)
	if DukeHelpers.IsHusk(player) then
		DukeHelpers.FillRottenGulletSlot(player, DukeHelpers.Spiders.ROTTEN.key, 1)
	end
end, CollectibleType.COLLECTIBLE_YUCK_HEART)

if EID then
	EID:addBirthright(DukeHelpers.HUSK_ID, "Tainted Duke's Rotten Gullet now fires 12 tears per charge", "Tainted Duke")
end
