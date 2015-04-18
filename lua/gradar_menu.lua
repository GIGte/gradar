
----------------------------------------------------------------------
-- Fonts' definition												--
----------------------------------------------------------------------

surface.CreateFont("GRadar_Title", {
	font = "Calibri",
	size = 78,
	weight = 500,
})

surface.CreateFont("GRadar_CategoryName", {
	font = "Calibri",
	size = 27,
	weight = 550,
})

surface.CreateFont("GRadar_OptionText", {
	font = "Calibri",
	size = 18,
	weight = 500,
})


----------------------------------------------------------------------
-- Utilities														--
----------------------------------------------------------------------

local function setDrawColor(r, g, b, a)
    if not b then
        a = g or 255
        g = r
        b = r
    elseif not a then
        a = 255
    end
    return surface.SetDrawColor(r, g, b, a)
end
local function setTextColor(r, g, b, a)
    if not b then
        a = g or 255
        g = r
        b = r
    elseif not a then
        a = 255
    end
    return surface.SetTextColor(r, g, b, a)
end


----------------------------------------------------------------------
-- Frame's table													--
----------------------------------------------------------------------

local frame_tbl = {}

function frame_tbl:Paint(w, h)
    local x,y = 3, 3
    w, h = w - 6, h - 6
    
    --------------------------
    -- Window's frame
    --------------------------
    
    setDrawColor(232)
    surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
    
    setDrawColor(255)
    surface.DrawOutlinedRect(x, y, w, h)
    
    setDrawColor(235)
    surface.DrawOutlinedRect(x+1, y+1, w-2, h-2)
    
    setDrawColor(50, 190)
    surface.DrawOutlinedRect(x-1, y-1, w+2, h+2)
    
    setDrawColor(30, 90)
    --surface.DrawOutlinedRect(x-2, y-2, w+4, h+4)
    surface.DrawLine(x-1,y-2,x+w,y-2)
    surface.DrawLine(x-2,y-1,x-2,y+h)
    surface.DrawLine(x+w+1,y-1,x+w+1,y+h)
    surface.DrawLine(x-1,y+h+1,x+w,y+h+1)
    
    setDrawColor(30, 30)
    --surface.DrawOutlinedRect(x-3, y-3, w+6, h+6)
    surface.DrawLine(x,y-3,x+w-1,y-3)
    surface.DrawLine(x,y+h+2,x+w-1,y+h+2)
    surface.DrawLine(x+w+2,y,x+w+2,y+h-1)
    surface.DrawLine(x-3,y,x-3,y+h-1)
    
    if self:HasFocus() then
        setDrawColor(255, 80)
        surface.SetTexture(surface.GetTextureID("gui/gradient_down"))
        surface.DrawTexturedRect(x+1,y+1,w-2,h-2)
    end
    
	setDrawColor(190)
	surface.DrawLine(x+130, y+120, x+130, y+h-38)
	
    --------------------------
    -- 
    --------------------------
    
    setTextColor(100)
    surface.SetFont("GRadar_Title")
    surface.SetTextPos(x+25,y+10)
    surface.DrawText("GRadar")
    
    setTextColor(170)
    surface.SetFont("HudSelectionText")
    surface.SetTextPos(x+225,y+61)
    surface.DrawText("ver. 1.0")
    
    setTextColor(190)
    surface.SetFont("DermaDefault")
    surface.SetTextPos(w - 150,h - 18)
    surface.DrawText("GRadar made by GIG © 2015")
end

local function draggingThink(self)
    local mousex = math.Clamp(gui.MouseX(), 1, ScrW()-1)
    local mousey = math.Clamp(gui.MouseY(), 1, ScrH()-1)
    
    local x = mousex - self.dragstart[1]
    local y = mousey - self.dragstart[2]
    
    self:SetPos(x, y)
end

function frame_tbl:OnMousePressed()
    self.dragstart = {gui.MouseX() - self.x, gui.MouseY() - self.y}
    self.Think = draggingThink
    self:MouseCapture(true)
end
function frame_tbl:OnMouseReleased()
    self.Think = nil
    self:MouseCapture(false)
end

vgui.RegisterTable(frame_tbl, "EditablePanel")


----------------------------------------------------------------------
-- Closing button													--
----------------------------------------------------------------------

local cbutton_tbl = {}

function cbutton_tbl:OnMousePressed(mousecode)
	if mousecode == MOUSE_LEFT or mousecode == MOUSE_MIDDLE then
		self:MouseCapture(true)
		self.pressed = true
	end
end
function cbutton_tbl:OnMouseReleased(mousecode)
	self:MouseCapture(false)
	self.pressed = false
	
	if self:IsHovered() then
		self:GetParent():Remove()
	end
