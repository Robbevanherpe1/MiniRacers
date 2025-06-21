-- @ScriptType: LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local updateEvent = ReplicatedStorage:WaitForChild("UpdateLeaderboard")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local leaderboardFrame = script.Parent:WaitForChild("Leaderboard"):WaitForChild("leaderboard")
local nameLabels = {
	leaderboardFrame:WaitForChild("p1"):WaitForChild("name"),
	leaderboardFrame:WaitForChild("p2"):WaitForChild("name"),
	leaderboardFrame:WaitForChild("p3"):WaitForChild("name"),
	leaderboardFrame:WaitForChild("p4"):WaitForChild("name"),
	leaderboardFrame:WaitForChild("p5"):WaitForChild("name"),
}
local finishLabels = {
	leaderboardFrame:WaitForChild("p1"):WaitForChild("Finished"),
	leaderboardFrame:WaitForChild("p2"):WaitForChild("Finished"),
	leaderboardFrame:WaitForChild("p3"):WaitForChild("Finished"),
	leaderboardFrame:WaitForChild("p4"):WaitForChild("Finished"),
	leaderboardFrame:WaitForChild("p5"):WaitForChild("Finished"),
}
local placementLabels = {
	leaderboardFrame:WaitForChild("p1"):WaitForChild("Place"),
	leaderboardFrame:WaitForChild("p2"):WaitForChild("Place"),
	leaderboardFrame:WaitForChild("p3"):WaitForChild("Place"),
	leaderboardFrame:WaitForChild("p4"):WaitForChild("Place"),
	leaderboardFrame:WaitForChild("p5"):WaitForChild("Place"),
}
local imgLabels = {
	leaderboardFrame:WaitForChild("p1"):WaitForChild("ImageLabel"),
	leaderboardFrame:WaitForChild("p2"):WaitForChild("ImageLabel"),
	leaderboardFrame:WaitForChild("p3"):WaitForChild("ImageLabel"),
	leaderboardFrame:WaitForChild("p4"):WaitForChild("ImageLabel"),
	leaderboardFrame:WaitForChild("p5"):WaitForChild("ImageLabel"),
}
local currentLapLabel = leaderboardFrame:WaitForChild("CurentLap")
local function updateLeaderboard(data)
	for i = 1, 5 do
		local info = data[i]
		if info then
			local plr = Players:FindFirstChild(info.Name)
			local placement = plr and plr:GetAttribute("Placement")
			nameLabels[i].Text = info.Name
			finishLabels[i].Visible = placement ~= nil
			placementLabels[i].Visible = true
			imgLabels[i].Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. info.UserId .. "&width=420&height=420&format=png"
			imgLabels[i].Visible = true
		else
			nameLabels[i].Text = ""
			imgLabels[i].Visible = false
			placementLabels[i].Visible = false
			finishLabels[i].Visible = false
		end
	end
	for _,info in ipairs(data) do
		if info.UserId == localPlayer.UserId then
			currentLapLabel.Text = "L " .. (info.Lap or 0) .. "/3"
			break
		end
	end
end
updateEvent.OnClientEvent:Connect(updateLeaderboard)
