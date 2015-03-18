
--[[ Externals (used by menu):
	GRadar.GetVisible() -> bool
	GRadar.SetVisible(bool)
	
	GRadar.GetPos() -> x, y
	GRadar.SetPos(x, y)
	
	GRadar.GetSize() -> size
	GRadar.SetSize(size) : that is, width & height
	
	GRadar.GetDistance() -> dist
	GRadar.SetDistance(dist)
	GRadar.GetDistanceVariable() -> bool
	GRadar.SetDistanceVariable(bool)
	
	GRadar.EnableOverviewRendering()
	GRadar.DisableOverviewRendering()
	
	GRadar.UpdateColorScheme()
	
	GRadar.AppendBeacon(handler_name, beacon_table)
	
	GRadar.SwitchToOverview()
	GRadar.SwitchToRadar()
	
	GRadar.Maximize()
	GRadar.Minimize()
]]

include("gram/render_radar.lua")
include("gram/render_overview.lua")

include("gradar_settings.lua")


local OVERVIEW_ANIM_LENGTH = 0.25 -- in seconds

-- General settings

local distance = GRadar.Settings["Distance"] -- radius in units
local distance_variable = GRadar.Settings["DistanceVariable"]
	-- i.e. GTA-like scaling, dependent on speed

local x = GRadar.Settings["PosX"]
local y = GRadar.Settings["PosY"]
local size = GRadar.Settings["Size"]


----------------------------------------------------------------------
-- Initialization / Class creation									--
----------------------------------------------------------------------

local obj_radar = Gram.Renderers.Radar:new()
obj_radar:SetDistance(distance)

local overview_data

if GRadar.Settings["RenderOverview"] then
	overview_data = Gram.Overview.Load(game.GetMap()) or false
end

if overview_data then
	obj_radar:SetOverviewData(overview_data)
end

local last, dist = 0
local function radar_Scale()
	local ent = LocalPlayer():GetParent()
	ent = ent:IsValid() and ent or LocalPlayer()
	
	dist = Lerp(FrameTime()*4, last, ent:GetVelocity():Length()/2)
	last = dist
	
	obj_radar:SetDistance(distance + dist)
end


local obj_map = Gram.Map:new()
obj_map:SetupDraw(x, y, size, size)
obj_map:SetRenderer(obj_radar)

obj_map.listener = Gram.Beacons.Listener:new()
obj_map.listener:SetMapObject(obj_map)
obj_map.listener:Listen()

obj_map.listener.OnBeaconCreated = function(self, handler_name, beacon_table)
	if handler_name == "player" then
		-- IMPORTANT:
		-- LocalPlayer() is NULL at the time players are created
		-- observed after the 15.03.09 update
		if beacon_table.Entity == LocalPlayer() then
			return
		end
	end
	
	self:GetMapObject():AppendBeacon(handler_name, beacon_table)
end

-- TEMPORARY FIX
hook.Add("InitPostEntity", "GRadar_LocalPlayerWA", function()
	obj_map:ForEach(function(beacon)
		if beacon.Player == LocalPlayer() then
			return false
		end
	end)
	
	hook.Remove("InitPostEntity", "GRadar_LocalPlayerWA")
end)
--for k,v in pairs(Gram.Handlers) do v:ReloadToListener(obj_map.listener) end


----------------------------------------------------------------------
-- Assets for the HUD												--
----------------------------------------------------------------------

surface.CreateFont("GRadar_LocationName", {
	font = "Verdana",
	size = 15,
	weight = 1000,
	antialias = false,
	shadow = false,
})
surface.CreateFont("GRadar_LocationName_Overview", {
	font = "Arial", 
	size = 24
})

local tex_ring = Gram.AssetTextureID("ring")
local tex_ring_outer = Gram.AssetTextureID("outer_ring")
local tex_ring_inner = Gram.AssetTextureID("inner_ring")
local tex_ring_shadow = Gram.AssetTextureID("ring_shadow")
local tex_circle = Gram.AssetTextureID("circle")
local tex_circle_glow = Gram.AssetTextureID("circle_glow")
local tex_be_pointed = Gram.BeaconTextureID("be_pointed")


