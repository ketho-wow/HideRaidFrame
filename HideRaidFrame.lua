-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2011.07.06					---
--- Version: 1.0 [2012.10.08]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/hideraidframe
--- WoWInterface	http://www.wowinterface.com/downloads/info20052-HideRaidFrame.html

local NAME, S = ...
local VERSION = "1.0"
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
		
		-- abort when in combat
		-- InCombatLockdown does not readily seem to return the correct value though
		if InCombatLockdown() or UnitAffectingCombat("player") then
			local old = SetItemRef
			
			function SetItemRef(...)
				local link = ...
				if link == "reload" then
					if not InCombatLockdown() then
						ReloadUI()
					end
				else
					old(...)
				end
			end
			
			print(format("|cff33FF99%s:|r |cffFF0000%s.|r |cffFF8040|Hreload|h[%s]|h|r", NAME, ERR_NOT_IN_COMBAT, SLASH_RELOAD1))
			return
		end
		
		-- CompactRaidFrameManager is parented to UIParent
		-- CompactRaidFrameContainer is parented to CompactRaidFrameManager
		-- bug: Container (if enabled) will still be shown when solo, after leaving a raid
		if db.Container then
			CompactRaidFrameContainer:SetParent(UIParent)
		end
		
		for _, v in ipairs(frames) do
			if not db[v] then
				local f = _G["CompactRaidFrame"..v]
				f:UnregisterAllEvents()
				f.Show = function() end
				f:Hide()
			end
		end
		
		-- yes I'm a noob with libraries >.<
		if not FixRaidTaint then
			local container = CompactRaidFrameContainer
			
			local t = {
				discrete = "flush",
				flush = "discrete",
			}
			
			-- refresh the (tainted) raid frames after combat
			local function OnEvent(self)
				-- secure or still in combat somehow
				if issecurevariable("CompactRaidFrame1") or InCombatLockdown() or not container:IsShown() then return end
				
				-- Bug #1: left/joined players not updated
				-- Bug #2: sometimes selecting different than the intended target
				
				-- change back and forth from flush <-> discrete
				local mode = container.groupMode -- groupMode changes after _SetGroupMode calls
				CompactRaidFrameContainer_SetGroupMode(container, t[mode]) -- forth
				CompactRaidFrameContainer_SetGroupMode(container, mode) -- back
			end
			
			local g = CreateFrame("Frame", "FixRaidTaint")
			g:RegisterEvent("PLAYER_REGEN_ENABLED")
			g:SetScript("OnEvent", OnEvent)
			
			g.version = 0.2
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

for i, v in ipairs({"hr", "hrf", "hideraid", "hideraidframe"}) do
	_G["SLASH_HIDERAIDFRAME"..i] = "/"..v
end

SlashCmdList.HIDERAIDFRAME = function(msg, editbox)
	ACD:Open(NAME)
end
