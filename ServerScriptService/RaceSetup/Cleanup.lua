-- @ScriptType: Script
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

Players.PlayerRemoving:Connect(function(player)
	local carName = player.Name .. "_Car"
	local car = Workspace:FindFirstChild(carName)

	if car and car:IsA("Model") then
		car:Destroy()
		print("[Cleanup] Removed car for", player.Name)
	end
end)
