-- Handles fly orbiting
dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	local data = DukeHelpers.GetDukeData(f)
	local sprite = f:GetSprite()
	if f.FrameCount == 6 then
		sprite:ReplaceSpritesheet(0, DukeHelpers.GetFlySpritesheetFromEntity(f))
		sprite:LoadGraphics()
		sprite:Play("Idle", true)
	end

	if data.layer == nil then
		local fliesData = DukeHelpers.GetDukeData(f.Player).heartFlies
		local foundFly = DukeHelpers.FindByProperties(fliesData, {initSeed = f.InitSeed})
		if foundFly then
			data.layer = foundFly.layer
			DukeHelpers.PositionHeartFly(f, foundFly.layer)
		else
			DukeHelpers.AddHeartFly(f.Player, DukeHelpers.GetHeartFlyFromFlyEntity(f).heart, 1)
			f:Remove()
		end
	end

	if data.layer == DukeHelpers.INNER then
		f.OrbitDistance = Vector(20, 20)
		f.OrbitSpeed = 0.045
		f.CollisionDamage = 7
	elseif data.layer == DukeHelpers.MIDDLE then
		f.OrbitDistance = Vector(40, 36)
		f.OrbitSpeed = 0.02
		f.CollisionDamage = 3
	elseif data.layer == DukeHelpers.OUTER then
		f.OrbitDistance = Vector(60, 56)
		f.OrbitSpeed = 0.01
		f.CollisionDamage = 2
	elseif data.layer == DukeHelpers.BIRTHRIGHT then
		f.OrbitDistance = Vector(80, 76)
		f.OrbitSpeed = 0.005
		f.CollisionDamage = 1
	end

	local centerPos = f.Player.Position
	if DukeHelpers.IsDuke(f.Player) and f.Player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH) then
		f.OrbitDistance = f.OrbitDistance * 3
		f.OrbitSpeed = f.OrbitSpeed * 1.3
		centerPos = centerPos - Vector(0, 75)
	end

	f.Velocity = f:GetOrbitPosition(centerPos + f.Player.Velocity) - f.Position
end, DukeHelpers.FLY_VARIANT)

-- Turns heart flies into attack flies when hit
dukeMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, f, e)
	if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
		if f.SubType ~= DukeHelpers.Flies.BROKEN.heartFlySubType then
			e:Die()
		end

		local data = DukeHelpers.GetDukeData(f)
		if DukeHelpers.GetHeartFlyFromFlyEntity(f).canAttack then
			if not data.hitPoints or data.hitPoints <= 1 then
				local attackFlyEntity = DukeHelpers.SpawnAttackFlyFromHeartFlyEntity(f)
				local attackFlyData = DukeHelpers.GetDukeData(attackFlyEntity)
				attackFlyData.attacker = e.SpawnerEntity
				attackFlyData.hitPoints = nil
				DukeHelpers.RemoveHeartFlyEntity(f)
			elseif data.hitPoints and data.hitPoints > 1 then
				data.hitPoints = data.hitPoints - 1
			end
		end
	end
end, DukeHelpers.FLY_VARIANT)

-- Handles attacking an enemy when attack fly
dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	local attackFlyData = DukeHelpers.GetDukeData(f)
	if attackFlyData.attacker then
		if not attackFlyData.attacker:IsDead() and DukeHelpers.IsActualEnemy(attackFlyData.attacker, true, false) then
			f.Target = attackFlyData.attacker
		else
			f.Target = nil
			attackFlyData.attacker = nil
		end
	end
	if attackFlyData.bffs then
		f.SpriteScale = Vector(1.2, 1.2)
	end
end, FamiliarVariant.BLUE_FLY)

dukeMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, f, e)
	local attackFlyData = DukeHelpers.GetDukeData(f)
	if attackFlyData.dropHeart then
		if e:ToNPC() and DukeHelpers.IsActualEnemy(e, true, false) and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			local heartFly = DukeHelpers.GetHeartFlyFromFlyEntity(f)
			if heartFly.dropHeartChance and DukeHelpers.PercentageChance(heartFly.dropHeartChance) then
				local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP, heartFly.dropHeart.variant or PickupVariant.PICKUP_HEART, heartFly.dropHeart.subType or 0,
				f.Position, Vector.Zero, f)
				DukeHelpers.GetDukeData(heart).noFlyHearts = true
				attackFlyData.dropHeart = false
			end
		end
	end
end, FamiliarVariant.BLUE_FLY)

dukeMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, type, rng, player)
	local flyScore = 0
	local fliesData = DukeHelpers.GetDukeData(player).heartFlies

	if fliesData and #fliesData > 0 then
		for i = #fliesData, 1, -1 do
			local fly = fliesData[i]
			local f = DukeHelpers.GetEntityByInitSeed(fly.initSeed)
			local heartFly = DukeHelpers.Flies[fly.key]
			flyScore = flyScore + heartFly.sacAltarQuality
			DukeHelpers.SpawnHeartFlyPoof(heartFly, f.Position, player)
			DukeHelpers.RemoveHeartFlyEntity(f)
		end

		if flyScore > 24 then flyScore = 24 end
		local itemQuality = math.floor(flyScore / 5)

		local itemPool = Game():GetItemPool()
		local roomPool = itemPool:GetPoolForRoom(RoomType.ROOM_DEVIL, Game():GetLevel():GetCurrentRoomDesc().SpawnSeed)

		local chosenItem

		while not chosenItem or
			(
			Isaac.GetItemConfig():GetCollectible(chosenItem).Quality ~= itemQuality and
				Isaac.GetItemConfig():GetCollectible(chosenItem).ID ~= CollectibleType.COLLECTIBLE_MAGIC_SKIN) do
			chosenItem = itemPool:GetCollectible(roomPool, true)
		end

		if chosenItem then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, chosenItem,
				Game():GetRoom():FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
		end

		DukeHelpers.sfx:Play(SoundEffect.SOUND_SATAN_GROW, 1, 0)
		Game():Darken(1, 60)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR) then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR, false, ActiveSlot.ACTIVE_PRIMARY)
		end
	end

end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)
