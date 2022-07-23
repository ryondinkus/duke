local Names = {
    en_us = "Duke Flute",
    spa = "Duque Flutue"
}
local Name = Names.en_us
local Tag = "dukeFlute"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Spawns a Friendly Duke of Flies, who flies around the room spitting out friendly Attack Flies for 15 seconds#Sometimes spawns a Champion Duke of Flies, who spits out different types of fly enemies",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "On use, spawns a familiar version of the Duke of Flies boss.",
        "- The Duke of Flies will fly diagonally around the room, dealing contact damage and occasionally spawning flies.",
        "-- He will either spawn three permacharmed Attack Flies or one larger Attack Fly with 1.5x HP.",
        "- After 15 seconds or when exiting the room, the Duke of Flies will die, spawning 6 more permacharmed Attack Flies.",
        "- There's a 10% chance of either the Orange or Green Champion versions of Duke of Flies spawning.",
        "-- The Orange Champion will be 1.15x larger and spawn a permacharmed Sucker instead of the larger Attack Fly.",
        "-- The Green Champion will spawn a permacharmed Moter instead of the larger Attack Fly."
    },
    {
        "Synergies",
        "Book of Virtues: The Duke of Flies will spit out Red Heart Fly Wisps instead of permacharmed Attack Flies. The flies spawned on death will still be Attack Flies.",
        "Car Battery: Spawns 2 Duke of Flies who will follow the same path"
    },
    {
        "Trivia",
        "Duke Flute parallels the Plum Flute, which spawns a familiar version of Baby Plum"
    }
})

local function MC_USE_ITEM(_, type, rng, player, flags)
    if DukeHelpers.Items.dukeFlute.IsUnlocked() then
        local friendlyDuke = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, DukeHelpers.EntityVariants.friendlyDuke.Id, 0,
            Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 0, true, true), Vector.Zero, player)
        friendlyDuke:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        DukeHelpers.sfx:Play(DukeHelpers.Sounds.dukeFlute, 1, 0)
        return true
    end
end

local function MC_FAMILIAR_INIT(_, familiar)
    if familiar.SubType == Id then
        familiar:Remove()
    end
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
        },
        {
            ModCallbacks.MC_FAMILIAR_INIT,
            MC_FAMILIAR_INIT,
            FamiliarVariant.WISP
        }
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.DELIRIUM, Tag, DukeHelpers.DUKE_NAME)
}
