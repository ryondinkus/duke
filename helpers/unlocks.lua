DukeHelpers.Unlocks = {
    MOMS_HEART = {
        entityType = EntityType.ENTITY_MOMS_HEART,
        stage = LevelStage.STAGE4_2,
        stageTypes = { StageType.STAGETYPE_ORIGINAL, StageType.STAGETYPE_WOTL, StageType.STAGETYPE_AFTERBIRTH },
        roomType = RoomType.ROOM_BOSS,
        onClear = true
    },
    ISAAC = {
        entityType = EntityType.ENTITY_ISAAC,
        stage = LevelStage.STAGE5,
        roomType = RoomType.ROOM_BOSS,
        stageTypes = { StageType.STAGETYPE_WOTL },
        onClear = true
    },
    BLUE_BABY = {
        entityType = EntityType.ENTITY_ISAAC,
        entityVariant = 1,
        stage = LevelStage.STAGE6,
        stageTypes = { StageType.STAGETYPE_WOTL },
        roomType = RoomType.ROOM_BOSS,
        onClear = true
    },
    SATAN = {
        entityType = EntityType.ENTITY_SATAN,
        stage = LevelStage.STAGE5,
        roomType = RoomType.ROOM_BOSS,
        stageTypes = { StageType.STAGETYPE_ORIGINAL },
        onClear = true
    },
    THE_LAMB = {
        entityType = EntityType.ENTITY_THE_LAMB,
        stage = LevelStage.STAGE6,
        roomType = RoomType.ROOM_BOSS,
        stageTypes = { StageType.STAGETYPE_ORIGINAL },
        onClear = true
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
        entityType = EntityType.ENTITY_HUSH,
        stage = LevelStage.STAGE4_3,
        roomType = RoomType.ROOM_BOSS,
        onClear = true
    },
    DELIRIUM = {
        entityType = EntityType.ENTITY_DELIRIUM,
        stage = LevelStage.STAGE7,
        roomShape = RoomShape.ROOMSHAPE_2x2,
        roomType = RoomType.ROOM_BOSS,
        onClear = true
    },
    MOTHER = {
        entityType = EntityType.ENTITY_MOTHER,
        stage = LevelStage.STAGE4_2,
        stageTypes = { StageType.STAGETYPE_REPENTANCE, StageType.STAGETYPE_REPENTANCE_B },
        roomType = RoomType.ROOM_BOSS,
        onClear = true
    },
    BEAST = {
        entityType = EntityType.ENTITY_BEAST,
        entityVariant = 0,
        stage = LevelStage.STAGE8,
        roomType = RoomType.ROOM_DUNGEON
    },
    GREED = {
        entityType = EntityType.ENTITY_ULTRA_GREED,
        stage = LevelStage.STAGE7_GREED,
        roomType = RoomType.ROOM_BOSS,
        difficulty = Difficulty.DIFFICULTY_GREED,
        onClear = true
    },
    GREEDIER = {
        entityType = EntityType.ENTITY_ULTRA_GREED,
        stage = LevelStage.STAGE7_GREED,
        roomType = RoomType.ROOM_BOSS,
        difficulty = Difficulty.DIFFICULTY_GREEDIER,
        onClear = true
    }
}

for key, unlock in pairs(DukeHelpers.Unlocks) do
    unlock.key = key
end

function DukeHelpers.GetUnlock(unlock, tag, playerType, alsoUnlock)
    local dupedUnlock = table.deepCopy(unlock)
    if DukeHelpers.IsArray(dupedUnlock) then
        for _, onceUnlocked in pairs(dupedUnlock) do
            onceUnlocked = DukeHelpers.GetUnlock(onceUnlocked, tag, playerType, alsoUnlock)
        end

        for i, onceUnlocked in pairs(dupedUnlock) do
            onceUnlocked.onceUnlocked = {}

            for j, ru in pairs(dupedUnlock) do
                if i ~= j then
                    table.insert(onceUnlocked.onceUnlocked, ru)
                end
            end
        end

        return dupedUnlock
    else
        dupedUnlock.playerType = playerType
        dupedUnlock.tag = tag

        if DukeHelpers.IsArray(alsoUnlock) then
            dupedUnlock.alsoUnlock = alsoUnlock
        else
            dupedUnlock.alsoUnlock = { alsoUnlock }
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

function DukeHelpers.IsUnlocked(unlock)
    return DukeHelpers.AreOnceUnlockedUnlocked(unlock)
        and DukeHelpers.Find(dukeMod.unlocks[unlock.playerType] or {},
            function(unlocked) return unlocked.key == unlock.key end)
end

local function saveUnlock(unlock)
    DukeGiantBookAPI.ShowAchievement("achievement_" .. unlock.tag .. ".png")
    local playerUnlocks = dukeMod.unlocks[unlock.playerType]
    if not playerUnlocks then
        playerUnlocks = {}
    end
    table.insert(playerUnlocks, { key = unlock.key, tag = unlock.tag })
    DukeHelpers.SaveGame()
end

local function handleUnlock(unlock, entity, forceUnlock)
    local game = Game()
    local level = game:GetLevel()
    local room = game:GetRoom()

    local hasPlayer = false

    DukeHelpers.ForEachPlayer(function(player)
        if not hasPlayer and player:GetPlayerType() == unlock.playerType then
            hasPlayer = true
        end
    end)

    local isStage = level:GetStage() == unlock.stage
    local isRoom = room:GetType() == unlock.roomType
    local isStageType = not unlock.stageTypes or
        DukeHelpers.Find(unlock.stageTypes, function(t) return t == level:GetStageType() end)
    local isRoomShape = not unlock.roomShape or room:GetRoomShape() == unlock.roomShape
    local isDifficulty = not unlock.difficulty or game.Difficulty == unlock.difficulty
    local isEntity = not entity or
        (
        (not unlock.entityVariant or entity.Variant == unlock.entityVariant) and
            (not unlock.entitySubType or entity.SubType == unlock.entitySubType))
    local isUnlocked = DukeHelpers.IsUnlocked(unlock)

    if not isUnlocked and (forceUnlock or
        (
        hasPlayer and isStage and isRoom and isStageType and isRoomShape and isDifficulty and isEntity and not isUnlocked
        )
        ) then

        if not DukeHelpers.AreOnceUnlockedUnlocked(unlock) then -- TODO there will be a bug here when greedier is completed
            return
        end

        saveUnlock(unlock)

        if unlock.alsoUnlock then
            for _, alsoUnlock in pairs(unlock.alsoUnlock) do
                handleUnlock(alsoUnlock, nil, true)
            end
        end
    end
end

function DukeHelpers.RegisterUnlock(unlock)
    if DukeHelpers.IsArray(unlock) then
        for _, onceUnlocked in pairs(unlock) do
            DukeHelpers.RegisterUnlock(onceUnlocked)
        end
    else
        if unlock.onClear then
            dukeMod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function() handleUnlock(unlock) end)
        else
            dukeMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, entity) handleUnlock(unlock, entity) end,
                unlock.entityType)
        end
    end
end
