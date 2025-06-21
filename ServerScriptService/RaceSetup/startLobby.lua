-- @ScriptType: Script
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RaceData = require(game.ServerScriptService.RaceControl.RaceData)
local joinEvent = ReplicatedStorage:WaitForChild("JoinRace")
local startRaceEvent = ReplicatedStorage:FindFirstChild("Start")
if not startRaceEvent then
	startRaceEvent = Instance.new("RemoteEvent")
	startRaceEvent.Name = "Start"
	startRaceEvent.Parent = ReplicatedStorage
end
local s3 = workspace.Map1.Race_start["3"].uni0033
local s2 = workspace.Map1.Race_start["2"].uni0032
local s1 = workspace.Map1.Race_start["1"].uni0031
local function runCountdown()
	task.wait(5)
	s3.Transparency, s2.Transparency, s1.Transparency = 0,1,1
	task.wait(1.2)
	s3.Transparency, s2.Transparency, s1.Transparency = 1,0,1
	task.wait(1.2)
	s3.Transparency, s2.Transparency, s1.Transparency = 1,1,0
	task.wait(1.2)
	s3.Transparency, s2.Transparency, s1.Transparency = 1,1,1
	startRaceEvent:FireAllClients()
end
local function onJoin(player)
	player:SetAttribute("Placement", nil)
	player:SetAttribute("RaceMode", 1)
	RaceData.add(player)
	if RaceData.getCount() >= 1 then
		runCountdown()
	end
end
joinEvent.OnServerEvent:Connect(onJoin)
