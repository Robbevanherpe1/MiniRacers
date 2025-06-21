-- @ScriptType: LocalScript
local gui = script.Parent
local mainUI = gui.MainUI
local raceUI = gui.RaceUI


-- remove offset for ui
mainUI.IgnoreGuiInset = true
raceUI.IgnoreGuiInset = true


-- join race
local joinraceButton = raceUI.StartButton.JoinRace
local replicatedStorage = game:GetService("ReplicatedStorage")
local joinEvent = replicatedStorage:WaitForChild("JoinRace")
local player = game.Players.LocalPlayer

joinraceButton.MouseButton1Click:Connect(function()
	joinEvent:FireServer()
	player:SetAttribute("RaceMode",1)
	
end)

-- hiden mainui

local driveButton = mainUI.Frame.Frame.Race

local function hideMainUI()
	mainUI.Enabled = false
	raceUI.StartButton.Visible = true

end

driveButton.MouseButton1Click:Connect(hideMainUI)




--hide/show race ui
local ReplicatedStorage = game:GetService("ReplicatedStorage")	
local startEvent = ReplicatedStorage:WaitForChild("Start")

local function showHideRaceUI()
	raceUI.StartButton.Visible = false
	raceUI.Leaderboard.Visible = true
	raceUI.Race.Visible = true
end


startEvent.OnClientEvent:Connect(showHideRaceUI)
joinraceButton.MouseButton1Click:Connect(showHideRaceUI)


-- hide/show leaderboard
local leaderboardButton = raceUI:WaitForChild("Leaderboard"):WaitForChild("close/open")

local leaderboard= raceUI:WaitForChild("Leaderboard"):WaitForChild("leaderboard")

local function hideShowLeaderboard()
	if leaderboard.Visible == true then
		leaderboard.Visible = false
		leaderboardButton.Text = "+"
	else
		leaderboard.Visible = true
		leaderboardButton.Text = "-"
	end

end


leaderboardButton.MouseButton1Click:Connect(hideShowLeaderboard)


-- reset after race

local resetUI = game.ReplicatedStorage:WaitForChild("ResetRaceUI")

resetUI.OnClientEvent:Connect(function()
	raceUI.Race.Visible = false
	wait(2)
	raceUI.Leaderboard.Visible = false
	raceUI.StartButton.Visible = true
	print("[Client] Race UI reset")
end)