end

function cbutton_tbl:Paint(w, h)
	if self.pressed then
		setDrawColor(165, 210, 240)
		surface.DrawRect(0, 0, w, h)
	elseif self:IsHovered() then
		setDrawColor(255)
		surface.DrawRect(0, 0, w, h)
	end
	
	setDrawColor(0)
	surface.DrawLine(11,11,11+w-22,11+h-22)
	surface.DrawLine(11+w-22,11,11,11+h-22)
end

vgui.RegisterTable(cbutton_tbl, "Panel")


----------------------------------------------------------------------
-- Numslider														--
----------------------------------------------------------------------

local numslider_tbl = {}

function numslider_tbl:Init()
    self.TextArea = self:Add("DTextEntry")
    self.TextArea:Dock(RIGHT)
    self.TextArea:SetDrawBackground(false)
    self.TextArea:SetWide(45)
    self.TextArea:SetNumeric(true)
    self.TextArea:SetValue("0")
    self.TextArea:SetUpdateOnType(true)
    self.TextArea.OnValueChange = function(textarea, value)
    	value = tonumber(value)
    	if value then
        	self:SetValue(value)
        end
    end
    self.TextArea.OnLoseFocus = function(textarea)
    	local value = tonumber(textarea:GetValue())
    	if value then
	    	local newval = math.Clamp(value, self:GetMin(), self:GetMax())
	    	if value ~= newval then
	    		textarea:SetText(tostring(newval))
	    	end
	    else
	    	textarea:SetText(tostring(self:GetMin()))
	    end
	end
    
    self.Slider = self:Add("DSlider")
    self.Slider:SetLockY(0.5)
    self.Slider:SetTrapInside(true)
    self.Slider:SetSlideX(0)
    self.Slider:Dock(FILL)
    self.Slider:SetHeight(16)
    self.Slider.TranslateValues = function(slider, x, y)
        return self:TranslateSliderValues(x, y)
    end
    Derma_Hook(self.Slider, "Paint", "Paint", "NumSlider")
    
    self:SetWide(204)
    
    self:SetTall(32)
    self:SetMinMax(0, 2)
    self:SetDecimals(0)
end

function numslider_tbl:SetValue(value)
    value = math.Clamp(value, self:GetMin(), self:GetMax())
    
    --if self:GetValue() == value then return end
    
    self.Slider:SetSlideX((value - self:GetMin()) / self:GetRange())
    
    if self.TextArea ~= vgui.GetKeyboardFocus() then
        self.TextArea:SetText(tostring(value))
    end
    
	self:OnValueChanged(value)
end

function numslider_tbl:GetMin()
    return self.min
end
function numslider_tbl:SetMin(min)
    self.min = min
    self:UpdateNotches()
end

function numslider_tbl:GetMax()
    return self.max
end
function numslider_tbl:SetMax(max)
    self.max = max
    self:UpdateNotches()
end

function numslider_tbl:SetMinMax(min, max)
    self.min = min
    self.max = max
    self:UpdateNotches()
end

function numslider_tbl:GetRange()
    return self.max - self.min
end

function numslider_tbl:GetDecimals()
    return self.decimals
end
function numslider_tbl:SetDecimals(dnum)
    self.decimals = math.Round(dnum)
end

function numslider_tbl:TranslateSliderValues(x, y)
    local value = x * self:GetRange() + self:GetMin()
    value = math.Round(value, self.decimals)
    
    if self.TextArea ~= vgui.GetKeyboardFocus() then
        self.TextArea:SetText(tostring(value))
    end
    
    self:OnValueChanged(value)
    
    return (value - self:GetMin()) / self:GetRange(), y
end

function numslider_tbl:UpdateNotches()
    local range = self:GetRange()
    self.Slider:SetNotches(nil)
    
    if range < self:GetWide()/4 then
        return self.Slider:SetNotches(range)
    else
        self.Slider:SetNotches(self:GetWide()/4)
    end
end

numslider_tbl.OnValueChanged = function() end

vgui.RegisterTable(numslider_tbl, "Panel")


----------------------------------------------------------------------
-- Color scheme template											--
----------------------------------------------------------------------

local coltemplate_tbl = {}

function coltemplate_tbl:Init()
    self:SetSize(16, 16)
	self:SetCursor("hand")
end

function coltemplate_tbl:SetupColors(col1, col2, col3)
    self.color1 = col1
    self.color2 = col2
	self.color3 = col3
end

function coltemplate_tbl:OnMousePressed(mousecode)
	if mousecode == MOUSE_LEFT then
		self:MouseCapture(true)
		self.pressed = true
	end
