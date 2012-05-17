-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2011.07.06					---
--- Version: 0.7 [2012.05.18]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/hideraidframe
--- WoWInterface	http://www.wowinterface.com/downloads/info20052-HideRaidFrame.html

local NAME, S = ...
local VERSION = 0.7
local BUILD = "Release"

local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local L = S.L

local db
local pendingReload

local function ToggleAddOn(v)
	local f = v and EnableAddOn or DisableAddOn
	f("Blizzard_CompactRaidFrames")
	f("Blizzard_CUFProfiles")
end

	---------------
	--- Options ---
	---------------

local options = {
	type = "group",
	name = format("%s |cffADFF2Fv%s|r", NAME, VERSION),
	args = {
		inline1 = {
			type = "group", order = 1,
			name = " ",
			inline = true,
			handler = HRF,
			get = function(i)
				return db[i[#i]]
			end,
			set = function(i, v)
				db[i[#i]] = v
				pendingReload = true
				ToggleAddOn(db.Manager or db.Container)
			end,
			args = {
				Manager = {
					type = "toggle", order = 1,
					width = "full", descStyle = "",
					name = " "..L.RAID_MANAGER,
				},
				Container = {
					type = "toggle", order = 2,
					width = "full", descStyle = "",
					name = " "..L.RAID_CONTAINER,
				},
			},
		},
		Reload = {
			type = "execute", order = 2,
			descStyle = "",
			name = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:-2|t"..SLASH_RELOAD1,
			func = ReloadUI,
			hidden = function() return not pendingReload end,
		},
	},
}

	----------------------
	--- Initialization ---
	----------------------

local f = CreateFrame("Frame")

function f:OnEvent(event, ...)
	local addon = ...
	
	if addon == NAME then
		HideRaidFrameDB3 = HideRaidFrameDB3 or {}
		db = HideRaidFrameDB3
		db.version = VERSION
		
		ACR:RegisterOptionsTable(NAME, options)
		ACD:AddToBlizOptions(NAME, NAME)
		ACD:SetDefaultSize(NAME, 300, 200)
		
		if IsAddOnLoaded("Blizzard_CompactRaidFrames") then
			
			-- InCombatLockdown does not readily seem to return the correct value though
			if InCombatLockdown() then print(format("|cff33FF99%s:|r %s", NAME, ERR_NOT_IN_COMBAT)) return end
			
			-- CompactRaidFrameManager is parented to UIParent
			-- CompactRaidFrameContainer is parented to CompactRaidFrameManager
			-- Bug: Container will still be shown when solo, after leaving a raid
			CompactRaidFrameContainer:SetParent(UIParent)
			
			if not db.Manager then
				CompactRaidFrameManager:UnregisterAllEvents()
				CompactRaidFrameManager.Show = function() end
				CompactRaidFrameManager:Hide()
			end
			if not db.Container then
				CompactRaidFrameContainer:UnregisterAllEvents()
				CompactRaidFrameContainer.Show = function() end
				CompactRaidFrameContainer:Hide()
			end
		end
		
		ToggleAddOn(db.Manager or db.Container)
		self:UnregisterEvent("ADDON_LOADED")
	end
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

	---------------------
	--- Slash Command ---
	---------------------

local slashCmds = {"hr", "hrf", "hideraid", "hideraidframe"}

for i, v in ipairs(slashCmds) do
	_G["SLASH_HIDERAIDFRAME"..i] = "/"..v
end

SlashCmdList.HIDERAIDFRAME = function(msg, editbox)
	ACD:Open(NAME)
end
