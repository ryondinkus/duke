local MenuName = "Duke - Beta"

local function isTableUnlocked(itemTable)
	for k, item in pairs(itemTable) do
		if not DukeHelpers.IsUnlocked(item.unlock) then
			return false
		end
		return true
	end
end

local function generateUnlockSetting(item, bossName, playerName)
	if DukeHelpers.IsArray(item) then
		ModConfigMenu.AddSetting(
			MenuName,
			"Unlocks",
			{
				Attribute = bossName,
				Type = ModConfigMenu.OptionType.BOOLEAN,
				CurrentSetting = function()
					return isTableUnlocked(item)
				end,
				Display = function()
					if not playerName then
						if isTableUnlocked(item) then
							return "Lock All"
						end
						return "Unlock All"
					else
						if isTableUnlocked(item) then
							return "Lock All for " .. playerName
						end
						return "Unlock All for " .. playerName
					end
				end,
				OnChange = function(currentBool)
					for k, i in pairs(item) do
						DukeHelpers.MCMUnlockToggle(i.unlock, currentBool)
					end
				end,
				Info = function ()
					if not playerName then
						return "Unlocks every unlock in the mod"
					end
					return "Unlocks all " .. playerName .. " unlocks"
				end
			}
		)
	else
		ModConfigMenu.AddSetting(
			MenuName,
			"Unlocks",
			{
				Attribute = bossName,
				Type = ModConfigMenu.OptionType.BOOLEAN,
				CurrentSetting = function()
					return DukeHelpers.IsUnlocked(item.unlock)
				end,
				Display = function()
					if DukeHelpers.IsUnlocked(item.unlock) then
						return bossName .. ": Unlocked"
					end
					return bossName .. ": Locked"
				end,
				OnChange = function(currentBool)
					DukeHelpers.MCMUnlockToggle(item.unlock, currentBool)
				end,
				Info = "Unlocks " .. item.Name .. ", for beating " .. bossName .. " as " .. playerName
			}
		)
	end
end

local function getItemVariant(item)
	if DukeHelpers.CountOccurencesInTable(DukeHelpers.Items, item) > 0 then
		return PickupVariant.PICKUP_COLLECTIBLE
	elseif DukeHelpers.CountOccurencesInTable(DukeHelpers.Trinkets, item) > 0 then
		return PickupVariant.PICKUP_TRINKET
	elseif DukeHelpers.CountOccurencesInTable(DukeHelpers.Cards, item) > 0 then
		return PickupVariant.PICKUP_TAROTCARD
	elseif item.Name == "Fly Hearts" then
		return PickupVariant.PICKUP_HEART
	else return nil end
end

local function generateSpawnItemSetting(item)
	ModConfigMenu.AddSetting(
		MenuName,
		"Spawn Item",
		{
			Attribute = bossName,
			Type = ModConfigMenu.OptionType.BOOLEAN,
			CurrentSetting = function()
				return false
			end,
			Display = function()
				return item.Name
			end,
			OnChange = function(currentBool)
				if currentBool then
					local room = Game():GetRoom()
					Isaac.Spawn(EntityType.ENTITY_PICKUP, getItemVariant(item), item.Id,
						room:FindFreePickupSpawnPosition(room:GetCenterPos()), Vector.Zero, nil)
					currentBool = false
				end
			end,
			Info = "Spawn " .. item.Name
		}
	)
end

