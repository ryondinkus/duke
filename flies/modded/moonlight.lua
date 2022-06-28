local key = "MOONLIGHT" -- From Moonlight Hearts Mod
local subType = 901
local attackFlySubType = DukeHelpers.GetAttackFlySubTypeBySubType(subType)

local function MC_PRE_FAMILIAR_COLLISION(_, f, e)
	if f.SubType == subType then
		if e.Type == EntityType.ENTITY_PROJECTILE and not e:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
			local p = f.SpawnerEntity:ToPlayer() or Isaac.GetPlayer(0)
			local data = p:GetData()
			local effect = DukeHelpers.rng:RandomInt(6)
			if effect == 0 then
				Game():GetLevel():ApplyBlueMapEffect()
			elseif effect == 1 then
				Game():GetLevel():ApplyCompassEffect()
			elseif effect == 2 then
				Game():GetLevel():ApplyMapEffect()
			elseif effect == 3 then
				Game():GetLevel():RemoveCurses(LevelCurse.CURSE_OF_DARKNESS | LevelCurse.CURSE_OF_BLIND |
					LevelCurse.CURSE_OF_THE_LOST | LevelCurse.CURSE_OF_THE_UNKNOWN | LevelCurse.CURSE_OF_MAZE)
			elseif effect == 4 then
				p:UseCard(Card.CARD_SOUL_CAIN, (UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOANIM))
			elseif effect == 5 then
				data.moontears = data.moontears + 2
				p:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
				p:EvaluateItems()
			end
		end
	end
end

return {
	key = key,
	spritesheet = "moonlight_heart_fly.png",
	canAttack = true,
	subType = subType,
	count = 1,
	weight = 0,
	poofColor = Color(0.62, 0.62, 0.62, 1, 0.90, 0.78, 1),
	sacAltarQuality = 3,
	sfx = SoundEffect.SOUND_SOUL_PICKUP,
	callbacks = {
		{
			ModCallbacks.MC_PRE_FAMILIAR_COLLISION,
			MC_PRE_FAMILIAR_COLLISION,
			DukeHelpers.FLY_VARIANT
		}
	},
	heartFlyDamageMultiplier = 1.3,
	attackFlyDamageMultiplier = 1.3
}
