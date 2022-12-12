local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
	{
		"Start Data",
		"Items:",
		"- Duke's Gullet",
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
		"Any hearts Duke picks up or gains via items turn into Heart Orbital Flies.",
		"- Heart Orbital Flies orbit around Duke, and can deal contact damage, as well as block enemy projectiles.",
		"- When a Heart Orbital Fly blocks a projectile, it turns into a Heart Attack Fly and charges into the enemy, dealing damage.",
		"Duke can have three layers of Heart Orbital Flies, holding up to 24 in total.",
		"- The inner layer can hold up to 3 flies, the middle can hold 9, and the outer can hold 12.",
		"Heart Orbital Flies deal contact damage based on their layer. Flies on the inner layer deal 7 contact damage, middle flies deal 3, and outer flies deal 2.",
		"Flies that Duke gains have special attributes based on the heart type that Duke picks up. For more information on specific fly effects, see Heart Flies.",
		"Duke's pocket active, Duke's Gullet, allows Duke to convert his outermost layer of Heart Orbital Flies into Heart Attack Flies. Heart Attack Flies spawned this way have a chance of spawning a half heart of their corresponding type.",
		"- Soul Heart Flies have a 100% chance of spawning a Half Soul Heart."
	},
	{
		"Notes",
		"If Duke is below 3 Soul Hearts, picking up Soul Hearts will replenish his health bar instead of turning into Heart Orbital Flies.",
		"Duke is able to pay for Devil Deals with his Heart Orbital Flies.",
		"- 1 Heart deals cost 4 flies, and 2 Heart deals cost 8 flies.",
		"- The fly type is irrelevant to the price.",
		"Duke is able to open the Mausoleum door at a cost of 2 Heart Orbital Flies per hit.",
		"- If he has no Heart Orbital Flies, the door will deal damage like normal.",
		"If Duke picks up a heart while all of his fly layers are full, the oldest Heart Orbital Flies will be replaced with the new ones.",
		"If Duke obtains 24 Broken Heart Orbital Flies, or 42 with Birthright, he will die."
	},
	{
		"Birthright",
		"Allows Duke to have a fourth layer of Heart Orbital Flies. The fourth layer can hold up to 18 additional flies, and flies in this layer deal 1 contact damage."
	},
	{
		"Interactions",
		"Book of Virtues: Using Duke's Gullet will spawn a temporary Heart Fly wisp for each Heart Orbital Fly converted into a Heart Attack Fly. The Heart Fly wisps will have tear effects based on the Heart Orbital Fly converted, and will die after 2 seconds.",
		"Hive Mind: Increases size and damage of Heart Orbital Flies and Attack Flies.",
		"Mega Mush: Greatly expands the orbit of Duke's Heart Orbital Flies, allowing him to practically cover the entire room if all three layers are filled.",
		"Sacrificial Altar: If Duke has Heart Orbital Flies when used, Sacrificial Altar will destroy all of his Heart Orbital Flies and spawn a Devil item, its quality dependent on the amount and quality of flies sacrificed. Heart Attack Flies will turn into pennies when sacrificed.",
		"Spin to Win: Duke's Heart Orbital Flies and Heart Attack Flies will spin much faster when this is activated."
	},
	{
		"Trivia",
		"Duke is, obviously, based on The Duke of Flies boss.",
		"- His capped health and extra durability from Heart Orbital Flies parallels how The Duke of Flies has low HP but can absorb many hits with his orbiting flies.",
		"- Some of Duke's costumes resemble other Duke of Flies-adjacent bosses. For example, Neptunus makes Duke resemble Lil' Blub, and Spoon Bender makes Duke resemble Rag Mega.",
		"- Duke's custom death animation is a reference to Duke of Flies death animation, in which he explodes into a burst of blood and releases all of his orbiting flies.",
		"Duke's nickname in the early stages of development was ''Sharty McFlies.'' This would later be adapted into the item Sharty McFly.",
		"Some of Duke's unlocks would have originally included co-op babies, similar to in-game unlocks. However, since co-op babies are difficult to implement and most people dislike them anyways, they were scrapped in favor of more items and trinkets."
	}
})

