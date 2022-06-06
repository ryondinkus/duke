-- Add flies on player startup
dukeMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
	if dukeMod.global.isInitialized and DukeHelpers.IsHusk(player) and (not player:GetData().duke or not player:GetData().duke.isInitialized) then
		DukeHelpers.InitializeHusk(player)
		DukeHelpers.AddStartupSpiders(player)
	end
end)

-- Allows the player to fly
dukeMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, p, f)
	if DukeHelpers.IsHusk(p) then
		p.CanFly = true
	end
end, CacheFlag.CACHE_FLYING)

function DukeHelpers.IsHusk(player)
	return DukeHelpers.IsDuke(player, true)
end

function DukeHelpers.InitializeHusk(p, continued)
	local dukeData = DukeHelpers.GetDukeData(p)
	local sprite = p:GetSprite()
	sprite:Load("gfx/characters/duke_b.anm2", true)
	if not continued then
		p:SetPocketActiveItem(DukeHelpers.Items.rottenGullet.Id)
		Game():GetItemPool():RemoveCollectible(DukeHelpers.Items.othersRottenGullet.Id)
		p:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/character_duke_b_scars.anm2"))
	end
	dukeData.isInitialized = true
end

function DukeHelpers.AddStartupSpiders(player)
	DukeHelpers.SpawnSpidersFromPickupSubType(HeartSubType.HEART_FULL, player.Position, player, 2)
end
