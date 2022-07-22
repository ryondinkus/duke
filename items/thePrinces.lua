local Names = {
    en_us = "The Princes",
    spa = "I don't know spanish and I'm on a plane lmao"
}
local Name = Names.en_us
local Tag = "thePrinces"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Spawns 3 Heart Orbital Flies on pickup and on every new floor#Flies can be one of six random types: {{Heart}}Red, {{SoulHeart}}Soul, {{BlackHeart}}Black, {{GoldenHeart}}Gold, {{EmptyBoneHeart}}Bone, or {{RottenHeart}}Rotten",
    spa = "I don't know spanish and I'm on a plane lmao"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "On pickup, and at the start of every new floor, grants 3 random Heart Orbital Flies.",
        "- These flies can be of the following types: Red, Soul, Black, Gold, Bone, and Rotten. Red and Soul are twice as likely to spawn.",
    },
    {
        "Trivia",
        "The three ''princes'' are meant to be the three Red Heart Orbital Flies that Duke starts with.",
    }
})

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
