local Name = "Sharty McFly"
local Tag = "shartyMcFly"
local Id = Isaac.GetEntityVariantByName(Name)

local STATE = {
	IDLE = 1,
	ATTACK = 2,
    EMPTY = 3
}

local function MC_FAMILIAR_INIT(_, f)
	f:AddToFollowers()
end

local function MC_FAMILIAR_UPDATE(_, f)
	local data = f:GetData()
	local sprite = f:GetSprite()
	if f.FrameCount == 6 then
		sprite:Play("Float", true)
		data.State = STATE.IDLE
		data.poopCount = 1
	end
	if data.State == STATE.IDLE then
		for i=4, 7 do --all shooting enums in ButtonAction
			if Input.IsActionPressed(i, f.Player.ControllerIndex) then
				sprite:Play("Attack", true)
				data.State = STATE.ATTACK
			end
		end
	end
	if data.State == STATE.ATTACK then
		if sprite:IsEventTriggered("Barf") then
			DukeHelpers.sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0, false, 1.5)
			local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, f.Position, Vector.Zero, nil)
			effect.Color = Color(0, 0, 0, 1)
			effect.SpriteScale = Vector(0.5, 0.5)
			Isaac.Spawn(EntityType.ENTITY_POOP, DukeHelpers.EntityVariants.lovePoop.Id, 0, f.Position, Vector.Zero, f)
		end
		if sprite:IsFinished("Attack") then
			if Sewn_API:IsUltra(data) then
				data.poopCount = data.poopCount - 0.5
			else
				data.poopCount = data.poopCount - 1
			end
			if data.poopCount <= 0 then
				sprite:Play("Float_Light", true)
				data.State = STATE.EMPTY
			else
				sprite:Play("Float", true)
				data.State = STATE.IDLE
			end
		end
	end
    f:FollowParent()
end

local function MC_POST_NEW_ROOM()
	DukeHelpers.ForEachEntityInRoom(function(entity)
		entity:GetSprite():Play("Float", true)
		entity:GetData().State = STATE.IDLE
		entity:GetData().poopCount = 1
	end, EntityType.ENTITY_FAMILIAR, DukeHelpers.EntityVariants.shartyMcFly.Id)
end

if Sewn_API then
	Sewn_API:MakeFamiliarAvailable(Id, DukeHelpers.Items.shartyMcFly.Id)
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
			ModCallbacks.MC_POST_NEW_ROOM,
			MC_POST_NEW_ROOM
		}
	}
}
