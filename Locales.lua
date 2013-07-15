local _, S = ...

local L = {
	deDE = {
		RAID_CONTAINER = "Schlachtzugsfenster",
		RAID_MANAGER = "Schlachtzugsmanager",
		BROKER_CLICK = "|cffFFFFFFKlickt|r, um das Optionsmenü zu öffnen",
		BROKER_SHIFT_CLICK = "|cffFFFFFFShift-klickt|r, um dieses AddOn ein-/auszuschalten",
	},
	enUS = {
		RAID_CONTAINER = RAID.." Container",
		RAID_MANAGER = RAID.." Manager",
		HARD_DISABLE = "Hard "..DISABLE,
		HARD_DISABLE_DESC = "Note: There might be compatibility issues with other "..ADDONS,
		BROKER_CLICK = "|cffFFFFFFClick|r to open the options menu",
	},
	esES = {
		BROKER_CLICK = "|cffffffffHaz clic|r para ver opciones.",
		BROKER_SHIFT_CLICK = "|cffffffffMayús-clic|r para activar/desactivar.",
	},
	esMX = {
		BROKER_CLICK = "|cffffffffHaz clic|r para ver opciones.",
		BROKER_SHIFT_CLICK = "|cffffffffMayús-clic|r para activar/desactivar.",
	},
	frFR = {
		RAID_CONTAINER = "Raid conteneurs",
		RAID_MANAGER = "Manageur du raid",
	},
	koKR = {
	},
	ptBR = {
	},
	ruRU = {
	},
	zhCN = {
		RAID_CONTAINER = "团队容器",
		RAID_MANAGER = "团队管理器",
		BROKER_CLICK = "|cffFFFFFF点击|r打开选项菜单",
		BROKER_SHIFT_CLICK = "|cffFFFFFFShift-点击|r 启用或禁用插件",
	},
	zhTW = {
		RAID_CONTAINER = "團隊內容",
		RAID_MANAGER = "團隊管理面板",
	},
}

S.L = setmetatable(L[GetLocale()] or L.enUS, {__index = function(t, k)
	local v = rawget(L.enUS, k) or k
	rawset(t, k, v)
	return v
end})
