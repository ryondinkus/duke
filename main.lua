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
    flyHearts = {}
}

dukeMod.global = table.deepCopy(defaultGlobal)

DukeHelpers = {
    DUKE_NAME = "Duke",
    HUSK_NAME = "DukeB",
    rng = RNG(),
    sfx = SFXManager(),
    PRICE_OFFSET = -50,
    MAX_HEALTH = 4,
    HeartKeys = {}
}

DukeHelpers.DUKE_ID = Isaac.GetPlayerTypeByName(DukeHelpers.DUKE_NAME)
DukeHelpers.HUSK_ID = Isaac.GetPlayerTypeByName(DukeHelpers.HUSK_NAME, true)

-- Sets the RNG seed for the run
dukeMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    local seeds = Game():GetSeeds()
    DukeHelpers.rng:SetSeed(seeds:GetStartSeed(), 35)
end)

-- Debug Commands

local debugHudSprite = Sprite()
debugHudSprite:Load("gfx/ui/debugHud.anm2", true)
debugHudSprite.Scale = Vector(800, 800)
local debugHud = false

dukeMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, args)
    if cmd == "debugHud" then
        debugHud = not debugHud
    end
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if debugHud then
        debugHudSprite:Play("Debug")
        debugHudSprite:Render(Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() / 2))
    end
end)

-- dukeMod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, cmd, args)
--     --Isaac.GetPlayer(0):AddBlackHearts(2)
--     --addWebHearts(2, Isaac.GetPlayer(0))
--     ComplianceImmortal.AddImmortalHearts(Isaac.GetPlayer(0), 2)
-- end)

-- Helpers
include("helpers/docs")
include("helpers/giantbook")
include("helpers/partitions")
include("helpers/utils")
include("helpers/flies")
include("helpers/spiders")
include("helpers/data")
include("helpers/husk")
include("helpers/unlocks")

-- Initialize player and flies
include("flies")
include("duke")
include("wisps")
include("husk")
include("flyHearts")

include("flies/registry")
include("spiders/registry")

include("cards/registry")
include("items/registry")
include("trinkets/registry")
include("entityVariants/registry")
include("entitySubTypes/registry")

local function registerCallbacks(callbacks)
    if callbacks then
        for _, callback in pairs(callbacks) do
            dukeMod:AddCallback(table.unpack(callback))
        end
    end
end

local function registerEncyclopediaDescription(object, registerFunction, extraOptions)
    if Encyclopedia and object and object.WikiDescription then
        local options = {
            Class = "Duke",
            ID = object.Id,
            WikiDesc = object.WikiDescription,
            ModName = "Duke",
            Hide = object.isWikiHidden
        }

        if extraOptions then
            for key, value in pairs(extraOptions) do
                options[key] = value
            end
        end

        registerFunction(options)
    end
end

local unlocks = {}

local function addUnlock(item)
    if item.unlock then
        table.insert(unlocks, item.unlock)
    end
end

for _, item in pairs(DukeHelpers.Items) do
    registerCallbacks(item.callbacks)

    DukeHelpers.AddExternalItemDescriptionItem(item)

    if Encyclopedia then
        registerEncyclopediaDescription(item, Encyclopedia.AddItem)
    end

    addUnlock(item)

    -- if AnimatedItemsAPI then
    -- 	AnimatedItemsAPI:SetAnimationForCollectible(item.Id, "items/collectibles/animated/".. item.Tag .. "Animated.anm2")
    -- end
end

for _, trinket in pairs(DukeHelpers.Trinkets) do
    registerCallbacks(trinket.callbacks)

    DukeHelpers.AddExternalItemDescriptionTrinket(trinket)

    if Encyclopedia then
        registerEncyclopediaDescription(trinket, Encyclopedia.AddTrinket)
    end

    addUnlock(trinket)
end

for _, card in pairs(DukeHelpers.Cards) do
    registerCallbacks(card.callbacks)

    DukeHelpers.AddExternalItemDescriptionCard(card)

    if Encyclopedia then
        registerEncyclopediaDescription(card, Encyclopedia.AddTrinket,
            { Spr = Encyclopedia.RegisterSprite(dukeMod.path .. "content/gfx/ui_cardfronts.anm2", card.Name) })
    end

    addUnlock(card)
end

for _, entityVariant in pairs(DukeHelpers.EntityVariants) do
    registerCallbacks(entityVariant.callbacks)
end

for _, entitySubType in pairs(DukeHelpers.EntitySubTypes) do
    registerCallbacks(entitySubType.callbacks)
end

table.sort(unlocks, function(x, y)
    if x.onceUnlocked and x.alsoUnlock then
        return false
    end

    if y.onceUnlocked and y.alsoUnlock then
        return true
    end

    if x.onceUnlocked then
        return y.onceUnlocked and not y.alsoUnlock
    end

    if y.onceUnlocked then
        return true
    end
end)

for _, unlock in ipairs(unlocks) do
    DukeHelpers.RegisterUnlock(unlock)
end

include("sounds/registry")
include("costumes/registry")
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
                    local familiarData = DukeHelpers.GetDukeData(familiar)
                    for key, value in pairs(DukeHelpers.RehydrateEntityData(savedFamiliarData)) do
                        familiarData[key] = value
                    end
                end

                if familiar.Variant == DukeHelpers.FLY_VARIANT then
                    DukeHelpers.PositionHeartFly(familiar, DukeHelpers.GetDukeData(familiar).layer)
                end

                if DukeHelpers.IsAttackFly(familiar) then
                    DukeHelpers.InitializeAttackFly(familiar)
                end

                if DukeHelpers.IsHeartSpider(familiar) then
                    DukeHelpers.InitializeHeartSpider(familiar)
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
                        end
                        pData = DukeHelpers.GetDukeData(p)
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

if Poglite then
    Poglite:AddPogCostume("DukePog", DukeHelpers.DUKE_ID,
        Isaac.GetCostumeIdByPath("gfx/characters/costume_duke_pog.anm2"))
    Poglite:AddPogCostume("DukeBPog", DukeHelpers.HUSK_ID,
        Isaac.GetCostumeIdByPath("gfx/characters/costume_duke_b_pog.anm2"))
end
