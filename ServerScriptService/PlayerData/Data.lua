-- @ScriptType: Script
local ProfileStore = require(game.ServerScriptService:WaitForChild("ProfileStore"))

local TEMPLATE = {Coins = 0, Level = 1}
local store = ProfileStore.New("PlayerStatsV1", TEMPLATE)
local profiles = {}

game.Players.PlayerAdded:Connect(function(player)
	local profile = store:StartSessionAsync(tostring(player.UserId))
	if not profile then
		player:Kick("Couldn't load your data")
		return
	end
	profile:Reconcile()
	profiles[player] = profile

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = profile.Data.Coins
	coins.Parent = leaderstats

	local level = Instance.new("NumberValue")
	level.Name = "Level"
	level.Value = profile.Data.Level
	level.Parent = leaderstats

	coins.Changed:Connect(function(v) profile.Data.Coins = v end)
	level.Changed:Connect(function(v) profile.Data.Level = v end)
end)

game.Players.PlayerRemoving:Connect(function(player)
	local profile = profiles[player]
	if profile then
		profile:Release()
		profiles[player] = nil
	end
end)