----------------------------------------------------------------------
-- HUD's color scheme												--
----------------------------------------------------------------------

local col_ring
local col_inner_ring
local col_circle
local col_glow

local col_zero_sign
local col_loc_text
local col_loc_shadow = Color(0,0,0,50)

local function updateColorScheme()
	col_ring = GRadar.Settings["Color_Ring"]
	col_inner_ring = GRadar.Settings["Color_InnerRing"]
	col_circle = GRadar.Settings["Color_Circle"]
	col_glow = GRadar.Settings["Color_Glow"]
	
	local c = (col_ring.r + col_ring.g + col_ring.b) / 3
	c = c > 150 and 0 or 255
	col_zero_sign = Color(c,c,c,170)
	col_loc_text = Color(c,c,c,220)
end
updateColorScheme()


----------------------------------------------------------------------
-- Additional HUD for the radar / Radar extensions					--
----------------------------------------------------------------------

local base = Gram.Renderers.Radar
local object = obj_radar

function object:PreRenderLayout()
	--base.PreRenderLayout(self)
	
	surface.SetDrawColor(col_circle)
	surface.SetTexture(tex_circle)
	surface.DrawTexturedRect(
		self._x - self._size*(8/256), self._y - self._size*(8/256),
		self._size*(256/240), self._size*(256/240)
	)
	
	if GRadar.Settings["GlowEnabled"] then
		surface.SetDrawColor(col_glow)
		surface.SetTexture(tex_circle_glow)
		surface.DrawTexturedRect(
			self._x - self._size*(8/256), self._y - self._size*(8/256),
			self._size*(256/240), self._size*(256/240)
		)
	end
end

function object:PostRenderLayout()
	--base.PostRenderLayout(self)
	
	local ring_type = GRadar.Settings["RingType"]
	
	surface.SetDrawColor(col_ring)
	surface.SetTexture(ring_type == 0 and tex_ring or tex_ring_outer)
	surface.DrawTexturedRect(
		self._x - self._size*(8/256), self._y - self._size*(8/256),
		self._size*(256/240), self._size*(256/240)
	)
	
	if ring_type == 2 then
		surface.SetDrawColor(col_inner_ring)
		surface.SetTexture(tex_ring_inner)
		surface.DrawTexturedRect(
			self._x - self._size*(8/256), self._y - self._size*(8/256),
			self._size*(256/240), self._size*(256/240)
		)
	end
	
	if GRadar.Settings["ShadowVisible"] then
		local offs = self._size*(20/200)
		
		surface.SetDrawColor(0,0,0,180)
		surface.SetTexture(tex_ring_shadow)
		surface.DrawTexturedRect(
			self._x - self._size*(8/256) - offs, self._y - self._size*(8/256) - offs,
			self._size*(256/240) + offs*2, self._size*(256/240) + offs*2
		)
	end
	
	if GRadar.Settings["ShowZeroSign"] then
		local pos = self._pos
		local ang = -math.rad(self._ang - 90) + math.atan2(-pos.y, -pos.x)
		local cos_r, sin_r = math.cos(ang), math.sin(ang)
		
		local x, y = self._x + self._size/2 * (1 + cos_r), self._y + self._size/2 * (1 - sin_r)
		local sz = self._size * 0.09--0.1
		
		x = x - sz/2
		y = y - sz/2
		
		surface.SetTexture(tex_circle)
		
		surface.SetDrawColor(0,0,0,150)
		surface.DrawTexturedRect(x - 1, y - 1, sz + 2, sz + 2)
		
		surface.SetDrawColor(col_ring)
		surface.DrawTexturedRect(x, y, sz, sz)
		
		local f = self._size * 0.01 * 3
		
		surface.SetDrawColor(col_zero_sign)
		surface.DrawTexturedRect(x + f, y + f, sz - f*2, sz - f*2)
	end
	
	if GRadar.Settings["DisplayLocation"] then
		local loc_name
		if LocalPlayer().GetLocationName then--GAMEMODE.Name == "Cinema" then
			loc_name = LocalPlayer():GetLocationName()
		else
			local data, entry = self._ovdata, self._ov_entry
			
			if not data or not entry then return end
			if not entry.name or entry.name == "" or entry.name == "Ambient" then return end
			
			loc_name = entry.name
		end
		
		surface.SetFont("GRadar_LocationName")
		surface.SetTextColor(col_loc_text)
		
		local x, y = self._x + self._size/2, self._y + self._size - 6
		
		local sz = surface.GetTextSize(loc_name)
		
		x = x - sz/4
		
		draw.RoundedBox(4, x-1, y-1, 18+sz, 26, col_loc_shadow)
		draw.RoundedBox(4, x, y, 16+sz, 24, col_ring)
		
		surface.SetTextPos(x+8, y+5)
		surface.DrawText(loc_name)
	end
