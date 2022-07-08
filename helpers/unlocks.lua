DukeHelpers.Unlocks = {
    MOMS_HEART = {
        stage = LevelStage.STAGE4_2,
        stageTypes = { StageType.STAGETYPE_ORIGINAL, StageType.STAGETYPE_WOTL, StageType.STAGETYPE_AFTERBIRTH },
        roomType = RoomType.ROOM_BOSS,
        difficulty = Difficulty.DIFFICULTY_HARD,
        onClear = true,
        bossId = { 8, 25 }
    },
    ISAAC = {
        stage = LevelStage.STAGE5,
        roomType = RoomType.ROOM_BOSS,
        stageTypes = { StageType.STAGETYPE_WOTL },
        onClear = true,
        bossId = 39
    },
    BLUE_BABY = {
        entityVariant = 1,
        stage = LevelStage.STAGE6,
        stageTypes = { StageType.STAGETYPE_WOTL },
        roomType = RoomType.ROOM_BOSS,
        onClear = true,
        bossId = 40
    },
    SATAN = {
        stage = LevelStage.STAGE5,
        roomType = RoomType.ROOM_BOSS,
        stageTypes = { StageType.STAGETYPE_ORIGINAL },
        onClear = true,
        bossId = 24
    },
    THE_LAMB = {
        stage = LevelStage.STAGE6,
        roomType = RoomType.ROOM_BOSS,
        stageTypes = { StageType.STAGETYPE_ORIGINAL },
        onClear = true,
        bossId = 54
    },
    MEGA_SATAN = {
        entityType = EntityType.ENTITY_MEGA_SATAN_2,
        stage = LevelStage.STAGE6,
        roomType = RoomType.ROOM_BOSS
    },
    BOSS_RUSH = {
        stage = LevelStage.STAGE3_2,
        roomType = RoomType.ROOM_BOSSRUSH,
        onClear = true
    },
    HUSH = {
        stage = LevelStage.STAGE4_3,
        roomType = RoomType.ROOM_BOSS,
        onClear = true,
        bossId = 63
    },
    DELIRIUM = {
        stage = LevelStage.STAGE7,
        roomShape = RoomShape.ROOMSHAPE_2x2,
        roomType = RoomType.ROOM_BOSS,
        onClear = true,
        bossId = 70
    },
    MOTHER = {
        stage = LevelStage.STAGE4_2,
        stageTypes = { StageType.STAGETYPE_REPENTANCE, StageType.STAGETYPE_REPENTANCE_B },
        roomType = RoomType.ROOM_BOSS,
        onClear = true,
        bossId = 88
    },
    BEAST = {
        entityType = EntityType.ENTITY_BEAST,
        entityVariant = 0,
        stage = LevelStage.STAGE8,
        roomType = RoomType.ROOM_DUNGEON
    },
    GREED = {
        stage = LevelStage.STAGE7_GREED,
        roomType = RoomType.ROOM_BOSS,
        difficulty = Difficulty.DIFFICULTY_GREED,
        onClear = true,
        bossId = 62
    },
    GREEDIER = {
        stage = LevelStage.STAGE7_GREED,
        roomType = RoomType.ROOM_BOSS,
        difficulty = Difficulty.DIFFICULTY_GREEDIER,
        onClear = true,
        bossId = { 62, 71 }
    }
}

for key, unlock in pairs(DukeHelpers.Unlocks) do
    unlock.key = key
end

function DukeHelpers.GetUnlock(unlock, tag, playerName, alsoUnlock, isHardMode)
    local dupedUnlock = table.deepCopy(unlock)
    if DukeHelpers.IsArray(dupedUnlock) then
        for key, onceUnlocked in pairs(dupedUnlock) do
            if onceUnlocked.playerName then
                onceUnlocked.tag = tag

                if onceUnlocked.alsoUnlock then
                    for i, au in pairs(onceUnlocked.alsoUnlock) do
                        onceUnlocked.alsoUnlock[i] = DukeHelpers.GetUnlock(au, tag, playerName, nil, isHardMode)
                        onceUnlocked.alsoUnlock[i].hideUnlock = true
                    end
                end
            else
                dupedUnlock[key] = DukeHelpers.GetUnlock(onceUnlocked, tag, playerName, alsoUnlock, isHardMode)
            end
        end

        local onceUnlockedUnlock = {}

        for i, onceUnlocked in pairs(dupedUnlock) do
            local dupedOnceUnlocked = table.deepCopy(onceUnlocked)
            dupedOnceUnlocked.onceUnlocked = {}

            for j, ru in pairs(dupedUnlock) do
                if i ~= j then
                    table.insert(dupedOnceUnlocked.onceUnlocked, ru)
                end
            end

            table.insert(onceUnlockedUnlock, dupedOnceUnlocked)
        end

        return onceUnlockedUnlock
    else
        dupedUnlock.playerName = playerName
        dupedUnlock.tag = tag

        if isHardMode and not dupedUnlock.difficulty then
            dupedUnlock.difficulty = Difficulty.DIFFICULTY_HARD
        end

        if alsoUnlock then
            if DukeHelpers.IsArray(alsoUnlock) then
                dupedUnlock.alsoUnlock = alsoUnlock
            else
                dupedUnlock.alsoUnlock = { alsoUnlock }
            end
        end

        return dupedUnlock
    end
end

function DukeHelpers.AreOnceUnlockedUnlocked(unlock)
    if unlock.onceUnlocked then
        for _, onceUnlocked in pairs(unlock.onceUnlocked) do
            if not DukeHelpers.IsUnlocked(onceUnlocked) then
                return false
            end
        end
    end

    return true
