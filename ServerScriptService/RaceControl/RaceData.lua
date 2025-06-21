-- @ScriptType: ModuleScript
local RaceData = { count = 0, racers = {}, placement = 0 }

function RaceData.add(player)
	if not RaceData.racers[player] then
		RaceData.racers[player] = true
		RaceData.count += 1
	end
end

function RaceData.remove(player)
	if RaceData.racers[player] then
		RaceData.racers[player] = nil
		RaceData.count -= 1
	end
end

function RaceData.getCount()
	return RaceData.count
end

function RaceData.reset()
	RaceData.count = 0
	RaceData.racers = {}
	RaceData.placement = 0
end

function RaceData.nextPlacement()
	RaceData.placement += 1
	return RaceData.placement
end

return RaceData
