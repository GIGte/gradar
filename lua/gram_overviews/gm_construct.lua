
local zones = {
	{
		name = "Colourable Room",
			Vector(-3300, -4580, -350), Vector(-790, -2570, 170),
		texture_id = Gram.OverviewTextureID_R("gm_construct", "_ug"),
		scale = 10.8,
		pos_x = -7228,
		pos_y = 6466,
	},
	{
		name = "The Nether",
			Vector(-3000, -2570, -700), Vector(-1150, 130, -165),
		texture_id = Gram.OverviewTextureID_R("gm_construct", "_ug"),
		scale = 10.8,
		pos_x = -7228,
		pos_y = 6466,
	},
	
	{
		name = "Ambient",
			vector_origin, vector_origin,
		texture_id = Gram.OverviewTextureID_R("gm_construct"),
		scale = 10.8,
		pos_x = -7228,
		pos_y = 6466,
		
		
	}
}

Gram.Overview.Return(zones)
