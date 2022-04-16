local Names = {
    en_us = "Duke Flute",
    spa = "Duque Flutue"
}
local Name = Names.en_us
local Tag = "dukeFlute"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Poops and shits everywhere",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function MC_USE_ITEM(_, type, rng, player, flags)
	local friendlyDuke = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, DukeHelpers.EntityVariants.friendlyDuke.Id, 0, player.Position, Vector.Zero, player)
	friendlyDuke:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	DukeHelpers.sfx:Play(DukeHelpers.Sounds.dukeFlute, 1, 0)
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
