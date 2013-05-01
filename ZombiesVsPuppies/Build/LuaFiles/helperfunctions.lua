module(..., package.seeall)
local maxLevelUnlocked
local currentLevel
local amountGrinded
local amountPunched
local barrelKills
local bloodPoints

--Helper functions--

--string split method
function mysplit(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
	end
	return t
end

function reloadFile()
	local file = loadFile ("game.txt")
	local count = 1
	local t = {}
	
	if file == "empty" then
		--set default params
		maxLevelUnlocked = 1
		currentLevel = 1
		amountGrinded = 0
		amountPunched = 0
		barrelKills = 0
		bloodPoints = 0
		
		file = maxLevelUnlocked .."," ..currentLevel .."," ..amountGrinded .."," ..amountPunched .."," ..barrelKills .."," ..bloodPoints
		saveFile("game.txt", file)
	else
		t = mysplit(file, ",")
		--max level unlocked, currentLevel,amountGrinded, amountPunched, barrelKills, BloodPoints
	
		for i,v in pairs(t) do
			if count == 1 then
				maxLevelUnlocked = v
			elseif count == 2 then
				currentLevel = v
			elseif count == 3 then
				amountGrinded = v
			elseif count == 4 then
				amountPunched = v
			elseif count == 5 then
				barrelKills = v
			elseif count == 6 then
				bloodPoints = v
			end
			count = count + 1
		end
	end
end
	
function getMaxLevelUnlocked()
	return maxLevelUnlocked
end

function getCurrentLevel()
	return currentLevel
end

function getAmountGrinded()
	return amountGrinded
end

function getAmountPunched()
	return amountPunched
end

function getBarrelKills()
	return barrelKills
end

function getBloodPoints()
	return bloodPoints
end

function saveCurrentLevel(params)
	local fileValues
	
	reloadFile()
	
	fileValues = maxLevelUnlocked .."," ..params.level .."," ..amountGrinded .."," ..amountPunched .."," ..barrelKills .."," ..bloodPoints
	
	saveFile("game.txt", fileValues)
end