BEACON.Label = nil
BEACON.Sprite = Gram.BeaconTextureID("be_contri")
BEACON.Color = Color(100,255,100)
BEACON.Size = 30

BEACON.ShouldPoll = true
BEACON.ShouldRemain = false
BEACON.ScaleDependent = false
BEACON.CanDiminish = true
BEACON.CanRotate = true
BEACON.ShowViewDirection = false

function BEACON:OnInitialize()
	--self.Label = self.Entity.PrintName
	local tbl = list.Get("SCarVehicles")
	local entry = tbl[self.Entity:GetClass()]
	if entry then
		self.Label = entry.Name
	end
end
