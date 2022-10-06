DukeHelpers.Spiders = {}

local spiders = {
    include("spiders/red"),
    include("spiders/soul"),
    include("spiders/eternal"),
    include("spiders/black"),
    include("spiders/golden"),
    include("spiders/bone"),
    include("spiders/rotten"),
    include("spiders/broken"),
    -- modded
    include("spiders/modded/immortal"),
    include("spiders/modded/moonlight"),
    include("spiders/modded/web"),
    -- Make sure any fly types that are used by other heart types are registered first
    include("spiders/halfRed"),
    include("spiders/doubleRed"),
    include("spiders/halfSoul"),
    include("spiders/scared"),
    include("spiders/blended"),
    --modded
    include("spiders/modded/patched"),
    include("spiders/modded/doublePatched"),

    include("spiders/modded/repPlus/broken"),
    include("spiders/modded/repPlus/dauntless"),
    include("spiders/modded/repPlus/hoarded"),
    include("spiders/modded/repPlus/soiled"),
    include("spiders/modded/repPlus/curdled"),
    include("spiders/modded/repPlus/baleful"),
    include("spiders/modded/repPlus/harlot"),
    include("spiders/modded/repPlus/miser"),
    include("spiders/modded/repPlus/empty"),
    include("spiders/modded/repPlus/zealot"),
    include("spiders/modded/repPlus/deserted"),
    include("spiders/modded/repPlus/halfDauntless")

}

-- Registers the flies
for _, spider in pairs(spiders) do
    if not spider.key then
        spider.key = spider.heart.key
    end

    spider.pickupVariant = spider.heart.variant
    spider.pickupSubType = spider.heart.subType

    if spider.pickupVariant ~= PickupVariant.PICKUP_HEART then
        spider.subType = spider.pickupVariant
    else
        spider.subType = spider.pickupSubType
    end

    spider.subType = DukeHelpers.OffsetIdentifier(spider.heart)
    spider.isBase = true

    if spider.use then
        local existingSpider = DukeHelpers.Spiders[spider.use.ke or spider.use.heart.key]
        spider.spritesheet = existingSpider.spritesheet
        spider.subType = existingSpider.subType
        spider.poofColor = existingSpider.poofColor
        spider.applyTearEffects = existingSpider.applyTearEffects

        if not spider.damageMultiplier then
            spider.damageMultiplier = existingSpider.damageMultiplier
        end

        if not spider.tearDamageMultiplier then
            spider.tearDamageMultiplier = existingSpider.tearDamageMultiplier
        end

        if not spider.tearColor then
            spider.tearColor = existingSpider.tearColor
        end

        if not spider.uiHeart then
            spider.uiHeart = existingSpider.uiHeart
        end

        if not spider.onRelease then
            spider.onRelease = existingSpider.onRelease
        end

        spider.isBase = false
    end

    if spider.spritesheet and spider.isBase then
        spider.spritesheet = "gfx/familiars/spiders/" .. spider.spritesheet
    end

    if spider.uses then
        spider.subType = spider.uses
    end

    if spider.callbacks then
        for _, callback in pairs(spider.callbacks) do
            dukeMod:AddCallback(table.unpack(callback))
        end
    end

    if spider.damageMultiplier then
        dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, f)
            if f.SubType == spider.subType then
                if f.FrameCount == 6 then
                    f.CollisionDamage = f.CollisionDamage * spider.damageMultiplier
                end
            end
        end, FamiliarVariant.BLUE_SPIDER)
    end

    DukeHelpers.Spiders[spider.key] = spider
end
