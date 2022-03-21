local Names = {
    en_us = "The Princes",
    spa = "I don't know spanish and I'm on a plane lmao"
}
local Name = Names.en_us
local Tag = "the Princes"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Like a princess, but a man.",
    spa = "I don't know spanish and I'm on a plane lmao"
}
local WikiDescription = "Like a princess, but a man."--helper.GenerateEncyclopediaPage("Poops and shits everywhere.")

local function MC_POST_NEW_LEVEL()
    DukeHelpers.ForEachPlayer(function(duke)
        for i = 1, 3 do
            DukeHelpers.AddHeartFly(duke, DukeHelpers.GetWeightedFly(), 1)
        end
    end, Id)
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
        }
    }
}
