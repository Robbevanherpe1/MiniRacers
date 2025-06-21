-- @ScriptType: LocalScript
local p = game.Players.LocalPlayer
local c = p.Character or p.CharacterAdded:Wait()
local h = c:WaitForChild("Humanoid")
local root = c:WaitForChild("HumanoidRootPart")
local car = script:WaitForChild("Car").Value
local stats = car:WaitForChild("Configurations")
local Raycast = require(car.CarScript.RaycastModule)
local cam = workspace.CurrentCamera
local UIS = game:GetService("UserInputService")

local isFrozen = true

local startSignal = game:GetService("ReplicatedStorage"):WaitForChild("Start")
startSignal.OnClientEvent:Connect(function()
	isFrozen = false
end)

local tune = {
	Acceleration = {targetSpeedMultiplier = 1, response = 0.05, velocityBlend = 0.1},
	Turning = {turnSpeedMultiplier = 1, response = 0.1, turnRateCap = math.rad(90), turnThreshold = 1},
	Suspension = {stiffnessMultiplier = 1, dampingMultiplier = 1},
	FP = {offset = Vector3.new(0, 3, 0.5), sens = 0.002, pMin = -0.2, pMax = 0.2},
	TP = {offset = Vector3.new(0, -20, -30), smooth = 0.05}
}

h.JumpPower = 0
h.AutoJumpEnabled = false
h:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

local move = Vector2.zero
car.DriveSeat.Changed:Connect(function(prop)
	if prop == "Steer" then
		move = Vector2.new(car.DriveSeat.Steer, move.Y)
	elseif prop == "Throttle" then
		move = Vector2.new(move.X, car.DriveSeat.Throttle)
	end
end)

local totalMass = 0
for _, v in pairs(car:GetChildren()) do
	if v:IsA("BasePart") then
		totalMass += v:GetMass() * 196.2
	end
end

local force = totalMass * stats.Suspension.Value * tune.Suspension.stiffnessMultiplier
local damping = force / stats.Bounce.Value * tune.Suspension.dampingMultiplier

local vel = Instance.new("BodyVelocity", car.Chassis)
vel.velocity, vel.maxForce = Vector3.zero, Vector3.zero
local ang = Instance.new("BodyAngularVelocity", car.Chassis)
ang.angularvelocity, ang.maxTorque = Vector3.zero, Vector3.zero

local rot, spd, turn = 0, 0, 0
local yaw, pitch = 0, 0
local fp = false

cam.CameraType = Enum.CameraType.Scriptable
local smPos = root.Position
local smLook = root.Position

local keep = {
	LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
	RightUpperArm = true, RightLowerArm = true, RightHand = true,
	["Left Arm"] = true, ["Right Arm"] = true
}

local function showBody()
	for _, pt in ipairs(c:GetDescendants()) do
		if pt:IsA("BasePart") or pt:IsA("Decal") then
			pt.LocalTransparencyModifier = 0
		end
	end
end

local function hideBody()
	for _, pt in ipairs(c:GetDescendants()) do
		if (pt:IsA("BasePart") or pt:IsA("Decal")) and not keep[pt.Name] then
			pt.LocalTransparencyModifier = 1
		end
	end
end

local function setFP()
	fp = true
	UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
	UIS.MouseIconEnabled = false
	p.CameraMinZoomDistance, p.CameraMaxZoomDistance = 0, 0
	hideBody()
end

local function setTP()
	fp = false
	UIS.MouseBehavior = Enum.MouseBehavior.Default
	UIS.MouseIconEnabled = true
	p.CameraMaxZoomDistance = 400
	showBody()
end

setTP()

UIS.InputBegan:Connect(function(i, g)
	if g then
		return
	end
	if i.KeyCode == Enum.KeyCode.V then
		if fp then
			setTP()
		else
			yaw, pitch = 0, 0
			setFP()
		end
	end
end)

UIS.InputChanged:Connect(function(i, g)
	if g or not fp then
		return
	end
	if i.UserInputType == Enum.UserInputType.MouseMovement then
		yaw -= i.Delta.X * tune.FP.sens
		pitch = math.clamp(pitch - i.Delta.Y * tune.FP.sens, tune.FP.pMin, tune.FP.pMax)
	end
end)

