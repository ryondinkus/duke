local Names = {
    en_us = "Ultra Heart Fly",
    spa = "I don't know spanish and I'm in my room lmao"
}
local Name = Names.en_us
local Tag = "ultraHeartFly"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Spawns an Ultra Heart Orbital Fly on pickup and on every new floor#Ultra Heart Flies have the properties of all other Heart Flies",
    spa = "I don't know spanish and I'm in my room lmao"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        " On pickup and at the start of every new floor, grants 1 Ultra Heart Orbital Fly.",
        "- Ultra Heart Orbital Flies have the combined abilities of all of Heart Flies, including:",
        "-- Deals 2x contact damage",
        "-- Has a random chance of Midas Freezing or Poisoning an enemy on contact",
        "-- Triggers the Necronomicon effect when it absorbs a bullet",
        "-- Can absorb 2 bullets before turning into an Ultra Heart Attack Fly",
        "-- As an attack fly, deals 2x contact damage",
        "-- As an attack fly, it will either fear, midas freeze, or poison the enemy on collision. It will also fire a ring of 8 bone tears and spawn 1-8 coins on collision",
    },
    {
        "Trivia",
        "Ultra Heart Fly was added later in development to replace the Husk Baby unlock, which was scrapped along with the other co-op babies.",
        "- Husk Baby would have fired Heart Spiders instead of tears"
    }
})

local function MC_POST_NEW_LEVEL()
    DukeHelpers.ForEachPlayer(function(duke)
        DukeHelpers.AddHeartFly(duke, DukeHelpers.Flies.ULTRA, 1)
    end, Id)
end

local function MC_POST_PEFFECT_UPDATE(_, p)
    local data = DukeHelpers.GetDukeData(p)
    if data and data[Tag] then
        if p:IsExtraAnimationFinished() then
            data[Tag] = nil
            DukeHelpers.AddHeartFly(p, DukeHelpers.Flies.ULTRA, 1)
        end
    else
        local targetItem = p.QueuedItem.Item
        if (not targetItem) or targetItem.ID ~= Id then
            return
        end
        data[Tag] = true
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
            ModCallbacks.MC_POST_NEW_LEVEL,
            MC_POST_NEW_LEVEL
        },
        {
            ModCallbacks.MC_POST_PEFFECT_UPDATE,
            MC_POST_PEFFECT_UPDATE
        }
    },
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.MEGA_SATAN, Tag, DukeHelpers.DUKE_NAME)
}