end

function object:PostRender()
	surface.SetDrawColor(250,250,130,255)
	surface.SetTexture(tex_be_pointed)
	surface.DrawTexturedRect(self._x + self._size/2 - 8, self._y + self._size/2 - 8, 16, 16)
end

function object:RenderBeacon(beacon, x, y, ...)
	local ent = beacon.Entity
	if ent and ent:IsValid() then -- current vehicle precision
		local veh = LocalPlayer():GetVehicle()
		if ent == veh then--or ent == veh:GetNWEntity("SCarEnt") then
			x = self._x + self._size/2
			y = self._y + self._size/2
		end
	end
	
	return base.RenderBeacon(self, beacon, x, y, ...)
end


----------------------------------------------------------------------
-- Fullscreeen map / Overview renderer								--
----------------------------------------------------------------------

local obj_overview = Gram.Renderers.Overview:new()
obj_overview:SetDistance(4096)

if overview_data then
	obj_overview:SetOverviewData(overview_data)
end

local w1, h1 = ScrH()*0.8, ScrH()*0.7
local x1, y1 = (ScrW() - w1)/2, (ScrH() - h1)/2
local size1 = h1 - 100

local old_lOnBeaconCreated, b_player

local function overview_Open()
	if not Gram.Handlers["player"] then return end
	if old_lOnBeaconCreated ~= nil then return end
	
	old_lOnBeaconCreated = obj_map.listener.OnBeaconCreated
	obj_map.listener.OnBeaconCreated = nil
	
	b_player = obj_map:AppendBeacon("player", { Entity = LocalPlayer() })
	obj_map:Poll()
end

local function overview_Close()
	if old_lOnBeaconCreated == nil then return end
	
	obj_map.listener.OnBeaconCreated = old_lOnBeaconCreated
	old_lOnBeaconCreated = nil
	
	b_player:Dispose()
end

local overview_Animate


----------------------------------------------------------------------
-- Updating functions												--
----------------------------------------------------------------------

local function poll()
	if not gui.IsGameUIVisible() then
		return obj_map:Poll()
	end
end

local function drawRadar()
	-- temporary - until i make something more flexible
	if LocalPlayer().InTheater and LocalPlayer():InTheater() then return end
	
	local pos = LocalPlayer():GetShootPos()
	local yaw = EyeAngles().Yaw
	
	return obj_map:Draw(pos, yaw)
end

local function drawOverview()
	surface.SetDrawColor(col_circle)
	surface.DrawRect(x + 1, y + 1, size - 2, size - 2)
	
	surface.SetDrawColor(col_zero_sign)
	surface.DrawOutlinedRect(x, y, size, size)
	
	local pos = LocalPlayer():GetShootPos()
	pos.x = b_player.pos.x
	pos.y = b_player.pos.y
	
	return obj_map:Draw(pos)
end

