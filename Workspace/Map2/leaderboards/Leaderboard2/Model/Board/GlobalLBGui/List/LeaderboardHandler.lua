-- @ScriptType: Script
local dss = game:GetService("DataStoreService")
local ds = dss:GetOrderedDataStore("EggsOpenedData")
local resetTime = 30

local lbModel = script.Parent.Parent.Parent.Parent.Parent
local dummy1 = lbModel:WaitForChild("Dummy1")
local dummy2 = lbModel:WaitForChild("Dummy2")
local dummy3 = lbModel:WaitForChild("Dummy3")

local dum1Hum = dummy1:WaitForChild("Humanoid")
local dum2Hum = dummy2:WaitForChild("Humanoid")
local dum3Hum = dummy3:WaitForChild("Humanoid")

local storedValueName = "Cash"

local suffixes = {'','K','M','B','T','Qd','Qn','sx','Sp','O','N','de','Ud','DD','tdD','qdD','QnD','sxD','SpD','OcD','NvD','Vgn','UVg','DVg','TVg','qtV','QnV','SeV','SPG','OVG','NVG','TGN','UTG','DTG','tsTG','qtTG','QnTG','ssTG','SpTG','OcTG','NoAG','UnAG','DuAG','TeAG','QdAG','QnAG','SxAG','SpAG','OcAG','NvAG','CT'}
local function format(val)
	for i=1, #suffixes do
		if tonumber(val) < 10^(i*3) then
			return math.floor(val/((10^((i-1)*3))/100))/(100)..suffixes[i]
		end
	end
end

function removeRank(char)
	local head = char:WaitForChild("Head")
	local gui = head:FindFirstChild("LeaderboardRanks")

	if not gui then
		gui = game.ReplicatedStorage.LeaderboardRanks:Clone()
		gui.Parent = head
	end

	gui.CoinGod.Visible = false
end

function giveRank(char, place)
	local head = char:WaitForChild("Head")
	local gui = head:FindFirstChild("LeaderboardRanks")

	if not gui then
		gui = game.ReplicatedStorage.LeaderboardRanks:Clone()
		gui.Parent = head
	end

	gui.CoinGod.Visible = true
	gui.CoinGod.Text = "Top ".. place .." Cash"
end

function playEmoteForDummies()
	for i = 1, 3 do
		local dummy = lbModel:WaitForChild("Dummy".. i)
		if dummy then
			for i, v in pairs(dummy:GetChildren()) do
				if v:IsA("BasePart") then
					if v ~= dummy.PrimaryPart then
						v.CanCollide = false
						v.Anchored = false
					else
						local bodyV = Instance.new("BodyPosition",v)
						bodyV.Position = v.Position
						bodyV.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
						
						local bodyG = Instance.new("BodyGyro",v)
						bodyG.CFrame = v.CFrame
						bodyG.MaxTorque = Vector3.new(math.huge,math.huge,math.huge)
						
						v.CanCollide = true
						v.Anchored = false
					end
				end
			end
		end
		local animation = Instance.new("Animation", dummy:WaitForChild("Humanoid"))

		if i == 1 then
			animation.AnimationId = 'rbxassetid://3337994105' 
		elseif i == 2 then
			animation.AnimationId = 'rbxassetid://4841405708'
		elseif i == 3 then
			animation.AnimationId = 'rbxassetid://3333499508'
		end

		local animationTrack = dummy:WaitForChild("Humanoid"):LoadAnimation(animation)
		animationTrack:Play()
	end
end

playEmoteForDummies()

local cache = {}
function getUserIdFromUsername(name)
	if cache[name] then return cache[name] end
	local player = game.Players:FindFirstChild(name)
	if player then
		cache[name] = player.UserId
		return player.UserId
	end 
	local id
	local success, err = pcall(function()
		id = game.Players:GetUserIdFromNameAsync(name)
	end)
	cache[name] = id
	return id
end

local characterAppearances = {}

