-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2011.07.06					---
--- Version: 1.3 [2014.04.28]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/hideraidframe
--- WoWInterface	http://www.wowinterface.com/downloads/info20052-HideRaidFrame.html

local NAME, S = ...
local VERSION = GetAddOnMetadata(NAME, "Version")
local BUILD = "Release"

-- since patch 4.2 Blizzard_CompactRaidFrames actually anchors PartyMemberFrame1
-- (see PartyFrame.xml and Blizzard_CompactRaidFrameManager.lua)
if not PartyMemberFrame1:GetPoint() then
	PartyMemberFrame1:SetPoint("TOPLEFT", 10, -160)
end

local function ToggleAddOn(v)
	local f = v and EnableAddOn or DisableAddOn
	f("Blizzard_CompactRaidFrames")
	f("Blizzard_CUFProfiles")
end

local ACR, ACD
if LibStub then
	ACR = LibStub("AceConfigRegistry-3.0", true)
	ACD = LibStub("AceConfigDialog-3.0", true)
end

-- avoid getting blamed for taint, even from embedding Ace3
-- this depends on another previously loaded addon with Ace3 embedded or the Ace3 standalone
-- hope there wont be that much ppl affected that want the toggle functionality
if not ACR or not ACD then
	ToggleAddOn(false)
	return
end

	---------------
	--- Options ---
	---------------

local db, pendingReload

local options = {
	type = "group",
	name = format("%s |cffADFF2Fv%s|r", NAME, VERSION),
	args = {
		RaidFrames = {
			type = "toggle", order = 1,
			name = " "..RAID_FRAMES_LABEL,
			get = function(i) return db.RaidFrames end,
			set = function(i, v)
				db.RaidFrames = v
				ToggleAddOn(v)
				pendingReload = (v ~= IsAddOnLoaded("Blizzard_CompactRaidFrames"))
			end,
		},
		Reload = {
			type = "execute", order = 2, descStyle = "",
			name = SLASH_RELOAD1,
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
	
	-- database
	HideRaidFrameDB4 = HideRaidFrameDB4 or {}
	db = HideRaidFrameDB4
	db.version = VERSION
	db.build = BUILD
	db.RaidFrames = db.RaidFrames or false -- nil to false for reload checks
	
	-- options menu
	ACR:RegisterOptionsTable(NAME, options)
	ACD:AddToBlizOptions(NAME, NAME)
	ACD:SetDefaultSize(NAME, 250, 125)
	
	-- require reload
	if db.RaidFrames ~= IsAddOnLoaded("Blizzard_CompactRaidFrames") then
		local old = SetItemRef
		
		function SetItemRef(...)
			local link = ...
			if link == "reload" then
				ReloadUI()
			else
				old(...)
			end
		end
		
		print(format("|cff33FF99%s:|r |cffFF8040|Hreload|h[%s]|h|r", NAME, SLASH_RELOAD1))
	end
	
	ToggleAddOn(db.RaidFrames)
	self:UnregisterEvent(event)
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
		tt:AddLine(S.L.BROKER_CLICK)
	end,
}

local LDB = LibStub("LibDataBroker-1.1", true)
if LDB then
	LDB:NewDataObject(NAME, dataobject)
end