end
function coltemplate_tbl:OnMouseReleased(mousecode)
	self:MouseCapture(false)
	self.pressed = false
	
	if self:IsHovered() then
		GRadar.Settings["Color_Ring"] = self.color1
		GRadar.Settings["Color_InnerRing"] = self.color1
		GRadar.Settings["Color_Circle"] = self.color2
		GRadar.Settings["Color_Glow"] = self.color3
	end
end

function coltemplate_tbl:Paint(w, h)
    if self:IsHovered() then
        setDrawColor(0,200,255)
    else
        setDrawColor(170)
    end
    surface.DrawOutlinedRect(0, 0, w, h)
    
    surface.SetDrawColor(self.color1)
    surface.DrawRect(1, 1, w - 2, h - 2)
    
    surface.SetDrawColor(self.color2)
    surface.DrawRect(4, 4, w - 8, h - 8)
end

vgui.RegisterTable(coltemplate_tbl, "Panel")


----------------------------------------------------------------------
-- Color selector button											--
----------------------------------------------------------------------

local cols_sel

local cols_col_default = Color(210,210,210,255)
local cols_col_selected = Color(185,185,185,255)
local cols_col_hovered = Color(220,220,220,255)
local cols_col_pressed = Color(160,180,200,255)

local colselect_tbl = {}

function colselect_tbl:Init()
	self:SetContentAlignment(5)
	
	self:SetMouseInputEnabled(true)
	self:SetCursor("hand")
	
	self:SetSize(60, 20)
	self:SetColor(Color(65,65,65))
	
    self:SetFont("DermaDefault")
	
	self:SetDrawBackground(true)
    self.bgcolor = cols_col_default
end

function colselect_tbl:OnMousePressed(mousecode)
    if mousecode == MOUSE_LEFT or mousecode == MOUSE_MIDDLE then
        self:MouseCapture(true)
		self.pressed = true
		
		self.bgcolor = cols_col_pressed
    end
end
function colselect_tbl:OnMouseReleased(mousecode)
    self:MouseCapture(false)
	self.pressed = false
    
    if self:IsHovered() then
		if cols_sel ~= self then
			self.selected = true
			cols_sel.selected = false
			
			self.panel:Show()
			cols_sel.panel:Hide()
			
			cols_sel.bgcolor = cols_col_default
			self.bgcolor = cols_col_selected
			
			cols_sel = self
		else
			self.bgcolor = cols_col_selected
		end
	else
		self.bgcolor = self.selected and cols_col_selected or cols_col_default
    end
end

function colselect_tbl:OnCursorEntered()
	if not self.selected and not self.pressed then
		self.bgcolor = cols_col_hovered
	end
end
function colselect_tbl:OnCursorExited()
	if not self.pressed then
		self.bgcolor = self.selected and cols_col_selected or cols_col_default
	end
end

function colselect_tbl:Paint(w, h)
	surface.SetDrawColor(self.bgcolor)
	surface.DrawRect(0, 0, w, h)
	
	return false
end

vgui.RegisterTable(colselect_tbl, "DLabel")


----------------------------------------------------------------------
-- Category button													--
----------------------------------------------------------------------

local catb_sel

local catb_col_default = Color(135,135,135,255)
local catb_col_selected = Color(95,125,155,255)
local catb_col_hovered = Color(120,150,180,255)--155,155,155,255)
local catb_col_pressed = catb_col_selected--Color(120,150,180,255)

local catbutton_tbl = {}

function catbutton_tbl:Init()
	self:SetMouseInputEnabled(true)
	self:SetCursor("hand")
	
	self:SetSize(90, 40)
	
    self:SetFont("GRadar_CategoryName")
    self:SetColor(catb_col_default)
end

function catbutton_tbl:OnMousePressed(mousecode)
    if mousecode == MOUSE_LEFT or mousecode == MOUSE_MIDDLE then
        self:MouseCapture(true)
		self.pressed = true
		
		self:SetColor(catb_col_pressed)
    end
end
function catbutton_tbl:OnMouseReleased(mousecode)
    self:MouseCapture(false)
	self.pressed = false
    
    if self:IsHovered() then
		if catb_sel ~= self then
			self.selected = true
			catb_sel.selected = false
			
			self.panel:Show()
			catb_sel.panel:Hide()
			
			catb_sel:SetColor(catb_col_default)
			self:SetColor(catb_col_selected)
			
			catb_sel = self
		end
	else
		self:SetColor(self.selected and catb_col_selected or catb_col_default)
    end
end

