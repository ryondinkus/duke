dukeMod = RegisterMod("Duke", 1)

local duke = Isaac.GetPlayerTypeByName("Duke")
local heartFly = Isaac.GetEntityVariantByName("Red Heart Fly")

local sfx = SFXManager()
local rng = RNG()

-- helpers
local HeartFlies = {
	FLY_RED = 1,
	nil,
	FLY_SOUL = 3,
	FLY_ETERNAL = 4,
	nil,
	FLY_BLACK = 6,
	FLY_GOLD = 7,
	nil,
	nil,
	nil,
	FLY_BONE = 11,
	FLY_ROTTEN = 12,
	FLY_BROKEN = 13
}

local AttackFlies = {}
for k,v in pairs(HeartFlies) do
	AttackFlies[k] = v + 903
end

local function SpawnHeartFly(player, subtype, layer)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, heartFly, subtype or 1, player.Position, Vector.Zero, player)
	fly:GetData().layer = layer
	fly:ToFamiliar():AddToOrbit(903 + layer)
	return fly
end

local function AddHeartFly(player, subtype)
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
		fly = SpawnHeartFly(player, subtype, 1)
		table.insert(playerData.heartFlies[1], fly.InitSeed)
	elseif #playerData.heartFlies[2] < 9 then
		fly = SpawnHeartFly(player, subtype, 2)
		table.insert(playerData.heartFlies[2], fly.InitSeed)
	elseif #playerData.heartFlies[3] < 12 then
		fly = SpawnHeartFly(player, subtype, 3)
		table.insert(playerData.heartFlies[3], fly.InitSeed)
	end

	return fly
end

local function RemoveHeartFly(heartFly)
	local p = heartFly.SpawnerEntity
	local playerData = p:GetData()
	if playerData.heartFlies then
		for k,v in pairs(playerData.heartFlies) do
			for i,j in pairs(v) do
				if j == heartFly.InitSeed then
					table.remove(playerData.heartFlies[k], i)
					heartFly:Remove()
					return
				end
			end
		end
	end
end

local function GetHeartFlySpritesheet(subtype)
	local spriteTable = {
		"gfx/familiars/red_heart_fly.png",
		nil,
		"gfx/familiars/soul_heart_fly.png",
		"gfx/familiars/eternal_heart_fly.png",
		nil,
		"gfx/familiars/black_heart_fly.png",
		"gfx/familiars/gold_heart_fly.png",
		nil,
		nil,
		nil,
		"gfx/familiars/bone_heart_fly.png",
		"gfx/familiars/rotten_heart_fly.png",
		"gfx/familiars/broken_heart_fly.png"
	}
	return spriteTable[subtype] or "gfx/familiars/red_heart_fly.png"
end

local function CanBecomeAttackFly(fly)
	local blacklist = {
		true,
		nil,
		true,
		false,
		nil,
		true,
		true,
		nil,
		nil,
		nil,
		true,
		true,
		false
	}
	return blacklist[fly.SubType]
end

local function SpawnAttackHeartFly(heartFly)
	local fly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, heartFly.SubType + 903, heartFly.Position, Vector.Zero, heartFly.SpawnerEntity)
	local sprite = fly:GetSprite()
	sprite:ReplaceSpritesheet(0, GetHeartFlySpritesheet(heartFly.SubType))
	sprite:LoadGraphics()
	sprite:Play("Attack", true)
	fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	return fly
end

local function ForEachEntityInRoom(callback, entityType, entityVariant, entitySubType, extraFilters)
    local filters = {
        Type = entityType,
        Variant = entityVariant,
        SubType = entitySubType
    }

    local initialEntities = Isaac.GetRoomEntities()
    for _, entity in ipairs(initialEntities) do
        local shouldReturn = true
        for entityKey, filter in pairs(filters) do
            if not shouldReturn then
                break
            end

            if filter ~= nil then
                if type(filter) == "function" then
                    shouldReturn = filter(entity[entityKey])
                else
                    shouldReturn = entity[entityKey] == filter
                end
            end
        end

        if shouldReturn and extraFilters ~= nil then
            shouldReturn = extraFilters(entity)
			print(shouldReturn)
        end

        if shouldReturn then
			print("mother")
            callback(entity)
        end
	end
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
				AddHeartFly(p, HeartFlies.FLY_RED)
			end
		end
	end
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	for i=0,Game():GetNumPlayers() - 1 do
		local p = Isaac.GetPlayer(i)
		if p:GetPlayerType() == duke then
			AddHeartFly(p, pickup.SubType)
			pickup:Remove()
			break
		end
	end
end, PickupVariant.PICKUP_HEART)

dukeMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, p)
	while p:GetBlackHearts() > 0 do
		p:AddBlackHearts(-1)
		AddHeartFly(p, HeartFlies.FLY_BLACK)
	end
	while p:GetBoneHearts() > 0 do
		p:AddBoneHearts(-1)
		AddHeartFly(p, HeartFlies.FLY_BONE)
	end
	if p:GetBrokenHearts() > 0 then
		while p:GetBrokenHearts() > 0 do
			p:AddBrokenHearts(-1)
			AddHeartFly(p, HeartFlies.FLY_BROKEN)
		end
		if p:GetMaxHearts() < 2 then
			p:AddMaxHearts(2)
			p:AddHearts(2)
		end
	end
	while p:GetEternalHearts() > 0 do
		p:AddEternalHearts(-1)
		AddHeartFly(p, HeartFlies.FLY_ETERNAL)
	end
	while p:GetGoldenHearts() > 0 do
		p:AddGoldenHearts(-1)
		AddHeartFly(p, HeartFlies.FLY_GOLD)
	end
	while p:GetHearts() > 2 do
		p:AddHearts(-1)
		AddHeartFly(p, HeartFlies.FLY_RED)
	end
	while p:GetMaxHearts() > 2 do
		p:AddMaxHearts(-1, true)
		AddHeartFly(p, HeartFlies.FLY_RED)
	end
	while p:GetRottenHearts() > 0 do
		p:AddRottenHearts(-1)
		p:AddHearts(1)
		AddHeartFly(p, HeartFlies.FLY_ROTTEN)
	end
	while p:GetSoulHearts() > 0 do
		p:AddSoulHearts(-1)
		AddHeartFly(p, HeartFlies.FLY_SOUL)
	end
end, duke)

-- heart flies
dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	local p = f.SpawnerEntity or Isaac.GetPlayer(0)
	local playerData = p:GetData()
	local data = f:GetData()
	local sprite = f:GetSprite()
	if f.FrameCount == 6 then
		sprite:ReplaceSpritesheet(0, GetHeartFlySpritesheet(f.SubType))
		sprite:LoadGraphics()
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
	if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
        e:Die()
		if CanBecomeAttackFly(f) then
			local fly = SpawnAttackHeartFly(f)
			fly:GetData().attacker = e.SpawnerEntity
			RemoveHeartFly(f)
		end
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

-- eternal heart flies
dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	if f.SubType == HeartFlies.FLY_ETERNAL then
		if f.FrameCount == 6 then
			ForEachEntityInRoom(function(entity)
				for i=1,4 do
					AddHeartFly(f.SpawnerEntity, HeartFlies.FLY_RED)
					RemoveHeartFly(entity)
					RemoveHeartFly(f)
				end
			end, EntityType.ENTITY_FAMILIAR, heartFly, HeartFlies.FLY_ETERNAL,
			function(entity)
				return entity.SpawnerEntity.InitSeed == f.SpawnerEntity.InitSeed and entity.InitSeed ~= f.InitSeed
			end)
		end
		f.CollisionDamage = f.CollisionDamage * 1.5
	end
end, heartFly)

dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	if f.SubType == AttackFlies.FLY_BLACK then
		if f.FrameCount == 6 then
			f.CollisionDamage = f.CollisionDamage * 1.5
		end
	end
end, FamiliarVariant.BLUE_FLY)

-- black heart flies
dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	if f.SubType == HeartFlies.FLY_BLACK then
		f.CollisionDamage = f.CollisionDamage * 1.3
	end
end, heartFly)

dukeMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, f, e)
	if f.SubType == HeartFlies.FLY_BLACK then
		if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			local p = f.SpawnerEntity or Isaac.GetPlayer(0)
			p:ToPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM)
	    end
	end
end, heartFly)

dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
	if f.SubType == AttackFlies.FLY_BLACK then
		if f.FrameCount == 6 then
			f.CollisionDamage = f.CollisionDamage * 1.3
		end
	end
end, FamiliarVariant.BLUE_FLY)

-- gold heart flies
dukeMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, f, e)
	if f.SubType == HeartFlies.FLY_GOLD then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) and rng:RandomInt(3) == 0 then
			e:AddMidasFreeze(EntityRef(f), 30)
		end
	end
end, heartFly)

dukeMod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function(_, f, e)
	if f.SubType == AttackFlies.FLY_GOLD then
		if e:ToNPC() and not e:HasEntityFlags(EntityFlag.FLAG_CHARM) then
			e:AddMidasFreeze(EntityRef(f), 150)
			for i=0,rng:RandomInt(8) do
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, f.Position, Vector.FromAngle(rng:RandomInt(360)), f)
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKED_ORB_POOF, 0, f.Position, Vector.Zero, f)
				local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER, 0, f.Position, Vector.Zero, f)
				effect.Color = Color(1,1,1,0,1,0.7,0)
				effect:GetSprite().Scale = Vector(0.5,0.5)
				sfx:Play(SoundEffect.SOUND_ULTRA_GREED_COIN_DESTROY, 1, 0)
			end
		end
	end
end, FamiliarVariant.BLUE_FLY)

dukeMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	local seeds = Game():GetSeeds()
	rng:SetSeed(seeds:GetStartSeed(), 35)
end)
