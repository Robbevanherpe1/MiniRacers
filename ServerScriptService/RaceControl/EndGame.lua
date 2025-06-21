-- @ScriptType: ModuleScript
local EndRace = {}
local Players = game:GetService("Players")
local RS    = game:GetService("ReplicatedStorage")

local RaceData   = require(script.Parent.RaceData)
local RaceLoop   = require(script.Parent.RaceLoop)
local AddReward  = require(game.ServerScriptService.PlayerData.AddReward)

local resetUI = RS:FindFirstChild("ResetRaceUI")
if not resetUI then
	resetUI = Instance.new("RemoteEvent")
	resetUI.Name   = "ResetRaceUI"
	resetUI.Parent = RS
end

function EndRace.backToLobby(player, placement)
	local car = workspace:FindFirstChild(player.Name .. "_Car")
	if car and car:IsA("Model") then car:Destroy() end

	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local spawn = workspace.Map1.Spawn.Spawn.SpawnLocation
		player.Character.HumanoidRootPart.CFrame = spawn.CFrame + Vector3.new(0,5,0)
	end

	RaceData.remove(player)
	AddReward(player, placement)

	if RaceData.getCount() == 0 then
		-- last racer finished → reset for next race
		RaceData.reset()
		RaceLoop.resetAll()
		for _, plr in ipairs(Players:GetPlayers()) do
			RaceLoop.startRaceLoop(plr)
			resetUI:FireClient(plr)
		end
	end
end

return EndRace
