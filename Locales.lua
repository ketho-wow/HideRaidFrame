local _, S = ...

local L = {
	deDE = {
		RAID_CONTAINER = "Schlachtzugsfenster",
		RAID_MANAGER = "Schlachtzugsmanager",
		WAITING_COMBAT = "\195\132nderungen werden nach Kampf wirksam",
		BROKER_CLICK = "|cffFFFFFFKlickt|r, um das Optionsmen\195\188 zu \195\182ffnen",
		BROKER_SHIFT_CLICK = "|cffFFFFFFShift-klickt|r, um dieses AddOn ein-/auszuschalten",
	},
	enUS = {
		RAID_CONTAINER = "Raid Container",
		RAID_MANAGER = "Raid Manager",
		WAITING_COMBAT = "Waiting for Combat",
		BROKER_CLICK = "|cffFFFFFFClick|r to open the options menu",
		BROKER_SHIFT_CLICK = "|cffFFFFFFShift-click|r to toggle this AddOn",
	},
	esES = {
	},
	esMX = {
	},
	frFR = {
		RAID_CONTAINER = "Raid conteneurs",
		RAID_MANAGER = "Manageur du raid",
		WAITING_COMBAT = "Attente de combat",
	},
	koKR = {
	},
	ptBR = {
		WAITING_COMBAT = "Esperando pelo Combate",
	},
	ruRU = {
	},
	zhCN = {
		RAID_CONTAINER = "\229\155\162\233\152\159\229\174\185\229\153\168", -- "�Ŷ�����"
		RAID_MANAGER = "\229\155\162\233\152\159\231\174\161\231\144\134\229\153\168", -- "�Ŷӹ�����"
		WAITING_COMBAT = "\231\173\137\229\190\133\230\136\152\230\150\151", -- "�ȴ�ս��"
		BROKER_CLICK = "\231\130\185\229\135\187\230\137\147\229\188\128\233\128\137\233\161\185\232\143\156\229\141\149", -- "�����ѡ��˵�"
		BROKER_SHIFT_CLICK = "Shift-\231\130\185\229\135\187 \229\144\175\231\148\168\230\136\150\231\166\129\231\148\168\230\143\146\228\187\182", -- "Shift-��� ���û���ò��"
	},
	zhTW = {
	},
}

S.L = setmetatable(L[GetLocale()] or L.enUS, {__index = function(t, k)
	local v = rawget(L.enUS, k) or k
	rawset(t, k, v)
	return v
end})