if Encyclopedia then
	if Encyclopedia.characters_aTable and Encyclopedia.characters_aTable.modded and
		DukeHelpers.FindByProperties(Encyclopedia.characters_aTable.modded, { CharacterId = DukeHelpers.HUSK_ID }) then
		Encyclopedia.UpdateCharacter(DukeHelpers.DUKE_ID, {
			ModName = "Duke",
			Name = "Duke",
			ID = DukeHelpers.DUKE_ID,
			Sprite = Encyclopedia.RegisterSprite(dukeMod.path .. "content/gfx/characterportraits.anm2", "Duke", 0),
			WikiDesc = WikiDescription
		})
	else
		Encyclopedia.AddCharacter({
			ModName = "Duke",
			Name = "Duke",
			ID = DukeHelpers.DUKE_ID,
			Sprite = Encyclopedia.RegisterSprite(dukeMod.path .. "content/gfx/characterportraits.anm2", "Duke", 0),
			WikiDesc = WikiDescription
		})
	end
end

-- Add flies on player startup
dukeMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if dukeMod.global.isInitialized and DukeHelpers.IsDuke(player) and not player:IsCoopGhost() then
		if not player:GetData().duke or not player:GetData().duke.isInitialized then
			DukeHelpers.InitializeDuke(player)
		end
		if not player:GetData().duke or not player:GetData().duke.hasStartupFlies then
			DukeHelpers.AddStartupFlies(player)
		end
	end
	if player:IsCoopGhost() then
		player:GetData().duke.isInitialized = false
	end
end)

-- Allows the player to fly
dukeMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, f)
	if DukeHelpers.IsDuke(p) then
		p.CanFly = true
	end
end, CacheFlag.CACHE_FLYING)

local function OnHeartCollision(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and DukeHelpers.IsDuke(p) and (pickup.Price <= 0 or p:GetNumCoins() >= pickup.Price) then
		local heart = DukeHelpers.Hearts[DukeHelpers.GetKeyFromPickup(pickup)]
		local playerData = DukeHelpers.GetDukeData(p)

		if heart and heart.ignore then
			if heart.OnPickup then
				heart.OnPickup(p, pickup)
			end

			return
		end

		local playSfx = nil

		if DukeHelpers.Hearts.PATCHED.IsHeart(pickup) or DukeHelpers.Hearts.DOUBLE_PATCHED.IsHeart(pickup) then
			local patchedFly = DukeHelpers.GetFlyByPickup(pickup)
			for i = 1, patchedFly.count do
				if DukeHelpers.CountByProperties(playerData.heartFlies, { key = DukeHelpers.Flies.BROKEN.key }) > 0 then
					local removedFlies = DukeHelpers.RemoveHeartFly(p, DukeHelpers.Flies.BROKEN, 1)

					DukeHelpers.SpawnHeartFlyPoof(DukeHelpers.Flies.BROKEN, removedFlies[1].Position, p)
					DukeHelpers.sfx:Play(Isaac.GetSoundIdByName("PATCHED_HEART_HEAL"))
					playSfx = false
				else
					DukeHelpers.AddHeartFly(p, patchedFly, patchedFly.count - i + 1)
					if playSfx == nil then
						playSfx = true
					end
					break
				end
			end

		else
			DukeHelpers.SpawnPickupHeartFly(p, pickup)
		end

		if pickup then
			DukeHelpers.PickupFlyHeart(pickup)
			pickup:Remove()

			if playSfx then
				DukeHelpers.PlayHeartPickupSfx(heart)
			end

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

-- Adds flies when a heart is collected
DukeHelpers.ForEachHeartVariant(function(variant)
	dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, OnHeartCollision, variant)
end)

-- Handles fly devil deals for Duke
dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and (DukeHelpers.IsDuke(p) or DukeHelpers.Trinkets.pocketOfFlies.helpers.HasPocketOfFlies(p)) then
		if DukeHelpers.IsCustomPrice(pickup.Price) then
			local heartPrice = DukeHelpers.GetCustomDevilDealPrice(pickup, p)

			local playerFlyCount = DukeHelpers.GetFlyCount(p)

			if not playerFlyCount or playerFlyCount < heartPrice then
				return true
			end

			DukeHelpers.RemoveOutermostHeartFlies(p, heartPrice)
			if DukeHelpers.Trinkets.pocketOfFlies.helpers.HasPocketOfFlies(p) then
				DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.RED, 2, false)
			end
		else
			if DukeHelpers.CanBuyDevilDeal(p, pickup) then
				DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.RED, 2, false)
			end
		end
	end
end)

