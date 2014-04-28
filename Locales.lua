local _, S = ...

local L = {
	deDE = {
		BROKER_CLICK = "|cffFFFFFFKlickt|r, um das Optionsmenü zu öffnen",
	},
	enUS = {
		BROKER_CLICK = "|cffFFFFFFClick|r to open the options menu",
	},
	esES = {
		BROKER_CLICK = "|cffffffffHaz clic|r para ver opciones.",
	},
	esMX = {
		BROKER_CLICK = "|cffffffffHaz clic|r para ver opciones.",
	},
	frFR = {
	},
	koKR = {
	},
	ptBR = {
	},
	ruRU = {
	},
	zhCN = {
		BROKER_CLICK = "|cffFFFFFF点击|r打开选项菜单",
	},
	zhTW = {
	},
}

S.L = setmetatable(L[GetLocale()] or L.enUS, {__index = function(t, k)
	local v = rawget(L.enUS, k) or k
	rawset(t, k, v)
	return v
end})
