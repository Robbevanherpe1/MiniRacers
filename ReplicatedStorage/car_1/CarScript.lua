-- @ScriptType: Script
local car = script.Parent
local stats = car.Configurations
local Raycast = require(script.RaycastModule)



local function UpdateThruster(thruster)
	-- Raycasting
	local hit, position = Raycast.new(thruster.Position, thruster.CFrame:vectorToWorldSpace(Vector3.new(0, -1, 0)) * stats.Height.Value) --game.Workspace:FindPartOnRay(ray, car)
	local thrusterHeight = (position - thruster.Position).magnitude

	-- Wheel
	local wheelWeld = thruster:FindFirstChild("WheelWeld")
	wheelWeld.C0 = CFrame.new(0, -math.min(thrusterHeight, stats.Height.Value * 0.8) + (wheelWeld.Part1.Size.Y / 2), 0)
	-- Wheel turning
	local offset = car.Chassis.CFrame:inverse() * thruster.CFrame
	local speed = car.Chassis.CFrame:vectorToObjectSpace(car.Chassis.Velocity)
	if offset.Z < 0 then
		local direction = 1
		if speed.Z > 0 then
			direction = -1
		end
		wheelWeld.C0 = wheelWeld.C0 * CFrame.Angles(0, (car.Chassis.RotVelocity.Y / 2) * direction, 0)
	end

	-- Particles
	if hit and thruster.Velocity.magnitude >= 5 then
		wheelWeld.Part1.ParticleEmitter.Enabled = true
	else
		wheelWeld.Part1.ParticleEmitter.Enabled = false
	end
end

car.DriveSeat.Changed:connect(function(property)
	if property == "Occupant" then
		if car.DriveSeat.Occupant then
			car.EngineBlock.Running.Pitch = 1
			car.EngineBlock.Running:Play()
		else
			car.EngineBlock.Running:Stop()
		end
	end
end)