end

function DukeHelpers.AreUnlocksEqual(unlock, savedUnlock)
    return unlock.tag == savedUnlock.tag and unlock.key == savedUnlock.key and
        savedUnlock.difficulty >= (unlock.difficulty or 0)
end

function DukeHelpers.IsUnlocked(unlocks)
    for _, unlock in pairs(DukeHelpers.IsArray(unlocks) and unlocks or { unlocks }) do
        if DukeHelpers.AreOnceUnlockedUnlocked(unlock)
            and DukeHelpers.Find(DukeHelpers.GetPlayerUnlocks(unlock.playerName),
                function(u) return DukeHelpers.AreUnlocksEqual(unlock, u)
                end) then
            return true
        end
    end

    return false
end

function DukeHelpers.GetPlayerUnlocks(playerName)
    if not dukeMod.unlocks then
        dukeMod.unlocks = {}
    end
    if not dukeMod.unlocks[tostring(playerName)] then
        dukeMod.unlocks[tostring(playerName)] = {}
    end

    return dukeMod.unlocks[tostring(playerName)]
end

local function saveUnlock(unlock)
    local existingUnlock

    DukeHelpers.ForEach(DukeHelpers.GetPlayerUnlocks(unlock.playerName), function(u)
        if u.key == unlock.key then
            u.difficulty = math.max((u.difficulty or 0), Game().Difficulty)

            if DukeHelpers.AreUnlocksEqual(unlock, u) then
                existingUnlock = u
            end
        end
    end)

    if not existingUnlock then
        local savedUnlock = { key = unlock.key, difficulty = Game().Difficulty, tag = unlock.tag }
        table.insert(DukeHelpers.GetPlayerUnlocks(unlock.playerName), savedUnlock)
    end

    DukeHelpers.SaveGame()
end

local function unlockUnlock(unlock)
    DukeGiantBookAPI.ShowAchievement("achievement_" .. unlock.tag .. ".png")
    saveUnlock(unlock)
end

local function handleUnlock(unlock, entity, forceUnlock)
    local game = Game()
    local level = game:GetLevel()
    local room = game:GetRoom()

    local hasPlayer = false

    DukeHelpers.ForEachPlayer(function(player)
        if not hasPlayer and
            unlock.playerName == player:GetName() then
            hasPlayer = true
        end
    end)

    local isStage = level:GetStage() == unlock.stage
    local isRoom = room:GetType() == unlock.roomType
    local isStageType = not unlock.stageTypes or
        DukeHelpers.Find(unlock.stageTypes, function(t) return t == level:GetStageType() end)
    local isRoomShape = not unlock.roomShape or room:GetRoomShape() == unlock.roomShape
    local isDifficulty = not unlock.difficulty or game.Difficulty == unlock.difficulty
    local isCorrectBossRoom = not unlock.bossId or
        (
        type(unlock.bossId) == "table" and
            DukeHelpers.Find(unlock.bossId, function(bossId) return bossId == room:GetBossID() end) or
            room:GetBossID() == unlock.bossId)
    local isEntity = not entity or
        (
        (not unlock.entityVariant or entity.Variant == unlock.entityVariant) and
            (not unlock.entitySubType or entity.SubType == unlock.entitySubType))
    local isUnlocked = DukeHelpers.IsUnlocked(unlock)
    local isVictoryLap = game:GetVictoryLap() > 0
    local isSeededRun = game:GetSeeds():IsCustomRun()

    if not isSeededRun and not isVictoryLap and (not isUnlocked or unlock.onceUnlocked) and (forceUnlock or
        (
        hasPlayer and isStage and isRoom and isStageType and isRoomShape and isDifficulty and isCorrectBossRoom and
            isEntity
        )
        ) then

        if unlock.onceUnlocked and not DukeHelpers.AreOnceUnlockedUnlocked(unlock) then
            local tempOnceUnlocked = table.deepCopy(unlock.onceUnlocked)
            local canBeUnlocked = true

            if unlock.alsoUnlock then
                for _, onceUnlocked in pairs(tempOnceUnlocked) do
                    if not DukeHelpers.IsUnlocked(onceUnlocked) then
                        local anyWillAlsoUnlock = false
                        for _, alsoUnlock in pairs(unlock.alsoUnlock) do
                            if (alsoUnlock.difficulty or 0) >= (onceUnlocked.difficulty or 0) and
                                onceUnlocked.key == alsoUnlock.key then
                                anyWillAlsoUnlock = true
                                break
                            end
                        end

                        if not anyWillAlsoUnlock then
                            canBeUnlocked = false
                            break
                        end
                    end
                end
            else
                canBeUnlocked = false
            end

            if not canBeUnlocked then
                saveUnlock(unlock)
                return
            end
        end

        if unlock.alsoUnlock then
            for _, alsoUnlock in pairs(unlock.alsoUnlock) do
                handleUnlock(alsoUnlock, nil, true)
            end
        end

        if unlock.hideUnlock then
            saveUnlock(unlock)
        else
            unlockUnlock(unlock)
        end
    end
end

function DukeHelpers.RegisterUnlock(unlock)
    if unlock then
        if DukeHelpers.IsArray(unlock) then
            for _, onceUnlocked in pairs(unlock) do
                DukeHelpers.RegisterUnlock(onceUnlocked)
            end
        else
            if unlock.onClear then
                dukeMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function() handleUnlock(unlock) end)
            else
                dukeMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL,
                    function(_, entity) handleUnlock(unlock, entity) end, unlock.entityType)
            end
        end
    end
end
