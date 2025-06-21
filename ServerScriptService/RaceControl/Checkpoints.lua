-- @ScriptType: Script
local Players = game:GetService("Players")
local RS      = game:GetService("ReplicatedStorage")

local RaceData  = require(script.Parent.RaceData)
local RaceLoop  = require(script.Parent.RaceLoop)
local EndRace   = require(script.Parent.EndGame)

local updateEP = RS:FindFirstChild("UpdateLeaderboard")
if not updateEP then
	updateEP = Instance.new("RemoteEvent")
	updateEP.Name   = "UpdateLeaderboard"
	updateEP.Parent = RS
end

-- hook each player once on join
Players.PlayerAdded:Connect(function(plr)
	task.wait(1)
	RaceLoop.startRaceLoop(plr)
end)

Players.PlayerRemoving:Connect(function(plr)
	RaceLoop.cleanupPlayer(plr)
end)

-- main loop: detect finishes and push leaderboard
while true do
	local data = {}
	for _, plr in ipairs(Players:GetPlayers()) do
		local lap = plr:GetAttribute("Lap") or 0
		local cp  = plr:GetAttribute("Checkpoint") or 0

		table.insert(data,{
			Name       = plr.Name,
			UserId     = plr.UserId,
			Lap        = lap,
			Checkpoint = cp,
		})

		-- finish when lap ≥ 3 and not yet flagged
		if lap > 0 and not plr:GetAttribute("FinishedRace") then
			plr:SetAttribute("FinishedRace", true)
			local place = RaceData.nextPlacement()
			plr:SetAttribute("Placement", place)
			EndRace.backToLobby(plr, place)
		end
	end

	table.sort(data, function(a,b)
		local ap = Players:FindFirstChild(a.Name)
		local bp = Players:FindFirstChild(b.Name)
		local aP = ap and ap:GetAttribute("Placement")
		local bP = bp and bp:GetAttribute("Placement")
		if aP and bP then
			return aP < bP
		elseif aP then
			return true
		elseif bP then
			return false
		else
			if a.Lap == b.Lap then
				return a.Checkpoint > b.Checkpoint
			end
			return a.Lap > b.Lap
		end
	end)

	updateEP:FireAllClients(data)
	task.wait(1)
end
