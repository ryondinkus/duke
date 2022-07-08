local Names = {
    en_us = "The Princes",
    spa = "I don't know spanish and I'm on a plane lmao"
}
local Name = Names.en_us
local Tag = "thePrinces"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Like a princess, but a man.",
    spa = "I don't know spanish and I'm on a plane lmao"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Like a princess, but a man.")

local function MC_POST_NEW_LEVEL()
    DukeHelpers.ForEachPlayer(function(duke)
        for i = 1, 3 do
            DukeHelpers.AddHeartFly(duke, DukeHelpers.GetWeightedFly(), 1)
        end
    end, Id)
end

local function MC_POST_PEFFECT_UPDATE(_, p)
    local data = DukeHelpers.GetDukeData(p)

    if data and data[Tag] then
        if p:IsExtraAnimationFinished() then
            data[Tag] = nil
            for i = 1, 3 do
                DukeHelpers.AddHeartFly(p, DukeHelpers.GetWeightedFly(), 1)
            end
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
    unlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.THE_LAMB, Tag, DukeHelpers.DUKE_NAME)
}
