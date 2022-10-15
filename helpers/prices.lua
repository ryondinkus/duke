function DukeHelpers.IsCustomPrice(x)
    return (x <= PickupPrice.PRICE_ONE_HEART + DukeHelpers.PRICE_OFFSET and
        x >= PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS + DukeHelpers.PRICE_OFFSET)
        or (x <= -7 + DukeHelpers.PRICE_OFFSET and
            x >= -8 + DukeHelpers.PRICE_OFFSET) -- Custom Blue Baby Devil Deal Prices :D :D :D: D::D
end

function DukeHelpers.GetCustomDevilDealPrice(collectible, player)
    if player and DukeHelpers.IsDuke(player) and DukeHelpers.Trinkets.pocketOfFlies.helpers.HasPocketOfFlies(player) then
        return 4
    end
    return Isaac.GetItemConfig():GetCollectible(collectible.SubType).DevilPrice * 4
end

function DukeHelpers.RenderCustomDevilDealPrice(pickup, key, animationPath)
    local pos = Isaac.WorldToScreen(pickup.Position)

    if pickup:GetData()[key] then
        local devilPrice = DukeHelpers.GetCustomDevilDealPrice(pickup, DukeHelpers.GetClosestPlayer(pickup.Position))

        local priceSprite = Sprite()
        priceSprite:Load(animationPath, true)
        priceSprite:Play(tostring(devilPrice))
        priceSprite:Render(Vector(pos.X, pos.Y + 10), Vector.Zero, Vector.Zero)
    end
end

function DukeHelpers.IsReplaceablePrice(x)
    return (x <= PickupPrice.PRICE_ONE_HEART and x >= PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS)
        or (x <= -7 and x >= -8) -- Devil Baby Prices Blue Custom Deal :D :D :D: D::D
end
