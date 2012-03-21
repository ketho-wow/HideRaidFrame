-------------------------------------------
--- Author: Ketho (EU-Boulderfist)		---
--- License: Public Domain				---
--- Created: 2011.07.06					---
--- Version: 0.6 [2012.03.21]			---
-------------------------------------------
--- Curse			http://www.curse.com/addons/wow/hideraidframe
--- WoWInterface	http://www.wowinterface.com/downloads/info20052-HideRaidFrame.html

-- wish I could do just this, like all the other cool addons
--[[
CompactRaidFrameManager:UnregisterAllEvents()
CompactRaidFrameManager.Show = function() end
CompactRaidFrameManager:Hide()
CompactRaidFrameContainer:UnregisterAllEvents()
CompactRaidFrameContainer.Show = function() end
CompactRaidFrameContainer:Hide()
]]

local NAME, S = ...
local VERSION = 0.6
local BUILD = "Release"

HideRaidFrame = LibStub("AceAddon-3.0"):NewAddon(NAME, "AceEvent-3.0", "AceConsole-3.0")
local HRF = HideRaidFrame

local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")

local L = S.L
local profile

local delayRaidManager, delayRaidContainer

local _G = _G
local CompactRaidFrameManager = _G.CompactRaidFrameManager
local CompactRaidFrameContainer = _G.CompactRaidFrameContainer
local InCombatLockdown = _G.InCombatLockdown

-- CompactRaidFrameManager is parented to UIParent
-- CompactRaidFrameContainer is parented to CompactRaidFrameManager
CompactRaidFrameContainer:SetParent(UIParent)

	--------------------------
	---- Raid Frame Events ---
	--------------------------

