MausoleumDoor_RedHeartPriority = RegisterMod("Red Heart Priority on Mausoleum Door", 1)
local mausoleumDamageFlags = 301998208;
local soulHeartOnlyPlayerTypes = { PlayerType.PLAYER_BLUEBABY, PlayerType.PLAYER_THELOST, PlayerType.PLAYER_BLACKJUDAS,
    PlayerType.PLAYER_KEEPER,
    PlayerType.PLAYER_THESOUL, PlayerType.PLAYER_BETHANY, PlayerType.JUDAS_B, PlayerType.PLAYER_BLUEBABY_B,
    PlayerType.THE_LOST_B, PlayerType.PLAYER_KEEPER_B, PlayerType.PLAYER_THEFORGOTTEN_B, PlayerType.PLAYER_BETHANY_B,
    PlayerType.PLAYER_JACBO2_B, PlayerType.PLAYER_THESOUL_B, PlayerType.PLAYER_THEFORGOTTEN }

local function canPlayerHaveRedHearts(playerType)
    for _, soulHeartOnlyPlayerType in pairs(soulHeartOnlyPlayerTypes) do
        if playerType == soulHeartOnlyPlayerType then
            return false
        end
    end
    return true
end

local function h()
    if FunctionOnRender then
        FunctionOnRender()
        FunctionOnRender = nil;
        MausoleumDoor_RedHeartPriority:RemoveCallback(ModCallbacks.MC_POST_RENDER, h)
    end
end

MausoleumDoor_RedHeartPriority:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG,
    function(_, tookDamageEntity, damageAmount, damageFlags, damageSource)
        local player = tookDamageEntity:ToPlayer()
        local levelStage = Game():GetLevel():GetStage()
        local roomType = Game():GetRoom():GetType()
        local canHaveRedHearts = canPlayerHaveRedHearts(player:GetPlayerType())
        local isBoss = roomType == RoomType.ROOM_BOSS
        local isCorrectStage = levelStage == LevelStage.STAGE2_2 or levelStage == LevelStage.STAGE3_1
        local doesNotHaveCrowHeart = not player:HasTrinket(TrinketType.TRINKET_CROW_HEART)
        local hasCorrectDamageFlags = damageFlags == mausoleumDamageFlags

        if isBoss and isCorrectStage and canHaveRedHearts and doesNotHaveCrowHeart and hasCorrectDamageFlags then
            local u, v = player:GetTrinket(0), player:GetTrinket(1)
            for f, w in pairs({ u, v }) do
                if w ~= 0 then
                    player:TryRemoveTrinket(w)
                end
            end
            player:AddTrinket(TrinketType.TRINKET_CROW_HEART, false)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, false, false, false)

            for f, w in pairs({ u, v }) do
                if w ~= 0 then
                    player:AddTrinket(w, false)
                end
            end
            FunctionOnRender = function()
                player:TryRemoveTrinket(TrinketType.TRINKET_CROW_HEART)
            end
            MausoleumDoor_RedHeartPriority:AddCallback(ModCallbacks.MC_POST_RENDER, h)
        end
    end, EntityType.ENTITY_PLAYER)
