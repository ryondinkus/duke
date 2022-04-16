local Name = "Friendly Duke"
local Tag = "friendlyDuke"
local Id = Isaac.GetEntityVariantByName(Name)

local STATE = {
	DESCEND = 0,
	FLOAT = 1,
	ATTACK_SMALL = 2,
	ATTACK_BIG = 3,
	ASCEND
}

local CONSTANTS = {
	EXISTENCE_TIMER = 450,
	ATTACK_COOLDOWN_MIN = 1,
	ATTACK_COOLDOWN_MAX = 3,
	MOVE_SPEED = 2
}

local function MC_FAMILIAR_UPDATE(_, f)
	local data = f:GetData()
	local sprite = f:GetSprite()
	if f.FrameCount == 6 then
		sprite:Play("Descend", true)
		data.State = STATE.DESCEND
		data.moveAngle = (DukeHelpers.rng:RandomInt(4) * 90) + 45
		f.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
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
				data.State= STATE.ATTACK_SMALL
			elseif attackType == 1 then
				sprite:Play("Attack02", true)
				data.State= STATE.ATTACK_BIG
			end
		end
		if data.existenceTimer <= 0 then
			sprite:Play("Ascend", true)
			data.State= STATE.ASCEND
		end
		data.existenceTimer = data.existenceTimer - 1
	end
	if data.State == STATE.ATTACK_SMALL then
		if sprite:IsEventTriggered("Barf") then
			for _= 1,3 do
				local fly = Isaac.Spawn(EntityType.ENTITY_ATTACKFLY, 0, 0, f.Position, Vector.Zero, f)
				fly:AddCharmed(EntityRef(f.Player), -1)
			end
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
			for _= 1,3 do
				local fly = Isaac.Spawn(EntityType.ENTITY_ATTACKFLY, 0, 0, f.Position, Vector.Zero, f)
				fly:AddCharmed(EntityRef(f.Player), -1)
			end
		end
		if sprite:IsFinished("Attack02") then
			sprite:Play("Float", true)
			data.State = STATE.FLOAT
			data.attackCooldown = 30 * DukeHelpers.rng:RandomInt(CONSTANTS.ATTACK_COOLDOWN_MAX) + CONSTANTS.ATTACK_COOLDOWN_MIN
		end
		data.existenceTimer = data.existenceTimer - 1
	end
	if data.State and data.State ~= STATE.DESCEND and data.State ~= STATE.ASCEND then
		if f:CollidesWithGrid() then
			data.moveAngle = (data.moveAngle + 90)%360
		end
		f.Velocity = Vector.FromAngle(data.moveAngle) * CONSTANTS.MOVE_SPEED
	end
	if data.State == STATE.ASCEND then
		if sprite:IsFinished("Ascend") then
			f:Remove()
		end
	end
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
    }
}
