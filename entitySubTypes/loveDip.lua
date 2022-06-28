local Name = "Friendly Dip (love)"
local Tag = "loveDip"
local Id = 332

local function MC_FAMILIAR_UPDATE(_, familiar)
    print("callback runs")
    if familiar.SubType == Id then
        print(":)")
    	local data = DukeHelpers.GetDukeData(familiar)
    	local sprite = familiar:GetSprite()
    	local player = familiar.Player

    	if data and not data.timer then
            print("chat time")
            data.timer = 300
        end

        if data.timer then
            if data.timer % 30 == 0 then
                print("yunk")
                familiar:TakeDamage(1, 0, EntityRef(familiar), 0)
            end
            data.timer = data.timer - 1
            if familiar:HasMortalDamage() then
                local explosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.FART, 0, familiar.Position,
                    Vector.Zero, familiar)
                explosion.Color = Color(1, 1, 1, 1, 0.59, 0, 0.39)
                explosion.SpriteScale = Vector(0.5, 0.5)
                local damage = 20
                local radius = 40
                for i, enemy in ipairs(Isaac.FindInRadius(familiar.Position, radius, EntityPartition.ENEMY)) do
                    enemy:TakeDamage(damage, DamageFlag.DAMAGE_EXPLOSION, EntityRef(player), 0)
                end
                entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                data.state = -1
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
			ModCallbacks.MC_FAMILIAR_UPDATE,
			MC_FAMILIAR_UPDATE,
            FamiliarVariant.DIP
		}
	}
}
