-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2011.07.06					---
--- Version: 1.6 [2015.09.04]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/hideraidframe
--- WoWInterface	http://www.wowinterface.com/downloads/info20052-HideRaidFrame.html

local NAME, S = ...
local VERSION = GetAddOnMetadata(NAME, "Version")
local BUILD = "Release"

local db
local state = IsAddOnLoaded("Blizzard_CompactRaidFrames")

-- since patch 4.2 Blizzard_CompactRaidFrames actually anchors PartyMemberFrame1
-- (see PartyFrame.xml and Blizzard_CompactRaidFrameManager.lua)
if not PartyMemberFrame1:GetPoint() then
	PartyMemberFrame1:SetPoint("TOPLEFT", 10, -160)
end

local function ToggleAddOn(v)
	db.RaidFrames = v
	local f = v and EnableAddOn or DisableAddOn
	f("Blizzard_CompactRaidFrames")
	f("Blizzard_CUFProfiles")
end

-- Slash Command
for i, v in ipairs({"hr", "hrf", "hideraid", "hideraidframe"}) do
	_G["SLASH_HIDERAIDFRAME"..i] = "/"..v
end

SlashCmdList.HIDERAIDFRAME = function(msg, editbox)
	ToggleAddOn(not state)
	db.msg = true
	ReloadUI()
end

	----------------------
	--- Initialization ---
	----------------------

local f = CreateFrame("Frame")

function f:OnEvent(event, addon)
	if addon ~= NAME then return end
	
	-- database
	HideRaidFrameDB4 = HideRaidFrameDB4 or {}
	db = HideRaidFrameDB4
	db.version = VERSION
	db.build = BUILD
	db.RaidFrames = db.RaidFrames or false -- nil to false for reload checks
	
	-- require reload
	if db.RaidFrames ~= state then
		local old = SetItemRef
		
		function SetItemRef(...)
			local link = ...
			if link == "reload" then
				db.msg = true
				ReloadUI()
			else
				old(...)
			end
		end
		
		print(format("|cff33FF99%s:|r |cffFF8040|Hreload|h[%s]|h|r", NAME, SLASH_RELOAD1))
	end
	
	if db.msg then
		msgstate = state and "|cffADFF2F"..VIDEO_OPTIONS_ENABLED.."|r" or "|cffFF2424"..VIDEO_OPTIONS_DISABLED.."|r"
		print(format("|cff33FF99%s|r has %s the Blizzard |cff33FF99%s|r", NAME, msgstate, RAID_FRAMES_LABEL))
		db.msg = false
	end
	
	ToggleAddOn(db.RaidFrames)
	self:UnregisterEvent(event)
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", f.OnEvent)

	---------------------
	--- LibDataBroker ---
	---------------------

local dataobject = {
	type = "launcher",
	icon = "Interface\\Icons\\Ability_Stealth",
	text = NAME,
	OnClick = function(clickedframe, button)
		if IsModifierKeyDown() then
			SlashCmdList.HIDERAIDFRAME()
		end
	end,
	OnTooltipShow = function(tt)
		tt:AddLine("|cffADFF2F"..NAME.."|r")
		tt:AddLine(S.L.BROKER_SHIFT_CLICK)
	end,
}

local LDB = LibStub("LibDataBroker-1.1", true)
if LDB then
	LDB:NewDataObject(NAME, dataobject)
end
