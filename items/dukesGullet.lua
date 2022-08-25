local Names = {
    en_us = "Duke's Gullet",
    spa = "La Garganta del Duque"
}
local Name = Names.en_us
local Tag = "dukesGullet"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Converts all of your current Heart Orbital Flies into Heart Attack Flies#Heart Attack Flies spawned this way have a chance of spawning a half heart of their type on death",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function MC_USE_ITEM(_, type, rng, p, flags)
    if DukeHelpers.IsDuke(p) then
        local fliesData = DukeHelpers.GetDukeData(p).heartFlies
        if fliesData and
        DukeHelpers.Find(fliesData, function(f) return DukeHelpers.Flies[f.key].canAttack end)
		then
			local outerLayer = DukeHelpers.OUTER
			if p:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
				outerLayer = DukeHelpers.BIRTHRIGHT
			end
			while outerLayer > 0 do
				local flyCount = 0
				for i = 1, #fliesData do
					if fliesData[i].layer == outerLayer and DukeHelpers.Flies[fliesData[i].key].canAttack then
						flyCount = flyCount + 1
					end
				end
				if flyCount > 0 then
					break
				else
					outerLayer = outerLayer - 1
				end
			end
            for i = #fliesData, 1, -1 do
                local fly = fliesData[i]
                local f = DukeHelpers.GetEntityByInitSeed(fly.initSeed)
                if DukeHelpers.Flies[fly.key].canAttack and fly.layer == outerLayer then
                    local attackFly = DukeHelpers.SpawnAttackFlyFromHeartFlyEntity(f)
					DukeHelpers.GetDukeData(attackFly).dropHeart = true
                    DukeHelpers.RemoveHeartFlyEntity(f)
                    if p:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                        DukeHelpers.SpawnAttackFlyWisp(DukeHelpers.Wisps[fly.key], p.Position, p, 60)
                    end
                end
            end
            DukeHelpers.sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0)
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, nil)
            effect.Color = Color(0, 0, 0, 1)
        else
            DukeHelpers.sfx:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0)
        end
        if (flags & UseFlag.USE_NOANIM == 0) then
            p:PlayExtraAnimation("DukeBarf")
        end
        return false
    end
end

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
    Id = Id,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    IsWikiHidden = true,
    callbacks = {
        {
            ModCallbacks.MC_USE_ITEM,
            MC_USE_ITEM,
            Id
        }
    }
}