local function drawOverviewFS()
	local x, y, w, h = overview_Animate()
	
	if x == nil then
		return drawRadar()
	end
	
	surface.SetDrawColor(0,0,0,200)
	surface.DrawRect(x, y, w, h)
	
	surface.SetDrawColor(255,255,255,200)
	surface.DrawRect(x, y, w, 10)
	
	--surface.DrawLine(x, y, x+w-1, y) -- top
	surface.DrawLine(x, y+h-1, x+w-1, y+h-1) -- bottom
	--surface.DrawLine(x+w-1, y, x+w-1, y+h-1) -- right
	--surface.DrawLine(x, y, x, y+h-1) -- left
	
	local entry = obj_overview:GetOverview()
	if not (entry and entry.name == "") then
		local loc_name
		if not entry or not entry.name then
			loc_name = "AMBIENT"
		else
			loc_name = string.upper(entry.name)
		end
		
		draw.SimpleText(loc_name, "GRadar_LocationName_Overview", x+40, y+28, color_white)
	end
	
	local pos = LocalPlayer():GetShootPos()
	pos.x = b_player.pos.x
	pos.y = b_player.pos.y
	
	return obj_map:Draw(pos)
end


----------------------------------------------------------------------
-- Fullscreen animation control										--
----------------------------------------------------------------------

local setPaintFunction

local frac = 0
local anim_out = false
local anim_len = 0
local anim_end = 0

overview_Animate = function()
	if frac == 0 then
		return x1, y1, w1, h1
	end
	
	local x2 = Lerp(frac, x+size/2, x1)
	local y2 = Lerp(frac, y+size/2, y1)
	local w2 = w1 * frac
	local h2 = h1 * frac
	
	local size2 = h2 - 100*(h2/h1)
	obj_map:SetupDraw(x2 + (w2 - size2)/2, y2 + 65*(h2/h1), size2, size2)
	
	anim_end = anim_end + FrameTime()/6 * (1/(anim_end - CurTime()+1)^2) -- smoothing a bit :/
	frac = (anim_end - CurTime()) / OVERVIEW_ANIM_LENGTH
	
	if anim_out then
		frac = 1 - frac
		
		if frac >= 1 then
			frac = 0
			
			obj_map:SetupDraw(x1 + (w1 - size1)/2, y1 + 65, size1, size1)
		end
	else
		if frac <= size/size1 - 0.2 then
			setPaintFunction(drawRadar)
			obj_map:SetupDraw(x, y, size, size)
			obj_map:SetRenderer(obj_radar)
			
			overview_Close()
			return
		end
	end
	
	return x2, y2, w2, h2
end

local function overview_Maximize()
	frac = size/size1 + 0.05
	
	setPaintFunction(drawOverviewFS)
	
	if obj_map:GetRenderer() == obj_radar then
		obj_map:SetRenderer(obj_overview)
		overview_Open()
	end
	
	if frac >= 1 or not GRadar.Settings["FullscreenAnimation"] then
		frac = 0
		
		obj_map:SetupDraw(x1 + (w1 - size1)/2, y1 + 65, size1, size1)
		return
	else
		frac = frac * 0.8
	end
	
	anim_out = true
	anim_len = (1 - frac) * OVERVIEW_ANIM_LENGTH
	anim_end = CurTime() + anim_len
end

local function overview_Minimize()
	frac = frac == 0 and 1 or frac
	
	if size/size1 >= 1 or not GRadar.Settings["FullscreenAnimation"] then
		setPaintFunction(drawRadar)
		obj_map:SetupDraw(x, y, size, size)
		obj_map:SetRenderer(obj_radar)
		
		overview_Close()
		return
	end
	
	anim_out = false
	anim_len = frac * OVERVIEW_ANIM_LENGTH
	anim_end = CurTime() + anim_len
end


----------------------------------------------------------------------
-- Externals...														--
----------------------------------------------------------------------

local visible = false

