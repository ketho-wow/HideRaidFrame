local _, S = ...

local L = {
	deDE = {
		RAID_CONTAINER = "Schlachtzugsfenster",
		RAID_MANAGER = "Schlachtzugsmanager",
		BROKER_CLICK = "|cffFFFFFFKlickt|r, um das Optionsmen\195\188 zu \195\182ffnen",
		BROKER_SHIFT_CLICK = "|cffFFFFFFShift-klickt|r, um dieses AddOn ein-/auszuschalten",
	},
	enUS = {
		RAID_CONTAINER = "Raid Container",
		RAID_MANAGER = "Raid Manager",
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
	},
	koKR = {
	},
	ptBR = {
	},
	ruRU = {
	},
	zhCN = {
		RAID_CONTAINER = "\229\155\162\233\152\159\229\174\185\229\153\168", -- "团队容器"
		RAID_MANAGER = "\229\155\162\233\152\159\231\174\161\231\144\134\229\153\168", -- "团队管理器"
		BROKER_CLICK = "\231\130\185\229\135\187\230\137\147\229\188\128\233\128\137\233\161\185\232\143\156\229\141\149", -- "点击打开选项菜单"
		BROKER_SHIFT_CLICK = "Shift-\231\130\185\229\135\187 \229\144\175\231\148\168\230\136\150\231\166\129\231\148\168\230\143\146\228\187\182", -- "Shift-点击 启用或禁用插件"
	},
	zhTW = {
		RAID_CONTAINER = "\229\156\152\233\154\138\229\133\167\229\174\185", -- "團隊內容"
		RAID_MANAGER = "\229\156\152\233\154\138\231\174\161\231\144\134\233\157\162\230\157\191", -- "團隊管理面板"
	},
}

S.L = setmetatable(L[GetLocale()] or L.enUS, {__index = function(t, k)
	local v = rawget(L.enUS, k) or k
	rawset(t, k, v)
	return v
end})
