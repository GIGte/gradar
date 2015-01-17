
GRadar.Config = {

	UseMenu = true,
	UseQMenu = false,
	ForceDownload = true,
	ForceDownloadOverview = true,
	
	--[[
		You can reset settings' variables and
		manage them manually, avoiding CVars.
		
		To do so:
		1. Add CVar's name to the table below.
		2. Use rawset on GRadar.Settings to define
		your own field that won't be affected
		by the metatable.
	]]
	CVarEventsDeleted = {
		--"gradar_enabled"
	}

}