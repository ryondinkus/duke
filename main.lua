dukeMod = RegisterMod("Duke", 1)

local duke = Isaac.GetPlayerTypeByName("Duke")
local heartFly = Isaac.GetEntityVariantByName("Heart Fly")

-- helpers
local function SpawnHeartFly(player)
	return Isaac.Spawn(EntityType.ENTITY_FAMILIAR, heartFly, 0, player.Position, Vector.Zero, player)
end

-- duke player
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	for i=0,3 do
		local p = Isaac.GetPlayer(i)
		if p:GetPlayerType() == duke then
			SpawnHeartFly(p)
			pickup:Remove()
			break
		end
	end
end, PickupVariant.PICKUP_HEART)

dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, p)
	while p:GetBlackHearts() > 0 do
		p:AddBlackHearts(-1)
		SpawnHeartFly(p)
	end
	while p:GetBoneHearts() > 0 do
		p:AddBoneHearts(-1)
		SpawnHeartFly(p)
	end
	if p:GetBrokenHearts() > 0 then
		while p:GetBrokenHearts() > 0 do
			p:AddBrokenHearts(-1)
			SpawnHeartFly(p)
		end
		if p:GetMaxHearts() < 2 then
			p:AddMaxHearts(2)
			p:AddHearts(2)
		end
	end
	while p:GetEternalHearts() > 0 do
		p:AddEternalHearts(-1)
		SpawnHeartFly(p)
	end
	while p:GetGoldenHearts() > 0 do
		p:AddGoldenHearts(-1)
		SpawnHeartFly(p)
	end
	while p:GetHearts() > 2 do
		p:AddHearts(-1)
		SpawnHeartFly(p)
	end
	while p:GetMaxHearts() > 2 do
		p:AddMaxHearts(-1, true)
		SpawnHeartFly(p)
	end
	while p:GetRottenHearts() > 0 do
		p:AddRottenHearts(-1)
		p:AddHearts(1)
		SpawnHeartFly(p)
	end
	while p:GetSoulHearts() > 0 do
		p:AddSoulHearts(-1)
		SpawnHeartFly(p)
	end
end, duke)

-- heart flies
dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, f)
	if f.SpawnerType == 1 then
		local p = f.SpawnerEntity
		local playerData = p:GetData()
		if not playerData.heartFlies then
			playerData.heartFlies = {}
		end
		table.insert(playerData.heartFlies, f.InitSeed)
		if #playerData.heartFlies < 4 then
			f:AddToOrbit(904)
		else
			f:AddToOrbit(905)
		end
	end
end, heartFly)

dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	local p = f.SpawnerEntity
	local playerData = p:GetData()
	local data = f:GetData()
	local sprite = f:GetSprite()
	if f.FrameCount == 6 then
		if #playerData.heartFlies < 4 then
			data.circle = 0
		else
			data.circle = 1
		end
		sprite:Play("Idle", true)
	end
	if data.circle == 0 then
		f.OrbitDistance = Vector(20, 20)
		f.OrbitSpeed = 0.045
	elseif data.circle == 1 then
		f.OrbitDistance = Vector(40, 36)
		f.OrbitSpeed = 0.02
		f.CollisionDamage = 3
	end
	f.Velocity = f:GetOrbitPosition(f.Player.Position + f.Player.Velocity) - f.Position
end, heartFly)

dukeMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, f, e)
	local p = f.SpawnerEntity
	local playerData = p:GetData()
	if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
        e:Die()
        local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, 0, f.Position, Vector.Zero, f.SpawnerEntity)
		fly:GetSprite():Load("gfx/familiars/heart_fly.anm2", true)
		fly:GetSprite():Play("Attack", true)
		fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		fly:GetData().attacker = e.SpawnerEntity
		for k,v in pairs(playerData.heartFlies) do
			if v == f.InitSeed then
				table.remove(playerData.heartFlies, k)
				break
			end
		end
		f:Remove()
    end
end, heartFly)

dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	if f:GetData().attacker then
		if not f:GetData().attacker:IsDead() then
			f.Target = f:GetData().attacker
		else
			f.Target = nil
			f:GetData().attacker = nil
		end
	end
end, FamiliarVariant.BLUE_FLY)
