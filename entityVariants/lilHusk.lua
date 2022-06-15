local Name = "Lil Husk"
local Tag = "lilHusk"
local Id = Isaac.GetEntityVariantByName(Name)

local DIRECTION = {
	[0] = "Left",
	[1] = "Up",
	[2] = "Right",
	[3] = "Down"
}

local fireCooldown = 7

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
		local spawnedSpider = DukeHelpers.SpawnSpidersFromPickupSubType(DukeHelpers.GetWeightedSpider(DukeHelpers.rng).pickupSubType,
			familiar.Position, familiar, 1, true)
		data.fireCooldown = fireCooldown
		data.canSpawnSpider = false
	end
	-- if sprite:IsFinished("ShootDown") or sprite:IsFinished("ShootLeft") or sprite:IsFinished("ShootRight") or sprite:IsFinished("ShootUp") then
	-- end
	if data.canSpawnSpider then
		data.fireCooldown = data.fireCooldown - 1
	end
	familiar:FollowParent()
end

local function MC_POST_ENTITY_REMOVE(_, e)
    if e.Variant == FamiliarVariant.BLUE_SPIDER and e.SpawnerType == EntityType.ENTITY_FAMILIAR and e.SpawnerVariant == Id then
        e.SpawnerEntity:GetData().canSpawnSpider = true
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
		}
	}
}
