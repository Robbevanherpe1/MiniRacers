-- @ScriptType: LocalScript
local player = game.Players.LocalPlayer
local cashicon = script.Parent:WaitForChild("stats"):WaitForChild("Coins")
local playerIcon = script.Parent:WaitForChild("stats"):WaitForChild("PlayerIcon")
local playerNameIcon = script.Parent:WaitForChild("stats"):WaitForChild("PlayerName")
local stats = player:WaitForChild("leaderstats")
local coins = stats:WaitForChild("Coins")
local AddRewardEvent = game.ReplicatedStorage:WaitForChild("AddReward")

playerIcon.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=420&height=420&format=png"
playerNameIcon.Text = player.Name
cashicon.Text = coins.Value


local function UpdateCoins()
	cashicon.Text = coins.Value
end



AddRewardEvent.OnClientEvent:Connect(UpdateCoins)