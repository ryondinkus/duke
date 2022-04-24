local Name = "Friendly Duke"
local Tag = "friendlyDuke"
local Id = Isaac.GetEntityVariantByName(Name)

local STATE = {
	DESCEND = 0,
	FLOAT = 1,
	ATTACK_SMALL = 2,
	ATTACK_BIG = 3,
	DEATH = 4
}

local CONSTANTS = {
	EXISTENCE_TIMER = 450,
	ATTACK_COOLDOWN_MIN = 1,
	ATTACK_COOLDOWN_MAX = 3,
	MOVE_SPEED = 2,
	FLY_SPAWN_OFFSET = Vector(0, 40)
}

local function MC_FAMILIAR_UPDATE(_, f)
	local data = f:GetData()
	local sprite = f:GetSprite()
	if f.FrameCount == 6 then
		data.State = STATE.DESCEND
		data.moveAngle = (DukeHelpers.rng:RandomInt(4) * 90) + 45
		f.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		if DukeHelpers.rng:RandomInt(5) == 0 then
			if DukeHelpers.rng:RandomInt(2) == 0 then
				data.Champion = "Green"
				sprite:ReplaceSpritesheet(0, "gfx/familiars/friendly_duke_green.png")
				sprite:LoadGraphics()
			else
				data.Champion = "Orange"
				sprite:ReplaceSpritesheet(0, "gfx/familiars/friendly_duke_orange.png")
				sprite:LoadGraphics()
			end
		end
	end
	if data.State == STATE.DESCEND then
		if sprite:IsFinished("Descend") then
			sprite:Play("Float", true)
			data.State = STATE.FLOAT
			data.existenceTimer = CONSTANTS.EXISTENCE_TIMER
			data.attackCooldown = 30 * DukeHelpers.rng:RandomInt(CONSTANTS.ATTACK_COOLDOWN_MAX) + CONSTANTS.ATTACK_COOLDOWN_MIN
		end
	end
	if data.State == STATE.FLOAT then
		data.attackCooldown = data.attackCooldown - 1
		if data.attackCooldown <= 0 then
			local attackType = DukeHelpers.rng:RandomInt(2)
			if attackType == 0 then
				sprite:Play("Attack01", true)
				data.State = STATE.ATTACK_SMALL
			elseif attackType == 1 then
				sprite:Play("Attack02", true)
				data.State = STATE.ATTACK_BIG
			end
		end
		if data.existenceTimer <= 0 then
			sprite:Play("Death", true)
			data.State = STATE.DEATH
			f.Velocity = Vector.Zero
		end
		data.existenceTimer = data.existenceTimer - 1
	end
	if data.State == STATE.ATTACK_SMALL then
		if sprite:IsEventTriggered("Barf") then
			for _ = 1, 3 do
				local fly = Isaac.Spawn(EntityType.ENTITY_ATTACKFLY, 0, 0, f.Position + CONSTANTS.FLY_SPAWN_OFFSET, Vector.Zero, f)
				fly:AddCharmed(EntityRef(f.Player), -1)
				fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
			DukeHelpers.sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_1, 1, 0)
		end
		if sprite:IsFinished("Attack01") then
			sprite:Play("Float", true)
			data.State = STATE.FLOAT
			data.attackCooldown = 30 * DukeHelpers.rng:RandomInt(CONSTANTS.ATTACK_COOLDOWN_MAX) + CONSTANTS.ATTACK_COOLDOWN_MIN
		end
		data.existenceTimer = data.existenceTimer - 1
	end
	if data.State == STATE.ATTACK_BIG then
		if sprite:IsEventTriggered("Barf") then
			if data.Champion == "Green" then
				local fly = Isaac.Spawn(EntityType.ENTITY_MOTER, 0, 0, f.Position + CONSTANTS.FLY_SPAWN_OFFSET, Vector.Zero, f)
				fly:AddCharmed(EntityRef(f.Player), -1)
				fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			elseif data.Champion == "Orange" then
				local fly = Isaac.Spawn(EntityType.ENTITY_SUCKER, 0, 0, f.Position + CONSTANTS.FLY_SPAWN_OFFSET, Vector.Zero, f)
				fly:AddCharmed(EntityRef(f.Player), -1)
				fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			else
				local fly = Isaac.Spawn(EntityType.ENTITY_ATTACKFLY, 0, 0, f.Position + CONSTANTS.FLY_SPAWN_OFFSET, Vector.Zero, f)
				fly:AddCharmed(EntityRef(f.Player), -1)
				fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				fly:GetData().bigFly = true
				fly.MaxHitPoints = fly.MaxHitPoints * 1.5
				fly.HitPoints = fly.HitPoints * 1.5
			end
			DukeHelpers.sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_2, 1, 0)
		end
		if sprite:IsFinished("Attack02") then
			sprite:Play("Float", true)
			data.State = STATE.FLOAT
			data.attackCooldown = 30 * DukeHelpers.rng:RandomInt(CONSTANTS.ATTACK_COOLDOWN_MAX) + CONSTANTS.ATTACK_COOLDOWN_MIN
		end
		data.existenceTimer = data.existenceTimer - 1
	end
	if data.State and data.State ~= STATE.DESCEND and data.State ~= STATE.DEATH then
		-- TODO: Make rotation more accurate, sometimes it bounces in the opposite direction intended
		-- this is because the rotation always adds 90, when it occasionally needs to subtract 90
		-- the switch between addition and subtraction happens when a top or bottom wall is hit after a change in horizontal speed
		if f:CollidesWithGrid() then
			data.moveAngle = (data.moveAngle + 90) % 360
		end
		f.Velocity = Vector.FromAngle(data.moveAngle) * CONSTANTS.MOVE_SPEED
	end
	if data.State == STATE.DEATH then
		if sprite:IsEventTriggered("Die") then
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LARGE_BLOOD_EXPLOSION, 0, f.Position, Vector.Zero, f)
			DukeHelpers.sfx:Play(SoundEffect.SOUND_ROCKET_BLAST_DEATH)
			for _ = 1, 6 do
				local fly = Isaac.Spawn(EntityType.ENTITY_ATTACKFLY, 0, 0, f.Position, Vector.FromAngle(DukeHelpers.rng:RandomInt(360)) * 5, f)
				fly:AddCharmed(EntityRef(f.Player), -1)
				fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			end
		end
		if sprite:IsFinished("Death") then
			f:Remove()
		end
	end
	if data.Champion and data.Champion == "Orange" then
		f.SpriteScale = f.SpriteScale * 1.15
	end
end

local function MC_POST_NEW_ROOM()
	DukeHelpers.ForEachEntityInRoom(function(entity)
		entity:Remove()
	end, EntityType.ENTITY_FAMILIAR, DukeHelpers.EntityVariants.friendlyDuke.Id)
end

local function MC_POST_UPDATE(_, e)
	DukeHelpers.ForEachEntityInRoom(function(entity)
		if entity:GetData().bigFly then
			entity.SpriteScale = entity.SpriteScale * 1.2
		end
	end, EntityType.ENTITY_ATTACKFLY)
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
			ModCallbacks.MC_POST_NEW_ROOM,
			MC_POST_NEW_ROOM
		},
		{
			ModCallbacks.MC_POST_UPDATE,
			MC_POST_UPDATE
		}
	}
}
