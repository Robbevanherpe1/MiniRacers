-- @ScriptType: LocalScript
local gui = script.Parent
local mainUI = gui.MainUI
local raceUI = gui.RaceUI
mainUI.IgnoreGuiInset = true
raceUI.IgnoreGuiInset = true
local joinraceButton = raceUI.StartButton.JoinRace
local replicatedStorage = game:GetService("ReplicatedStorage")
local joinEvent = replicatedStorage:WaitForChild("JoinRace")
local player = game.Players.LocalPlayer
joinraceButton.MouseButton1Click:Connect(function()
	joinEvent:FireServer()
	player:SetAttribute("RaceMode",1)
end)
local driveButton = mainUI.Frame.Frame.Race
local function hideMainUI()
	mainUI.Enabled = false
	raceUI.StartButton.Visible = true
end
driveButton.MouseButton1Click:Connect(hideMainUI)
local startEvent = replicatedStorage:WaitForChild("Start")
local function showHideRaceUI()
	raceUI.StartButton.Visible = false
	raceUI.Leaderboard.Visible = true
	raceUI.Race.Visible = true
end
startEvent.OnClientEvent:Connect(showHideRaceUI)
joinraceButton.MouseButton1Click:Connect(showHideRaceUI)
local leaderboardButton = raceUI:WaitForChild("Leaderboard"):WaitForChild("close/open")
local leaderboard = raceUI:WaitForChild("Leaderboard"):WaitForChild("leaderboard")
local function hideShowLeaderboard()
	if leaderboard.Visible then
		leaderboard.Visible = false
		leaderboardButton.Text = "+"
	else
		leaderboard.Visible = true
		leaderboardButton.Text = "-"
	end
end
leaderboardButton.MouseButton1Click:Connect(hideShowLeaderboard)
local resetUI = replicatedStorage:WaitForChild("ResetRaceUI")
resetUI.OnClientEvent:Connect(function()
	raceUI.Race.Visible = false
	task.wait(2)
	raceUI.Leaderboard.Visible = false
	raceUI.StartButton.Visible = true
end)
