
GRadar = { _VERSION = "1.0" }

include("gradar_config.lua")

if SERVER then
	AddCSLuaFile("gradar.lua")
	AddCSLuaFile("gradar_config.lua")
	AddCSLuaFile("gradar_settings.lua")
	
	if GRadar.Config.UseMenu then
		AddCSLuaFile("gradar_menu.lua")
	end
	
	if GRadar.Config.ForceDownload then
		for k, f in pairs(file.Find("materials/gr_content/*", "GAME")) do
			resource.AddFile("materials/gr_content/" .. f)
		end
	end
	
	if GRadar.Config.ForceDownloadOverview then
		local mapname = game.GetMap()
		local path = "materials/gr_overviews/" .. mapname .. "/"
		
		for k, f in pairs(file.Find(path .. "*", "GAME")) do
			resource.AddFile(path .. f)
		end
	end
	
	include("gram/gram_sv.lua")
	
	--GRadar = nil
	
	return
end

include("gram/gram_cl.lua")
include("gradar.lua")

if GRadar.Config.UseMenu then
	include("gradar_menu.lua")
end

if GRadar.Config.UseQMenu then
	-- TODO?
end
