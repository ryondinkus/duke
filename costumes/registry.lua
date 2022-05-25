local function CostumePathToId(path)
    return Isaac.GetCostumeIdByPath(string.format("gfx/characters/%s.anm2", path))
end

DukeHelpers.Costumes = {
    duke_b_scars = CostumePathToId("character_duke_b_scars"),
}
