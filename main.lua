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

defaultMcmOptions = {}

dukeMod.global = table.deepCopy(defaultGlobal)

DukeHelpers = {
    DUKE_NAME = "Duke",
    HUSK_NAME = "DukeB",
    rng = RNG(),
    sfx = SFXManager(),
    PRICE_OFFSET = -50,
    MAX_HEALTH = 6,
    SUBTYPE_OFFSET = 903
}

DukeHelpers.DUKE_ID = Isaac.GetPlayerTypeByName(DukeHelpers.DUKE_NAME)
DukeHelpers.HUSK_ID = Isaac.GetPlayerTypeByName(DukeHelpers.HUSK_NAME, true)

-- Sets the RNG seed for the run
dukeMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    local seeds = Game():GetSeeds()
    DukeHelpers.rng:SetSeed(seeds:GetStartSeed(), 35)
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local data = DukeHelpers.GetDukeData(player)

    if not data.health then
        data.previousHealth = nil
        data.health = {}
    else
        data.previousHealth = table.deepCopy(data.health)
    end

    for _, heart in pairs(DukeHelpers.GetBaseHearts()) do
        data.health[heart.key] = heart.GetCount(player)
    end
end)

-- Helpers
include("helpers/utils")
include("helpers/data")
include("helpers/docs")
include("helpers/duke")
include("helpers/entities")
include("helpers/flies")
include("helpers/giantbook")
include("helpers/hearts")
include("helpers/husk")
include("helpers/modConfigMenu")
include("helpers/partitions")
include("helpers/players")
include("helpers/prices")
include("helpers/spiders")
include("helpers/unlocks")
include("helpers/wisps")

if dukeMod:HasData() then
    local data = DukeHelpers.LoadData()
    if data.unlocks then
        dukeMod.unlocks = data.unlocks
    end
end


-- Initialize player and flies
include("hearts")
include("flies")
include("duke")
include("wisps")
include("husk")
include("flyHearts")

-- Callbacks to handle pound of flesh not working with custom prices
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    local hasPoundOfFlesh = DukeHelpers.AnyPlayerHasItem(CollectibleType.COLLECTIBLE_POUND_OF_FLESH)

    if hasPoundOfFlesh ~= dukeMod.global.hasPoundOfFlesh then
        if pickup:GetData().showFliesPrice or pickup:GetData().showSlotsPrice then
            pickup.AutoUpdatePrice = true
        end
    end
end)

dukeMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    dukeMod.global.hasPoundOfFlesh = DukeHelpers.AnyPlayerHasItem(CollectibleType.COLLECTIBLE_POUND_OF_FLESH)
end)

dukeMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, _, _, player)
    local data = DukeHelpers.GetDukeData(player)
    if DukeHelpers.IsDuke(player) or DukeHelpers.IsHusk(player) then
        DukeHelpers.Hearts.SOUL.Add(player,
            DukeHelpers.Clamp(data.health.SOUL - DukeHelpers.Hearts.SOUL.GetCount(player), 0))
    end
end, CollectibleType.COLLECTIBLE_MAGIC_SKIN)

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

local function registerEncyclopediaDescription(object, getFunction, registerFunction, updateFunction, extraOptions)
    if Encyclopedia and object and object.WikiDescription then
        local options = {
            Class = "duke",
            ID = object.Id,
            WikiDesc = object.WikiDescription,
            ModName = "Duke",
            Hide = object.IsWikiHidden
        }

        if extraOptions then
            for key, value in pairs(extraOptions) do
                options[key] = value
            end
        end

        if getFunction(options.ID) then
            updateFunction(options.ID, options)
        else
            registerFunction(options)
        end
    end
end

local unlocks = {}

local function addUnlock(item)
    if item.unlock then
        table.insert(unlocks, item.unlock)

        item.IsUnlocked = function()
            return DukeHelpers.IsUnlocked(item.unlock)
        end
    else
        item.IsUnlocked = function()
            return true
        end
    end
end

for _, item in pairs(DukeHelpers.Items) do
    registerCallbacks(item.callbacks)

    DukeHelpers.AddExternalItemDescriptionItem(item)

    if Encyclopedia then
        registerEncyclopediaDescription(item, Encyclopedia.GetItem, Encyclopedia.AddItem, Encyclopedia.UpdateItem)
    end

    addUnlock(item)

    if item.unlock then
        dukeMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
            if player:HasCollectible(item.Id) and not item.IsUnlocked() then
                player:RemoveCollectible(item.Id)
            end
        end)
    end

    -- if AnimatedItemsAPI then
    -- 	AnimatedItemsAPI:SetAnimationForCollectible(item.Id, "items/collectibles/animated/".. item.Tag .. "Animated.anm2")
    -- end
end

for _, trinket in pairs(DukeHelpers.Trinkets) do
    registerCallbacks(trinket.callbacks)

    DukeHelpers.AddExternalItemDescriptionTrinket(trinket)

    if Encyclopedia then
        registerEncyclopediaDescription(trinket, Encyclopedia.GetTrinket, Encyclopedia.AddTrinket,
            Encyclopedia.UpdateTrinket)
    end

    addUnlock(trinket)

    if trinket.unlock then
        dukeMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
            if player:HasTrinket(trinket.Id) and not trinket.IsUnlocked() then
                player:TryRemoveTrinket(trinket.Id)
            end
        end)
    end
