local Name = "Lil Husk"
local Tag = "lilHusk"
local Id = Isaac.GetEntityVariantByName(Name)

local DIRECTION = {
	[0] = "Left",
	[1] = "Up",
	[2] = "Right",
	[3] = "Down"
}

local fireCooldown = 19
local lullabyFireCooldown = 7

local function MC_FAMILIAR_INIT(_, familiar)
	familiar:AddToFollowers()
end

local function MC_FAMILIAR_UPDATE(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local player = familiar.Player
	local fireDirection = player:GetFireDirection()
	local fireDirectionSprite = DIRECTION[fireDirection]
	if familiar.FrameCount == 6 then
		data.fireCooldown = 0
		data.canSpawnSpider = true
	end
	if fireDirection == Direction.NO_DIRECTION then
		sprite:Play("FloatDown", false)
	else
		if data.fireCooldown <= 0 then
			if data.canSpawnSpider then
				sprite:Play("Shoot" .. fireDirectionSprite, false)
			end
		else
			local frame = sprite:GetFrame()
			sprite:Play("Float" .. fireDirectionSprite, false)
			sprite:SetFrame(frame)
		end
	end
	if sprite:IsEventTriggered("Barf") then
		DukeHelpers.sfx:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0, false, 1.5)
		local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, nil)
		effect.Color = Color(0, 0, 0, 1)
		effect.SpriteScale = Vector(0.5, 0.5)
		local spawnedSpider = DukeHelpers.SpawnSpidersFromPickupSubType(DukeHelpers.GetWeightedSpider(DukeHelpers.rng).pickupSubType,
			familiar.Position, familiar, 1, true)
		if familiar.Player and familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and not familiar.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
			spawnedSpider[1]:GetData().bffs = true
			spawnedSpider[1].CollisionDamage = spawnedSpider[1].CollisionDamage * 2
		end
		if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
			data.fireCooldown = lullabyFireCooldown
		else
			data.fireCooldown = fireCooldown
		end
		data.canSpawnSpider = false
	end

	if data.canSpawnSpider then
		data.fireCooldown = data.fireCooldown - 1
	end
	familiar:FollowParent()
	print(data.fireCooldown)
end

local function MC_POST_ENTITY_REMOVE(_, e)
    if e.Variant == FamiliarVariant.BLUE_SPIDER and e.SpawnerEntity and e.SpawnerType == EntityType.ENTITY_FAMILIAR and e.SpawnerVariant == Id then
        e.SpawnerEntity:GetData().canSpawnSpider = true
    end
end

local function MC_SPIDER_FAMILIAR_UPDATE(_, familiar)
	if familiar:GetData().bffs then
		familiar.SpriteScale = Vector(1.2, 1.2)
	end
end

if Sewn_API then
	Sewn_API:MakeFamiliarAvailable(Id, DukeHelpers.Items.lilHusk.Id)
end

return {
	Name = Name,
	Tag = Tag,
	Id = Id,
	callbacks = {
		{
			ModCallbacks.MC_FAMILIAR_INIT,
			MC_FAMILIAR_INIT,
			Id
		},
		{
			ModCallbacks.MC_FAMILIAR_UPDATE,
			MC_FAMILIAR_UPDATE,
			Id
		},
		{
			ModCallbacks.MC_POST_ENTITY_REMOVE,
			MC_POST_ENTITY_REMOVE,
			EntityType.ENTITY_FAMILIAR
		},
		{
			ModCallbacks.MC_FAMILIAR_UPDATE,
			MC_SPIDER_FAMILIAR_UPDATE,
			FamiliarVariant.BLUE_SPIDER
		}
	}
}
