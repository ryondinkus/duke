dukeMod = RegisterMod("Duke", 1)

local duke = Isaac.GetPlayerTypeByName("Duke")
local heartFly = Isaac.GetEntityVariantByName("Heart Fly")

-- helpers
local function SpawnHeartFly(player, layer)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, heartFly, 0, player.Position, Vector.Zero, player)
	fly:GetData().layer = layer
	fly:ToFamiliar():AddToOrbit(903 + layer)
	return fly
end

local function AddHeartFly(player)
	print(player)
	local playerData = player:GetData()
	if not playerData.heartFlies then
		playerData.heartFlies = {
			{},
			{},
			{}
		}
	end

	local fly
	if #playerData.heartFlies[1] < 3 then
		fly = SpawnHeartFly(player, 1)
		table.insert(playerData.heartFlies[1], fly.InitSeed)
	elseif #playerData.heartFlies[2] < 9 then
		fly = SpawnHeartFly(player, 2)
		table.insert(playerData.heartFlies[2], fly.InitSeed)
	elseif #playerData.heartFlies[3] < 12 then
		fly = SpawnHeartFly(player, 3)
		table.insert(playerData.heartFlies[3], fly.InitSeed)
	end

	return fly
end

-- duke player
dukeMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, flag)
	if p:GetPlayerType() == duke then
		p.CanFly = true
	end
end, CacheFlag.CACHE_FLYING)

dukeMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	for i=0,Game():GetNumPlayers() - 1 do
		local p = Isaac.GetPlayer(i)
		if p:GetPlayerType() == duke then
			for i=1,3 do
				AddHeartFly(p)
			end
		end
	end
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	for i=0,Game():GetNumPlayers() - 1 do
		local p = Isaac.GetPlayer(i)
		if p:GetPlayerType() == duke then
			AddHeartFly(p)
			pickup:Remove()
			break
		end
	end
end, PickupVariant.PICKUP_HEART)

dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, p)
	while p:GetBlackHearts() > 0 do
		p:AddBlackHearts(-1)
		AddHeartFly(p)
	end
	while p:GetBoneHearts() > 0 do
		p:AddBoneHearts(-1)
		AddHeartFly(p)
	end
	if p:GetBrokenHearts() > 0 then
		while p:GetBrokenHearts() > 0 do
			p:AddBrokenHearts(-1)
			AddHeartFly(p)
		end
		if p:GetMaxHearts() < 2 then
			p:AddMaxHearts(2)
			p:AddHearts(2)
		end
	end
	while p:GetEternalHearts() > 0 do
		p:AddEternalHearts(-1)
		AddHeartFly(p)
	end
	while p:GetGoldenHearts() > 0 do
		p:AddGoldenHearts(-1)
		AddHeartFly(p)
	end
	while p:GetHearts() > 2 do
		p:AddHearts(-1)
		AddHeartFly(p)
	end
	while p:GetMaxHearts() > 2 do
		p:AddMaxHearts(-1, true)
		AddHeartFly(p)
	end
	while p:GetRottenHearts() > 0 do
		p:AddRottenHearts(-1)
		p:AddHearts(1)
		AddHeartFly(p)
	end
	while p:GetSoulHearts() > 0 do
		p:AddSoulHearts(-1)
		AddHeartFly(p)
	end
end, duke)

-- heart flies
dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	local p = f.SpawnerEntity
	local playerData = p:GetData()
	local data = f:GetData()
	local sprite = f:GetSprite()
	if not sprite:IsPlaying("Idle") then
		sprite:Play("Idle", true)
	end
	if data.layer == 1 then
		f.OrbitDistance = Vector(20, 20)
		f.OrbitSpeed = 0.045
	elseif data.layer == 2 then
		f.OrbitDistance = Vector(40, 36)
		f.OrbitSpeed = 0.02
		f.CollisionDamage = 3
	elseif data.layer == 3 then
		f.OrbitDistance = Vector(60, 56)
		f.OrbitSpeed = 0.01
		f.CollisionDamage = 2
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
		for _,v in pairs(playerData.heartFlies) do
			for i,j in pairs(v) do
				if j == f.InitSeed then
					table.remove(playerData.heartFlies, k)
					break
				end
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