function getCharacterApperance(userID)
	if characterAppearances[userID] then
		return characterAppearances[userID]
	end
	local humanoiddesc

	local success, err = pcall(function()
		humanoiddesc = game.Players:GetHumanoidDescriptionFromUserId(userID)
	end)
	if not success then
		warn(err)
		while not success do
			local success, err = pcall(function()
				humanoiddesc = game.Players:GetHumanoidDescriptionFromUserId(userID)
			end)
			if success then
				break
			else
				wait(3)
			end
		end
	end
	characterAppearances[userID] = humanoiddesc
	return humanoiddesc
end

local function Handler()
	local Success, Err = pcall(function()
		local Data = ds:GetSortedAsync(false, 100)
		local Page = Data:GetCurrentPage()
				
		local names = {}
		for Rank, Data in ipairs(Page) do
			local Name = Data.key
			local Amount = Data.value
			local NewObj = script.Template:Clone()
			NewObj.PlrName.Text = Name
			local retrievedValue = Data.value ~= 0 and (1.0000001 ^ Data.value) or 0
			if Rank == 1 or Rank == "1" then
				NewObj.Rank.TextColor3 = Color3.fromRGB(255, 255, 0)
				local userID = getUserIdFromUsername(Name)
				local humanoiddesc = getCharacterApperance(userID)
				dum1Hum:ApplyDescription(humanoiddesc)
				dum1Hum.DisplayName = Name
			elseif Rank == 2 or Rank == "2" then
				NewObj.Rank.TextColor3 = Color3.fromRGB(255, 170, 0)
				local userID = getUserIdFromUsername(Name)
				local humanoiddesc = getCharacterApperance(userID)
				dum2Hum:ApplyDescription(humanoiddesc)
				dum2Hum.DisplayName = Name
			elseif Rank == 3 or Rank == "3" then
				NewObj.Rank.TextColor3 = Color3.fromRGB(255, 0, 0)
				local userID = getUserIdFromUsername(Name)
				local humanoiddesc = getCharacterApperance(userID)
				dum3Hum:ApplyDescription(humanoiddesc)
				dum3Hum.DisplayName = Name
			end
			if game.Players:FindFirstChild(Name) then
				names[Name] = Rank
			end
			NewObj.Cash.Text = format(retrievedValue)
			NewObj.Rank.Text = "#"..Rank
			NewObj.Parent = script.Parent
		end
		for i, v in pairs(game.Players:GetChildren()) do
			if names[v.Name] then
				local char = v.Character or v.CharacterAdded:Wait()
				giveRank(char, names[v.Name])
			else
				local char = v.Character or v.CharacterAdded:Wait()
				removeRank(char)
			end
		end
	end)
	if not Success then
		warn(Err)
	end
end

local timeUntilReset = resetTime


while wait(1) do
	timeUntilReset = timeUntilReset - 1

	if timeUntilReset == 0 then

		timeUntilReset = resetTime
		for _,Player in pairs(game.Players:GetPlayers()) do
			local storedValue = Player.leaderstats[storedValueName].Value ~= 0 and math.floor(math.log(Player.leaderstats[storedValueName].Value) / math.log(1.0000001)) or 0
			ds:SetAsync(Player.Name, storedValue)
		end
		for _,v in pairs(script.Parent:GetChildren()) do
			if v:IsA("Frame") then
				v:Destroy()
			end
		end
		Handler()
	end
end

Handler()

game.Players.PlayerRemoving:Connect(function(Player)
	local storedValue = Player.leaderstats[storedValueName].Value ~= 0 and math.floor(math.log(Player.leaderstats[storedValueName].Value) / math.log(1.0000001)) or 0
	local success, err = pcall(function()
		ds:SetAsync(Player.Name, storedValue)
	end)
	if success then
		print("leaderboard stats successfully saved")
	else
		local count = 0
		while not success do
			local success, errormsg = pcall(function()
				ds:SetAsync(Player.Name, storedValue)
			end)
			count += 1
			if success then
				print("Took ".. count .." to successfully save leaderboard stats")
				break
			else
				warn(errormsg)
				wait(3)
			end
		end
	end


end)