-- Renders fly devil deal prices
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, pickup)
	DukeHelpers.RenderCustomDevilDealPrice(pickup, "showFliesPrice", "gfx/ui/fly_devil_deal_price.anm2")
end)

local function resetItemPrice(pickup, pickupData)
	if pickupData.showFliesPrice then
		pickupData.showFliesPrice = nil
		if not pickup.AutoUpdatePrice then
			pickup.AutoUpdatePrice = true
		end
	end
end

local function customizeItemPrice(pickup, pickupData)
	pickupData.showFliesPrice = true
	pickup.AutoUpdatePrice = false
	pickup.Price = (pickup.Price % DukeHelpers.PRICE_OFFSET) + DukeHelpers.PRICE_OFFSET
end

dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
	local closestPlayer = DukeHelpers.GetClosestPlayer(pickup.Position)
	local pickupData = pickup:GetData()
	
	if closestPlayer and not DukeHelpers.AnyPlayerHasTrinket(TrinketType.TRINKET_YOUR_SOUL) and
		(DukeHelpers.IsReplaceablePrice(pickup.Price) or DukeHelpers.IsCustomPrice(pickup.Price)) then
		if DukeHelpers.IsDuke(closestPlayer) then
			customizeItemPrice(pickup, pickupData)
		elseif DukeHelpers.Trinkets.pocketOfFlies.helpers.HasPocketOfFlies(closestPlayer) then
			local heartPrice = DukeHelpers.GetCustomDevilDealPrice(pickup, closestPlayer)

			local playerFlyCount = DukeHelpers.GetFlyCount(closestPlayer)

			if playerFlyCount and playerFlyCount >= heartPrice then
				customizeItemPrice(pickup, pickupData)
			else
				resetItemPrice(pickup, pickupData)
			end
		else
			resetItemPrice(pickup, pickupData)
		end
	else
		resetItemPrice(pickup, pickupData)
	end
end)

-- Adds flies when the player's health changes
dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, p)
	local data = DukeHelpers.GetDukeData(p)
	local removedHearts = DukeHelpers.RemoveUnallowedHearts(p)
	data.previousSoulHearts = DukeHelpers.Hearts.SOUL.GetCount(p)

	for heartKey, removedAmount in pairs(removedHearts) do
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies[heartKey], removedAmount)
	end

	DukeHelpers.KillAtMaxBrokenFlies(p)
end, DukeHelpers.DUKE_ID)

function DukeHelpers.GetDukeData(p)
	local data = p:GetData()
	if not data.duke then
		data.duke = {}

		if p.Type == EntityType.ENTITY_PLAYER then
			data.duke.heartFlies = {}
		end
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
		if (sprite:IsPlaying("Death") and sprite:GetFrame() == 19) or
			(sprite:IsPlaying("LostDeath") and sprite:GetFrame() == 1) then
			local dukeData = DukeHelpers.GetDukeData(p)
			local fliesData = dukeData.heartFlies
			if fliesData then
				for i = #fliesData, 1, -1 do
					local fly = fliesData[i]
					local f = DukeHelpers.GetEntityByInitSeed(fly.initSeed)
					DukeHelpers.SpawnAttackFlyFromHeartFlyEntity(f, true)
					DukeHelpers.RemoveHeartFlyEntity(f)
				end
			end

			if sprite:IsPlaying("Death") then
				DukeHelpers.PlayCustomDeath(p)
			end
		end
	end)

	local foundEntities = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.DEVIL, -1)

	for _, entity in pairs(foundEntities) do
		local sprite = entity:GetSprite()
		if sprite:GetFilename() == "gfx/characters/duke.anm2" and sprite:IsPlaying("Death") and sprite:GetFrame() == 19 then
			DukeHelpers.PlayCustomDeath(entity)
		end
	end
end)

dukeMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, flags)
	if DukeHelpers.IsDuke(player) and player:GetData().duke and
		not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
		local heartFlies = DukeHelpers.GetDukeData(player).heartFlies
		if heartFlies then
			for i = #heartFlies, 1, -1 do
				local fly = heartFlies[i]
				local f = DukeHelpers.GetEntityByInitSeed(fly.initSeed)
				if DukeHelpers.GetDukeData(player).layer == DukeHelpers.BIRTHRIGHT then
					DukeHelpers.RemoveHeartFlyEntity(f)
					DukeHelpers.SpawnAttackFlyFromHeartFlyEntity(f)
				end
			end
		end
	end
end)

dukeMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, entity, _, flags, source)
	local player = entity:ToPlayer()
	local game = Game()
	local levelStage = game:GetLevel():GetStage()

	if player and game:GetRoom():GetType() == RoomType.ROOM_BOSS and
		(levelStage == LevelStage.STAGE2_2 or levelStage == LevelStage.STAGE3_1) and flags == 301998208 and
		(not source or not source.Entity) then

		if DukeHelpers.IsDuke(player) or DukeHelpers.IsHusk(player) then
			local numRemoved = 0

			if DukeHelpers.IsDuke(player) then
				numRemoved = numRemoved +
					DukeHelpers.LengthOfTable(DukeHelpers.RemoveOutermostHeartFlies(player, 2 - numRemoved, false))
			end

			if numRemoved < 2 and DukeHelpers.IsHusk(player) then
				numRemoved = numRemoved + DukeHelpers.RemoveRottenGulletSlots(player, 2 - numRemoved, true)
			end

			DukeHelpers.Hearts.SOUL.Add(player, numRemoved)
		end
	end
end)

dukeMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player)
	if DukeHelpers.IsDuke(player) then
		DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.RED, 2)
	end
end, CollectibleType.COLLECTIBLE_YUM_HEART)

dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	if DukeHelpers.IsDuke(player) or DukeHelpers.IsHusk(player) then
		DukeHelpers.OnItemPickup(player, CollectibleType.COLLECTIBLE_DEAD_CAT, "DukeNineLivesPickup", function()
			DukeHelpers.RemoveHeartFly(player, DukeHelpers.Flies.RED, 2)
			DukeHelpers.RemoveHeartFly(player, DukeHelpers.Flies.SOUL, 2)
			local soulHearts = DukeHelpers.Clamp(DukeHelpers.Hearts.SOUL.GetCount(player) - 2, 0)
			if soulHearts > 0 then
				DukeHelpers.Hearts.SOUL.Remove(player, soulHearts)
			end
		end)
	end
end)

dukeMod:AddPriorityCallback(ModCallbacks.MC_USE_CARD, CallbackPriority.EARLY, function(_, card, player)
	if FiendFolio and card == Card.JACK_OF_HEARTS and DukeHelpers.IsDuke(player) then
		local data = DukeHelpers.GetDukeData(player)
		data.jackOfHearts = DukeHelpers.Hearts.SOUL.GetCount(player)
	end
end)

dukeMod:AddPriorityCallback(ModCallbacks.MC_USE_CARD, CallbackPriority.LATE, function(_, card, player)
	if FiendFolio and card == Card.JACK_OF_HEARTS and DukeHelpers.IsDuke(player) then
		local data = DukeHelpers.GetDukeData(player)

		local immoralHeartsToAdd = data.jackOfHearts - 1

		DukeHelpers.Hearts.IMMORAL.Remove(player, DukeHelpers.Hearts.IMMORAL.GetCount(player))

		DukeHelpers.Hearts.SOUL.Add(player, 1)

		local heartFlies = data.heartFlies

		for i, fly in pairs(heartFlies) do
			if fly.key == DukeHelpers.Hearts.SOUL.key or fly.key == DukeHelpers.Hearts.BLACK.key then
				DukeHelpers.ReplaceHeartFly(player, i, DukeHelpers.Flies.IMMORAL)
			end
		end

		DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.IMMORAL, immoralHeartsToAdd, false)

		data.jackOfHearts = nil
	end
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
	DukeHelpers.OnItemPickup(player, CollectibleType.COLLECTIBLE_ABADDON, "DukeAbaddonPickup", function()
		local redFlies = DukeHelpers.CountByProperties(DukeHelpers.GetDukeData(player).heartFlies,
			{ key = DukeHelpers.Flies.RED.key })
		if redFlies > 0 then
			DukeHelpers.RemoveHeartFly(player, DukeHelpers.Flies.RED, redFlies)
			DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.BLACK, redFlies)
		end
	end)
end, DukeHelpers.DUKE_ID)

dukeMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player)
	if DukeHelpers.IsDuke(player) then
		DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.ROTTEN, 1)
	end
end, CollectibleType.COLLECTIBLE_YUCK_HEART)

if EID then
	EID:addBirthright(DukeHelpers.DUKE_ID,
		"Allows Duke to have a fourth ring of Heart Orbital Flies, holding up to 18 additional flies#Heart Orbital Flies in the fourth ring deal 1 contact damage")
end
