BEACON.Label = nil
BEACON.Sprite = Gram.BeaconTextureID("be_circle")
BEACON.Color = Color(255,130,50)
BEACON.Size = 10

BEACON.ShouldPoll = true
BEACON.ShouldRemain = false
BEACON.ScaleDependent = false
BEACON.CanDiminish = false
BEACON.CanRotate = false
BEACON.ShowViewDirection = false

function BEACON:OnInitialize()
	
end

function BEACON:OnAnimate()
	self.Size = (math.sin(CurTime()*30)+1)*2 + 10
end
