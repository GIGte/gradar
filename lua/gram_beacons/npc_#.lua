BEACON.Label = nil
BEACON.Sprite = Gram.BeaconTextureID("be_square")
BEACON.Color = Color(255,65,65)
BEACON.Size = 8

BEACON.ShouldPoll = true
BEACON.ShouldRemain = false
BEACON.ScaleDependent = false
BEACON.CanDiminish = false
BEACON.CanRotate = false
BEACON.ShowViewDirection = true

function BEACON:OnInitialize()
	self.Label = self.Entity:GetClass()
end

function BEACON:CheckEntity(entity)
	return entity:IsNPC()
end
