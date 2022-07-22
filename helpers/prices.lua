function DukeHelpers.IsCustomPrice(x)
    return x <= PickupPrice.PRICE_ONE_HEART + DukeHelpers.PRICE_OFFSET and
        x >= PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS + DukeHelpers.PRICE_OFFSET
end

function DukeHelpers.GetCustomDevilDealPrice(collectible, player)
    if player and DukeHelpers.IsDuke(player) and player:HasTrinket(DukeHelpers.Trinkets.pocketOfFlies.Id) then
        return 4
    end
    return Isaac.GetItemConfig():GetCollectible(collectible.SubType).DevilPrice * 4
end

function DukeHelpers.RenderCustomDevilDealPrice(pickup, key, animationPath)
    local pos = Isaac.WorldToScreen(pickup.Position)

    if pickup:GetData()[key] then
        local devilPrice = DukeHelpers.GetCustomDevilDealPrice(pickup, DukeHelpers.GetClosestPlayer(pickup.Position))

        local priceSprite = Sprite()
        priceSprite:Load(animationPath)
        priceSprite:Play(tostring(devilPrice))
        priceSprite:Render(Vector(pos.X, pos.Y + 10), Vector.Zero, Vector.Zero)
    end
end
