DukeHelpers.RegisterUnlock(DukeHelpers.GetUnlock(DukeHelpers.Unlocks.MEGA_SATAN, "flyHearts", DukeHelpers.HUSK_ID))

local function SetFlyHeart(pickup)
    local pickupData = pickup:GetData()
    pickupData.isFlyHeart = true

    local fly = DukeHelpers.GetFlyByPickupSubType(pickup.SubType == 0 and pickup.Variant or pickup.SubType)

    local spritesheet

    if fly and fly.spritesheet then
        spritesheet = fly.spritesheet
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
    if pickup.FrameCount <= 1 then
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
    if pickupData.isFlyHeart then
        pickupData.flyHeartSpritesheet:Update()
    end
end

-- Choose which hearts to be fly hearts and restore them if they already existed
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, flyHeartPickupUpdate, PickupVariant.PICKUP_HEART)
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, flyHeartPickupUpdate, 901)
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, flyHeartPickupUpdate, 2000)
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, flyHeartPickupUpdate, 2002)

local function flyHeartPickupRender(_, pickup)
    local pickupData = pickup:GetData()
    if pickupData.isFlyHeart then
        if pickupData.flyHeartSpritesheet:IsFinished("FlyHeartAppear") then
            pickupData.flyHeartSpritesheet:Play("FlyHeart")
        end
        pickupData.flyHeartSpritesheet:Render(Isaac.WorldToScreen(pickup.Position) - Vector(1, 5), Vector.Zero,
            Vector.Zero)
    end
end

-- Replace with the fly heart spritesheet
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, flyHeartPickupRender, PickupVariant.PICKUP_HEART)
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, flyHeartPickupRender, 901)
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, flyHeartPickupRender, 2000)
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, flyHeartPickupRender, 2002)

local function flyHeartPickupCollide(_, pickup)
    pickup = pickup:ToPickup()
    if pickup:GetSprite():IsPlaying("Collect") and (not pickup:GetData().isCollected) and
        (pickup.Variant == PickupVariant.PICKUP_HEART or pickup.Variant == 901 or pickup.Variant == 2000 or
            pickup.Variant == 2002) then
        local player = DukeHelpers.GetClosestPlayer(pickup.Position)

        if player and pickup:GetData().isFlyHeart then
            DukeHelpers.AddHeartFly(player,
                DukeHelpers.GetFlyByPickupSubType(pickup.SubType == 0 and pickup.Variant or pickup.SubType))
            pickup:GetData().isCollected = true
        end
    end
end

-- Spawn flies on fly heart pickup
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, flyHeartPickupCollide)
