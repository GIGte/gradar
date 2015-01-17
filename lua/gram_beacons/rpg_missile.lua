BEACON.Label = nil
BEACON.Sprite = Gram.BeaconTextureID("be_contri2")
BEACON.Color = Color(255,50,50)
BEACON.Size = 16

BEACON.ShouldPoll = true
BEACON.ShouldRemain = false
BEACON.ScaleDependent = false
BEACON.CanDiminish = false
BEACON.CanRotate = true
BEACON.ShowViewDirection = false

function BEACON:OnInitialize()
	
end

function BEACON:OnAnimate()
	self.Size = (math.sin(CurTime()*30)+1)*6 + 16
end