local cur_func = drawRadar
setPaintFunction = function(func)
	cur_func = func or cur_func
	
	if visible then
		hook.Add("HUDPaint","GRadar_Paint",cur_func)
	end
end

function GRadar.GetVisible()
	return visible
end
function GRadar.SetVisible(state)
	if state then
		visible = true
		
		setPaintFunction()
		hook.Add("Think"--[["Tick"]],"GRadar_Poll",poll)
		
		Gram.StartHandlers()
	else
		visible = false
		
		hook.Remove("HUDPaint","GRadar_Paint")
		hook.Remove("Think","GRadar_Poll")
		
		Gram.StopHandlers() -- to prevent unwanted memory consumption,
								-- as the new beacons won't be cleared
	end
end

local function resetupMap()
	if obj_map:GetRenderer() == obj_radar then
		obj_map:SetupDraw(x, y, size, size)
	elseif cur_func == drawOverview then
		obj_map:SetupDraw(x + 15, y + 15, size - 30, size - 30)
	end
end

function GRadar.GetPos()
	return x, y
end
function GRadar.SetPos(_x, _y)
	x = _x
	y = _y
	
	resetupMap()
end
function GRadar.GetSize()
	return size
end
function GRadar.SetSize(_size)
	size = _size
	
	resetupMap()
end

function GRadar.GetDistance()
	return distance
end
function GRadar.SetDistance(dist)
	distance = dist
	
	obj_radar:SetDistance(dist)
end
function GRadar.GetDistanceVariable()
	return distance_variable
end
function GRadar.SetDistanceVariable(state)
	distance_variable = state
	
	if state then
		hook.Add("Think","GRadar_ScaleRadar",radar_Scale)
	else
		hook.Remove("Think","GRadar_ScaleRadar")
		
		obj_radar:SetDistance(distance)
	end
end

function GRadar.EnableOverviewRendering()
	if overview_data == nil then
		overview_data = Gram.Overview.Load(game.GetMap()) or false
	end
	
	if overview_data then
		obj_radar:SetOverviewData(overview_data)
		obj_overview:SetOverviewData(overview_data)
	end
end
function GRadar.DisableOverviewRendering()
	if overview_data then
		obj_radar:SetOverviewData(nil)
		obj_overview:SetOverviewData(nil)
	end
end

GRadar.UpdateColorScheme = updateColorScheme

function GRadar.AppendBeacon(handler_name, beacon_table)
	return obj_map:AppendBeacon(handler_name, beacon_table)
end

function GRadar.SwitchToOverview()
	setPaintFunction(drawOverview)
	obj_map:SetupDraw(x + 15, y + 15, size - 30, size - 30)
	obj_map:SetRenderer(obj_overview)
	
	overview_Open()
end
function GRadar.SwitchToRadar()
	setPaintFunction(drawRadar)
	obj_map:SetupDraw(x, y, size, size)
	obj_map:SetRenderer(obj_radar)
	
	overview_Close()
end

GRadar.Maximize = overview_Maximize
GRadar.Minimize = overview_Minimize

--[[function GRadar.ShowOverview()
	if GRadar.Settings["FullscreenOverview"] then
		GRadar.Maximize()
	else
		GRadar.SwitchToOverview()
	end
end
function GRadar.HideOverview()
	if GRadar.Settings["FullscreenOverview"] then
		GRadar.Minimize()
	else
		GRadar.SwitchToRadar()
	end
end]]

concommand.Add("gr_overview", function()
	if obj_map:GetRenderer() == obj_radar then
		GRadar.Maximize()
	else
		GRadar.Minimize()
	end
end)

concommand.Add("+gr_overview", GRadar.SwitchToOverview)
concommand.Add("-gr_overview", GRadar.SwitchToRadar)


----------------------------------------------------------------------
-- Startup															--
----------------------------------------------------------------------

if GRadar.Settings["Enabled"] then
	GRadar.SetVisible(true)
end
if GRadar.Settings["DistanceVariable"] then
	GRadar.SetDistanceVariable(true)
end
