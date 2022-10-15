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
        end,
        removeOrder = 0
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
        end,
        removeOrder = 4
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
                    local count = 1
                    if FiendFolio.getTrinketMultiplierAcrossAllPlayers(TrinketType.TRINKET_RED_RIBBON) > 1 then
                        count = 3
                    end

                    if DukeHelpers.IsDuke(player) or
                        DukeHelpers.AnyPlayerHasTrinket(DukeHelpers.Trinkets.infestedHeart.Id) then
                        DukeHelpers.AddHeartFly(player, DukeHelpers.Flies.ETERNAL, count, false)
                    elseif DukeHelpers.IsHusk(player) then
                        DukeHelpers.FillRottenGulletSlot(player, DukeHelpers.Hearts.ETERNAL.key, count)
                    end

                end
            end
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
        end,
        removeOrder = 5
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
        end,
        removeOrder = 12
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
            player:AddRottenHearts(-math.min(amount * 2, DukeHelpers.Hearts.ROTTEN.GetCount(player) * 2))
        end,
        removeOrder = 1
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
        GetCount = function(player)
            return DukeHelpers.Hearts.RED.GetCount(player)
        end,
        CanPick = function(player)
            return PATCH_GLOBAL and (DukeHelpers.Hearts.RED.CanPick(player) or player:GetBrokenHearts() > 0)
        end,
        Remove = function(player, amount)
            DukeHelpers.Hearts.RED.Remove(player, amount)
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
        end,
        removeOrder = 11
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
        end,
        removeOrder = 6,
        removeMultiplier = 2
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
        end,
        removeOrder = 7
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
            CustomHealthAPI.Library.AddHealth(player, "HEART_SOILED", amount * 2)
        end,
        Remove = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_SOILED",
                -math.min(amount * 2, DukeHelpers.Hearts.SOILED.GetCount(player) * 2))
        end,
        removeOrder = 2
    },
    CURDLED = {
        subType = 89,
        CanPick = function(player)
            return canPickRedTypeHeart(player)
        end,
        OnPickup = function(player)
            local hasRedHealth = DukeHelpers.Hearts.RED.GetCount(player) > 0
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLOOD_BABY, 0, player.Position, Vector.Zero, player)

            if hasRedHealth then
                DukeHelpers.Hearts.RED.Add(player, 1)
            end
        end
    },
    ENIGMA = {
        subType = 92,
        ignore = true
    },
    CAPRICIOUS = {
        subType = 93,
        ignore = true
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
            if not RepentancePlusMod then
                return false
            end
            return RepentancePlusMod.CanPickOverlayHeart(player)
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
        end,
        removeOrder = 8
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
            if not RepentancePlusMod then
                return false
            end
            return RepentancePlusMod.CanPickOverlayHeart(player)
        end,
        Add = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_EMPTY", amount)
        end,
        Remove = function(player, amount)
            CustomHealthAPI.Library.AddHealth(player, "HEART_EMPTY", -amount)
        end
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
        end,
        removeOrder = 9
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
        end,
        removeOrder = 10
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
        end,
        removeOrder = 3
    },
}

local useHearts = {
    HALF_RED = {
        subType = HeartSubType.HEART_HALF,
        uses = DukeHelpers.Hearts.RED
    },
    DOUBLE_RED = {
        subType = HeartSubType.HEART_DOUBLEPACK,
        uses = DukeHelpers.Hearts.RED
    },
    HALF_SOUL = {
        subType = HeartSubType.HEART_HALF_SOUL,
        uses = DukeHelpers.Hearts.SOUL
    },
    SCARED = {
        subType = HeartSubType.HEART_SCARED,
        uses = DukeHelpers.Hearts.RED
    },
    DOUBLE_PATCHED = {
        subType = 3321,
        uses = DukeHelpers.Hearts.PATCHED
    },
    DOUBLE_WEB = {
        variant = 2002,
        uses = DukeHelpers.Hearts.WEB,
        CanPick = function(player)
            return DukeHelpers.Hearts.WEB.CanPick(player, true)
        end
    },
    SAVAGE = {
        subType = 90,
        uses = DukeHelpers.Hearts.RED,
        ignore = true,
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
        uses = DukeHelpers.Hearts.BLACK,
        ignore = true
    },
    FETTERED = {
        subType = 98,
        uses = DukeHelpers.Hearts.SOUL,
        ignore = true,
        CanPick = function(player)
            return (player:GetNumKeys() > 0 or player:HasGoldenKey()) and DukeHelpers.Hearts.SOUL.CanPick(player)
        end
    },
    HALF_DAUNTLESS = {
        subType = 101,
        uses = DukeHelpers.Hearts.DAUNTLESS
    },
    HALF_BLACK = {
        variant = 1022,
        uses = DukeHelpers.Hearts.BLACK
    },
    HALF_IMMORAL = {
        variant = 1025,
        uses = DukeHelpers.Hearts.IMMORAL
    },
    TWO_THIRDS_MORBID = {
        variant = 1029,
        uses = DukeHelpers.Hearts.MORBID
    },
    THIRD_MORBID = {
        variant = 1030,
        uses = DukeHelpers.Hearts.MORBID
    },
}

local function registerHeart(key, heart)
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

for key, heart in pairs(DukeHelpers.Hearts) do
    registerHeart(key, heart)
end

local doNotCopyProperties = {
    "subType",
    "variant",
    "isBase",
    "key",
    "removeOrder",
    "removeMultiplier"
}

for key, heart in pairs(useHearts) do
    if DukeHelpers.IsArray(heart) then

    else
        for propertyKey, propertyValue in pairs(heart.uses) do
            if heart[propertyKey] == nil and
                not DukeHelpers.Find(doNotCopyProperties, function(v) return v ~= propertyKey end) then
                heart[propertyKey] = propertyValue
            end
        end
    end

    DukeHelpers.Hearts[key] = heart
    registerHeart(key, heart)
end