local eventsCRFM = {
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

local eventsCRFC = {
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
		-- still needs more band-aid ..
		if InCombatLockdown() then
			delayRaidManager = true
		else
			oldCompactRaidFrameManager_Show(self)
		end
		--print("|cffFFFF00Raid|rManager: |cffB6CA00Show|r", profile.RaidManager)
	end
end

local oldCompactRaidFrameManager_Hide = CompactRaidFrameManager.Hide
function CompactRaidFrameManager:Hide()
	if not profile.RaidManager or not IsRaidManager() then
		if InCombatLockdown() then
			delayRaidManager = true
		else
			oldCompactRaidFrameManager_Hide(self)
		end
		--print("|cffFFFF00Raid|rManager: |cffFF2424Hide|r", profile.RaidManager)
	end
end

local oldCompactRaidFrameContainer_Show = CompactRaidFrameContainer.Show
function CompactRaidFrameContainer:Show()
	if profile.RaidContainer and IsRaidContainer() then
		if InCombatLockdown() then
			delayRaidContainer = true
		else
			oldCompactRaidFrameContainer_Show(self)
		end
		--print("|cffFFFF00Raid|rContainer: |cffB6CA00Show|r", profile.RaidContainer)
	end
end

local oldCompactRaidFrameContainer_Hide = CompactRaidFrameContainer.Hide
function CompactRaidFrameContainer:Hide()
	if not profile.RaidContainer or not IsRaidContainer() then
		if InCombatLockdown() then
			delayRaidContainer = true
		else
			oldCompactRaidFrameContainer_Hide(self)
		end
		--print("|cffFFFF00Raid|rContainer: |cffFF2424Hide|r", profile.RaidContainer)
	end
end

	--------------------
	---- Show / Hide ---
	--------------------

function HRF:RaidManager(show)
	if show and IsRaidManager() then
		for _, v in ipairs(eventsCRFM) do
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

local f = CreateFrame("Frame")

function HRF:RaidContainer(show, isDelayed)
	-- combat state still seems to be leaking through
	if InCombatLockdown() then
		delayRaidContainer = true
		return
	end
	
	if show and IsRaidContainer() then
		for _, v in ipairs(eventsCRFC) do
			CompactRaidFrameContainer:RegisterEvent(v)
		end
		CompactRaidFrameContainer:Show()
		-- this didn't seem to properly update, when "Use Raid-Style Party Frames" is disabled
		if not InCombatLockdown() then
			CompactRaidFrameContainer_OnEvent(CompactRaidFrameContainer, "PARTY_MEMBERS_CHANGED")
		end
		--print("|cffB6CA00Enabling|r: |cffFFFF00CompactRaidFrame|rContainer")
	else
		CompactRaidFrameContainer:UnregisterAllEvents()
		CompactRaidFrameContainer:Hide()
		--print("|cffFF2424Disabling|r: |cffFFFF00CompactRaidFrame|rContainer")
	end
	-- ugly fix; leaving a raid is sometimes not yet updated in time
	if isDelayed then
		-- single OnUpdate iteration delay
		f:SetScript("OnUpdate", function(self, elapsed)
			HRF:RaidContainer(show)
			self:SetScript("OnUpdate", nil)
		end)
	end
end

	---------------
	--- Options ---
	---------------

local function WaitingCombat(bool)
	return bool and "  |cffFFFF00("..L.WAITING_COMBAT..")|r" or ""
end

local options = {
	type = "group",
	handler = HRF,
	get = "GetValue",
	name = format("%s |cffADFF2Fv%s|r", NAME, VERSION),
	args = {
		inline = {
			type = "group", order = 1,
			name = " ",
			inline = true,
			args = {
				RaidManager = {
					type = "toggle", order = 1,
					width = "full", descStyle = "",
					name = function() return " "..L.RAID_MANAGER..WaitingCombat(delayRaidManager) end,
					set = function(i, v) profile.RaidManager = v
						if InCombatLockdown() then
							delayRaidManager = true
						else
							HRF:RaidManager(profile.RaidManager)
						end
					end,
				},
				RaidContainer = {
					type = "toggle", order = 2,
					width = "full", descStyle = "",
					name = function() return " "..L.RAID_CONTAINER..WaitingCombat(delayRaidContainer) end,
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
			type = "toggle", order = 2,
			width = "full", descStyle = "",
			name = " |cff71D5FF"..SOLO.."|r",
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

function HRF:GetValue(i)
	return profile[i[#i]]
end

	----------------------
	--- Initialization ---
	----------------------

local slashCmds = {"hr", "hrf", "hideraid", "hideraidframe"}

function HRF:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("HideRaidFrameDB2", nil, true)

	self.db.RegisterCallback(self, "OnProfileChanged", "RefreshDB")
	self.db.RegisterCallback(self, "OnProfileCopied", "RefreshDB")
	self.db.RegisterCallback(self, "OnProfileReset", "RefreshDB")
	self:RefreshDB()

	self.db.global.version = VERSION
	self.db.global.build = BUILD

	local profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)
	ACR:RegisterOptionsTable("HideRaidFrame_Main", options)
	ACR:RegisterOptionsTable("HideRaidFrame_Profiles", profiles)

	ACD:AddToBlizOptions("HideRaidFrame_Main", NAME)
	ACD:AddToBlizOptions("HideRaidFrame_Profiles", profiles.name, NAME)
	
	ACD:SetDefaultSize("HideRaidFrame_Main", 350, 200)

	for _, v in ipairs(slashCmds) do
		self:RegisterChatCommand(v, "SlashCommand")
	end
end

function HRF:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("CVAR_UPDATE")

	if InCombatLockdown() then
		delayRaidManager, delayRaidContainer = true, true
	else
		self:RaidManager(profile.RaidManager)
		self:RaidContainer(profile.RaidContainer)
	end
end

function HRF:RefreshDB()
	profile = self.db.profile
	if InCombatLockdown() then
		delayRaidManager, delayRaidContainer = true, true
	else
		self:RaidManager(profile.RaidManager)
		self:RaidContainer(profile.RaidContainer)
	end
end

function HRF:SlashCommand(input)
	ACD:Open("HideRaidFrame_Main")
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
	if InterfaceOptionsFrame:IsShown() or ACD.OpenFrames["HideRaidFrame_Main"] then
		ACR:NotifyChange("HideRaidFrame_Main")
	end
end

local cd

-- check if player joins/leaves groups
function HRF:PARTY_MEMBERS_CHANGED()
	if time() > (cd or 0) then
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
function HRF:CVAR_UPDATE(event, cvar, value)
	if cvar == "USE_RAID_STYLE_PARTY_FRAMES" then
		CompactRaidFrameContainer_OnEvent(CompactRaidFrameContainer, "PARTY_MEMBERS_CHANGED")
	end
end
