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
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Like a princess, but a man.")

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
