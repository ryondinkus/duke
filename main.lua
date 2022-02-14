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