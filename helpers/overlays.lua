local mod = dukeMod
local game = Game()
local sfx = SFXManager()

local bigBook = Sprite()
local maxFrames = { ["Appear"] = 33, ["Shake"] = 36, ["ShakeFire"] = 32, ["Flip"] = 33 }
local bookColors = { [0] = Color(1, 1, 1, 1, 0, 0, 0), [1] = Color(1, 1, 1, 1, 0, 0, 0), [2] = Color(1, 1, 1, 1, 0, 0, 0),
    [3] = Color(1, 1, 1, 1, 0, 0, 0), [4] = Color(1, 1, 1, 1, 0, 0, 0), [5] = Color(1, 1, 1, 1, 0, 0, 0) }
local bookLength = 0

--layer #0 - popup
--layer #1 - screen (color 2)
--layer #2 - dust poof (color 1)
--layer #3 - dust poof (color 1)
--layer #4 - swirl poof (color 3)
--layer #5 - fire

mod.global.isPaused = false
local pausedKey
local savedTimer
local savedVelocities = {}

local function FreezeGame(key)
    if not mod.global.isPaused then
        pausedKey = key
        mod.global.isPaused = true
        if not savedTimer then
            savedTimer = game.TimeCounter
        end
        DukeHelpers.ForEachEntityInRoom(function(entity) entity:AddEntityFlags(EntityFlag.FLAG_FREEZE) end, nil, nil, nil
            , function(entity)
            return entity:IsEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FREEZE)
        end)
        game.TimeCounter = savedTimer
        if (ModConfigMenu and ModConfigMenu.IsVisible) then
            ModConfigMenu.CloseConfigMenu()
        end
        if (DeadSeaScrollsMenu and DeadSeaScrollsMenu.OpenedMenu) then
            DeadSeaScrollsMenu:CloseMenu(true, true)
        end

        DukeHelpers.ForEachPlayer(function(player)
            local data = DukeHelpers.GetDukeData(player)

            if not data.pausedVelocity then
                data.pausedVelocity = player.Velocity
                player.ControlsEnabled = false
                player.Velocity = Vector.Zero
            end
        end)

        for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_TEAR)) do
            local tear = entity:ToTear()
            savedVelocities[tostring(tear.InitSeed)] = { Velocity = tear.Velocity, FallingSpeed = tear.FallingSpeed,
                FallingAcceleration = tear.FallingAcceleration }

            tear.Velocity = Vector.Zero
            tear.FallingAcceleration = -0.1
            tear.FallingSpeed = 0
        end

        for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
            local projectile = entity:ToProjectile()
            savedVelocities[tostring(projectile.InitSeed)] = { Velocity = projectile.Velocity,
                FallingSpeed = projectile.FallingSpeed, FallingAcceleration = projectile.FallingAccel }

            projectile.Velocity = Vector.Zero
            projectile.FallingAccel = -0.1
            projectile.FallingSpeed = 0
        end

        for _, poof in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1)) do
            poof:Remove()
        end
        for _, poof in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, -1)) do
            poof:Remove()
        end

        for _, poof in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF04, -1)) do
            poof:Remove()
        end
    end
end

local function UnfreezeGame(key)
    if mod.global.isPaused and pausedKey == key then
        stopPause = true
        mod.global.isPaused = false
        savedTimer = nil

        DukeHelpers.ForEachEntityInRoom(function(entity) entity:ClearEntityFlags(EntityFlag.FLAG_FREEZE) end, nil, nil,
            nil, function(entity)
            return entity:IsEnemy() and entity:HasEntityFlags(EntityFlag.FLAG_FREEZE)
        end)

        DukeHelpers.ForEach(savedVelocities, function(values, initSeed)
            local entity = DukeHelpers.GetEntityByInitSeed(initSeed)
            if entity and entity:Exists() then
                entity.Velocity = values.Velocity
                if entity:ToTear() then
                    entity = entity:ToTear()
                    entity.FallingAcceleration = values.FallingAcceleration
                    entity.FallingSpeed = values.FallingSpeed
                else
                    entity = entity:ToProjectile()
                    entity.FallingAccel = values.FallingAcceleration
                    entity.FallingSpeed = values.FallingSpeed
                end
            end

            savedVelocities[tostring(initSeed)] = nil
        end)

        DukeHelpers.ForEachPlayer(function(player)
            local data = DukeHelpers.GetDukeData(player)

            if data.pausedVelocity then
                player.Velocity = data.pausedVelocity
                player.ControlsEnabled = true
                data.pausedVelocity = nil
            end
        end)
    end
