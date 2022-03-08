dukeMod = RegisterMod("Duke", 1)

function table.deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = table.deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

local defaultGlobal = {
	isInitialized = false,
	isGameStarted = false,
	floorDevilDealChance = nil
}

dukeMod.global = table.deepCopy(defaultGlobal)

DukeHelpers = {
	DUKE_ID = Isaac.GetPlayerTypeByName("Duke"),
	rng = RNG(),
	sfx = SFXManager(),
	PRICE_OFFSET = -50
}

-- Sets the RNG seed for the run
dukeMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
	local seeds = Game():GetSeeds()
	DukeHelpers.rng:SetSeed(seeds:GetStartSeed(), 35)
end)

-- Resets the floor devil deal randomness on new floor
dukeMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	dukeMod.global.floorDevilDealChance = nil
end)

-- Helpers
include("helpers/utils")
include("helpers/flies")
include("helpers/data")

-- Initialize player and flies
include("flies")
include("duke")

DukeHelpers.Items = {
	dukesGullet = include("items/dukesGullet"),
	othersGullet = include("items/othersGullet")
}

for _, item in pairs(DukeHelpers.Items) do
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

-- Save and continue callbacks

-- Loads familiar data on startup
dukeMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function(_, isContinued)
    if dukeMod:HasData() then
        local data = DukeHelpers.LoadData()

        if isContinued then
            DukeHelpers.ForEachEntityInRoom(function(familiar)
                local savedFamiliarData = data.familiars[tostring(familiar.InitSeed)]
                if savedFamiliarData then
                    local familiarData = familiar:GetData()
                    for key, value in pairs(DukeHelpers.RehydrateEntityData(savedFamiliarData)) do
                        familiarData[key] = value
                    end
                end

				if familiar.Variant == DukeHelpers.FLY_VARIANT then
					DukeHelpers.PositionHeartFly(familiar, familiar:GetData().layer)
				end

                if DukeHelpers.IsAttackFly(familiar) then
                    DukeHelpers.InitializeAttackFly(familiar)
                end
            end, EntityType.ENTITY_FAMILIAR)
        end
    end

    dukeMod.global.isGameStarted = true
end)

-- Loads DUke data on startup
dukeMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    if not dukeMod.global.isInitialized then
        local seeds = Game():GetSeeds()
        DukeHelpers.rng:SetSeed(seeds:GetStartSeed(), 35)

        if dukeMod:HasData() then
            local data = DukeHelpers.LoadData()
            local initSeed = seeds:GetPlayerInitSeed()
            local isContinued = data.seed == initSeed
            if not isContinued then
                DukeHelpers.SaveData({
                    players = {},
                    familiars = {},
                    global = table.deepCopy(defaultGlobal),
                    mcmOptions = data.mcmOptions or {},
                    unlocks = data.unlocks or {}
                })
                dukeMod.global = table.deepCopy(defaultGlobal)
                dukeMod.unlocks = data.unlocks or {}
            else
                DukeHelpers.ForEachPlayer(function(p, pData)
                    local savedPlayerData = data.players[tostring(p.InitSeed)]
                    if savedPlayerData then
						if DukeHelpers.IsDuke(p) then
                            DukeHelpers.InitializeDuke(p, true)
							pData = DukeHelpers.InitializeDukeData(p)
						end
                        for key, value in pairs(DukeHelpers.RehydrateEntityData(savedPlayerData)) do
                            pData[key] = value
                        end
                    end
                end)

                if data.global then
                    for key, value in pairs(DukeHelpers.RehydrateEntityData(data.global)) do
                        dukeMod.global[key] = value
                    end
                end
            end

            dukeMod.mcmOptions = data.mcmOptions or {}
            dukeMod.unlocks = data.unlocks or {}
        else
            dukeMod.f = table.deepCopy(defaultGlobal)
            dukeMod.unlocks = {}
            dukeMod.mcmOptions = {}
		end
        --InitializeMCM(defaultMcmOptions)
        dukeMod.global.isInitialized = true
    end

end)

-- Saves game on exit
dukeMod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, function(_, shouldSave)
    if shouldSave then
        DukeHelpers.SaveGame()
    end
    dukeMod.global = table.deepCopy(defaultGlobal)
end)