function catbutton_tbl:OnCursorEntered()
	if not self.selected and not self.pressed then
		self:SetColor(catb_col_hovered)
	end
end
function catbutton_tbl:OnCursorExited()
	if not self.pressed then
		self:SetColor(self.selected and catb_col_selected or catb_col_default)
	end
end

vgui.RegisterTable(catbutton_tbl, "DLabel")


----------------------------------------------------------------------
-- Common locals													--
----------------------------------------------------------------------

local w, h = 465, 402
local frame


----------------------------------------------------------------------
-- Menu completion													--
----------------------------------------------------------------------

local pnlOnMousePressed = function() frame:OnMousePressed() end
local pnlOnMouseReleased = function() frame:OnMouseReleased() end

local x, y
local panel
local lastcatb

local function newCategory(name)
	x, y = 0, 0
	
	panel = frame:Add("Panel")
	panel:SetPos(162, 130)
	panel:SetSize(w - 162, h - 130)
	
	panel.OnMousePressed = pnlOnMousePressed
	panel.OnMouseReleased = pnlOnMouseReleased
	
	panel:SetVisible(lastcatb == nil)
	
	local button = frame:Add(catbutton_tbl)
	button:SetText(name)
	
	button.panel = panel
	
	if lastcatb then
		local x, y = lastcatb:GetPos()
		button:SetPos(x, y + 40)
	else
		catb_sel = button
		button.selected = true
		button:OnCursorExited()
		button:SetPos(37, 120)
	end
	
	lastcatb = button
end

local function catEnd()
	lastcatb = nil
end

local function addLabel(name)
	local label = panel:Add("DLabel")
	label:SetPos(x, y)
	label:SetFont("GRadar_OptionText")
	label:SetColor(Color(90,90,90))
	label:SetText(name)
	label:SizeToContents()
	
	y = y + 32
	
	return y - 32
end

local function addNumSlider(name, cvar_name, minv, maxv)
	local numslider = panel:Add(numslider_tbl)
	numslider:SetPos(x + 88, y - 6)
	numslider:SetMinMax(minv, maxv)
	
	--numslider.TextArea:SetConVar(cvar_name)
	--numslider.Slider:SetConVar(cvar_name)
	
	numslider:SetValue(cvars.Number(cvar_name))
	
	numslider.OnValueChanged = function(self, value)
		RunConsoleCommand(cvar_name, tostring(value))
	end
	
	cvars.AddChangeCallback(cvar_name, function(name, oldval, newval)
		numslider:SetValue(tonumber(newval) or 0)
	end, "GRadar_Menu")
	
	numslider.OnRemove = function(self)
		cvars.RemoveChangeCallback(cvar_name, "GRadar_Menu")
	end
	
	addLabel(name)
end

local function addCheckBox(name, cvar_name)
	local checkbox = panel:Add("DCheckBox")
	checkbox:SetPos(x + 225--[[98]], y + 2)
	checkbox:SetConVar(cvar_name)
	
	addLabel(name)
end

local function addComboBox(name, cvar_name, options)
	local combobox = panel:Add("DComboBox")
	combobox:SetPos(x + 140--[[98]], y)
	combobox:SetSize(100, 20)
	
	local curval = cvars.String(cvar_name)
	local n = 1
	
	for k, v in pairs(options) do
		combobox:AddChoice(k, v, v == curval)
		n = n + 1
	end
	
	--combobox:SetConVar(cvar_name)
	
	combobox.OnSelect = function(self, id, value, data)
		RunConsoleCommand(cvar_name, tostring(data))
	end
	
	cvars.AddChangeCallback(cvar_name, function(name, oldval, newval)
		if newval == combobox:GetText() then return end
		
		for i = 1, n do
			if combobox:GetOptionText(i) == newval then
				combobox:SetText(newval)
				break
			end
		end
	end, "GRadar_Menu")
	
	combobox.OnRemove = function(self)
		cvars.RemoveChangeCallback(cvar_name, "GRadar_Menu")
	end
	
	addLabel(name)
end

local function createColorMixer(cvar_name, noalpha)
	local colmixer = panel:Add("DColorMixer")
	--colmixer:SetPos(x + 20, y)
	colmixer:SetSize(noalpha and 176 or 196, 92)
	colmixer:SetPalette(false)
	
	if noalpha then
		colmixer:SetAlphaBar(false)
	end
	
	local curval = cvars.String(cvar_name)
	
	local r, g, b, a = string.match(curval, "(%d+) (%d+) (%d+) (%d+)")
	if r then
		colmixer:SetColor(Color(r, g, b, a))
	end
	
	colmixer.ValueChanged = function(self, col)
		RunConsoleCommand(cvar_name,
			string.format("%d %d %d %d", col.r, col.g, col.b, col.a))
	end
	
	cvars.AddChangeCallback(cvar_name, function(name, oldval, newval)
		if newval == tostring(colmixer:GetColor()) then return end
		
		local r, g, b, a = string.match(newval, "(%d+) (%d+) (%d+) (%d+)")
		if r then
			colmixer:SetColor(Color(r, g, b, a))
		end
	end, "GRadar_Menu")
	
	colmixer.OnRemove = function(self)
		cvars.RemoveChangeCallback(cvar_name, "GRadar_Menu")
	end
	
	return colmixer
