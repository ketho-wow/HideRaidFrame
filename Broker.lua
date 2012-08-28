local NAME, S = ...
local L = S.L
local ACD = LibStub("AceConfigDialog-3.0")

	---------------------
	--- LibDataBroker ---
	---------------------

local dataobject = {
	type = "launcher",
	icon = "Interface\\Icons\\Ability_Stealth",
	text = NAME,
	OnClick = function(clickedframe, button)
		ACD[ACD.OpenFrames[NAME] and "Close" or "Open"](ACD, NAME)
	end,
	OnTooltipShow = function(tt)
		tt:AddLine("|cffADFF2F"..NAME.."|r")
		tt:AddLine(L.BROKER_CLICK)
	end,
}

LibStub("LibDataBroker-1.1"):NewDataObject(NAME, dataobject)
