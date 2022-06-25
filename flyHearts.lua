local function SetFlyHeart(pickup)
    pickup:GetData().isFlyHeart = true
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
    if pickup.FrameCount <= 1 and pickup.SubType <= HeartSubType.HEART_ROTTEN then
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
end, PickupVariant.PICKUP_HEART)

-- Replace with the fly heart spritesheet
dukeMod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, pickup)
    if pickup:GetData().isFlyHeart then
        -- Replace spritesheet
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
