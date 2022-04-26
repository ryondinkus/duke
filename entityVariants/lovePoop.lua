local Name = "Love Poop"
local Tag = "lovePoop"
local Id = Isaac.GetEntityVariantByName(Name)

local function MC_NPC_UPDATE(_, entity)
    if entity.Variant == Id then
        if not entity:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
            entity:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
        end
        local sprite = entity:GetSprite()
        local data = entity:GetData()
        sprite:ReplaceSpritesheet(0, "gfx/familiars/love_poop.png")
        sprite:LoadGraphics()

        local enemies = DukeHelpers.ListEnemiesInRoom(true)
        for _,enemy in pairs(enemies) do
            if sprite:GetAnimation() ~= "State5" then
                enemy.Target = entity
            elseif data.dead == nil then
                enemy.Target = nil
                data.dead = true
            end
        end
    end
end

return {
	Name = Name,
	Tag = Tag,
	Id = Id,
	callbacks = {
		{
			ModCallbacks.MC_NPC_UPDATE,
			MC_NPC_UPDATE,
			EntityType.ENTITY_POOP
		}
	}
}
