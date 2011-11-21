-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2011.07.06					---
--- Version: 0.4 [2011.11.21]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/hideraidframe
--- WoWInterface	http://www.wowinterface.com/downloads/info20052-HideRaidFrame.html

-- I wish I could do just this, like all the other addons
--[[
CompactRaidFrameManager:UnregisterAllEvents()
CompactRaidFrameManager.Show = function() end
CompactRaidFrameManager:Hide()
CompactRaidFrameContainer:UnregisterAllEvents()
CompactRaidFrameContainer.Show = function() end
CompactRaidFrameContainer:Hide()
]]

local VERSION = 0.4
local NAME = "HideRaidFrame"

HideRaidFrame = LibStub("AceAddon-3.0"):NewAddon(NAME, "AceEvent-3.0", "AceTimer-3.0", "AceConsole-3.0")
local HRF = HideRaidFrame

local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("HideRaidFrame", true)

local profile
local delayRaidManager, delayRaidContainer

local _G = _G
local CompactRaidFrameManager = _G.CompactRaidFrameManager
local CompactRaidFrameContainer = _G.CompactRaidFrameContainer

-- CompactRaidFrameManager is parented to UIParent
-- CompactRaidFrameContainer is parented to CompactRaidFrameManager
CompactRaidFrameContainer:SetParent(UIParent)

	--------------------------
	---- Raid Frame Events ---
	--------------------------

local CRFM_Events = {
	"DISPLAY_SIZE_CHANGED",
	"UI_SCALE_CHANGED",
	"RAID_ROSTER_UPDATE",
	"UNIT_FLAGS",
	"PLAYER_FLAGS_CHANGED",
	"PLAYER_ENTERING_WORLD",
	"PARTY_LEADER_CHANGED",
	"RAID_TARGET_UPDATE",
	"PLAYER_TARGET_CHANGED",
	"PARTY_MEMBERS_CHANGED",
}

local CRFC_Events = {
	"RAID_ROSTER_UPDATE",
	"PARTY_MEMBERS_CHANGED",
	"UNIT_PET",
}

	-----------------
	---- Prehooks ---
	-----------------

local function IsRaidManager()
	return GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0 or profile.Solo
end

-- "Use Raid-Style Party Frames" option
local function IsRaidContainer()
	local numPartyMembers = GetNumPartyMembers()
	return GetNumRaidMembers() > 0 or (GetCVar("useCompactPartyFrames") == "1" and numPartyMembers > 0) or (numPartyMembers == 0 and profile.Solo)
end

-- this is to prevent InterfaceOptionsFrameCancel, and other stuff from showing/hiding it again
local oldCompactRaidFrameManager_Show = CompactRaidFrameManager.Show
function CompactRaidFrameManager:Show()
	if profile.RaidManager and IsRaidManager() then
		oldCompactRaidFrameManager_Show(self)
		--print("|cffFFFF00Raid|rManager: |cffB6CA00Show|r", profile.RaidManager)
	end
end

local oldCompactRaidFrameManager_Hide = CompactRaidFrameManager.Hide
function CompactRaidFrameManager:Hide()
	if not profile.RaidManager or not IsRaidManager() then
		oldCompactRaidFrameManager_Hide(self)
		--print("|cffFFFF00Raid|rManager: |cffFF2424Hide|r", profile.RaidManager)
	end
end

local oldCompactRaidFrameContainer_Show = CompactRaidFrameContainer.Show
function CompactRaidFrameContainer:Show()
	if profile.RaidContainer and IsRaidContainer() then
		oldCompactRaidFrameContainer_Show(self)
		--print("|cffFFFF00Raid|rContainer: |cffB6CA00Show|r", profile.RaidContainer)
	end
end