end

for _, card in pairs(DukeHelpers.Filter(DukeHelpers.Cards, function(pi) return not pi.IsRune end)) do
    registerCallbacks(card.callbacks)

    DukeHelpers.AddExternalItemDescriptionCard(card)

    if Encyclopedia then
        registerEncyclopediaDescription(card,
            Encyclopedia.GetCard,
            Encyclopedia.AddCard,
            Encyclopedia.UpdateCard,
            { Spr = Encyclopedia.RegisterSprite(dukeMod.path .. "content/gfx/ui_cardfronts.anm2", card.Name) })
    end

    addUnlock(card)

    if card.unlock then
        dukeMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
            for i = 0, 3 do
                if player:GetCard(i) == card.Id and not card.IsUnlocked() then
                    player:SetCard(i, 0)
                end
            end
        end)
    end
end

for _, rune in pairs(DukeHelpers.Filter(DukeHelpers.Cards, function(pi) return pi.IsRune end)) do
    registerCallbacks(rune.callbacks)

    DukeHelpers.AddExternalItemDescriptionCard(rune)

    if Encyclopedia then
        registerEncyclopediaDescription(rune,
            Encyclopedia.GetRune,
            Encyclopedia.AddRune,
            Encyclopedia.UpdateRune,
            { Spr = Encyclopedia.RegisterSprite(dukeMod.path .. "content/gfx/ui_cardfronts.anm2", rune.Name) })
    end

    addUnlock(rune)

    if rune.unlock then
        dukeMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
            for i = 0, 3 do
                if player:GetCard(i) == rune.Id and not rune.IsUnlocked() then
                    player:SetCard(i, 0)
                end
            end
        end)
    end
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

-- Loads Duke data on startup
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
        DukeHelpers.InitializeMCM(defaultMcmOptions)
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

dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
    local game = Game()
    local room = game:GetRoom()
    local roomType = room:GetType()

    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
        local item = DukeHelpers.FindByProperties(DukeHelpers.Items, { Id = pickup.SubType })

        if not item then
            return
        end

        if not item.IsUnlocked() then
            local seed = game:GetSeeds():GetStartSeed()
            local pool = game:GetItemPool():GetPoolForRoom(roomType, seed)

            if pool == ItemPoolType.POOL_NULL then
                pool = ItemPoolType.POOL_TREASURE
            end

            local newItem = game:GetItemPool():GetCollectible(pool, true, pickup.InitSeed)
            game:GetItemPool():RemoveCollectible(pickup.SubType)
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, newItem, true, false, true)
        end
    elseif pickup.Variant == PickupVariant.PICKUP_TRINKET then
        local trinketId = pickup.SubType
        local isGolden = false

        if trinketId > TrinketType.TRINKET_GOLDEN_FLAG then
            trinketId = trinketId - TrinketType.TRINKET_GOLDEN_FLAG
            isGolden = true
        end

        local trinket = DukeHelpers.FindByProperties(DukeHelpers.Trinkets, { Id = trinketId })

        if not trinket then
            return
        end

        if not trinket.IsUnlocked() then
            local newTrinket = game:GetItemPool():GetTrinket(false)

            if isGolden then
                newTrinket = newTrinket + TrinketType.TRINKET_GOLDEN_FLAG
            end

            game:GetItemPool():RemoveTrinket(trinketId)
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, newTrinket, true, false, true)
        end
    elseif pickup.Variant == PickupVariant.PICKUP_TAROTCARD then
        local card = DukeHelpers.FindByProperties(DukeHelpers.Cards, { Id = pickup.SubType })

        if not card then
            return
        end

        if not card.IsUnlocked() then
            local pool = game:GetItemPool()
            local rune = pool:GetCard(pickup.InitSeed, not card.IsRune, card.IsRune, card.IsRune)

            if pickup.SubType == Card.THE_UNKNOWN then
                rune = 0
            end
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, rune, true, false, true)
        end
    end
end)

-- TRAILER EFFECTS --
-- dukeMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, e)
--     if e.Variant == 0 then
--         Isaac.Spawn(EntityType.ENTITY_EFFECT, Isaac.GetEntityVariantByName("Duke Reform"), 0, e.Position, Vector.Zero, e)
--     else
--         Isaac.Spawn(EntityType.ENTITY_EFFECT, Isaac.GetEntityVariantByName("Husk Reform"), 0, e.Position, Vector.Zero, e)
--     end
-- end, EntityType.ENTITY_DUKE)

-- dukeMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
--     local playingSoundEffects = {}
--     for soundEffectName, soundEffect in pairs(SoundEffect) do
--         if DukeHelpers.sfx:IsPlaying(soundEffect) then
--             table.insert(playingSoundEffects, soundEffectName..": "..soundEffect)
--         end
--     end
--     if #playingSoundEffects > 0 then
--         print("=====Sounds playing on frame "..Isaac.GetFrameCount().."=====")
--         for _, sfx in pairs(playingSoundEffects) do
--             print(sfx)
--         end
--         print("=====End of sounds playing on frame "..Isaac.GetFrameCount().."=====")
--     end
-- end)
