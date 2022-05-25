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
			for i = 1, patchedFly.fliesCount do
				if DukeHelpers.CountByProperties(playerData.heartFlies, { subType = DukeHelpers.Flies.FLY_BROKEN.heartFlySubType }) > 0 then
					local removedFlies = DukeHelpers.RemoveHeartFlyBySubType(p, DukeHelpers.Flies.FLY_BROKEN.heartFlySubType, 1)

					DukeHelpers.SpawnHeartFlyPoof(DukeHelpers.Flies.FLY_BROKEN.heartFlySubType, removedFlies[1].Position, p)
				else
					DukeHelpers.AddHeartFly(p, patchedFly, patchedFly.fliesCount - i + 1)
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

-- Adds flies when a heart is collected
dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and DukeHelpers.IsDuke(p) and (pickup.Price <= 0 or p:GetNumCoins() >= pickup.Price) then
		DukeHelpers.SpawnPickupHeartFly(p, pickup)
		return true
	end
end, PickupVariant.PICKUP_HEART)

dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local p = collider:ToPlayer()
	if p and (DukeHelpers.IsDuke(p) or p:HasTrinket(DukeHelpers.Trinkets.pocketOfFlies.Id)) and DukeHelpers.IsFlyPrice(pickup.Price) then
		local heartPrice = DukeHelpers.GetDukeDevilDealPrice(pickup)

		local playerFlyCounts = DukeHelpers.GetFlyCounts()[tostring(p.InitSeed)]

		local neededRedFlies = heartPrice.RED - playerFlyCounts.RED
		local remainingUltraFlies = playerFlyCounts.ULTRA

		if neededRedFlies > 0 and remainingUltraFlies >= neededRedFlies then
			remainingUltraFlies = remainingUltraFlies - neededRedFlies
			neededRedFlies = 0
		end

		local neededSoulFlies = heartPrice.SOUL - playerFlyCounts.SOUL

		if neededSoulFlies > 0 and remainingUltraFlies >= neededSoulFlies then
			remainingUltraFlies = remainingUltraFlies - neededSoulFlies
			neededSoulFlies = 0
		end

		if neededRedFlies > 0 or neededSoulFlies > 0 then
			return true
		end

		DukeHelpers.RemoveHeartFlyBySubType(p, {
			DukeHelpers.Flies.FLY_RED.heartFlySubType,
			{
				count = 2,
				subType = DukeHelpers.Flies.FLY_BONE.heartFlySubType
			},
			{
				count = 2,
				subType = DukeHelpers.Flies.FLY_ROTTEN.heartFlySubType
			}
		}, heartPrice.RED)

		DukeHelpers.RemoveHeartFlyBySubType(p, {
			DukeHelpers.Flies.FLY_SOUL.heartFlySubType,
			DukeHelpers.Flies.FLY_BLACK.heartFlySubType
		}, heartPrice.SOUL)

		DukeHelpers.RemoveHeartFlyBySubType(p, DukeHelpers.Flies.FLY_ULTRA.heartFlySubType, playerFlyCounts.ULTRA - remainingUltraFlies)
	end
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, pickup)
	local pos = Isaac.WorldToScreen(pickup.Position)

	if pickup:GetData().showFliesPrice then
		local devilPrice = DukeHelpers.GetDukeDevilDealPrice(pickup)

		local flyPriceSprite = Sprite()
		flyPriceSprite:Load("gfx/ui/fly_devil_deal_price.anm2")
		flyPriceSprite:Play(string.format("%s_%s", devilPrice.RED, devilPrice.SOUL))
		flyPriceSprite:Render(Vector(pos.X, pos.Y + 10), Vector.Zero, Vector.Zero)
	end
end)

-- Adds flies when the player's health changes
dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, p)
	if DukeHelpers.GetBlackHearts(p) > 0 then
		local totalSoulHearts = DukeHelpers.GetTrueSoulHearts(p)
		local immortalHeartCount = ComplianceImmortal.GetImmortalHearts(p)
		local webHeartCount = ARACHNAMOD:GetData(p).webHearts
		if immortalHeartCount > 0 then
			DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_IMMORTAL, immortalHeartCount)
			ComplianceImmortal.AddImmortalHearts(p, -immortalHeartCount)
		elseif webHeartCount > 0 then
			DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_WEB, webHeartCount)
			addWebHearts(-webHeartCount, p)
		else
			DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_BLACK, DukeHelpers.GetBlackHearts(p))
		end
		p:AddSoulHearts(-p:GetSoulHearts())
		p:AddSoulHearts(totalSoulHearts)
	end

	if p:GetBoneHearts() > 0 then
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_BONE, p:GetBoneHearts())
		p:AddBoneHearts(-p:GetBoneHearts())
	end

	if p:GetBrokenHearts() > 0 then
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_BROKEN, p:GetBrokenHearts() * 2)
		p:AddBrokenHearts(-p:GetBrokenHearts())
		if DukeHelpers.GetTrueSoulHearts(p) < DukeHelpers.MAX_HEALTH then
			p:AddSoulHearts(DukeHelpers.MAX_HEALTH)
		end
		DukeHelpers.KillAtMaxBrokenFlies(p)
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

	if p:GetData().moons and p:GetData().moons > 0 then
		DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.FLY_MOONLIGHT, p:GetData().moons)
		p:GetData().moons = 0
	end
end, DukeHelpers.DUKE_ID)

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
