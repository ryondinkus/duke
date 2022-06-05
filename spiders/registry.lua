local spiders = {
    include("spiders/red"),
    include("spiders/soul"),
    include("spiders/eternal"),
    include("spiders/black"),
    include("spiders/golden"),
    include("spiders/bone"),
    include("spiders/rotten"),
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
    include("spiders/modded/doublePatched")
}

-- Registers the flies
for _, spider in pairs(spiders) do
    spider.subType = DukeHelpers.GetSpiderSubTypeByPickupSubType(spider.pickupSubType)
    spider.isBase = true

    if spider.use then
        local existingSpider = DukeHelpers.Spiders[spider.use]

        spider.spritesheet = existingSpider.spritesheet
        spider.subType = existingSpider.subType
        spider.poofColor = existingSpider.poofColor

        if not spider.damageMultiplier then
            spider.damageMultiplier = existingSpider.damageMultiplier
        end

        existingSpider.isBase = false
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
        dukeMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE_ATTACK, function(_, f)
            if f.SubType == spider.subType then
                if f.FrameCount == 6 then
                    f.CollisionDamage = f.CollisionDamage * spider.damageMultiplier
                end
            end
        end, FamiliarVariant.BLUE_SPIDER)
    end

    DukeHelpers.Spiders[spider.key] = spider
end
