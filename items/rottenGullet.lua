local Names = {
    en_us = "Rotten Gullet",
    spa = "La Garganta del Duque"
}
local Name = Names.en_us
local Tag = "rottenGullet"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Poops and shits everywhere",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage("Poops and shits everywhere.")

local font = Font()
font:Load("font/pftempestasevencondensed.fnt")

local shownHearts = 6
local errorFrames = 15

local largeXTextOffset = 16
local largeXHeartSpacing = 7
local largeY = 16
local largeMaxSlotTextXOffset = 9
local largeMaxSlotTextYOffset = 8
local largeMaxSlotTextScale = 0.5

local smallXTextOffset = 7
local smallXHeartSpacing = 3.5
local smallY = 8
local smallMaxSlotTextXOffset = 10
local smallMaxSlotTextYOffset = 2
local smallMaxSlotTextScale = 1

local defaultAnimationPath = "gfx/ui/ui_hearts.anm2"
local defaultAnimationName = "RedHeartHalf"

local function fireRottenGulletShot(player, pickupSubType, rng)
    local numberOfTears = 8

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        numberOfTears = 12
    end

    local foundSpider = DukeHelpers.GetSpiderByPickupSubType(pickupSubType)

    DukeHelpers.sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0)
    DukeHelpers.sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE, 1, 0)
    DukeHelpers.SpawnPickupPoof(player, pickupSubType)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 4, player.Position, Vector.Zero, player)
    effect.Color = foundSpider.poofColor
    Game():ShakeScreen(10)

    local radius = 80
    local enemiesInRadius = DukeHelpers.FindInRadius(player.Position, radius)

    local radiusDamage = 40

    if foundSpider and foundSpider.damageMultiplier then
        radiusDamage = radiusDamage * foundSpider.damageMultiplier
    end

    for _, enemy in pairs(enemiesInRadius) do
        local directionVector = enemy.Position - player.Position
        local maxVector = Vector(radius / 2 * DukeHelpers.Sign(directionVector.X),
            radius / 2 * DukeHelpers.Sign(directionVector.Y))
        directionVector = (maxVector - directionVector)

        if DukeHelpers.Sign(directionVector.X) ~= DukeHelpers.Sign(maxVector.X) then
            directionVector = Vector(-directionVector.X, directionVector.Y)
        end

        if DukeHelpers.Sign(directionVector.Y) ~= DukeHelpers.Sign(maxVector.Y) then
            directionVector = Vector(directionVector.X, -directionVector.Y)
        end

        enemy.Velocity = directionVector
        enemy:TakeDamage(radiusDamage, 0, EntityRef(player), 0)
    end

    for i = 0, numberOfTears - 1 do
        local tear = player:FireTear(player.Position, Vector.FromAngle(i * (360 / numberOfTears)) * 10)

        if foundSpider then
            if foundSpider.tearDamageMultiplier then
                tear.CollisionDamage = tear.CollisionDamage * foundSpider.tearDamageMultiplier
                tear.Size = tear.Size * foundSpider.tearDamageMultiplier
                tear.Scale = tear.Scale * foundSpider.tearDamageMultiplier

                if foundSpider.tearColor then
                    tear.Color = foundSpider.tearColor
                end
            end

            if foundSpider.applyTearEffects then
                foundSpider.applyTearEffects(tear)
            end
        end

        local function tearCollision(_, t)
            if tear.InitSeed == t.InitSeed then
                if DukeHelpers.PercentageChance(50, 100, rng) then
                    DukeHelpers.SpawnSpidersFromPickupSubType(pickupSubType, t.Position, t, 1)
                    local player = t.SpawnerEntity:ToPlayer()
                    if player and player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                        DukeHelpers.SpawnSpiderWisp(DukeHelpers.Wisps[foundSpider.key], t.Position, player, false)
                    end
                end
                dukeMod:RemoveCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, tearCollision, EntityType.ENTITY_TEAR)
            end
        end

        dukeMod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, tearCollision, EntityType.ENTITY_TEAR)
    end
end

local function MC_USE_ITEM(_, type, rng, p, flags)
    local releasedSlots = DukeHelpers.ReleaseRottenGulletSlots(p, 1)

    if (flags & UseFlag.USE_NOANIM == 0) then
        p:PlayExtraAnimation("DukeBarf")
    end

    if DukeHelpers.LengthOfTable(releasedSlots) <= 0 then
        DukeHelpers.sfx:Play(SoundEffect.SOUND_WORM_SPIT, 1, 0)
        local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, p)
        effect.Color = Color(0, 0, 0, 1)

        DukeHelpers.GetDukeData(p)[Tag .. "Error"] = errorFrames
        return false
    end

    DukeHelpers.GetDukeData(p)[Tag .. "Error"] = nil

    fireRottenGulletShot(p, releasedSlots[1], rng)

    return false
