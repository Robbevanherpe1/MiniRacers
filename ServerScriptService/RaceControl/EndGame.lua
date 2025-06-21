-- @ScriptType: ModuleScript
local EndRace = {}
local RaceData = require(game.ServerScriptService.RaceControl.RaceData)
local AddRewardFn = require(game.ServerScriptService.PlayerData.AddReward)
local players = game:GetService("Players")

local resetUI = game.ReplicatedStorage:FindFirstChild("ResetRaceUI") or Instance.new("RemoteEvent", game.ReplicatedStorage)
resetUI.Name = "ResetRaceUI"

function EndRace.backToLobby(player, position)
	local workspaceService = game:GetService("Workspace")
	local car = workspaceService:FindFirstChild(player.Name .. "_Car")

	if player.Character then
		local humanoid = player.Character:FindFirstChild("Humanoid")
		if humanoid and humanoid.SeatPart and car and humanoid.SeatPart:IsDescendantOf(car) then
			humanoid.Sit = false
			task.wait()
		end
	end

	if car and car:IsA("Model") then
		car:Destroy()
	end

	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local spawn = workspaceService.Map1.Spawn.Spawn.SpawnLocation
		player.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)
	end

	RaceData.remove(player)
	AddRewardFn(player, position)

	if RaceData.getCount() == 0 then
		for _, p in ipairs(players:GetPlayers()) do
			p:SetAttribute("Lap", 0)
			p:SetAttribute("Checkpoint", 0)
			p:SetAttribute("FinishedRace", false)
			p:SetAttribute("RaceMode", 0)
			resetUI:FireClient(p)
			
		end
		print("[Server] ResetRaceUI fired to all clients")
	end
end

return EndRace