local function thruster(t)
	local thrust = t:FindFirstChild("BodyThrust") or Instance.new("BodyThrust", t)
	local hit, pos = Raycast.new(t.Position, t.CFrame:VectorToWorldSpace(Vector3.new(0, -1, 0)) * stats.Height.Value)
	local h = (pos - t.Position).Magnitude
	if hit and hit.CanCollide then
		thrust.force = Vector3.new(0, (stats.Height.Value - h)^2 * (force / stats.Height.Value^2), 0)
		local dmp = t.CFrame:ToObjectSpace(CFrame.new(t.Velocity + t.Position)).p * damping
		thrust.force -= Vector3.new(0, dmp.Y, 0)
	else
		thrust.force = Vector3.zero
	end
	local w = t:FindFirstChild("WheelWeld")
	if w then
		w.C0 = CFrame.new(0, -math.min(h, stats.Height.Value * 0.8) + w.Part1.Size.Y / 2, 0)
		local off = car.Chassis.CFrame:Inverse() * t.CFrame
		local sp = car.Chassis.CFrame:VectorToObjectSpace(car.Chassis.Velocity)
		if off.Z < 0 then
			local d = sp.Z > 0 and -1 or 1
			w.C0 *= CFrame.Angles(0, car.Chassis.RotVelocity.Y / 2 * d, 0)
		end
		w.C0 *= CFrame.Angles(rot, 0, 0)
	end
end

local function grounded()
	local hit = Raycast.new(
		(car.Chassis.CFrame * CFrame.new(0, 0, car.Chassis.Size.Z / 2 - 1)).p,
		car.Chassis.CFrame:VectorToWorldSpace(Vector3.new(0, -1, 0)) * (stats.Height.Value + 0.2))
	return hit and hit.CanCollide
end

while game:GetService("RunService").Heartbeat:Wait()
	and car:FindFirstChild("DriveSeat")
	and c.Humanoid.SeatPart == car.DriveSeat do

	game:GetService("RunService").RenderStepped:Wait()

	if fp then
		cam.CFrame = car.DriveSeat.CFrame
			* CFrame.Angles(0, yaw, 0)
			* CFrame.Angles(pitch, 0, 0)
			* CFrame.new(tune.FP.offset)
	else
		local tgt = root.Position + root.CFrame:VectorToWorldSpace(-tune.TP.offset)
		smPos = smPos:Lerp(tgt, tune.TP.smooth)
		smLook = smLook:Lerp(root.Position, tune.TP.smooth)
		cam.CFrame = CFrame.new(smPos, smLook)
	end

	if grounded() then
		if isFrozen then
			spd = 0
			turn = 0
			root.Velocity = Vector3.zero
			root.RotVelocity = Vector3.zero
		else
			local tSpd = move.Y * stats.Speed.Value * tune.Acceleration.targetSpeedMultiplier
			spd += (tSpd - spd) * tune.Acceleration.response
			spd = math.clamp(spd, -stats.Speed.Value * tune.Acceleration.targetSpeedMultiplier, stats.Speed.Value * tune.Acceleration.targetSpeedMultiplier)

			root.Velocity = root.Velocity:Lerp(root.CFrame.LookVector * spd, tune.Acceleration.velocityBlend)

			local loc = -root.CFrame:VectorToObjectSpace(root.Velocity).Z
			local tTurn = 0
			if math.abs(loc) > tune.Turning.turnThreshold then
				tTurn = -move.X * loc * stats.TurnSpeed.Value * tune.Turning.turnSpeedMultiplier
				tTurn = math.clamp(tTurn, -tune.Turning.turnRateCap, tune.Turning.turnRateCap)
			end
			turn += (tTurn - turn) * tune.Turning.response

			local rVel = root.CFrame:VectorToWorldSpace(Vector3.new(spd / 50, 0, 0))
				+ root.CFrame:VectorToWorldSpace(Vector3.new(0, turn, 0))
			root.RotVelocity = root.RotVelocity:Lerp(rVel, 0.1)
			rot += math.rad(spd / 5)
		end
	end

	for _, p2 in pairs(car:GetChildren()) do
		if p2.Name == "Thruster" then
			thruster(p2)
		end
	end
end

UIS.MouseBehavior = Enum.MouseBehavior.Default
UIS.MouseIconEnabled = true
p.CameraMaxZoomDistance = 400
h.JumpPower = 50
h.AutoJumpEnabled = true
h:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
showBody()

for _, v in pairs(car:GetChildren()) do
	if v:FindFirstChild("BodyThrust") then
		v.BodyThrust:Destroy()
	end
end

vel:Destroy()
ang:Destroy()
cam.CameraType = Enum.CameraType.Custom
script:Destroy()
