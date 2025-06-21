-- @ScriptType: ModuleScript
return function(player, position)
	local stats = player:FindFirstChild("leaderstats")

	if not stats then return end

	local coins = stats:FindFirstChild("Coins")
	local level = stats:FindFirstChild("Level")
	
	if not coins or not level then return end

	if position == 1 then
		coins.Value += 5
		level.Value += 0.5
	elseif position == 2 then
		coins.Value += 3
		level.Value += 0.3
	elseif position == 3 then
		coins.Value += 2
		level.Value += 0.2
	else
		coins.Value += 1
		level.Value += 0.1
	end
	
	local AddRewardEvent = game.ReplicatedStorage:WaitForChild("AddReward")
	AddRewardEvent:FireClient(player)
end
