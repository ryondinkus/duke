local Name = "The Invader"
local Tag = "theInvader"
local Id = Isaac.GetEntityVariantByName(Name)

local STATE = {
	IDLE = 1,
	HOP = 2,
	APPEAR = 3,
	POSSESS = 4
}

local jumpCooldown = 10
local jumpDistance = 4

local function MC_FAMILIAR_UPDATE(_, familiar)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local player = familiar.Player

	if player:HasTrinket(TrinketType.TRINKET_FORGOTTEN_LULLABY) then
		jumpCooldown = 3
	else
		jumpCooldown = 10
	end

	if sprite:IsFinished("Appear") or sprite:IsFinished("Hop") then
		data.jumpCooldown = jumpCooldown
		sprite:Play("Idle", false)
		familiar.SpriteScale = Vector.One
		familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
		familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
		if not familiar:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
			familiar:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
		end
	end

	if data.State == STATE.IDLE then
		if data.jumpCooldown then
			if data.jumpCooldown <= 0 then
				sprite:Play("Hop", false)
			end
			data.jumpCooldown = data.jumpCooldown - 1
		end
	end

	if sprite:IsEventTriggered("Jump") then
		data.State = STATE.HOP
		data.startPosition = familiar.Position
		local target = DukeHelpers.GetNearestEnemy(familiar.Position) or player
		if target then
			data.targetPosition = target.Position
		end
		familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	end

	if data.State == STATE.HOP then
		if data.targetPosition then
			local moveVector = (data.targetPosition - data.startPosition):Normalized() * jumpDistance
			local destinationPosition = (data.startPosition + (moveVector * 14))
			local room = Game():GetRoom()
			if room:GetGridCollisionAtPos(destinationPosition) ~= GridCollisionClass.COLLISION_NONE then
				local newDestinationPosition = room:FindFreeTilePosition(destinationPosition, 0) - data.startPosition
				moveVector = ((newDestinationPosition)/14)
			end
			familiar.Velocity = moveVector
		end
	end

	if sprite:IsEventTriggered("Land") then
		familiar.Velocity = Vector.Zero
		data.State = STATE.IDLE
	end

	if data.State == STATE.POSSESS then
		familiar.Position = data.possessedEntity.Position
		if data.possessedEntity:IsDead() then
			if Sewn_API and Sewn_API:IsUltra(data) then
				Isaac.Explode(data.possessedEntity.Position, player, 40)
			end

			data.State = STATE.SPAWN
			data.possessedEntity = nil
			data.jumpCooldown = jumpCooldown

			DukeHelpers.sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, familiar.Position, Vector.Zero, familiar)

			sprite:Play("Appear", false)
		end
	end

end

local function MC_PRE_FAMILIAR_COLLISION(_, familiar, entity)
	local data = familiar:GetData()
	local sprite = familiar:GetSprite()
	local player = familiar.Player

	if DukeHelpers.IsActualEnemy(entity) and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
		data.State = STATE.POSSESS
		data.possessedEntity = entity
		familiar.SpriteScale = Vector.Zero
		familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

		DukeHelpers.sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, entity.Position, Vector.Zero, familiar)

		sprite:Play("Possess", false)
		entity:AddCharmed(EntityRef(player), -1)
		if player and (player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND)
		or player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)) then
			entity.MaxHitPoints = entity.MaxHitPoints * 2
			entity.HitPoints = entity.HitPoints * 2
		end
		if Sewn_API and Sewn_API:IsSuper(data) then
			entity:ToNPC():MakeChampion(DukeHelpers.rng:Next())
		end
	end
end

local function MC_POST_NEW_ROOM()
	DukeHelpers.ForEachEntityInRoom(function(familiar)
		local data = familiar:GetData()
		if data.State ~= STATE.POSSESS then
			print("hey")
			familiar.Velocity = Vector.Zero
			data.State = STATE.IDLE
		end
	end, EntityType.ENTITY_FAMILIAR, Id, 0)
end

if Sewn_API then
	Sewn_API:MakeFamiliarAvailable(Id, DukeHelpers.Items.theInvader.Id)
end

return {
	Name = Name,
	Tag = Tag,
	Id = Id,
	callbacks = {
		{
			ModCallbacks.MC_FAMILIAR_UPDATE,
			MC_FAMILIAR_UPDATE,
			Id
		},
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			Id
		},
		{
			ModCallbacks.MC_POST_NEW_ROOM,
			MC_POST_NEW_ROOM
		}
	}
}
