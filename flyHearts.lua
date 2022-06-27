local function SetFlyHeart(pickup)
    local pickupData = pickup:GetData()
    pickupData.isFlyHeart = true

    local fly = DukeHelpers.GetFlyByPickupSubType(pickup.SubType)

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

-- Choose which hearts to be fly hearts and restore them if they already existed
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    if pickup.FrameCount <= 1 then
        if pickup:GetSprite():GetAnimation() == "Appear" then
            if DukeHelpers.PercentageChance(100) then
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
end, PickupVariant.PICKUP_HEART)

-- TODO add update and render callbacks for modded hearts

-- Replace with the fly heart spritesheet
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, pickup)
    local pickupData = pickup:GetData()
    if pickupData.isFlyHeart then
        if pickupData.flyHeartSpritesheet:IsFinished("FlyHeartAppear") then
            pickupData.flyHeartSpritesheet:Play("FlyHeart")
        end
        pickupData.flyHeartSpritesheet:Render(Isaac.WorldToRenderPosition(pickup.Position) - Vector(1, 5), Vector.Zero,
            Vector.Zero)
    end
end, PickupVariant.PICKUP_HEART)

-- Spawn flies on fly heart pickup
dukeMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
    local player

    if collider then
        player = collider:ToPlayer()
    end

    if player and pickup:GetData().isFlyHeart then
        if DukeHelpers.CanPickUpHeart(player, pickup) then
            DukeHelpers.AddHeartFly(player, DukeHelpers.GetFlyByPickupSubType(pickup.SubType))
        end
    end
end, PickupVariant.PICKUP_HEART)