end

local playerHUDPositions = {
    [0] = {
        [0] = Vector(-35, -37),
        [1] = Vector(-36.5, -37.5),
        [2] = Vector(-38, -38),
        [3] = Vector(-40, -39),
        [4] = Vector(-41.5, -39.5),
        [5] = Vector(-43, -40),
        [6] = Vector(-44.5, -40.5),
        [7] = Vector(-46, -41),
        [8] = Vector(-48, -42),
        [9] = Vector(-49.5, -42.5),
        [10] = Vector(-51, -43)
    },
    [1] = {
        [0] = Vector(-111, 47),
        [1] = Vector(-113.5, 48),
        [2] = Vector(-116, 50),
        [3] = Vector(-118, 51),
        [4] = Vector(-120.5, 52.5),
        [5] = Vector(-123, 53.5),
        [6] = Vector(-125.5, 54.5),
        [7] = Vector(-128, 56),
        [8] = Vector(-130, 57),
        [9] = Vector(-132.5, 58.5),
        [10] = Vector(-135, 59.5)
    },
    [2] = {
        [0] = Vector(65.5, -7),
        [1] = Vector(67.5, -7.5),
        [2] = Vector(70, -8),
        [3] = Vector(72, -9),
        [4] = Vector(74.5, -9.5),
        [5] = Vector(76.5, -10),
        [6] = Vector(78.5, -10.5),
        [7] = Vector(81, -11),
        [8] = Vector(83, -12),
        [9] = Vector(85.5, -12.5),
        [10] = Vector(87.5, -13)
    },
    [3] = {
        [0] = Vector(-111.5, -7),
        [1] = Vector(-113, -7.5),
        [2] = Vector(-114.5, -8),
        [3] = Vector(-116.5, -9),
        [4] = Vector(-118, -9.5),
        [5] = Vector(-119.5, -10),
        [6] = Vector(-121, -10.5),
        [7] = Vector(-122.5, -11),
        [8] = Vector(-124.5, -12),
        [9] = Vector(-126, -12.5),
        [10] = Vector(-127.5, -13)
    }
}

