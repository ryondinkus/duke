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
    PRICE_OFFSET = -50,
    MAX_HEALTH = 4
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
include("helpers/docs")
include("helpers/giantbook")
include("helpers/partitions")
include("helpers/utils")
include("helpers/flies")
include("helpers/data")

-- Initialize player and flies
include("flies")
include("duke")
include("wisps")

include("items/registry")

for _, item in pairs(DukeHelpers.Items) do
    if item.callbacks then
        for _, callback in pairs(item.callbacks) do
            dukeMod:AddCallback(table.unpack(callback))
        end
    end

    DukeHelpers.AddExternalItemDescriptionItem(item)

    if Encyclopedia and item.WikiDescription then
        Encyclopedia.AddItem({
            Class = "Duke",
            ID = item.Id,
            WikiDesc = item.WikiDescription,
            ModName = "Duke",
            Hide = item.Hide
        })
    end

    -- if AnimatedItemsAPI then
    -- 	AnimatedItemsAPI:SetAnimationForCollectible(item.Id, "items/collectibles/animated/".. item.Tag .. "Animated.anm2")
    -- end
end

include("trinkets/registry")

for _, trinket in pairs(DukeHelpers.Trinkets) do
    if trinket.callbacks then
        for _, callback in pairs(trinket.callbacks) do
            dukeMod:AddCallback(table.unpack(callback))
        end
    end

    DukeHelpers.AddExternalItemDescriptionTrinket(trinket)

    if Encyclopedia and trinket.WikiDescription then
        Encyclopedia.AddTrinket({
            Class = "Duke",
            ID = trinket.Id,
            WikiDesc = trinket.WikiDescription,
            ModName = "Duke",
            Hide = trinket.Hide
        })
    end
end

include("cards/registry")

for _, card in pairs(DukeHelpers.Cards) do
    if card.callbacks then
        for _, callback in pairs(card.callbacks) do
            dukeMod:AddCallback(table.unpack(callback))
        end
    end

    DukeHelpers.AddExternalItemDescriptionCard(card)

    if Encyclopedia and card.WikiDescription then
        Encyclopedia.AddCard({
            Class = "Duke",
            ID = card.Id,
            WikiDesc = card.WikiDescription,
            ModName = "Duke",
            Spr = Encyclopedia.RegisterSprite(dukeMod.path .. "content/gfx/ui_cardfronts.anm2", card.Name),
            Hide = card.Hide
        })
    end
end

include("entityVariants/registry")

for _, entityVariant in pairs(DukeHelpers.EntityVariants) do
    if entityVariant.callbacks then
        for _, callback in pairs(entityVariant.callbacks) do
            dukeMod:AddCallback(table.unpack(callback))
        end
    end
end

include("sounds/registry")

include("wisps/registry")

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
                            pData = DukeHelpers.GetDukeData(p)
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

local unlocks = include("unlocks/registry")

local function saveUnlock(tag)
    DukeGiantBookAPI.ShowAchievement("achievement_" .. tag .. ".png")
    dukeMod.unlocks[tag] = true
    DukeHelpers.SaveGame()
end

local function handleUnlock(unlock, entity)
    if DukeHelpers.HasDuke()
        and Game():GetLevel():GetStage() == unlock.stage
        and Game():GetRoom():GetType() == unlock.roomType
        and (not unlock.stageTypes or DukeHelpers.Find(unlock.stageTypes, function(t) return t == Game():GetLevel():GetStageType() end))
        and (not unlock.roomShape or Game():GetRoom():GetRoomShape() == unlock.roomShape)
        and (not unlock.difficulty or Game().Difficulty == unlock.difficulty)
        and (not entity or not unlock.entityVariant or entity.Variant == unlock.entityVariant)
        and (not entity or not unlock.entitySubType or entity.SubType == unlock.entitySubType)
        and not DukeHelpers.Find(dukeMod.unlocks, function(_, t) return t == unlock.tag end) then
        if unlock.alsoUnlock and not DukeHelpers.Find(dukeMod.unlocks, function(_, t) return t == unlock.alsoUnlock end) then
            local alsoUnlock = DukeHelpers.Find(unlocks, function(u) return u.tag == unlock.alsoUnlock end)

            if alsoUnlock then
                saveUnlock(alsoUnlock.tag)
            end
        end

        saveUnlock(unlock.tag)

        local completeUnlocks = {}

        for _, u in pairs(unlocks) do
            if u.onceUnlocked then
                table.insert(completeUnlocks, u)
            end
        end

        for _, cu in pairs(completeUnlocks) do
            if not DukeHelpers.Find(dukeMod.unlocks, function(_, t) return t == cu.tag end) then
                local shouldUnlock = true
                for _, u in pairs(cu.onceUnlocked) do
                    if not DukeHelpers.Find(dukeMod.unlocks, function(_, k) return k == u end) then
                        shouldUnlock = false
                        break
                    end
                end

                if shouldUnlock then
                    saveUnlock(cu.tag)
                end
            end
        end
    end
end

for _, unlock in pairs(unlocks) do
    if unlock.onClear then
        dukeMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function() handleUnlock(unlock) end, unlock.entityType)
    else
        dukeMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, entity) handleUnlock(unlock, entity) end, unlock.entityType)
    end
end

if Poglite then
    Poglite:AddPogCostume("DukePog", DukeHelpers.DUKE_ID, Isaac.GetCostumeIdByPath("gfx/characters/costume_duke_pog.anm2"))
end
