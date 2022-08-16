local MenuName = "Duke - Beta"

function isTableUnlocked(itemTable)
	for k, item in pairs(itemTable) do
		if not DukeHelpers.IsUnlocked(item.unlock) then
			return false
		end
		return true
	end
end

function generateUnlockSetting(item, bossName, playerName)
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
				Info = "Unlocks all " .. playerName .. " unlocks"
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

	local unlocks = {
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
	}

	if ModConfigMenu then
		generateUnlockSetting(unlocks)

		ModConfigMenu.AddText(MenuName, "Unlocks", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks, nil, "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[1], "Mom's Heart", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[2], "Isaac", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[3], "Satan", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[4], "???", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[5], "The Lamb", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[6], "Mega Satan", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[7], "Boss Rush", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[8], "Hush", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[9], "Delirium", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[10], "Mother", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[11], "The Beast", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[12], "Ultra Greed", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[13], "Ultra Greedier", "Duke")
		generateUnlockSetting(unlocks.dukeUnlocks[14], "all Hard Mode Marks", "Duke")

		ModConfigMenu.AddText(MenuName, "Unlocks", "Tainted Duke")
		generateUnlockSetting(unlocks.huskUnlocks, nil, "Tainted Duke")
		generateUnlockSetting(unlocks.huskUnlocks[1], "Isaac, Satan, ???, and The Lamb", "Tainted Duke")
		generateUnlockSetting(unlocks.huskUnlocks[2], "Mega Satan", "Tainted Duke")
		generateUnlockSetting(unlocks.huskUnlocks[3], "Boss Rush and Hush", "Tainted Duke")
		generateUnlockSetting(unlocks.huskUnlocks[4], "Delirium", "Tainted Duke")
		generateUnlockSetting(unlocks.huskUnlocks[5], "Mother", "Tainted Duke")
		generateUnlockSetting(unlocks.huskUnlocks[6], "The Beast", "Tainted Duke")
		generateUnlockSetting(unlocks.huskUnlocks[7], "Ultra Greedier", "Tainted Duke")
	end
end
