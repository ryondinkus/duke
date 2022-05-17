local sfx = SFXManager()
--GIANTBOOK ANIMATION
local bigBook = Sprite()
local maxFrames = { ["Appear"] = 33, ["Shake"] = 36, ["ShakeFire"] = 32, ["Flip"] = 33 }
local bookColors = { [0] = Color(1, 1, 1, 1, 0, 0, 0), [1] = Color(1, 1, 1, 1, 0, 0, 0), [2] = Color(1, 1, 1, 1, 0, 0, 0), [3] = Color(1, 1, 1, 1, 0, 0, 0), [4] = Color(1, 1, 1, 1, 0, 0, 0), [5] = Color(1, 1, 1, 1, 0, 0, 0) }
local bookLength = 0
local bookHideBerkano = false

local function doBerkanoPause()
	Isaac.GetPlayer(0):UseCard(Card.RUNE_BERKANO, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	for _, bluefly in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, -1, false, false)) do
		if bluefly:Exists() and bluefly.FrameCount <= 0 then
			bluefly:Remove()
		end
	end
	for _, bluespider in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER, -1, false, false)) do
		if bluespider:Exists() and bluespider.FrameCount <= 0 then
			bluespider:Remove()
		end
	end
end

DukeGiantBookAPI = {}

function DukeGiantBookAPI.playGiantBook(_animName, _popup, _poofColor, _bgColor, _poof2Color, _soundName, _notHide)
	bigBook:Load("gfx/ui/giantbook/giantbook.anm2", true)
	bigBook:ReplaceSpritesheet(0, "gfx/ui/giantbook/" .. _popup)
	bigBook:LoadGraphics()
	bigBook:Play(_animName, true)
	bookLength = maxFrames[_animName]
	bookColors[1] = _bgColor
	bookColors[2] = _poofColor
	bookColors[3] = _poofColor
	bookColors[4] = _poof2Color
	bookHideBerkano = true
	if not _notHide then
		doBerkanoPause()
		if (_soundName) then
			sfx:Play(_soundName, 0.8, 0, false, 1)
		end
	end
end

function DukeGiantBookAPI.playDukeGiantBook(_animName, _popup, _gfxRoot, _poofColor, _bgColor, _poof2Color, _soundName, _notHide)
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
	bookHideBerkano = true
	if not _notHide then
		doBerkanoPause()
		if (_soundName) then
			sfx:Play(_soundName, 0.8, 0, false, 1)
		end
	end
end

function DukeGiantBookAPI.bookRender()
	if bookLength > 0 then
		if (Isaac.GetFrameCount() % 2 == 0) then
			bigBook:Update()
			bookLength = bookLength - 1
		end
		for i = 5, 0, -1 do
			bigBook.Color = bookColors[i]
			bigBook:RenderLayer(i, GetScreenCenterPosition(), Vector(0, 0), Vector(0, 0))
		end
	end
	if bookLength == 0 and bookHideBerkano then
		bookHideBerkano = false
	end
end

dukeMod:AddCallback(ModCallbacks.MC_POST_RENDER, DukeGiantBookAPI.bookRender)

function GetScreenCenterPosition()
	return Vector(Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() / 2)
end

--giving berkano back it's visual effect
function DukeGiantBookAPI:useBerkano()
	if not bookHideBerkano then
		DukeGiantBookAPI.playGiantBook("Appear", "Rune_07_Berkand.png", Color(0.2, 0.1, 0.3, 1, 0, 0, 0), Color(0.117, 0.0117, 0.2, 1, 0, 0, 0), Color(0, 0, 0, 0.8, 0, 0, 0), nil, true)
	end
end

dukeMod:AddCallback(ModCallbacks.MC_USE_CARD, DukeGiantBookAPI.useBerkano, Card.RUNE_BERKANO)

--ACHIEVEMENT DISPLAY
local achievementQueue = {}
local bigPaper = Sprite()
local paperFrames = 0
local paperSwitch = false

function DukeGiantBookAPI.paperRender()
	if (paperFrames <= 0) then
		if paperSwitch then
			for i = 1, #achievementQueue - 1 do
				achievementQueue[i] = achievementQueue[i + 1]
			end
			achievementQueue[#achievementQueue] = nil
			paperSwitch = false
		end
		if (not paperSwitch) and (#achievementQueue > 0) then
			bigPaper:Load("gfx/ui/achievements/achievement.anm2", true)
			bigPaper:ReplaceSpritesheet(2, "gfx/ui/achievements/" .. achievementQueue[1])
			bigPaper:LoadGraphics()
			bigPaper:Play("Idle", true)
			paperFrames = 41
			paperSwitch = true
			bookHideBerkano = true
			doBerkanoPause()
		end
	else
		if (Isaac.GetFrameCount() % 2 == 0) then
			bigPaper:Update()
			paperFrames = paperFrames - 1
		end
		for i = 0, 3, 1 do
			bigPaper:RenderLayer(i, GetScreenCenterPosition(), Vector(0, 0), Vector(0, 0))
		end
	end

	--sound
	if bigPaper:IsEventTriggered("paperIn") then
		sfx:Play(SoundEffect.SOUND_PAPER_IN, 1, 0, false, 1)
	end
	if bigPaper:IsEventTriggered("paperOut") then
		sfx:Play(SoundEffect.SOUND_PAPER_OUT, 1, 0, false, 1)
	end
end

dukeMod:AddCallback(ModCallbacks.MC_POST_RENDER, DukeGiantBookAPI.paperRender)

function DukeGiantBookAPI.ShowAchievement(_drawingSprite)
	table.insert(achievementQueue, #achievementQueue + 1, _drawingSprite)
end
