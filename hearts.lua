local function canPickRedTypeHeart(player)
    if DukeHelpers.IsDuke(player) or DukeHelpers.IsHusk(player) then
        return true
    end

    return CustomHealthAPI.Helper.CanPickRed(player, "RED_HEART")
end

DukeHelpers.Hearts = {
    RED = {
        subType = HeartSubType.HEART_FULL,
        isBase = true,
        GetCount = function(player)
            return DukeHelpers.Clamp(player:GetHearts() - (DukeHelpers.Hearts.ROTTEN.GetCount(player) * 2) -
                DukeHelpers.Hearts.MORBID.GetCount(player) - (DukeHelpers.Hearts.SOILED.GetCount(player) * 2), 0)

        end,
        CanPick = function(player)
            return player:CanPickRedHearts()
        end,
        Add = function(player, amount)
            player:AddHearts(amount)
        end,
        Remove = function(player, amount)
            player:AddHearts(-amount)
        end
    },
    HALF_RED = {
        subType = HeartSubType.HEART_HALF,
        GetCount = function(player)
            return DukeHelpers.Hearts.RED.GetCount(player)
        end,
        CanPick = function(player)
            return DukeHelpers.Hearts.RED.CanPick(player)
        end,
        Add = function(player, amount)
            DukeHelpers.Hearts.RED.Add(player, amount)
        end,
        Remove = function(player, amount)
            DukeHelpers.Hearts.RED.Remove(player, amount)
        end
    },
    SOUL = {
        subType = HeartSubType.HEART_SOUL,
        isBase = true,
        GetCount = function(player)
            return DukeHelpers.Clamp(player:GetSoulHearts() - DukeHelpers.Hearts.BLACK.GetCount(player) -
                DukeHelpers.Hearts.IMMORTAL.GetCount(player) - DukeHelpers.Hearts.WEB.GetCount(player) -
                DukeHelpers.Hearts.IMMORAL.GetCount(player) - DukeHelpers.Hearts.DAUNTLESS.GetCount(player) -
                DukeHelpers.Hearts.MISER.GetCount(player) - DukeHelpers.Hearts.ZEALOT.GetCount(player), 0)
        end,
        CanPick = function(player)
            return player:CanPickSoulHearts()
        end,
        Add = function(player, amount)
            player:AddSoulHearts(amount)
        end,
        Remove = function(player, amount)
            player:AddSoulHearts(-math.min(DukeHelpers.Hearts.SOUL.GetCount(player), amount))
        end
    },
    ETERNAL = {
        subType = HeartSubType.HEART_ETERNAL,
        isBase = true,
        GetCount = function(player)
            return DukeHelpers.Clamp(player:GetEternalHearts(), 0)
        end,
        CanPick = function(_)
            return true
        end,
        Add = function(player, amount)
            player:AddEternalHearts(amount)
        end,
        Remove = function(player, amount)
            player:AddEternalHearts(-amount)
        end,
        OnPickup = function(player)
            if FiendFolio then
                if FiendFolio.anyPlayerHas(TrinketType.TRINKET_RED_RIBBON, true) then
                    if FiendFolio.getTrinketMultiplierAcrossAllPlayers(TrinketType.TRINKET_RED_RIBBON) > 1 then
                        if DukeHelpers.IsDuke(player) then
                            DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.ETERNAL, 3, false)
                        elseif DukeHelpers.IsHusk(player) then
                            DukeHelpers.FillRottenGulletSlot(player, DukeHelpers.Hearts.ETERNAL.key, 3)
                        end
                    else
                        if DukeHelpers.IsDuke(player) then
                            DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.ETERNAL, 1, false)
                        elseif DukeHelpers.IsHusk(player) then
                            DukeHelpers.FillRottenGulletSlot(player, DukeHelpers.Hearts.ETERNAL.key, 1)
                        end
                    end
                end
            end
        end
    },
    DOUBLE_RED = {
        subType = HeartSubType.HEART_DOUBLEPACK,
        GetCount = function(player)
            return DukeHelpers.Hearts.RED.GetCount(player)
        end,
        CanPick = function(player)
            return DukeHelpers.Hearts.RED.CanPick(player)
        end,
        Add = function(player, amount)
            DukeHelpers.Hearts.RED.Add(player, amount)
        end,
        Remove = function(player, amount)
            DukeHelpers.Hearts.RED.Remove(player, amount)
        end
    },
    BLACK = {
        subType = HeartSubType.HEART_BLACK,
        isBase = true,
        GetCount = function(player)
            local binary = DukeHelpers.IntegerToBinary(player:GetBlackHearts())

            local count = select(2, binary:gsub("1", "")) * 2

            if player:GetSoulHearts() % 2 ~= 0 and binary:sub(-1) == "1" then
                count = count - 1
            end

            return DukeHelpers.Clamp(count - DukeHelpers.Hearts.IMMORTAL.GetCount(player) -
                DukeHelpers.Hearts.WEB.GetCount(player), 0)
        end,
        CanPick = function(player)
            return player:CanPickBlackHearts()
        end,
        Add = function(player, amount)
            return player:AddBlackHearts(amount)
        end,
        Remove = function(player, amount)
            local soulHearts = DukeHelpers.Hearts.SOUL.GetCount(player)
            local blackHearts = DukeHelpers.Hearts.BLACK.GetCount(player)
            local immortalHearts = DukeHelpers.Hearts.IMMORTAL.GetCount(player)
            local webHearts = DukeHelpers.Hearts.WEB.GetCount(player)

            DukeHelpers.Hearts.WEB.Remove(player, webHearts)
            DukeHelpers.Hearts.IMMORTAL.Remove(player, immortalHearts)
            DukeHelpers.Hearts.SOUL.Remove(player, soulHearts)

            player:AddBlackHearts(-math.min(blackHearts, amount))

            DukeHelpers.Hearts.SOUL.Add(player, soulHearts)
            DukeHelpers.Hearts.IMMORTAL.Add(player, immortalHearts)
            DukeHelpers.Hearts.WEB.Add(player, webHearts)
        end
    },
    GOLDEN = {
        subType = HeartSubType.HEART_GOLDEN,
        isBase = true,
        GetCount = function(player)
            return DukeHelpers.Clamp(player:GetGoldenHearts(), 0)
        end,
        CanPick = function(player)
            return player:CanPickGoldenHearts()
        end,
        Add = function(player, amount)
            player:AddGoldenHearts(amount)
        end,
        Remove = function(player, amount)
            player:AddGoldenHearts(-amount)
        end
    },
    HALF_SOUL = {
        subType = HeartSubType.HEART_HALF_SOUL,
        GetCount = function(player)
            return DukeHelpers.Hearts.SOUL.GetCount(player)
        end,
        CanPick = function(player)
            return DukeHelpers.Hearts.SOUL.CanPick(player)
        end,
        Add = function(player, amount)
            DukeHelpers.Hearts.SOUL.Add(player, amount)
        end,
        Remove = function(player, amount)
            DukeHelpers.Hearts.SOUL.Remove(player, amount)
        end
    },
    SCARED = {
        subType = HeartSubType.HEART_SCARED,
        GetCount = function(player)
            return DukeHelpers.Hearts.RED.GetCount(player)
        end,
        CanPick = function(player)
            return DukeHelpers.Hearts.RED.CanPick(player)
        end,
        Add = function(player, amount)
            DukeHelpers.Hearts.RED.Add(player, amount)
        end,
        Remove = function(player, amount)
            DukeHelpers.Hearts.RED.Remove(player, amount)
        end
    },
    BLENDED = {
        subType = HeartSubType.HEART_BLENDED,
        CanPick = function(player)
            return DukeHelpers.Hearts.RED.CanPick(player) or DukeHelpers.Hearts.SOUL.CanPick(player)
        end,
        Add = function(player, amount)
            player:AddHearts(amount)
        end,
        Remove = function(player, amount)
            player:AddHearts(-amount)
        end
    },
    BONE = {
        subType = HeartSubType.HEART_BONE,
        isBase = true,
        GetCount = function(player)
            return DukeHelpers.Clamp(player:GetBoneHearts(), 0)
        end,
        CanPick = function(player)
            return player:CanPickBoneHearts()
        end,
        Add = function(player, amount)
            player:AddBoneHearts(amount)
        end,
        Remove = function(player, amount)
            player:AddBoneHearts(-amount)
        end
    },
    ROTTEN = {
        subType = HeartSubType.HEART_ROTTEN,
        isBase = true,
        GetCount = function(player)
            return DukeHelpers.Clamp(player:GetRottenHearts(), 0)
        end,
        CanPick = function(player)
            return player:CanPickRottenHearts()
        end,
        Add = function(player, amount)
            player:AddRottenHearts(amount)
        end,
        Remove = function(player, amount)
            player:AddRottenHearts(-math.max(amount * 2, DukeHelpers.Hearts.ROTTEN.GetCount(player) * 2))
        end
    },
    BROKEN = {
        subType = 13,
        isBase = true,
        notCollectible = true,
        GetCount = function(player)
            return DukeHelpers.Clamp(player:GetBrokenHearts(), 0)
        end,
        Add = function(player, amount)
            player:AddBrokenHearts(amount)
        end,
        Remove = function(player, amount)
            player:AddBrokenHearts(-amount)
        end
    },
    MOONLIGHT = {
        variant = 901,
        isBase = true,
        GetCount = function(player)
            return DukeHelpers.Clamp(player:GetData().moons or Isaac.GetPlayer(0):GetData().moons or 0, 0)
        end,
        CanPick = function(player)
            return DukeHelpers.Hearts.MOONLIGHT.GetCount(player) < 12
        end,
        Add = function(player, amount)
            local data = player:GetData()

            if not data.moons then
                data = Isaac.GetPlayer(0):GetData()
            end

            data.moons = data.moons + amount
        end,
        Remove = function(player, amount)
            local data = player:GetData()

            if not data.moons then
                data = Isaac.GetPlayer(0):GetData()
            end

            data.moons = math.max(data.moons - amount, 0)
        end
    },
    PATCHED = {
        subType = 3320,
        CanPick = function(player)
            return PATCH_GLOBAL and (DukeHelpers.Hearts.RED.CanPick(player) or player:GetBrokenHearts() > 0)
        end
    },
    DOUBLE_PATCHED = {
        subType = 3321,
        CanPick = function(player)
            return DukeHelpers.Hearts.PATCHED.CanPick(player)
        end
    },
    IMMORTAL = {
        subType = 902,
        isBase = true,
        GetCount = function(player)
            if ComplianceImmortal then
                return DukeHelpers.Clamp(ComplianceImmortal.GetImmortalHearts(player), 0)
            end

            return 0
        end,
        CanPick = function(player)
            local hearts = DukeHelpers.Hearts.IMMORTAL.GetCount(player)

            return hearts and hearts < (player:GetHeartLimit() - player:GetEffectiveMaxHearts())
        end,
        Add = function(player, amount)
            if not ComplianceImmortal or amount == 0 then
                return
            end
            ComplianceImmortal.AddImmortalHearts(player, amount)
        end,
        Remove = function(player, amount)
            if not ComplianceImmortal or amount == 0 then
                return
            end
            local initialSoulHearts = DukeHelpers.Hearts.SOUL.GetCount(player)
            ComplianceImmortal.AddImmortalHearts(player, -amount)
            local soulHeartsRemoved = initialSoulHearts - DukeHelpers.Hearts.SOUL.GetCount(player)
            DukeHelpers.Hearts.SOUL.Add(player, soulHeartsRemoved)
        end
    },
    WEB = {
        variant = 2000,
        isBase = true,
        GetCount = function(player)
            if ARACHNAMOD then
                local webHearts = ARACHNAMOD:GetData(player).webHearts

                if webHearts then
                    return DukeHelpers.Clamp(webHearts * 2, 0)
                end
            end

            return 0
        end,
        CanPick = function(player, double)
            if not ARACHNAMOD or DukeHelpers.GetPlayerControllerIndex(player) ~= 0 then
                return false
            end

            local playerType = player:GetPlayerType()
            if DukeHelpers.IsKeeper(player) or DukeHelpers.IsLost(player) or (not player:CanPickSoulHearts()) then
                return false
            end

            player = playerType == PlayerType.PLAYER_THESOUL_B and player:GetMainTwin() or player
            player = playerType == PlayerType.PLAYER_THEFORGOTTEN and player:GetSubPlayer() or player

            local webHeartAmount = ARACHNAMOD:GetData(player).webHearts

            local maxHP = player:GetHeartLimit()
            local healthAmount = maxHP
            if webHeartAmount then
                healthAmount = player:GetSoulHearts() + getRedContainers(player)
            end
            if healthAmount < maxHP and (not double or healthAmount < maxHP - 2) then
                return true
            end
            return false
        end,
        Add = function(player, amount)
            if not ARACHNAMOD then
                return
            end
            addWebHearts(amount, player)
        end,
        Remove = function(player, amount)
            if not ARACHNAMOD or DukeHelpers.GetPlayerControllerIndex(player) ~= 0 then
                return
            end
            local initialSoulHearts = DukeHelpers.Hearts.SOUL.GetCount(player)
            addWebHearts(-amount / 2, player)
            local soulHeartsRemoved = initialSoulHearts - DukeHelpers.Hearts.SOUL.GetCount(player)
            DukeHelpers.Hearts.SOUL.Add(player, soulHeartsRemoved)
        end
    },
    DOUBLE_WEB = {
        variant = 2002,
        GetCount = function(player)
            return DukeHelpers.Hearts.WEB.GetCount(player)
        end,
        CanPick = function(player)
            return DukeHelpers.Hearts.WEB.CanPick(player, true)
        end,
        Add = function(player, amount)
            DukeHelpers.Hearts.WEB.Add(player, amount)
        end,
        Remove = function(player, amount)
            DukeHelpers.Hearts.WEB.Remove(player, amount)
        end
    },
    BROKEN_HEART = {
        subType = 84,
        CanPick = function(_)
            return true
        end,
        OnPickup = function(player)
            player:AddSoulHearts(2)
        end
    },
    DAUNTLESS = {
        subType = 85,
        isBase = true,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Library.GetHPOfKey(player, "HEART_DAUNTLESS")
            end

            return 0
        end,
        CanPick = function(player)
            if not RepentancePlusMod or not CustomHealthAPI then
                return false
            end
            return CustomHealthAPI.Library.CanPickKey(player, "HEART_DAUNTLESS")
        end,
        Add = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_DAUNTLESS", amount)
        end,
        Remove = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_DAUNTLESS", -amount)
        end
    },
    HOARDED = {
        subType = 86,
        CanPick = function(player)
            return canPickRedTypeHeart(player)
        end
    },
    SOILED = {
        subType = 88,
        isBase = true,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Library.GetHPOfKey(player, "HEART_SOILED") / 2
            end

            return 0
        end,
        CanPick = function(player)
            if not RepentancePlusMod or not CustomHealthAPI then
                return false
            end
            return CustomHealthAPI.Library.CanPickKey(player, "HEART_SOILED")
        end,
        Add = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_SOILED", amount)
        end,
        Remove = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_SOILED", -amount)
        end
    },
    CURDLED = {
        subType = 89,
        CanPick = function(player)
            return canPickRedTypeHeart(player)
        end,
        OnPickup = function(player)
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLOOD_BABY, 0, player.Position, Vector.Zero, player)
        end
    },
    SAVAGE = {
        subType = 90,
        Ignore = true,
        OnPickup = function(player, pickup)
            if DukeHelpers.IsDuke(player) then
                DukeHelpers.SpawnPickupHeartFly(player,
                    { Type = pickup.Type, Variant = pickup.Variant, SubType = pickup.SubType, Price = 0 },
                    DukeHelpers.Hearts.RED.key, 2
                    , false)
            elseif DukeHelpers.IsHusk(player) then
                DukeHelpers.FillRottenGulletSlot(player, DukeHelpers.Hearts.RED.key, 2)
            end
        end
    },
    BENIGHTED = {
        subType = 91,
        Ignore = true
    },
    ENIGMA = {
        subType = 92,
        Ignore = true
    },

    CARICIOUS = {
        subType = 93,
        Ignore = true
    },
    BALEFUL = {
        subType = 94,
        isBase = true,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Library.GetHPOfKey(player, "HEART_BALEFUL")
            end

            return 0
        end,
        CanPick = function(player)
            if not RepentancePlusMod or not CustomHealthAPI then
                return false
            end
            return CustomHealthAPI.Library.CanPickKey(player, "HEART_BALEFUL")
        end,
        Add = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_BALEFUL", amount)
        end,
        Remove = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_BALEFUL", -amount)
        end
    },
    HARLOT = {
        subType = 95,
        CanPick = function(player)
            return canPickRedTypeHeart(player)
        end,
        OnPickup = function(player)
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.LEPROSY, 0, player.Position, Vector.Zero, player)
        end
    },
    MISER = {
        subType = 96,
        isBase = true,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Library.GetHPOfKey(player, "HEART_MISER")
            end

            return 0
        end,
        CanPick = function(player)
            if not RepentancePlusMod or not CustomHealthAPI then
                return false
            end
            return CustomHealthAPI.Library.CanPickKey(player, "HEART_MISER")
        end,
        Add = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_MISER", amount)
        end,
        Remove = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_MISER", -amount)
        end
    },
    EMPTY = {
        subType = 97,
        isBase = true,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Library.GetHPOfKey(player, "HEART_EMPTY")
            end

            return 0
        end,
        CanPick = function(player)
            if not RepentancePlusMod or not CustomHealthAPI then
                return false
            end
            return CustomHealthAPI.Library.CanPickKey(player, "HEART_EMPTY")
        end,
        Add = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_EMPTY", amount)
        end,
        Remove = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_EMPTY", -amount)
        end
    },
    FETTERED = {
        subType = 98,
        Ignore = true
    },
    ZEALOT = {
        subType = 99,
        isBase = true,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Library.GetHPOfKey(player, "HEART_ZEALOT")
            end

            return 0
        end,
        CanPick = function(player)
            if not RepentancePlusMod or not CustomHealthAPI then
                return false
            end
            return CustomHealthAPI.Library.CanPickKey(player, "HEART_ZEALOT")
        end,
        Add = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_ZEALOT", amount)
        end,
        Remove = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_ZEALOT", -amount)
        end
    },
    DESERTED = {
        subType = 100,
        CanPick = function(player)
            if not RepentancePlusMod or not CustomHealthAPI then
                return false
            end
            return CustomHealthAPI.Library.CanPickKey(player, "HEART_ZEALOT")
        end
    },
    HALF_DAUNTLESS = {
        subType = 101,
        GetCount = function(player)
            return DukeHelpers.Hearts.DAUNTLESS.GetCount(player)
        end,
        CanPick = function(player)
            return DukeHelpers.Hearts.DAUNTLESS.CanPick(player)
        end,
        Add = function(player, amount)
            DukeHelpers.Hearts.DAUNTLESS.Add(player, amount)
        end,
        Remove = function(player, amount)
            DukeHelpers.Hearts.DAUNTLESS.Remove(player, amount)
        end
    },
    HALF_BLACK = {
        variant = 1022,
        CanPick = function(player)
            return DukeHelpers.Hearts.BLACK.CanPick(player)
        end
    },
    BLENDED_BLACK = {
        variant = 1023,
        CanPick = function(player)
            return DukeHelpers.Hearts.BLACK.CanPick(player) or DukeHelpers.Hearts.RED.CanPick(player)
        end
    },
    IMMORAL = {
        variant = 1024,
        isBase = true,
        GetCount = function(player)
            if FiendFolio and CustomHealthAPI then
                return CustomHealthAPI.Library.GetHPOfKey(player, "IMMORAL_HEART")
            end

            return 0
        end,
        CanPick = function(player)
            if not CustomHealthAPI then
                return false
            end
            return CustomHealthAPI.Library.CanPickKey(player, "IMMORAL_HEART")
        end,
        Add = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "IMMORAL_HEART", amount)

        end,
        Remove = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "IMMORAL_HEART", -amount)
        end
    },
    HALF_IMMORAL = {
        variant = 1025,
        GetCount = function(player)
            return DukeHelpers.Hearts.IMMORAL.GetCount(player)
        end,
        CanPick = function(player)
            return DukeHelpers.Hearts.IMMORAL.CanPick(player)
        end,
        Add = function(player, amount)
            DukeHelpers.Hearts.IMMORAL.Add(player, amount)
        end,
        Remove = function(player, amount)
            DukeHelpers.Hearts.IMMORAL.Add(player, amount)
        end
    },
    BLENDED_IMMORAL = {
        variant = 1026,
        CanPick = function(player)
            return DukeHelpers.Hearts.IMMORAL.CanPick(player) or DukeHelpers.Hearts.RED.CanPick(player)
        end
    },
    MORBID = {
        variant = 1028,
        isBase = true,
        GetCount = function(player)
            if FiendFolio and CustomHealthAPI then
                return CustomHealthAPI.Library.GetHPOfKey(player, "MORBID_HEART")
            end

            return 0
        end,
        CanPick = function(player)
            if not CustomHealthAPI then
                return false
            end
            return CustomHealthAPI.Library.CanPickKey(player, "MORBID_HEART")
        end,
        Add = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "MORBID_HEART", amount)
        end,
        Remove = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "MORBID_HEART", -amount)
        end
    },
    TWO_THIRDS_MORBID = {
        variant = 1029,
        GetCount = function(player)
            return DukeHelpers.Hearts.MORBID.GetCount(player)
        end,
        CanPick = function(player)
            return DukeHelpers.Hearts.MORBID.CanPick(player)
        end,
        Add = function(player, amount)
            DukeHelpers.Hearts.MORBID.Add(player, amount)
        end,
        Remove = function(player, amount)
            DukeHelpers.Hearts.MORBID.Add(player, amount)
        end
    },
    THIRD_MORBID = {
        variant = 1030,
        GetCount = function(player)
            return DukeHelpers.Hearts.MORBID.GetCount(player)
        end,
        CanPick = function(player)
            return DukeHelpers.Hearts.MORBID.CanPick(player)
        end,
        Add = function(player, amount)
            DukeHelpers.Hearts.MORBID.Add(player, amount)
        end,
        Remove = function(player, amount)
            DukeHelpers.Hearts.MORBID.Add(player, amount)
        end
    },

}

for key, heart in pairs(DukeHelpers.Hearts) do
    if not heart.variant then
        heart.variant = PickupVariant.PICKUP_HEART
    elseif not heart.subType then
        heart.subType = 0
    end

    if not heart.key then
        heart.key = key
    end

    heart.IsHeart = function(pickup)
        return pickup.Variant == heart.variant and pickup.SubType == heart.subType
    end

    if not heart.isBase then
        heart.isBase = false
    end

    if not heart.CanPick then
        heart.CanPick = function()
            return true
        end
    end
end