local function MC_POST_RENDER()
    DukeHelpers.ForEachPlayer(function(player)
        if DukeHelpers.IsHusk(player) and
            (player:GetActiveItem(ActiveSlot.SLOT_POCKET) == Id and player:GetCard(0) == 0 and player:GetPill(0) == 0) then
            local controllerIndex = DukeHelpers.GetPlayerControllerIndex(player)
            local hudOffset = math.floor((Options.HUDOffset * 10) + 0.5)

            local playerSlots = DukeHelpers.GetFilledRottenGulletSlots(player)
            local numberOfFilledSlots = DukeHelpers.LengthOfTable(playerSlots)
            local playerHudPositions = playerHUDPositions[controllerIndex]
            local hudPosition = type(playerHudPositions) == "table" and playerHudPositions[hudOffset] or
                playerHudPositions
            local screenShakeOffset = Game().ScreenShakeOffset

            local isSmall = controllerIndex ~= 0

            local x = hudPosition.X
            local y = hudPosition.Y

            if controllerIndex == 0 then
                x = x + Isaac.GetScreenWidth()
                y = y + Isaac.GetScreenHeight()
            elseif controllerIndex == 1 then
                x = x + Isaac.GetScreenWidth()
            elseif controllerIndex == 2 then
                y = y + Isaac.GetScreenHeight()
            elseif controllerIndex == 3 then
                x = x + Isaac.GetScreenWidth()
                y = y + Isaac.GetScreenHeight()
            end

            local scale = isSmall and 0.5 or 1

            local maxSlotTextXOffset = isSmall and smallMaxSlotTextXOffset or largeMaxSlotTextXOffset
            local maxSlotTextYOffset = isSmall and smallMaxSlotTextYOffset or largeMaxSlotTextYOffset
            local maxSlotTextScale = isSmall and smallMaxSlotTextScale or largeMaxSlotTextScale

            local currentCountColor = KColor(1, 1, 1, 1)

            local data = DukeHelpers.GetDukeData(player)

            local errorCount = data[Tag .. "Error"]
            if errorCount and errorCount > 1 then
                local smoothedBlueAndGreenValues = 1 - (errorCount / errorFrames)
                currentCountColor = KColor(1, smoothedBlueAndGreenValues, smoothedBlueAndGreenValues, 1)
                data[Tag .. "Error"] = errorCount - 1
            else
                data[Tag .. "Error"] = nil
            end

            font:DrawStringScaled("x" .. numberOfFilledSlots, x + screenShakeOffset.X, y + screenShakeOffset.Y, scale,
                scale, currentCountColor
                , 1, false)

            local percentBrokenSlots = (
                DukeHelpers.MAX_ROTTEN_GULLET_COUNT - DukeHelpers.GetMaxRottenGulletSlots(player)) /
                DukeHelpers.MAX_ROTTEN_GULLET_COUNT

            local blueAndGreenValues = 0.5 - (0.5 * percentBrokenSlots)

            font:DrawStringScaled("/" .. tostring(DukeHelpers.GetMaxRottenGulletSlots(player)),
                x + maxSlotTextXOffset + screenShakeOffset.X,
                y + maxSlotTextYOffset + screenShakeOffset.Y, scale * maxSlotTextScale, scale * maxSlotTextScale,
                KColor(0.5, blueAndGreenValues, blueAndGreenValues, 1), 1, false)

            local amountToRender = math.min(numberOfFilledSlots, shownHearts)

            local startingY = y + ((isSmall and smallY or largeY) / 2)

            for i = amountToRender, 1, -1 do
                local slotSpider = DukeHelpers.Find(DukeHelpers.Spiders, function(spider)
                    return spider.pickupSubType == playerSlots[i]
                end)
                local sprite = Sprite()
                local renderAboveSprite = Sprite()

                local animationPath = defaultAnimationPath
                local animationName = defaultAnimationName
                local overlayAnimationName = nil
                local renderAbove = nil
                local spriteOffset = Vector.Zero

                if slotSpider.uiHeart then
                    animationPath = slotSpider.uiHeart.animationPath or animationPath
                    animationName = slotSpider.uiHeart.animationName or animationName
                    overlayAnimationName = slotSpider.uiHeart.overlayAnimationName
                    renderAbove = slotSpider.uiHeart.renderAbove
                    spriteOffset = slotSpider.uiHeart.spriteOffset or spriteOffset
                end

                if renderAbove then
                    renderAboveSprite:Load(renderAbove.animationPath or defaultAnimationPath, true)
                    renderAboveSprite:Play(renderAbove.animationName or defaultAnimationName)
                end

                sprite:Load(animationPath, true)
                sprite:Play(animationName)

                if renderAbove and renderAbove.overlayAnimationName then
                    sprite:PlayOverlay(renderAbove.overlayAnimationName)
                end

                if overlayAnimationName then
                    sprite:PlayOverlay(overlayAnimationName)
                end

                sprite.Scale = Vector(scale, scale)
                renderAboveSprite.Scale = Vector(scale, scale)

                renderAboveSprite.Color = Color(renderAboveSprite.Color.R, renderAboveSprite.Color.G,
                    renderAboveSprite.Color.B, 1 - (i * (1 / shownHearts) - (1 / shownHearts)))
                sprite.Color = Color(sprite.Color.R, sprite.Color.G, sprite.Color.B,
                    1 - (i * (1 / shownHearts) - (1 / shownHearts)))

                local extraXOffset = -(isSmall and smallXTextOffset or largeXTextOffset)

                local position = Vector(x + extraXOffset - ((isSmall and smallXHeartSpacing or largeXHeartSpacing) * i),
                    startingY)

                if renderAbove then
                    renderAboveSprite:Render(position + (renderAbove.spriteOffset or Vector.Zero),
                        Vector.Zero,
                        Vector.Zero)
                end
                sprite:Render(position + spriteOffset, Vector.Zero, Vector.Zero)
            end
        end
    end)
end

return {
    Name = Name,
    Names = Names,
    Tag = Tag,
    Id = Id,
    Descriptions = Descriptions,
    WikiDescription = WikiDescription,
    callbacks = {
        {
            ModCallbacks.MC_USE_ITEM,
            MC_USE_ITEM,
            Id
        },
        {
            ModCallbacks.MC_POST_RENDER,
            MC_POST_RENDER
        }
    },
    helpers = {
        fireRottenGulletShot = fireRottenGulletShot
    }
}
