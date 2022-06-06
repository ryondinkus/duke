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

local xOffset = 5
local yOffset = 16
local shownHearts = 4

local function MC_USE_ITEM(_, type, rng, p)
    DukeHelpers.sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 1, 0)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, p.Position, Vector.Zero, nil)
    effect.Color = Color(0, 0, 0, 1)

    local numberOfTears = 8

    if p:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
        numberOfTears = 12
    end

    local releasedSlots = DukeHelpers.ReleaseRottenGulletSlots(p, 1)
    local pickupSubType = releasedSlots[1]
    local foundSpider = DukeHelpers.GetSpiderByPickupSubType(pickupSubType)

    for i = 0, numberOfTears - 12 do
        local tear = p:FireProjectile(Vector.FromAngle(i * (360 / numberOfTears)))

        local function tearCollision(_, t)
            if tear.InitSeed == t.InitSeed then
                if DukeHelpers.PercentageChance(50, 100, rng) then
                    DukeHelpers.SpawnSpidersFromPickupSubType(pickupSubType, t.Position, t, 1)
                end
                dukeMod:RemoveCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, tearCollision, tear.Variant)
            end
        end

        dukeMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, tearCollision, tear.Variant)

        if foundSpider then
            if foundSpider.tearDamageMultiplier then
                tear.CollisionDamage = tear.CollisionDamage * foundSpider.tearDamageMultiplier
                tear.Size = tear.Size * foundSpider.tearDamageMultiplier
                tear.Scale = tear.Scale * foundSpider.tearDamageMultiplier
            end

            if foundSpider.applyTearEffects then
                foundSpider.applyTearEffects(tear)
            end
        end
    end


    return true
end

local playerHUDPositions = {
    [0] = {
        [0] = Vector(-23, -37),
        [1] = Vector(-24.5, -37.5),
        [2] = Vector(-26, -38),
        [3] = Vector(-28.5, -39),
        [4] = Vector(-30, -40),
        [5] = Vector(-32, -40.5),
        [6] = Vector(-33.5, -41.5)
    }
}

local function MC_POST_RENDER()
    DukeHelpers.ForEachPlayer(function(player)
        if DukeHelpers.IsHusk(player) and player:GetActiveItem(ActiveSlot.SLOT_POCKET) == Id then
            local controllerIndex = DukeHelpers.GetPlayerControllerIndex(player)
            local hudOffset = math.floor((Options.HUDOffset * 10) + 0.5)
            local isXFlipped = controllerIndex ~= 0

            local numberOfFilledSlots = DukeHelpers.LengthOfTable(DukeHelpers.GetFilledRottenGulletSlots(player))
            local hudPosition = playerHUDPositions[controllerIndex][hudOffset]

            local x = Isaac.GetScreenWidth() + hudPosition.X
            local y = Isaac.GetScreenHeight() + hudPosition.Y

            local scale = 1
            font:DrawStringScaled("x" .. numberOfFilledSlots, x, y, scale, scale, KColor(1, 1, 1, 1), 1, false)

            local amountToRender = math.min(numberOfFilledSlots, shownHearts)

            local startingY = y + (yOffset / 2)

            for i = 1, amountToRender do
                local sprite = Sprite()
                sprite:Load("gfx/ui/ui_hearts.anm2", true)
                sprite:Play("RedHeartHalf")
                sprite.Color = Color(sprite.Color.R, sprite.Color.G, sprite.Color.B, 1 - (i * (1 / shownHearts) - (1 / shownHearts)))

                local extraXOffset = -xOffset

                if isXFlipped then
                    extraXOffset = extraXOffset * 2.5
                end
                sprite:Render(Vector(x + extraXOffset - (yOffset * i), startingY), Vector.Zero, Vector.Zero)
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
    }
}
