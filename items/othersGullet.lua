local Names = {
    en_us = "DUKE'S GULLET",
    spa = "La Garganta del Duque"
}
local Name = Names.en_us
local Tag = "othersGullet"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Poops and shits everywhere",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = "Poops and shits everywhere."--helper.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function MC_USE_ITEM(_, type, rng, p)
    for _= 1, 2 do
        local flyToSpawn = DukeHelpers.GetWeightedFly(rng)
        DukeHelpers.SpawnAttackFlyBySubType(flyToSpawn.heartFlySubType, p.Position, p)
    end
    return true
end

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
	Id = Id,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    callbacks = {
        {
            ModCallbacks.MC_USE_ITEM,
            MC_USE_ITEM,
            Id
        }
    }
}
