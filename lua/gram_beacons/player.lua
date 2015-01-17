BEACON.Label = nil
BEACON.Sprite = Gram.BeaconTextureID("be_pointed")
BEACON.Color = color_white
BEACON.Size = 16

BEACON.ShouldPoll = true
BEACON.ShouldRemain = true
BEACON.ScaleDependent = false
BEACON.CanDiminish = false
BEACON.CanRotate = true
BEACON.ShowViewDirection = false

BEACON.Priority = Gram.EPriority.High

function BEACON:OnInitialize()
	self.Player = self.Entity
	self.Entity = nil
end

function BEACON:OnPoll()
	local ply = self.Player
	if ply:IsValid() then
		self.Label = ply:Nick()
		self.Color = team.GetColor(ply:Team())
		
		local angles = ply:EyeAngles()
		if ply == LocalPlayer() and ply:InVehicle() then
			angles = angles + ply:GetVehicle():GetAngles()
		end
		
		return ply:GetPos(), angles
	else
		return false--self:Dispose()
	end
end
