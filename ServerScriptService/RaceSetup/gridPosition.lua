-- @ScriptType: Script
local replicatedStorage = game:GetService("ReplicatedStorage")
local map1 = workspace:WaitForChild("Map1")
local startingGrid = map1:WaitForChild("StartingGrid")
local carTemplate = replicatedStorage:WaitForChild("car_1")
local joinEvent = replicatedStorage:WaitForChild("JoinRace")

local usedPositions = {}

local function getAvailableGridPosition()
	for i = 1, #startingGrid:GetChildren() do
		local part = startingGrid:FindFirstChild("Position" .. i)
		if part and not usedPositions[i] then
			usedPositions[i] = true
			print("[Grid] Assigned Position" .. i)
			return part, i
		end
	end
	warn("[Grid] No available grid positions")
	return nil, nil
end

local function setAnchoredState(model, state)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = state
		end
	end
end

local function spawnCarForPlayer(player)
	print("[Join] Player requested to join:", player.Name)

	local gridPart, index = getAvailableGridPosition()
	if not gridPart then return end

	local car = carTemplate:Clone()
	car.Name = player.Name .. "_Car"
	car.Parent = workspace

	local desiredCFrame = (gridPart.CFrame * CFrame.Angles(0, math.rad(180), 0)) + Vector3.new(0, 5, 0)
	
	print("[Car] Intended Grid Position:", gridPart.Position)
	print("[Car] Intended Car CFrame Position:", desiredCFrame.Position)

	car:SetPrimaryPartCFrame(desiredCFrame)
	setAnchoredState(car, true)
	print("[Car] All parts anchored (locked).")

	local seat = car:FindFirstChildWhichIsA("VehicleSeat", true)
	if not seat then
		warn("[Seat] No VehicleSeat found in car!")
	end

	task.delay(1, function()
		local character = player.Character or player.CharacterAdded:Wait()
		character:WaitForChild("HumanoidRootPart", 5)
		character:WaitForChild("Humanoid", 5)

		local root = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not root or not humanoid then
			warn("[Character] Missing HumanoidRootPart or Humanoid")
			return
		end

		local characterCFrame = gridPart.CFrame + Vector3.new(0, 6, 0)
		print("[Character] Moving player to:", characterCFrame.Position)
		character:SetPrimaryPartCFrame(characterCFrame)

		task.delay(0.2, function()
			if seat and seat:IsDescendantOf(workspace) then
				print("[Seat] Attempting to sit character")
				seat:Sit(humanoid)
				local CarScript = car:FindFirstChild("CarScript")
				local localCarScript = CarScript:FindFirstChild("LocalCarScript")
				
				if localCarScript then
					local clone = localCarScript:Clone()
					clone.Parent = player:WaitForChild("PlayerGui")
					clone.Car.Value = car
					clone.Disabled = false
					print("[LocalCarScript] Injected and activated for", player.Name)
				else
					warn("[LocalCarScript] Missing from car:", car.Name)
				end
			else
				warn("[Seat] Seat not found in workspace")
				return
			end

			-- Unanchor car after player seated
			setAnchoredState(car, false)
			print("[Car] Car unanchored — ready for physics.")
			
		end)
	end)

	-- Now set network ownership (allowed because car is unanchored)
	task.delay(0.1, function()
		if seat and not seat.Anchored then
			seat:SetNetworkOwner(player)
			print("[Seat] Network owner set to:", player.Name)
		else
			warn("[Seat] Could not set network ownership — seat is anchored or missing")
		end
	end)

	car.AncestryChanged:Connect(function()
		if not car:IsDescendantOf(game) then
			usedPositions[index] = nil
			print("[Cleanup] Freed grid slot Position" .. index)
		end
	end)

	print("[Join] " .. player.Name .. " joined the race at grid position " .. index)
end



joinEvent.OnServerEvent:Connect(spawnCarForPlayer)