local oldCompactRaidFrameContainer_Hide = CompactRaidFrameContainer.Hide
function CompactRaidFrameContainer:Hide()
	if not profile.RaidContainer or not IsRaidContainer() then
		oldCompactRaidFrameContainer_Hide(self)
		--print("|cffFFFF00Raid|rContainer: |cffFF2424Hide|r", profile.RaidContainer)
	end
end

	--------------------
	---- Show / Hide ---
	--------------------

function HRF:RaidManager(show)
	if show and IsRaidManager() then
		for _, v in ipairs(CRFM_Events) do
			CompactRaidFrameManager:RegisterEvent(v)
		end
		CompactRaidFrameManager:Show()
		--print("|cffB6CA00Enabling|r: |cffFFFF00CompactRaidFrame|rManager")
	else
		CompactRaidFrameManager:UnregisterAllEvents()
		CompactRaidFrameManager:Hide()
		--print("|cffFF2424Disabling|r: |cffFFFF00CompactRaidFrame|rManager")
	end
end

function HRF:RaidContainer(show, isDelayed)
	if show and IsRaidContainer() then
		for _, v in ipairs(CRFC_Events) do
			CompactRaidFrameContainer:RegisterEvent(v)
		end
		CompactRaidFrameContainer:Show()
		-- this didn't seem to properly update, when "Use Raid-Style Party Frames" is disabled
		CompactRaidFrameContainer_OnEvent(CompactRaidFrameContainer, "PARTY_MEMBERS_CHANGED")
		--print("|cffB6CA00Enabling|r: |cffFFFF00CompactRaidFrame|rContainer")
	else
		CompactRaidFrameContainer:UnregisterAllEvents()
		CompactRaidFrameContainer:Hide()
		--print("|cffFF2424Disabling|r: |cffFFFF00CompactRaidFrame|rContainer")
	end
	-- hack: leaving a raid, is sometimes not yet updated in time
	if isDelayed then
		self:ScheduleTimer(function()
			self:RaidContainer(show)
		end, .5)
	end
end

	---------------
	--- Options ---
	---------------

local function WaitingCombat(bool)
	return bool and "  |cffFFFF00("..L["Waiting for Combat"]..")|r" or ""
end

local options = {
	type = "group",
	name = NAME.." |cffADFF2Fv"..VERSION.."|r",
	args = {
		inline = {
			type = "group",
			order = 1,
			name = " ",
			inline = true,
			args = {
				Manager = {
					type = "toggle",
					order = 1,
					descStyle = "",
					width = "full",
					name = function() return " "..L["Raid Manager"]..WaitingCombat(delayRaidManager) end,
					get = function(i) return profile.RaidManager end,
					set = function(i, v) profile.RaidManager = v
						if InCombatLockdown() then
							delayRaidManager = true
						else
							HRF:RaidManager(profile.RaidManager)
						end
					end,
				},
				Container = {
					order = 2,
					type = "toggle",
					descStyle = "",
					width = "full",
					name = function() return " "..L["Raid Container"]..WaitingCombat(delayRaidContainer) end,
					get = function(i) return profile.RaidContainer end,
					set = function(i, v) profile.RaidContainer = v
						if InCombatLockdown() then
							delayRaidContainer = true
						else
							HRF:RaidContainer(profile.RaidContainer)
						end
					end,
				},
			},
		},
		Solo = {
			type = "toggle",
			order = 2,
			descStyle = "",
			width = "full",
			name = function() return " |cff71D5FF"..SOLO.."|r" end,
			get = function(i) return profile.Solo end,
			set = function(i, v) profile.Solo = v
				if InCombatLockdown() then
					delayRaidManager, delayRaidContainer = true, true
				else
					HRF:RaidManager(profile.RaidManager)
					HRF:RaidContainer(profile.RaidContainer)
				end
			end,
			hidden = function()
				return not profile.RaidManager and not profile.RaidContainer
			end,
		},
	},
}

	----------------------
	--- Initialization ---
	----------------------

local optionsFrame

