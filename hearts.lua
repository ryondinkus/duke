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
            return DukeHelpers.Clamp(player:GetHearts() - (DukeHelpers.Hearts.ROTTEN.GetCount(player) * 2), 0)
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
                DukeHelpers.Hearts.IMMORTAL.GetCount(player) - DukeHelpers.Hearts.WEB.GetCount(player), 0)
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
        end
    },
    DAUNTLESS = {
        subType = 85,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Helper.GetHPOfKey(player, "HEART_DAUNTLESS")
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
        CanPick = canPickRedTypeHeart
    },
    SOILED = {
        subType = 88,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Helper.GetHPOfKey(player, "HEART_SOILED")
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
            return player:CanPickRedHearts() or not DukeHelpers.IsRedFred(player)
        end
    },
    SAVAGE = {
        subType = 90,
        CanPick = function(_)
            return true
        end
    },
    BENIGHTED = {
        subType = 90,
        CanPick = function(player)
            return player:CanPickBlackHearts()
        end
    },
    BALEFUL = {
        subType = 94,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Helper.GetHPOfKey(player, "HEART_BALEFUL")
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
    EMPTY = {
        subType = 97,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Helper.GetHPOfKey(player, "HEART_EMPTY")
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
    MISER = {
        subType = 96,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Helper.GetHPOfKey(player, "HEART_MISER")
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
    ZEALOT = {
        subType = 99,
        GetCount = function(player)
            if RepentancePlusMod and CustomHealthAPI then
                return CustomHealthAPI.Helper.GetHPOfKey(player, "HEART_ZEALOT")
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
end
