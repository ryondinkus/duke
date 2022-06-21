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

	if sprite:IsFinished("Appear") or sprite:IsFinished("Hop") then
		data.jumpCooldown = jumpCooldown
		sprite:Play("Idle", false)
		familiar.SpriteScale = Vector.One
		familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
		familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
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
				local newDestinationPosition = room:FindFreeTilePosition(data.targetPosition, 0) - data.startPosition
				local sign = 1
				if DukeHelpers.Sign(newDestinationPosition.X) ~= 1 or DukeHelpers.Sign(newDestinationPosition.Y) ~= 1 then
					sign = -1
				end
				moveVector = ((newDestinationPosition)/14)
			end
			familiar.Velocity = moveVector
		end
	end

	if sprite:IsEventTriggered("Land") then
		familiar.Velocity = Vector.Zero
		data.State = STATE.IDLE
		print(familiar.Position)
	end

	if data.State == STATE.POSSESS then
		familiar.Position = data.possessedEntity.Position
		if data.possessedEntity:IsDead() then
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

	if DukeHelpers.IsActualEnemy(entity) then
		data.State = STATE.POSSESS
		data.possessedEntity = entity
		familiar.SpriteScale = Vector.Zero
		familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

		DukeHelpers.sfx:Play(SoundEffect.SOUND_MEAT_JUMPS, 1, 0)
		Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, entity.Position, Vector.Zero, familiar)

		sprite:Play("Possess", false)
		entity:AddCharmed(EntityRef(player), -1)
	end
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
		}
	}
}
