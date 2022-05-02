-- List of flies
local flies = {
	include("flies/red"),
	include("flies/soul"),
	include("flies/eternal"),
	include("flies/black"),
	include("flies/golden"),
	include("flies/bone"),
	include("flies/rotten"),
	include("flies/broken"),
	-- Make sure any fly types that are used by other heart types are registered first
	include("flies/halfRed"),
	include("flies/doubleRed"),
	include("flies/halfSoul"),
	include("flies/scared")
}

-- Handles fly orbiting
dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	local data = f:GetData()
	local sprite = f:GetSprite()
	if f.FrameCount == 6 then
		sprite:ReplaceSpritesheet(0, DukeHelpers.GetFlySpritesheet(f.SubType))
		sprite:LoadGraphics()
		sprite:Play("Idle", true)
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
		if f.SubType ~= DukeHelpers.FLY_BROKEN then
			e:Die()
		end
		local data = f:GetData()
		if DukeHelpers.CanBecomeAttackFly(f) then
			if not data.hitPoints or data.hitPoints <= 1 then
				local fly = DukeHelpers.SpawnAttackFly(f)
				local flyData = fly:GetData()
				flyData.attacker = e.SpawnerEntity
				flyData.hitPoints = nil
				DukeHelpers.RemoveHeartFly(f)
			elseif data.hitPoints and data.hitPoints > 1 then
				data.hitPoints = data.hitPoints - 1
			end
		end
	end
end, DukeHelpers.FLY_VARIANT)

-- Handles attacking an enemy when attack fly
dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	if f:GetData().attacker then
		if not f:GetData().attacker:IsDead() then
			f.Target = f:GetData().attacker
		else
			f.Target = nil
			f:GetData().attacker = nil
		end
	end
	if f:GetData().bffs then
		f.SpriteScale = Vector(1.2, 1.2)
	end
end, FamiliarVariant.BLUE_FLY)

-- Registers the flies
for _, fly in pairs(flies) do
	local newFly = {
		key = fly.key,
		spritesheet = fly.spritesheet,
		canAttack = fly.canAttack,
		pickupSubType = fly.subType,
		heartFlySubType = fly.subType,
		attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(fly.subType),
		fliesCount = fly.fliesCount,
		weight = fly.weight,
		sfx = fly.sfx,
		poofColor = fly.poofColor,
		sacAltarQuality = fly.sacAltarQuality
	}

	if fly.useFly then
		local existingFly = DukeHelpers.Flies[fly.useFly]
		newFly.spritesheet = existingFly.spritesheet
		newFly.canAttack = existingFly.canAttack
		newFly.heartFlySubType = existingFly.heartFlySubType
		newFly.attackFlySubType = existingFly.attackFlySubType
		newFly.poofColor = existingFly.poofColor
		newFly.sacAltarQuality = existingFly.sacAltarQuality
	end


	if fly.callbacks then
		for _, callback in pairs(fly.callbacks) do
			dukeMod:AddCallback(table.unpack(callback))
		end
	end

	DukeHelpers.Flies[fly.key] = newFly
end

dukeMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, type, rng, player)
	local flyScore = 0
	local fliesData = DukeHelpers.GetDukeData(player).heartFlies

	if fliesData and #fliesData > 0 then
		for i = #fliesData, 1, -1 do
			local fly = fliesData[i]
			local f = DukeHelpers.GetEntityByInitSeed(fly.initSeed)
			local heartFly = DukeHelpers.GetFlyByHeartSubType(fly.subType)
			flyScore = flyScore + heartFly.sacAltarQuality
			DukeHelpers.SpawnHeartFlyPoof(fly.subType, f.Position, player)
			DukeHelpers.RemoveHeartFly(f)
		end

		if flyScore > 24 then flyScore = 24 end
		local itemQuality = math.floor(flyScore / 5)

		local itemPool = Game():GetItemPool()
		local roomPool = itemPool:GetPoolForRoom(RoomType.ROOM_DEVIL, Game():GetLevel():GetCurrentRoomDesc().SpawnSeed)

		local chosenItem

		while not chosenItem or (Isaac.GetItemConfig():GetCollectible(chosenItem).Quality ~= itemQuality and Isaac.GetItemConfig():GetCollectible(chosenItem).ID ~= CollectibleType.COLLECTIBLE_MAGIC_SKIN) do
			chosenItem = itemPool:GetCollectible(roomPool, true)
		end

		if chosenItem then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, chosenItem, Game():GetRoom():FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
		end

		DukeHelpers.sfx:Play(SoundEffect.SOUND_SATAN_GROW, 1, 0)
		Game():Darken(1, 60)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR) then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR, false, ActiveSlot.ACTIVE_PRIMARY)
		end
	end

end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)