end

local function addSchemeEditor(colmixers)
	y = y + 8
	
	for i = 1, #colmixers do
		local tbl = colmixers[i]
		
		local button = panel:Add(colselect_tbl)
		button:SetPos(x, y + (i - 1) * 21 + 4)
		button:SetText(tbl[1])
		
		button.panel = createColorMixer(tbl[2], tbl[3])
		button.panel:SetPos(x + 74, y)
		
		if i == 1 then
			cols_sel = button
			button.selected = true
			button:OnCursorExited()
		else
			button.panel:Hide()
		end
		
		i = i + 1
	end
	
	y = y + 40
end


----------------------------------------------------------------------
-- Menu creation													--
----------------------------------------------------------------------

concommand.Add("gr_menu", function()
	frame = vgui.CreateFromTable(frame_tbl)
	frame:SetSize(w, h)
	frame:Center()
	frame:MakePopup()

	local but_close = frame:Add(cbutton_tbl)
	but_close:SetSize(34,34)
	but_close:SetPos(w - but_close:GetWide() - 3, 3)
	but_close:SetMouseInputEnabled(true)
	
	local enabled_bool = frame:Add("DCheckBoxLabel")
	enabled_bool:SetPos(w-95,65)
	enabled_bool:SetText("Enabled")
	enabled_bool:SetDark(true)
	enabled_bool:SetConVar("gradar_enabled")
	
	
	newCategory("Layout")
		addNumSlider("X", "gradar_pos_x", 0, ScrW())
		addNumSlider("Y", "gradar_pos_y", 0, ScrH())
		addNumSlider("Size", "gradar_size", 100, 800)
	
	newCategory("Scaling")
		addNumSlider("Radius", "gradar_distance", 100, 2400)
		addCheckBox("Speed scaling", "gradar_distance_variable")
	
	newCategory("Map")
		addCheckBox("Draw map", "gradar_render_map")
		addCheckBox("Location name", "gradar_location")
	
	newCategory("Style")
		addComboBox("Ring style", "gradar_ring_style",
			{ ["Bordered"] = "0", ["Plain"] = "1", ["Double"] = "2" })
		addCheckBox("Glow", "gradar_glow")
		addCheckBox("Shadow", "gradar_shadow")
		
		local y = addLabel("Themes")
		
		local themes = {
			{color_white, color_white, Color(92,200,240,150)},
			{Color(192,230,255), Color(32,64,94,160), Color(0,0,0,130)},
			{color_black, Color(85,85,85,170), Color(130,130,130,150)},
			{color_black, Color(65,65,40,150), Color(135,135,0,55)},
			{Color(0,165,215), Color(60,45,90,130), Color(60,60,155,55)},
			{Color(210,95,215), Color(10,190,190,50), Color(120,10,135,70)},
		}
		for i = 1, #themes do
			local col_e = panel:Add(coltemplate_tbl)
			col_e:SetPos(98 + (i-1)*(24), y)
			col_e:SetupColors(unpack(themes[i]))
		end
		
		addSchemeEditor({
			{"Ring", "gradar_col_ring", true},
			{"Inner ring", "gradar_col_inner_ring", true},
			{"Circle", "gradar_col_circle"},
			{"Glow", "gradar_col_glow"}
		})
	
	newCategory("Misc")
		addCheckBox("Fullscreen animation", "gradar_fs_animation")
		addCheckBox("Zero sign", "gradar_zero_sign")
	
	newCategory("Help")
		local text = panel:Add("DLabel")
		text:SetSize(panel:GetSize())
		text:SetAutoStretchVertical(true)
		text:SetFont("GRadar_OptionText")
		text:SetColor(Color(75,75,75))
		text:SetText([[[ GRadar v1.0 made via Gram Framework. ]

Some commands you can bind:
  * gr_menu * (this menu)
  * gr_overview * (fullscreen overview)
  * +gr_overview * (an overview that replaces
radar)

All of the settings' CVars are presented in
this menu. They start with gradar_*]])
	
	catEnd()
end)
