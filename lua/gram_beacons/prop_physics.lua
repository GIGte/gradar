BEACON.Label = nil
BEACON.Sprite = Gram.BeaconTextureID("be_hqrect")
BEACON.Color = Color(250,250,130,200)
BEACON.Size = 10

BEACON.ShouldPoll = true
BEACON.ShouldRemain = false
BEACON.ScaleDependent = true
BEACON.CanDiminish = true
BEACON.CanRotate = true
BEACON.ShowViewDirection = false

BEACON.AngleOffset = 90

BEACON.Priority = Gram.EPriority.Low

function BEACON:OnInitialize()
	self.Size = math.Clamp(self.Entity:BoundingRadius()/6, 4, 80)
	--self.Entity:GetPhysicsObject():GetMagnitude()
end
