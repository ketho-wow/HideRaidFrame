-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2011.07.06					---
--- Version: 0.9 [2012.08.28]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/hideraidframe
--- WoWInterface	http://www.wowinterface.com/downloads/info20052-HideRaidFrame.html

local NAME, S = ...
local VERSION = 0.9
local BUILD = "Release"

local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local L = S.L

local db
local pendingReload

local function ToggleAddOn(v)
	local f = (v or not db.HardDisable) and EnableAddOn or DisableAddOn
	f("Blizzard_CompactRaidFrames")
	f("Blizzard_CUFProfiles")
end

local frames = {"Manager", "Container"}

	---------------
	--- Options ---
	---------------

local options = {
	type = "group",
	name = format("%s |cffADFF2Fv%s|r", NAME, VERSION),
	get = function(i)
		return db[i[#i]]
	end,
	set = function(i, v)
		db[i[#i]] = v
		if db.Manager or db.Container then
			db.HardDisable = false
		end
		pendingReload = true
		ToggleAddOn(db.Manager or db.Container)
	end,
	args = {
		inline1 = {
			type = "group", order = 1,
			name = " ",
			inline = true,
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
		HardDisable = {
			type = "toggle", order = 2,
			desc = L.HARD_DISABLE_DESC,
			name = L.HARD_DISABLE,
			disabled = function() return db.Manager or db.Container end,
		},
		Reload = {
			type = "execute", order = 3,
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

function f:OnEvent(event, addon)
	if addon ~= NAME then return end
	
	HideRaidFrameDB3 = HideRaidFrameDB3 or {}
	db = HideRaidFrameDB3
	db.version = VERSION
	
	ACR:RegisterOptionsTable(NAME, options)
	ACD:AddToBlizOptions(NAME, NAME)
	ACD:SetDefaultSize(NAME, 380, 200)
	
	if IsAddOnLoaded("Blizzard_CompactRaidFrames") then
		
		-- InCombatLockdown does not readily seem to return the correct value though
		if InCombatLockdown() then print(format("|cff33FF99%s:|r %s", NAME, ERR_NOT_IN_COMBAT)) return end
		
		-- CompactRaidFrameManager is parented to UIParent
		-- CompactRaidFrameContainer is parented to CompactRaidFrameManager
		-- bug: Container (if enabled) will still be shown when solo, after leaving a raid
		CompactRaidFrameContainer:SetParent(UIParent)
		
		for _, v in ipairs(frames) do
			if not db[v] then
				local f = _G["CompactRaidFrame"..v]
				f:UnregisterAllEvents()
				f.Show = function() end
				f:Hide()
			end
		end
	end
	
	ToggleAddOn(db.Manager or db.Container)
	self:UnregisterEvent("ADDON_LOADED")
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
