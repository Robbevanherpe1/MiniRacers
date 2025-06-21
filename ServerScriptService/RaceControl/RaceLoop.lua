-- @ScriptType: ModuleScript
local RaceLoop = {}
local map1 = workspace:WaitForChild("Map1")
local checkpoints = map1:WaitForChild("Checkpoints")
local checkpointCount = #checkpoints:GetChildren()
local connections = {}

function RaceLoop.cleanupPlayer(player)
	if connections[player] then
		for _, conn in pairs(connections[player]) do
			conn:Disconnect()
		end
		connections[player] = nil
	end
end

function RaceLoop.resetAll()
	for player in pairs(connections) do
		RaceLoop.cleanupPlayer(player)
	end
end

function RaceLoop.startRaceLoop(player)
	RaceLoop.cleanupPlayer(player)
	connections[player] = {}
	player:SetAttribute("Lap", 0)
	player:SetAttribute("Checkpoint", 0)
	player:SetAttribute("FinishedRace", false)

	local currentCheckpoint = 0
	local lapCount = 0

	for i = 1, checkpointCount do
		local cp = checkpoints:FindFirstChild(tostring(i))
		if cp then
			connections[player][i] = cp.Touched:Connect(function(hit)
				local car = workspace:FindFirstChild(player.Name .. "_Car")
				if not car or not hit:IsDescendantOf(car) then return end

				-- next checkpoint in sequence?
				if i == currentCheckpoint + 1 then
					currentCheckpoint = i
					player:SetAttribute("Checkpoint", i)
					if i == 1 then
						lapCount += 1
						player:SetAttribute("Lap", lapCount)
					end

					-- wrap around from final → first?
				elseif currentCheckpoint == checkpointCount and i == 1 then
					currentCheckpoint = 1
					lapCount += 1
					player:SetAttribute("Checkpoint", 1)
					player:SetAttribute("Lap", lapCount)
				end
			end)
		end
	end
end

return RaceLoop
