dukeMod = RegisterMod("Duke", 1)

DukeHelpers = {
	DUKE_ID = Isaac.GetPlayerTypeByName("Duke"),
	rng = RNG(),
	sfx = SFXManager()
}

-- Sets the RNG seed for the run
dukeMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	local seeds = Game():GetSeeds()
	DukeHelpers.rng:SetSeed(seeds:GetStartSeed(), 35)
end)

-- Helpers
include("helpers/utils")
include("helpers/flies")

-- Initialize player and flies
include("flies")
include("duke")

local items = {
	include("items/dukesGullet")
}

for _, item in pairs(items) do
    if item.callbacks then
        for _, callback in pairs(item.callbacks) do
            dukeMod:AddCallback(table.unpack(callback))
        end
    end

	-- helper.AddExternalItemDescriptionItem(item)

	-- if Encyclopedia and item.WikiDescription then
	-- 	Encyclopedia.AddItem({
	-- 		Class = "Loot Deck",
	-- 		ID = item.Id,
	-- 		WikiDesc = item.WikiDescription,
	-- 		ModName = "Loot Deck"
	-- 	})
	-- end

	-- if AnimatedItemsAPI then
	-- 	AnimatedItemsAPI:SetAnimationForCollectible(item.Id, "items/collectibles/animated/".. item.Tag .. "Animated.anm2")
	-- end
end