function DukeHelpers.InitializeMCM(defaultMcmOptions)
	if not dukeMod.mcmOptions then
		dukeMod.mcmOptions = table.deepCopy(defaultMcmOptions)
	else
		for key, value in pairs(defaultMcmOptions) do
			if not dukeMod.mcmOptions[key] then
				dukeMod.mcmOptions[key] = value
			end
		end
	end
	local mcmOptions = dukeMod.mcmOptions

	dukeUnlocks = { DukeHelpers.Items.othersGullet,
					DukeHelpers.Trinkets.dukesTooth,
					DukeHelpers.Trinkets.infestedHeart,
					DukeHelpers.Trinkets.pocketOfFlies,
					DukeHelpers.Items.thePrinces,
					DukeHelpers.Items.ultraHeartFly,
					DukeHelpers.Items.lilDuke,
					DukeHelpers.Items.superInfestation,
					DukeHelpers.Items.dukeFlute,
					DukeHelpers.Items.fiendishSwarm,
					DukeHelpers.Items.queenFly,
					DukeHelpers.Cards.tapewormCard,
					DukeHelpers.Items.shartyMcFly,
					DukeHelpers.Items.dukeOfEyes }

	huskUnlocks = { DukeHelpers.Trinkets.mosquito,
					DukeHelpers.FlyHearts,
					DukeHelpers.Cards.soulOfDuke,
					DukeHelpers.Items.othersRottenGullet,
					DukeHelpers.Items.lilHusk,
					DukeHelpers.Items.theInvader,
					DukeHelpers.Cards.redTapewormCard }

	if ModConfigMenu then
		generateUnlockSetting(DukeHelpers.CombineArrays(dukeUnlocks, huskUnlocks))
		ModConfigMenu.AddSpace(MenuName, "Unlocks")

		ModConfigMenu.AddTitle(MenuName, "Unlocks", "Duke")
		generateUnlockSetting(dukeUnlocks, nil, "Duke")
		generateUnlockSetting(dukeUnlocks[1], "Mom's Heart", "Duke")
		generateUnlockSetting(dukeUnlocks[2], "Isaac", "Duke")
		generateUnlockSetting(dukeUnlocks[3], "Satan", "Duke")
		generateUnlockSetting(dukeUnlocks[4], "???", "Duke")
		generateUnlockSetting(dukeUnlocks[5], "The Lamb", "Duke")
		generateUnlockSetting(dukeUnlocks[6], "Mega Satan", "Duke")
		generateUnlockSetting(dukeUnlocks[7], "Boss Rush", "Duke")
		generateUnlockSetting(dukeUnlocks[8], "Hush", "Duke")
		generateUnlockSetting(dukeUnlocks[9], "Delirium", "Duke")
		generateUnlockSetting(dukeUnlocks[10], "Mother", "Duke")
		generateUnlockSetting(dukeUnlocks[11], "The Beast", "Duke")
		generateUnlockSetting(dukeUnlocks[12], "Ultra Greed", "Duke")
		generateUnlockSetting(dukeUnlocks[13], "Ultra Greedier", "Duke")
		generateUnlockSetting(dukeUnlocks[14], "all Hard Mode Marks", "Duke")
		ModConfigMenu.AddSpace(MenuName, "Unlocks")

		ModConfigMenu.AddTitle(MenuName, "Unlocks", "Tainted Duke")
		generateUnlockSetting(huskUnlocks, nil, "Tainted Duke")
		generateUnlockSetting(huskUnlocks[1], "Isaac, Satan, ???, and The Lamb", "Tainted Duke")
		generateUnlockSetting(huskUnlocks[2], "Mega Satan", "Tainted Duke")
		generateUnlockSetting(huskUnlocks[3], "Boss Rush and Hush", "Tainted Duke")
		generateUnlockSetting(huskUnlocks[4], "Delirium", "Tainted Duke")
		generateUnlockSetting(huskUnlocks[5], "Mother", "Tainted Duke")
		generateUnlockSetting(huskUnlocks[6], "The Beast", "Tainted Duke")
		generateUnlockSetting(huskUnlocks[7], "Ultra Greedier", "Tainted Duke")

		ModConfigMenu.AddText(MenuName, "Spawn Item", "Use this menu to spawn items, trinkets,")
		ModConfigMenu.AddText(MenuName, "Spawn Item", "and cards that are new to this mod.")
		ModConfigMenu.AddSpace(MenuName, "Spawn Item")
		ModConfigMenu.AddText(MenuName, "Spawn Item", "NOTE: You must have the unlocks")
		ModConfigMenu.AddText(MenuName, "Spawn Item", "unlocked to properly spawn the item!")
		ModConfigMenu.AddSpace(MenuName, "Spawn Item")

		for k,v in pairs(dukeUnlocks) do
			generateSpawnItemSetting(v)
		end

		for k,v in pairs(huskUnlocks) do
			generateSpawnItemSetting(v)
		end
	end
end
