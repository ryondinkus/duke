local Names = {
    en_us = "Duke of Eyes",
    spa = "Duque no Eyeballos"
}
local Name = Names.en_us
local Tag = "dukeOfEyes"
local Id = Isaac.GetItemIdByName(Name)
local Descriptions = {
    en_us = "Luck-based chance of firing Duke Tears, which spawn 1-2 Heart Attack Flies or Heart Spiders on collision#5% chance of triggering at 0 luck, capping at 50% at 10 luck",
    spa = "Caca y mierda por todos lados"
}
local WikiDescription = DukeHelpers.GenerateEncyclopediaPage({
    {
        "Effects",
        "Tears have a luck-based chance of spawning 1-2 Heart Attack Flies or Heart Spiders of random types.",
        "- The random types can be: Red, Soul, Black, Gold, Bone, or Rotten. Red and Soul are more likely to spawn.",
        "- Duke of Eyes tears have a 5% chance of appearing at 0 luck, capping at 50% at 10 luck."
    },
    {
        "Trivia",
        "Duke of Eyes was originally unlocked by beating The Beast as Tainted Duke, but was later moved to an all-completion marks reward after scrapping co-op babies.",
        "- The scrapped baby would've been Swarm Baby, a big mass of Heart Flies, and would've fired tears with effects based on the different heart fly types.",
        "This is the weirdest fucking item idea."
    }
})

local function MC_POST_FIRE_TEAR(_, tear)
    if DukeHelpers.Items.dukeOfEyes.IsUnlocked() then
        local player = tear:GetLastParent():ToPlayer()

        if player:HasCollectible(Id) then
            if DukeHelpers.PercentageChance(player.Luck * 5 + 5, 50) then
                tear:GetData()[Tag] = true

                local sprite = tear:GetSprite()

                if not tear:HasTearFlags(DukeHelpers.ConvertBitSet64ToBitSet128(77)) then
                    local animationToPlay = sprite:GetAnimation()

                    sprite:Load("gfx/tears/dukeOfEyesTear.anm2", true)
                    if player:GetPlayerType() == DukeHelpers.HUSK_ID then
                        sprite:ReplaceSpritesheet(0, "gfx/tears/dukeOfEyes_husk.png")
                        sprite:LoadGraphics()
                    end
                    sprite:Play(animationToPlay, true)
                end
            end
        end
    end
end

local function MC_PRE_TEAR_COLLISION(_, tear, collider)
    local player = tear:GetLastParent():ToPlayer()

    if DukeHelpers.IsActualEnemy(collider, true) and tear:GetData()[Tag] then
        local amount = DukeHelpers.PercentageChance(50) and 1 or 2
        if DukeHelpers.PercentageChance(50) then
            local selectedFly = DukeHelpers.GetWeightedFly(DukeHelpers.rng)
            DukeHelpers.SpawnAttackFlyFromHeartFly(selectedFly, player.Position, player)
            DukeHelpers.SpawnHeartFlyPoof(selectedFly, player.Position, player)
        else
            local selectedSpider = DukeHelpers.GetWeightedSpider(DukeHelpers.rng)
            DukeHelpers.SpawnSpidersFromKey(selectedSpider.key, player.Position, player, amount, true)
            DukeHelpers.SpawnHeartFlyPoof(selectedSpider, player.Position, player)
        end
        DukeHelpers.sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 1, 0, false, 1)
    end
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
            ModCallbacks.MC_PRE_TEAR_COLLISION,
            MC_PRE_TEAR_COLLISION
        },
        {
            ModCallbacks.MC_POST_FIRE_TEAR,
            MC_POST_FIRE_TEAR
        }
    },
    unlock = DukeHelpers.GetUnlock({
        DukeHelpers.Unlocks.MOMS_HEART,
        DukeHelpers.Unlocks.ISAAC,
        DukeHelpers.Unlocks.BLUE_BABY,
        DukeHelpers.Unlocks.SATAN,
        DukeHelpers.Unlocks.THE_LAMB,
        DukeHelpers.Unlocks.MEGA_SATAN,
        DukeHelpers.Unlocks.BOSS_RUSH,
        DukeHelpers.Unlocks.HUSH,
        DukeHelpers.Unlocks.DELIRIUM,
        DukeHelpers.Unlocks.MOTHER,
        DukeHelpers.Unlocks.BEAST,
        DukeHelpers.Unlocks.GREEDIER
    }, Tag, DukeHelpers.DUKE_NAME, nil, true)
}