function HRF:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("HideRaidFrameDB2", nil, true)

	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
	self:RefreshConfig()

	self.db.global.version = VERSION
	self.db.global.fileType = "Release"

	ACR:RegisterOptionsTable("HideRaidFrame_Main", options)
	ACR:RegisterOptionsTable("HideRaidFrame_Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))

	optionsFrame = ACD:AddToBlizOptions("HideRaidFrame_Main", NAME)
	ACD:AddToBlizOptions("HideRaidFrame_Profiles", L["Profiles"], NAME)

	self:RegisterChatCommand("hr", "SlashCommand")
	self:RegisterChatCommand("hrf", "SlashCommand")
	self:RegisterChatCommand("hideraid", "SlashCommand")
	self:RegisterChatCommand("hideraidframe", "SlashCommand")

	-- show/hide based on configuration
	if InCombatLockdown() then
		delayRaidManager, delayRaidContainer = true, true
	else
		self:RaidManager(profile.RaidManager)
		self:RaidContainer(profile.RaidContainer)
	end
end

function HRF:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("CVAR_UPDATE")
end

function HRF:RefreshConfig()
	profile = self.db.profile
	if InCombatLockdown() then
		delayRaidManager, delayRaidContainer = true, true
	else
		self:RaidManager(profile.RaidManager)
		self:RaidContainer(profile.RaidContainer)
	end
end

function HRF:SlashCommand(input)
	InterfaceOptionsFrame_OpenToCategory(optionsFrame)
end

	---------------
	---- Events ---
	---------------

-- leaving combat
function HRF:PLAYER_REGEN_ENABLED()
	if delayRaidManager then
		self:RaidManager(profile.RaidManager)
	end
	if delayRaidContainer then
		self:RaidContainer(profile.RaidContainer)
	end
	delayRaidManager, delayRaidContainer = false, false
	if InterfaceOptionsFrame:IsShown() then
		ACR:NotifyChange("HideRaidFrame_Main")
	end
end

local cd = 0

-- check if player joins/leaves groups
function HRF:PARTY_MEMBERS_CHANGED()
	if time() > cd then
		cd = time() + .5
		if InCombatLockdown() then
			delayRaidManager, delayRaidContainer = true, true
		else
			self:RaidManager(profile.RaidManager)
			self:RaidContainer(profile.RaidContainer, true)
		end
	end
end

-- make sure stuff is updated when the "Use Raid-Style Party Frames" option is changed
function HRF:CVAR_UPDATE(event, cvar, val)
	if cvar == "USE_RAID_STYLE_PARTY_FRAMES" then
		CompactRaidFrameContainer_OnEvent(CompactRaidFrameContainer, "PARTY_MEMBERS_CHANGED")
	end
end

	---------------------
	--- LibDataBroker ---
	---------------------

local dataobject = {
	type = "launcher",
	icon = "Interface\\Icons\\Ability_Stealth",
	text = NAME,
	OnClick = function(clickedframe, button)
		if InterfaceOptionsFrame:IsShown() and InterfaceOptionsFramePanelContainer.displayedPanel.name == NAME then
			InterfaceOptionsFrame:Hide()
		else
			InterfaceOptionsFrame_OpenToCategory(optionsFrame)
		end
	end,
	OnTooltipShow = function(tt)
		tt:AddLine("|cffFFFFFF"..NAME.."|r")
		tt:AddDoubleLine(L["Raid Manager"], format("|cff%s|r", profile.RaidManager and "ADFF2F"..VIDEO_OPTIONS_ENABLED or "FF0000"..VIDEO_OPTIONS_DISABLED))
		tt:AddDoubleLine(L["Raid Container"], format("|cff%s|r", profile.RaidContainer and "ADFF2F"..VIDEO_OPTIONS_ENABLED or "FF0000"..VIDEO_OPTIONS_DISABLED))
	end,
}

LibStub("LibDataBroker-1.1"):NewDataObject("HideRaidFrame", dataobject)