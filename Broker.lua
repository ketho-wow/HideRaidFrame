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
		if ACD.OpenFrames["HideRaidFrame_Main"] then
			ACD:Close("HideRaidFrame_Main")
		else
			ACD:Open("HideRaidFrame_Main")
		end
	end,
	OnTooltipShow = function(tt)
		tt:AddLine("|cffFFFFFF"..NAME.."|r")
		tt:AddLine(L.BROKER_CLICK)
		tt:AddLine(L.BROKER_SHIFT_CLICK)
	end,
}

LibStub("LibDataBroker-1.1"):NewDataObject(NAME, dataobject)
