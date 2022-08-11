local MenuName = "Duke - Beta"

function generateUnlockSetting(item, bossName, playerName)
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
				return bossName + ": Locked"
			end,
			OnChange = function(currentBool)
				DukeHelpers.MCMUnlockToggle(item.unlock, currentBool)
			end,
			Info = "Unlocks " .. item.Name .. ", for beating " .. bossName .. " as " .. playerName
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
	if ModConfigMenu then
		ModConfigMenu.AddText(MenuName, "Unlocks", "Duke")
		generateUnlockSetting(DukeHelpers.Items.othersGullet, "Mom's Heart", "Duke")
		generateUnlockSetting(DukeHelpers.Trinkets.dukesTooth, "Isaac", "Duke")
		generateUnlockSetting(DukeHelpers.Trinkets.infestedHeart, "Satan", "Duke")
		generateUnlockSetting(DukeHelpers.Trinkets.pocketOfFlies, "???", "Duke")
		generateUnlockSetting(DukeHelpers.Items.thePrinces, "The Lamb", "Duke")
		generateUnlockSetting(DukeHelpers.Items.ultraHeartFly, "Mega Satan", "Duke")
		generateUnlockSetting(DukeHelpers.Items.lilDuke, "Boss Rush", "Duke")
		generateUnlockSetting(DukeHelpers.Items.superInfestation, "Hush", "Duke")
		generateUnlockSetting(DukeHelpers.Items.dukeFlute, "Delirium", "Duke")
		generateUnlockSetting(DukeHelpers.Items.fiendishSwarm, "Mother", "Duke")
		generateUnlockSetting(DukeHelpers.Items.queenFly, "The Beast", "Duke")
		generateUnlockSetting(DukeHelpers.Cards.tapewormCard, "Ultra Greed", "Duke")
		generateUnlockSetting(DukeHelpers.Items.shartyMcFly, "Ultra Greedier", "Duke")
	end
end
