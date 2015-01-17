
local settings = {
	Enabled = {"enabled", true},
	
	Distance = {"distance", 1500},
	DistanceVariable = {"distance_variable", true},
	
	PosX = {"pos_x", ScrW()/2 - 450},
	PosY = {"pos_y", ScrH()/2 + 40},
	Size = {"size", 260},
	
	RenderOverview = {"render_map", true},
	
	--FullscreenOverview = {"fs_overview", true},
	FullscreenAnimation = {"fs_animation", true},
	
	GlowEnabled = {"glow", true},
	ShadowVisible = {"shadow", true},
	
	DisplayLocation = {"location", true},
	ShowZeroSign = {"zero_sign", true},
	
	RingType = {"ring_style", 0},
	
	Color_Ring = {"col_ring", color_white},
	Color_InnerRing = {"col_inner_ring", color_white},
	Color_Circle = {"col_circle", color_white},
	Color_Glow = {"col_glow", Color(92,200,240,150)}
}

local cv_meta = FindMetaTable("ConVar")

local cv_get = {
	["number"] = cv_meta.GetInt,
	["boolean"] = cv_meta.GetBool,
	["string"] = cv_meta.GetString,
	["table"] = function(cvar)
		local r, g, b, a = string.match(cvar:GetString(), "(%d+) (%d+) (%d+) (%d+)")
		return Color(r or 255, g or 255, b or 255, a or 255)
	end
}

for k, v in pairs(settings) do
	local val = isbool(v[2]) and (v[2] and "1" or "0") or tostring(v[2])
	v[1] = CreateClientConVar("gradar_" .. v[1], val)
	v[2] = cv_get[type(v[2])]
end

local meta = {
	__index = function(self, key)
		local s = settings[key]
		return s and s[2](s[1]) or nil
	end,
	__newindex = function(self, key, value)
		local s = settings[key]
		if s then
			value = isbool(value) and (value and "1" or "0") or tostring(value)
			RunConsoleCommand(s[1]:GetName(), value)
		end
	end
}

GRadar.Settings = setmetatable({}, meta)


local cvarsAddChangeCB

if GRadar.Config and #GRadar.Config.CVarEventsDeleted ~= 0 then
	cvarsAddChangeCB = function(name, ...)
		if not table.HasValue(GRadar.Config.CVarEventsDeleted, name) then
			return cvars.AddChangeCallback(name, ...)
		end
	end
else
	cvarsAddChangeCB = cvars.AddChangeCallback
end

cvarsAddChangeCB("gradar_enabled", function(name, oldval, newval)
	return GRadar.SetVisible(newval == "1")
end)
cvarsAddChangeCB("gradar_distance", function(name, oldval, newval)
	return GRadar.SetDistance(tonumber(newval) or 1500)
end)
cvarsAddChangeCB("gradar_distance_variable", function(name, oldval, newval)
	return GRadar.SetDistanceVariable(newval == "1")
end)
cvarsAddChangeCB("gradar_pos_x", function(name, oldval, newval)
	return GRadar.SetPos(tonumber(newval) or ScrW() - 400, GRadar.Settings["PosY"])
end)
cvarsAddChangeCB("gradar_pos_y", function(name, oldval, newval)
	return GRadar.SetPos(GRadar.Settings["PosX"], tonumber(newval) or 100)
end)
cvarsAddChangeCB("gradar_size", function(name, oldval, newval)
	return GRadar.SetSize(tonumber(newval) or 300)
end)
cvarsAddChangeCB("gradar_render_map", function(name, oldval, newval)
	if newval == "1" then
		return GRadar.EnableOverviewRendering()
	else
		return GRadar.DisableOverviewRendering()
	end
end)

local function cbColor()
	return GRadar.UpdateColorScheme()
end

local col_cvars = {
	"gradar_col_ring",
	"gradar_col_inner_ring",
	"gradar_col_circle",
	"gradar_col_glow"
}
for i = 1, #col_cvars do
	cvarsAddChangeCB(col_cvars[i], cbColor)
end
