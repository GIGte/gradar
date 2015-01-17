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

BEACON.AngleOffset = 90

function BEACON:OnInitialize()
	--self.Label = self.Entity:GetClass()
end

function BEACON:CheckEntity(entity)
	return entity:GetNWInt("SCarSeat") == 0
end
