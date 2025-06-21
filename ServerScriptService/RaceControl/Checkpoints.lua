-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local updateEvent = ReplicatedStorage:FindFirstChild("UpdateLeaderboard") or Instance.new("RemoteEvent")
updateEvent.Name = "UpdateLeaderboard"
updateEvent.Parent = ReplicatedStorage

local map1 = workspace:WaitForChild("Map1")
local checkpoints = map1:WaitForChild("Checkpoints")
local checkpointCount = #checkpoints:GetChildren()

local placementCounter = 0
local connections = {}
local raceActive = false

local function waitForCar(player)
	local carName = player.Name .. "_Car"
	while not workspace:FindFirstChild(carName) do
		task.wait(0.5)
	end
	return workspace:FindFirstChild(carName)
end

local function cleanupPlayer(player)
	if connections[player] then
		for _, c in pairs(connections[player]) do
			c:Disconnect()
		end
		connections[player] = nil
	end
end

local function startRaceLoop(player)
	cleanupPlayer(player)
	local currentCheckpoint = 0
	local lapCount = 0
	player:SetAttribute("Checkpoint", 0)
	player:SetAttribute("Lap", 0)
	connections[player] = {}
	for i = 1, checkpointCount do
		local checkpoint = checkpoints:FindFirstChild(i)
		if checkpoint then
			local idx = i
			connections[player][idx] = checkpoint.Touched:Connect(function(hit)
				local carNow = workspace:FindFirstChild(player.Name .. "_Car")
				if hit and carNow and hit:IsDescendantOf(carNow) then
					if idx > currentCheckpoint and idx < currentCheckpoint + 2 then
						if currentCheckpoint == 0 then
							lapCount += 1
							player:SetAttribute("Lap", lapCount)
						end
						currentCheckpoint = idx
						player:SetAttribute("Checkpoint", currentCheckpoint)
					elseif currentCheckpoint == checkpointCount and idx == 1 then
						lapCount += 1
						currentCheckpoint = idx
						player:SetAttribute("Lap", lapCount)
						player:SetAttribute("Checkpoint", currentCheckpoint)
					end
				end
			end)
		end
	end
end

local function checkForRaceMode()
	for _, p in ipairs(Players:GetPlayers()) do
		if p:GetAttribute("RaceMode") == 1 then
			return true
		end
	end
	return false
end

Players.PlayerAdded:Connect(function(player)
	task.wait(1)
	if player:GetAttribute("RaceMode") == 1 then
		startRaceLoop(player)
	end
	local first = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr:GetAttribute("RaceMode") == 1 then
			table.insert(first, {
				Name = plr.Name,
				UserId = plr.UserId,
				Lap = plr:GetAttribute("Lap") or 0,
				Checkpoint = plr:GetAttribute("Checkpoint") or 0,
			})
		end
	end
	table.sort(first, function(a, b)
		if a.Lap == b.Lap then
			return a.Checkpoint > b.Checkpoint
		end
		return a.Lap > b.Lap
	end)
	updateEvent:FireClient(player, first)
end)

Players.PlayerRemoving:Connect(function(player)
	cleanupPlayer(player)
end)

while true do
	if not checkForRaceMode() then
		if raceActive then
			for _, plr in ipairs(Players:GetPlayers()) do
				cleanupPlayer(plr)
			end
			raceActive = false
		end
		task.wait(1)
		continue
	end
	if not raceActive then
		placementCounter = 0
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr:GetAttribute("RaceMode") == 1 then
				startRaceLoop(plr)
			end
		end
		raceActive = true
	end
	local data = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr:GetAttribute("RaceMode") == 1 then
			table.insert(data, {
				Name = plr.Name,
				UserId = plr.UserId,
				Lap = plr:GetAttribute("Lap") or 0,
				Checkpoint = plr:GetAttribute("Checkpoint") or 0,
			})
			if (plr:GetAttribute("Lap") or 0) > 0 and not plr:GetAttribute("FinishedRace") then
				placementCounter += 1
				plr:SetAttribute("FinishedRace", true)
				plr:SetAttribute("Placement", placementCounter)
				local EndRace = require(game.ServerScriptService.RaceControl.EndGame)
				--updateEvent:FireAllClients(data)
				EndRace.backToLobby(plr, placementCounter)
			end
		end
	end
	table.sort(data, function(a, b)
		local ap = Players:FindFirstChild(a.Name)
		local bp = Players:FindFirstChild(b.Name)
		local aPlace = ap and ap:GetAttribute("Placement")
		local bPlace = bp and bp:GetAttribute("Placement")
		if aPlace and bPlace then
			return aPlace < bPlace
		elseif aPlace then
			return true
		elseif bPlace then
			return false
		else
			if a.Lap == b.Lap then
				return a.Checkpoint > b.Checkpoint
			end
			return a.Lap > b.Lap
		end
	end)
	updateEvent:FireAllClients(data)
	task.wait(1)
end
