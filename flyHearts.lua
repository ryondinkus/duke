local flyHeartsUnlock = DukeHelpers.GetUnlock(DukeHelpers.Unlocks.MEGA_SATAN, "flyHearts", DukeHelpers.HUSK_NAME)

DukeHelpers.RegisterUnlock(flyHeartsUnlock)

local function SetFlyHeart(pickup)
    local pickupData = pickup:GetData()
    pickupData.isFlyHeart = true

    local pickupKey = DukeHelpers.GetKeyFromPickup(pickup)

    if not pickupKey then
        return
    end

    local flyToSpawn = DukeHelpers.Flies[pickupKey]

    local spritesheet

    if flyToSpawn and flyToSpawn.spritesheet then
        spritesheet = flyToSpawn.spritesheet
    else
        spritesheet = DukeHelpers.Flies.RED.spritesheet
    end

    pickupData.flyHeartSpritesheet = Sprite()
    pickupData.flyHeartSpritesheet:Load("gfx/familiars/heart_fly.anm2", true)
    pickupData.flyHeartSpritesheet:ReplaceSpritesheet(0, spritesheet)
    pickupData.flyHeartSpritesheet:LoadGraphics()
    pickupData.flyHeartSpritesheet.Color = Color(pickupData.flyHeartSpritesheet.Color.R,
        pickupData.flyHeartSpritesheet.Color.G, pickupData.flyHeartSpritesheet.Color.B, 0.7)
    pickupData.flyHeartSpritesheet:Play("FlyHeartAppear")
end

local function StoreFlyHeart(pickup)
    SetFlyHeart(pickup)
    if not dukeMod.global.flyHearts then
        dukeMod.global.flyHearts = {}
    end

    table.insert(dukeMod.global.flyHearts, pickup.InitSeed)
end

-- Reset fly hearts list on new level
dukeMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
    dukeMod.global.flyHearts = {}
end)

local function flyHeartPickupUpdate(_, pickup)
    if pickup.FrameCount <= 1 and DukeHelpers.IsSupportedHeart(pickup) and DukeHelpers.IsUnlocked(flyHeartsUnlock) then
        if pickup:GetSprite():GetAnimation() == "Appear" then
            if DukeHelpers.PercentageChance(5) then
                StoreFlyHeart(pickup)
            end
        else
            for _, flyHeartHash in pairs(dukeMod.global.flyHearts) do
                if pickup.InitSeed == flyHeartHash then
                    SetFlyHeart(pickup)
                    break
                end
            end
        end
    end

    local pickupData = pickup:GetData()
    if pickupData.isFlyHeart and pickupData.flyHeartSpritesheet then
        pickupData.flyHeartSpritesheet:Update()
    end
end

-- Choose which hearts to be fly hearts and restore them if they already existed
DukeHelpers.ForEachHeartVariant(function(variant)
    dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, flyHeartPickupUpdate, variant)
end)

local function flyHeartPickupRender(_, pickup)
    local pickupData = pickup:GetData()
    if pickupData.isFlyHeart and pickupData.flyHeartSpritesheet then
        if pickupData.flyHeartSpritesheet:IsFinished("FlyHeartAppear") then
            pickupData.flyHeartSpritesheet:Play("FlyHeart")
        end
        pickupData.flyHeartSpritesheet:Render(Isaac.WorldToScreen(pickup.Position) - Vector(1, 5), Vector.Zero,
            Vector.Zero)
    end
end

-- Replace with the fly heart spritesheet
DukeHelpers.ForEachHeartVariant(function(variant)
    dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, flyHeartPickupRender, variant)
end)

function DukeHelpers.PickupFlyHeart(pickup)
    pickup = pickup:ToPickup()
    if not pickup:GetData().isCollected and DukeHelpers.IsSupportedHeart(pickup) then
        local player = DukeHelpers.GetClosestPlayer(pickup.Position)

        if player and pickup:GetData().isFlyHeart then
            local pickupKey = DukeHelpers.GetKeyFromPickup(pickup)

            if not pickupKey then
                return
            end

            DukeHelpers.AddHeartFly(player, DukeHelpers.Flies[pickupKey])
            pickup:GetData().isCollected = true
        end
    end
end

-- Spawn flies on fly heart pickup
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    pickup = pickup:ToPickup()
    if pickup:GetSprite():IsPlaying("Collect") then
        return DukeHelpers.PickupFlyHeart(pickup)
    end
end)