end

local function GetScreenCenter()
    return Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() / 2)
end

-- Stops players' controls
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, function(_, _, _, action)
    if not mod.global.isPaused then
        return nil
    end

    if action >= ButtonAction.ACTION_BOMB
        and action <= ButtonAction.ACTION_MENUTAB
    then
        return false
    end
end, InputHook.IS_ACTION_TRIGGERED)

function DukeHelpers.PlayGiantBook(_animName, _popup, _poofColor, _bgColor, _poof2Color, _soundName, _notHide, _gfxRoot)
    bigBook:Load(_gfxRoot or "gfx/ui/giantbook/giantbook.anm2", true)
    if _popup then
        bigBook:ReplaceSpritesheet(0, "gfx/ui/giantbook/" .. _popup)
        bigBook:LoadGraphics()
    end
    bigBook:Play(_animName, true)
    bookLength = maxFrames[_animName]
    bookColors[1] = _bgColor
    bookColors[2] = _poofColor
    bookColors[3] = _poofColor
    bookColors[4] = _poof2Color
    if not _notHide then
        FreezeGame("giantbook")
        --if sound exists, play it
        if _soundName then
            sfx:Play(_soundName, 0.8, 0, false, 1)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if bookLength > 0 and mod.global.isPaused and not game:IsPaused() and pausedKey == "giantbook" then
        bigBook:Update()
        bookLength = bookLength - 1

        for _, entity in pairs(Isaac.GetRoomEntities()) do
            local sprite = entity:GetSprite()
            if sprite:IsPlaying(sprite:GetAnimation()) then
                sprite:SetFrame(math.max(sprite:GetFrame() - 1, 0))
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if bookLength > 0 and mod.global.isPaused and pausedKey == "giantbook" then
        for i = 5, 0, -1 do
            bigBook.Color = bookColors[i]
            bigBook:RenderLayer(i, GetScreenCenter(), Vector.Zero, Vector.Zero)
        end
    else
        UnfreezeGame("giantbook")
    end
end)

--ACHIEVEMENT DISPLAY
local achievementQueue = {}
local bigPaper = Sprite()
local paperFrames = 0
local paperSwitch = false

mod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    if paperFrames > 0 and mod.global.isPaused and not game:IsPaused() and pausedKey == "achievement" then
        bigPaper:Update()
        paperFrames = paperFrames - 1
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if paperFrames <= 0 then
        if paperSwitch then
            for i = 1, #achievementQueue - 1 do
                achievementQueue[i] = achievementQueue[i + 1]
            end
            achievementQueue[#achievementQueue] = nil
            paperSwitch = false
        end

        if not paperSwitch and #achievementQueue > 0 then
            bigPaper:Load("gfx/ui/achievements/achievement.anm2", true)
            bigPaper:ReplaceSpritesheet(2, "gfx/ui/achievements/" .. achievementQueue[1])
            bigPaper:LoadGraphics()
            bigPaper:Play("Idle", true)
            --set variables and pause
            paperFrames = 41
            paperSwitch = true
            FreezeGame("achievement")
        else
            UnfreezeGame("achievement")
        end
    else
        for i = 0, 3 do
            bigPaper:RenderLayer(i, GetScreenCenter(), Vector.Zero, Vector.Zero)
        end

        if bigPaper:IsEventTriggered("paperIn") then
            sfx:Play(SoundEffect.SOUND_PAPER_IN, 1, 0, false, 1)
        end
        if bigPaper:IsEventTriggered("paperOut") then
            sfx:Play(SoundEffect.SOUND_PAPER_OUT, 1, 0, false, 1)
        end
    end
end)

function DukeHelpers.ShowAchievement(_drawingSprite)
    table.insert(achievementQueue, #achievementQueue + 1, _drawingSprite)
end
