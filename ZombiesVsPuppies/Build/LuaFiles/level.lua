-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.

module(..., package.seeall)

--TODOS:
--Continue to work out the waving per level
--Finish out cute puppy functionality (zombies eating animation, pick up / drop, grind,
--save on top-right conveyor belt)
--Finish out blood shop UI
--Write Config file read/save for blood shop
--Implement puppy pen & rabid puppy
--Implement zombie limb stuck in conveyor belt

--NOTES:
--Spawns have been reworked, positioning/stacking of enemy objects, and waving mechanics somewhat implemented.
--Puppy pen has health, and when destroyed level is failed
--Rabid puppy will shoot/break out of cage, and destroy zombies in it's path. (cartoonish whirlwind effect)

--Known Issues/Bugs:
--Sometimes the hand still drops after a zombie is picked up and in dangling state, but the zombie does not fall out of the hand.

-- Main function - MUST return a display.newGroup()
function new()		

	local levelConf = require ("LuaFiles.levelconfig")
	local sheetData = require ("LuaFiles.sheetdata")
	local rand = math.random
	
	local level1Group
	local row1Group
	local row2Group
	local row3Group
	local row4Group
	local row5Group
	local menuGroup -- front row for UI, pause menu, etc to keep it on top
	
	local gameVarTable = {}
	gameVarTable["scrollBackground"] = true
	
	------------
	--JOYSTICK--
	------------
	local prevx = 0
	local prevy = 0
	local motionx = 0 
	local motiony = 0 
	
	--setting up display groups-
	level1Group = display.newGroup()
	level1Group.x = -0
	
	row1Group = display.newGroup()
	row1Group.x = -0
	
	row2Group = display.newGroup()
	row2Group.x = -0
	
	row3Group = display.newGroup()
	row3Group.x = -0
	
	row4Group = display.newGroup()
	row4Group.x = -0
	
	row5Group = display.newGroup()
	row5Group.x = -0

	menuGroup = display.newGroup()
	menuGroup.x = -0	
	
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
	
	local file = loadFile ("game.txt")
	local fileReadCount = 1

	gameVarTable["currentLevel"] = 1
	gameVarTable["maxLevelUnlocked"] = 1
	
	local saveFileTable = {}
	
	if file == "empty" then
		gameVarTable["currentLevel"] = 1
		gameVarTable["maxLevelUnlocked"] = 1
	else
		saveFileTable = mysplit(file, ",")
		
		for i,v in pairs(t) do
			if fileReadCount == 1 then
				gameVarTable["maxLevelUnlocked"]  = v
			elseif fileReadCount == 2 then
				gameVarTable["currentLevel"] = v	
			end
			fileReadCount = fileReadCount + 1
		end
	end
	
	local levelConfig
	
	local function getLevelConfig()
		levelConfig = levelConf.getLevelTable()
	end

	getLevelConfig()
	
	gameVarTable["currentWave"] = 0
	
	--level winning condition variables
	pointsInLevelTotal = nil
	pointsInLevelTotal = 0
	gameVarTable["pointsRequiredToCompleteLevel"] = levelConfig["level"..gameVarTable["currentLevel"]]["pointsRequiredToCompleteLevel"]

	--Game Variables--
	gameVarTable["walkerXBounds"] = 30
	gameVarTable["maxEnemiesAlive"] = 40
	gameVarTable["zombiesLeftToSpawn"] = 0
	gameVarTable["limbsInGrinder"] = 0
	gameVarTable["puppySpawned"] = false
	gameVarTable["canDrop"] = false
	gameVarTable["conveyorWaitTime"] = levelConfig["level"..gameVarTable["currentLevel"]]["conveyorWaitTime"]
	exiting = false
	gameVarTable["zombiesInCrane"] = 0
	gameVarTable["zombieLimitForLevel"] = levelConfig["level"..gameVarTable["currentLevel"]]["zombieEscapeLimit"]
	gameVarTable["craneDropPressed"] = false
	gameVarTable["zombiesExited"] = 0
	gameVarTable["enemiesAlive"] = 0
	gameVarTable["barrelTouchRegion"] = 45
	gameVarTable["spawnSelectedItem"] = nil
	gameVarTable["maxHandEnergy"] = levelConfig["level"..gameVarTable["currentLevel"]]["maxHandEnergy"]
	gameVarTable["handEnergy"] =	levelConfig["level"..gameVarTable["currentLevel"]]["handEnergy"]
	gameVarTable["energyRequiredToPunch"] = levelConfig["level"..gameVarTable["currentLevel"]]["energyRequiredToPunch"]
	gameVarTable["energyRequiredToGrab"] = levelConfig["level"..gameVarTable["currentLevel"]]["energyRequiredToGrab"]
	gameVarTable["handEnergyRegenRate"] = levelConfig["level"..gameVarTable["currentLevel"]]["handEnergyRegenRate"]
	--local barrelFallSpeed = 10
	local handEnergyRegenCount = 10
	gameVarTable["maxWaveNumber"] = levelConfig["level"..gameVarTable["currentLevel"]]["numWavesInLevel"]
	gameVarTable["barrelAreaOfEffect"] = levelConfig["level"..gameVarTable["currentLevel"]]["barrelAreaOfEffect"]
	gameVarTable["punchAreaOfEffect"] = levelConfig["level"..gameVarTable["currentLevel"]]["punchAreaOfEffect"]
	gameVarTable["canPunchKill"]  = false
	gameVarTable["craneDropSpeed"] = levelConfig["level"..gameVarTable["currentLevel"]]["craneDropSpeed"]
	gameVarTable["craneSpeed"] = levelConfig["level"..gameVarTable["currentLevel"]]["craneSpeed"] 
	
	gameVarTable["amountGrinded"] = 0
	gameVarTable["amountPunched"] = 0
	gameVarTable["barrelKills"] = 0
	
	gameVarTable["conveyorSpeed"] = levelConfig["level"..gameVarTable["currentLevel"]]["conveyorBeltSpeed"]
	
	--coin collecting and cost
	gameVarTable["coinsCollected"] = 0
	gameVarTable["costForPuppy"] = levelConfig["level"..gameVarTable["currentLevel"]]["coinsRequiredForPuppy"]
	gameVarTable["costForFastBarrels"] = levelConfig["level"..gameVarTable["currentLevel"]]["coinsRequiredForFastBarrels"]
	
	gameVarTable["conveyorSpeedUpgradeTime"] = levelConfig["level"..gameVarTable["currentLevel"]]["conveyorSpeedUpgradeTime"]
	
	--Pause Menu Options
	gameVarTable["gotoMainMenuBool"] = false
	gameVarTable["restartLevelBool"] = false
	gameVarTable["canPause"] = false
        
	--computer monitor
	local currentDisplay = "puppyCuteImage"
	
	local spawnPuppyNext = false
	local barrelFallSpeed = 20
	--crane speed----------------
	--local speed = 10
	gameVarTable["craneVerticalSpeed"] = 16
	------------------------------
	--Sounds--
	audioStash.grindSound1 = audio.loadSound( "Sounds/grinder.mp3" )
	audioStash.grindSound2 = audio.loadSound( "Sounds/grinder2.mp3" )
---------------------------------------------------------
--Crane Properties-- Spawn Methods
---------------------------------------------------------
	--Crane Grab and Retract booleans / Grab accounts for full upward and downward motion
	--Retracting is only when it hit the bottom, and must return to the top
	gameVarTable["craneGrabPressed"] = false
	gameVarTable["craneRetracting"] = false
	gameVarTable["canPunch"] = false
	
	--Crane Min and Max positions on the screen
	gameVarTable["craneMinXPosition"] = 0
	gameVarTable["craneMaxXPosition"] = 475
	gameVarTable["craneMinYPosition"] = 20
	gameVarTable["craneMaxYPosition"] = 230
	
	--Create a table to hold our spawns, and keep track of number of alive enemies
	local spawnTable = {}
	local bloodTable = {}
	local explosionTable = {}
	local barricadeTable = {}
    local particles = {}
	local itemTable = {}
	local testTable = {}

--------------------	
--BACKGROUND IMAGE--
--------------------
    local backgroundImage = display.newImageRect( "Images/Backgrounds/ExtendedBG.png",2450, 340 )
    backgroundImage:setReferencePoint(display.BottomRightReferencePoint)
	
	local function scrollBackground()
		if not exiting and gameVarTable["scrollBackground"] then
			if tonumber(gameVarTable["currentLevel"]) == 2 then
				gameVarTable["scrollBackground"] = false
			elseif tonumber(gameVarTable["currentLevel"]) == 2 and gameVarTable["scrollBackground"] then
				if backgroundImage.x >= 1920 then
					backgroundImage.x = backgroundImage.x - 5
					exiting = true
				else
					exiting = false
					gameVarTable["scrollBackground"] = false
				end
			elseif tonumber(gameVarTable["currentLevel"]) == 3 and gameVarTable["scrollBackground"] then
				if backgroundImage.x >= 1440 then
					backgroundImage.x = backgroundImage.x - 5
					exiting = true
				else
					exiting = false
					gameVarTable["scrollBackground"] = false
				end
			elseif tonumber(gameVarTable["currentLevel"]) == 4 and gameVarTable["scrollBackground"] then
				if backgroundImage.x >= 960 then
					backgroundImage.x = backgroundImage.x - 5
					exiting = true
				else
					exiting = false
					gameVarTable["scrollBackground"] = false
				end
			elseif tonumber(gameVarTable["currentLevel"]) == 5 and gameVarTable["scrollBackground"] then
				if backgroundImage.x >= 535 then
					backgroundImage.x = backgroundImage.x - 5
					exiting = true
				else
					exiting = false
					gameVarTable["scrollBackground"] = false
				end
			end
		end
	end
	
	if tonumber(gameVarTable["currentLevel"]) == 1 then
		backgroundImage.x = 2400; backgroundImage.y = 340;
	elseif tonumber(gameVarTable["currentLevel"]) == 2 then
		backgroundImage.x = 1920; backgroundImage.y = 340;
		--backgroundImage.x = 3180; backgroundImage.y = 350;
	elseif tonumber(gameVarTable["currentLevel"]) == 3 then
		backgroundImage.x = 1440; backgroundImage.y = 340;
		--backgroundImage.x = 2550; backgroundImage.y = 350;
	elseif tonumber(gameVarTable["currentLevel"]) == 4 then
		backgroundImage.x = 960; backgroundImage.y = 340;
		--backgroundImage.x = 1900; backgroundImage.y = 350;
	elseif tonumber(gameVarTable["currentLevel"]) == 5 then
		backgroundImage.x = 535; backgroundImage.y = 340;
		--backgroundImage.x = 1200; backgroundImage.y = 350;
	end
	
	local catwalkFloorImage = display.newImageRect("Images/LevelObjects/Conveyor Belt_72ppi.png", 600,19)
	catwalkFloorImage:setReferencePoint(display.BottomRightReferencePoint)
	catwalkFloorImage.x = -50; catwalkFloorImage.y = 102
	catwalkFloorImage.xScale = 1 catwalkFloorImage.yScale = 1
	
	local catwalkFloorImage2 = display.newImageRect("Images/LevelObjects/Conveyor Belt_72ppi.png", 600,19)
	catwalkFloorImage2:setReferencePoint(display.BottomRightReferencePoint)
	catwalkFloorImage2.x = -600; catwalkFloorImage2.y = 102
	catwalkFloorImage2.xScale = 1 catwalkFloorImage2.yScale = 1
	
	local catwalkFloorImage3 = display.newImageRect("Images/LevelObjects/Conveyor Belt_72ppi.png", 600,19)
	catwalkFloorImage3:setReferencePoint(display.BottomRightReferencePoint)
	catwalkFloorImage3.x = 525; catwalkFloorImage3.y = 102
	catwalkFloorImage3.xScale = 1 catwalkFloorImage3.yScale = 1
-------------------------------------------------------------------------------------------------------	
	local catwalkFloorBottomImage = display.newImageRect("Images/LevelObjects/ConveyorBottom.png", 602,11)
	catwalkFloorBottomImage:setReferencePoint(display.BottomRightReferencePoint)
	catwalkFloorBottomImage.x = -50; catwalkFloorBottomImage.y = 124
	catwalkFloorBottomImage.xScale = 1 catwalkFloorBottomImage.yScale = 1
	
	local catwalkFloorBottomImage2 = display.newImageRect("Images/LevelObjects/ConveyorBottom.png", 602,11)
	catwalkFloorBottomImage2:setReferencePoint(display.BottomRightReferencePoint)
	catwalkFloorBottomImage2.x = -600; catwalkFloorBottomImage2.y = 124
	catwalkFloorBottomImage2.xScale = 1 catwalkFloorBottomImage2.yScale = 1
	
	local catwalkFloorBottomImage3 = display.newImageRect("Images/LevelObjects/ConveyorBottom.png", 602,11)
	catwalkFloorBottomImage3:setReferencePoint(display.BottomRightReferencePoint)
	catwalkFloorBottomImage3.x = 525; catwalkFloorBottomImage3.y = 124
	catwalkFloorBottomImage3.xScale = 1 catwalkFloorBottomImage3.yScale = 1
	
	local catwalkImage = display.newImageRect("Images/LevelObjects/Conveyor_72ppi.png", 605,160)
	catwalkImage.x = 240; catwalkImage.y = 50
	catwalkImage.xScale = .95 catwalkImage.yScale = 1
    
	local spawnTubeImage = display.newImageRect("Images/LevelObjects/Tube_72ppi.png", 64,47)
	spawnTubeImage.x = 40; spawnTubeImage.y = 10
	spawnTubeImage.xScale = 1.2 spawnTubeImage.yScale = 1.2
	
	local computerMonitorImage = display.newImageRect("Images/LevelObjects/Monitor.png",125,75)
	computerMonitorImage.x = 155; computerMonitorImage.y = 175;
	computerMonitorImage.xScale = 1; computerMonitorImage.yScale = 1;
	
	local upgradeConveyorButton = display.newImageRect("Images/ButtonIconsEtc/singlecoinicon.png",25,25)
	upgradeConveyorButton.x = 165; upgradeConveyorButton.y = 100
	upgradeConveyorButton.xScale = 1; upgradeConveyorButton.yScale = 1
	upgradeConveyorButton.id = "fastConveyor"
	
	
	local function useUpgrades(event)
		local t = event.target
		
		if t.id == "fastConveyor" then
			if gameVarTable["coinsCollected"] >= gameVarTable["costForFastBarrels"] then
				gameVarTable["conveyorWaitTime"] = gameVarTable["conveyorSpeedUpgradeTime"]
				gameVarTable["coinsCollected"] = gameVarTable["coinsCollected"] - gameVarTable["costForFastBarrels"]
			else
				print("not enough")
			end
		else
			print("id: " ..t.id .."notfound")
		end
	end
	
	upgradeConveyorButton:addEventListener("touch", useUpgrades)
	
	local function touchPuppy(event)
		if event.phase == "release" then
			if gameVarTable["puppyIsDisabled"] == false and not spawnPuppyNext then
				spawnPuppyNext = true
				gameVarTable["coinsCollected"] = gameVarTable["coinsCollected"] - gameVarTable["costForPuppy"]
			end
		end
	end
	
	local monitorText = display.newText("0", 115, 160, "Let's Eat", 35)
	      monitorText:setTextColor(0,0,0); monitorText.isVisible = true
		  
	local puppyCuteImage = ui.newButton{
		defaultSrc = "Images/AlliedObjects/CutePuppy.png",
		defaultX = 190,
		defaultY = 190,
		overSrc = "Images/AlliedObjects/CutePuppy.png",
		overX = 190,
		overY = 190,
		onEvent = touchPuppy,
		id = "CutePuppy",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		size = 0,
		emboss = false
	}

	puppyCuteImage.x = 445; puppyCuteImage.y = 20
	puppyCuteImage.xScale = .15; puppyCuteImage.yScale = .2
	puppyCuteImage.isVisible = false
	
	local handBar = display.newImageRect( "Images/AlliedObjects/handbarsheet.png", 54, 400 )
	handBar.xScale = 1.5
	
	local playerConsole = display.newImageRect("Images/ControlPanel/Consoles.png",480 ,33)
	playerConsole.x = 240 playerConsole.y = 300
	playerConsole.xScale = 1.3
	playerConsole.isVisible = false
	level1Group:insert( backgroundImage )
	level1Group:insert( computerMonitorImage )
	level1Group:insert( catwalkFloorImage )
	level1Group:insert( catwalkFloorImage2 )
	level1Group:insert( catwalkFloorImage3 )
	level1Group:insert( catwalkFloorBottomImage )
	level1Group:insert( catwalkFloorBottomImage2 )
	level1Group:insert( catwalkFloorBottomImage3 )
	menuGroup:insert( spawnTubeImage)
	menuGroup:insert( catwalkImage )
	menuGroup:insert(handBar)
	menuGroup:insert(playerConsole)
	menuGroup:insert(upgradeConveyorButton)
	local catwalkSpeed = levelConfig["level"..gameVarTable["currentLevel"]]["conveyorBeltSpeed"]
	
	local function moveCatwalk()
		if not exiting then
			if catwalkFloorImage.x <= 1100 then
				catwalkFloorImage.x = catwalkFloorImage.x + catwalkSpeed
			else
				catwalkFloorImage.x = -50
			end
			if catwalkFloorImage2.x <= 1100 then
				catwalkFloorImage2.x = catwalkFloorImage2.x + catwalkSpeed
			else
				catwalkFloorImage2.x = -50
			end
			if catwalkFloorImage3.x <= 1100 then
				catwalkFloorImage3.x = catwalkFloorImage3.x + catwalkSpeed
			else
				catwalkFloorImage3.x = -50
			end
			if catwalkFloorBottomImage.x >= -50 then
				catwalkFloorBottomImage.x = catwalkFloorBottomImage.x - catwalkSpeed
			else
				catwalkFloorBottomImage.x = 1100
			end
			if catwalkFloorBottomImage2.x >= -50 then
				catwalkFloorBottomImage2.x = catwalkFloorBottomImage2.x - catwalkSpeed
			else
				catwalkFloorBottomImage2.x = 1100
			end
			if catwalkFloorBottomImage3.x >= -50 then
				catwalkFloorBottomImage3.x = catwalkFloorBottomImage3.x - catwalkSpeed
			else
				catwalkFloorBottomImage3.x = 1100
			end
		end
	end

--For the coins	
local randNum
local numCoins = 0

	local function touchCoin(event)
		local t = event.target		
		t.isMoving = true
	end

-----------------------
--BEGIN SPAWN FUNCTIONS
-----------------------
local function spawn(params)

	--Create the object and assign it's sprite set
	local spriteSheet = params.spriteSheet or nil
	local object = display.newSprite( spriteSheet, params.sequenceData ) or nil
	
	--Set the objects table to a table passed in by parameters
	object.objTable = params.objTable or nil
	object.objType = params.objType or nil
	--Automatically set the table index to be inserted into the next available table index
	object.index = #object.objTable + 1 or nil
   
	--Give the object a custom name
	object.Name = params.Name .. object.index
   
	--The objects group
	object.group = params.group or nil

	--Positioning
	object.x = params.xPosition or nil
	object.y = params.yPosition or nil
	object.xScale = params.xScale or nil
	object.yScale = params.yScale or nil
	object.facingSide = params.defaultOrientation or nil
	
	if (object.facingSide == "left") then
		object:scale(-1,1)
		object.facingSide = "right"
	end
	
	if params.health ~= nil then
		object.health = params.health		
		object.damageReceived = 0
		object.healthPercent = 100
	end
   
	--Animation Frame Speed
	object.timeScale = params.timeScale or nil
	
	--If the function call has a parameter named group then insert it into the specified group
	if not exiting then
		object.group:insert(object or nil) 
    end
	
	--Insert the object into the table at the specified index
	object.objTable[object.index] = object 
	
	object.moveSpeed = params.moveSpeed or nil
	object.currentState = params.currentState or nil
	
	--Collision
	if params.objType == "Enemy" or params.Name == "Puppy" then 
		object.isPickedUp = false
		object.isEating = false
		object.startingY = params.yPosition
		object.grindPoints = params.grindPoints
		object.puppyDamage = params.puppyDamage or nil
		object.barrierDamage = params.barrierDamage or nil
		object.isStopped = false
		object.isInHand = false
		object.flaggedForRemoval = false
		if params.objType == "Enemy" then
			gameVarTable["enemiesAlive"] = gameVarTable["enemiesAlive"] + 1
		else 
			object.isFalling = false
			object.isGassed = false
			object.isPlaying = false
			object.isAttackingFlag = false
			object.isAttackingHelpFlag = false
		end
	elseif params.objType == "Barrel" then
		object.isFalling = false
		object.isReadyToAct = false
		object.isGassed = false
	end
	
	if params.objType == "Explosion" then
		object.isPlaying = false
	end
	
	if params.objType == "Limb" then
		object:addEventListener("touch", touchCoin)
		object:setSequence("spin")
		object:play()
	end
	
	return object
end
--------------------
--END SPAWN FUNCTION
--------------------	
	
--------------------
--CRANE SPAWN
--------------------
	for i = 1, 1 do
		local spawns = spawn(
			{
				objTable = spawnTable,
				objType = "Player",
				Name = "Crane",
				group = menuGroup,
				spriteSheet = sheetData.getHandGrabSheet(),
				xPosition = gameVarTable["craneMinXPosition"],
				yPosition = gameVarTable["craneMinYPosition"],
				xScale = .9,
				yScale = .9,
				timeScale = 1,
				currentState = "empty",
				moveSpeed = 5,
				sequenceData = {
					{ name="idle", frames={ 7 }, time=250, loopCount = 1},
					{ name="grab", frames={ 1,2,3,4,5,6,7 }, time=550, loopCount = 1},
					{ name="punch", sheet=sheetData.getHandFistSheet(), frames={ 10 }, time=550, loopCount = 1}
				}
			}
		)
	end
	
	--additional variables to be read from config eventually.
	spawnTable[1].minCarry = 1
	spawnTable[1].maxCarry = 2
	spawnTable[1].amountCarrying = 0 
	spawnTable[1].accuracy = 100
	--Create the explosions via spawn
	
	for i = 1, 1 do
		local spawns = spawn(
			{
				objTable = spawnTable,
				objType = "PlayerDisplay",
				Name = "CraneEnergy",
				group = menuGroup,
				spriteSheet = sheetData.getHandLightDisplaySheet(),
				xPosition = 300,
				yPosition = 35,
				xScale = 1,				
				yScale = 1,
				timeScale = 1,
				currentState = "empty",
				moveSpeed = 5,
				sequenceData = {
					{ name="green", frames={1}, time=250, loopCount = 1},
					{ name="red", frames={2}, time=550, loopCount = 1},
					{ name="yellow", frames={3}, time=550, loopCount = 1}
				}
			}
		)
	end
	
	local function spawnLevelDrop(params)
		local limbSheet
		local randNum
		
		if not exiting then
			for i = 1, params.randomNum do
				numCoins = numCoins + 1
				
				randNum = rand(1,4)
				
				if randNum == 1 then
					limbSheet = sheetData.getArmLeftSheet()
				elseif randNum == 2 then
					limbSheet = sheetData.getArmRightSheet()
				elseif randNum == 3 then
					limbSheet = sheetData.getLegLeftSheet()
				elseif randNum == 4 then 
					limbSheet = sheetData.getLegRightSheet()
				elseif randNum == 5 then
					--limbSheet = sheetData.getHeadSheet()
				end

				local spawnr = spawn(
					{
						objTable = spawnTable,
						objType = "Limb",
						Name = tonumber(numCoins),
						group = menuGroup,
						spriteSheet = limbSheet,
						xPosition = params.x,
						yPosition = params.y,
						xScale = .4,
						yScale = .4,
						timeScale = .3,
						currentState = "empty",
						moveSpeed = 5,
						isPlaying = false,
						sequenceData = {
							{ name="idle", frames={1}, time=250, loopCount = 0}
						}
					}
				)
			end
		end
	end
	
	local function spawnExplosion(params)
		if not exiting then
			for i = params.spawnAmount, 1 do
				local spawnr = spawn(
					{
						objTable = spawnTable,
						objType = "Explosion",
						Name = "Explosion",
						group = menuGroup,
						spriteSheet = sheetData.getExplosionSheet(),
						xPosition = params.x,
						yPosition = params.y,
						xScale = 2,
						yScale = 2,
						timeScale = .3,
						currentState = "empty",
						moveSpeed = 5,
						isPlaying = false,
						sequenceData = {
							{ name="explode", frames={ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42}, time=250, loopCount = 1}
						}
					}
				)
			end
		end
	end
-------------------------
--Siren
-------------------------
local function spawnSiren(params)
		if not exiting then
			for i = 1, 1 do
				local spawnr = spawn(
					{
						objTable = spawnTable,
						objType = "Siren",
						Name = "Siren",
						group = menuGroup,
						spriteSheet = sheetData.getRedSirenSheet(),
						xPosition = params.x,
						yPosition = params.y,
						xScale = 1,
						yScale = 1,
						timeScale = .3,
						currentState = "empty",
						moveSpeed = 5,
						isPlaying = false,
						sequenceData = {
							{ name="play", frames={ 1,2,3,4,5,6,7,8,9,10,11}, time=250, loopCount = 0}
						}
					}
				)
			end
		end
	end
	
spawnSiren({x=145,y=25})
spawnSiren({x=180,y=25})
-------------------------
--Puppy
-------------------------
	local function spawnPuppy(params)
	
		if not exiting then
			for i = 1, 1 do
				local spawns = spawn(
					{
						objTable = spawnTable,
						objType = "Puppy",
						Name = "Puppy",
						group = row1Group,
						spriteSheet = sheetData.getNormalPuppySheet(),
						xPosition = 40,
						yPosition = 60,
						xScale = .25,
						yScale = .25,
						timeScale = 0.3,
						currentState = "normal",
						moveSpeed = 0,
						grindPoints = 2500,
						health = 500,
						barrierDamage = 0,
						sequenceData = {
							{ name="idle", sheet=sheetData.getNormalPuppySheet(), frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19}, time=250, loopcount=0 },
							{ name="crackAttack", sheet=sheetData.getCrackPuppyAttackSheet(), frames={1,2,3,4,5,6,7,8}, time=250, loopcount=0 },
							{ name="crackIdle", sheet=sheetData.getCrackPuppyIdleSheet(), frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30}, time=250, loopcount=0 },
							{ name="bombAttackFat1", sheet=sheetData.getBombPuppyFat1Sheet(), frames={29,30,31,32,33,34,35,36,37,38}, time=250, loopcount=1 },
							{ name="bombAttackFat2", sheet=sheetData.getBombPuppyFat2Sheet(), frames={45,46,47,48,49,50,51,52,53,54}, time=250, loopcount=0 },
							{ name="bombAttackFat3", sheet=sheetData.getBombPuppyFat3Sheet(), frames={44,45,46,47,48,49,50,51,52,53}, time=250, loopcount=0 },
							{ name="bombAttackFat4", sheet=sheetData.getBombPuppyFat4Sheet(), frames={44,45,46,47,48,49,50,51,52}, time=250, loopcount=0 },
							{ name="bombAttackFat5", sheet=sheetData.getBombPuppyFat5Sheet(), frames={44,45,46,47,48,49,50}, time=250, loopcount=0 },
							{ name="bombIdleFat1", sheet=sheetData.getBombPuppyFat1Sheet(), frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28}, time=250, loopcount=0 },
							{ name="bombIdleFat2", sheet=sheetData.getBombPuppyFat2Sheet(), frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44}, time=250, loopcount=0 },
							{ name="bombIdleFat3", sheet=sheetData.getBombPuppyFat3Sheet(), frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43}, time=250, loopcount=0 },
							{ name="bombIdleFat4", sheet=sheetData.getBombPuppyFat4Sheet(), frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43}, time=250, loopcount=0 },
							{ name="bombIdleFat5", sheet=sheetData.getBombPuppyFat5Sheet(), frames={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43}, time=250, loopcount=0 }
						}
					}
				)
			end
		end
	end

	
------------------------
--Zombies---------------
------------------------	
	local function spawnWalkers(params)
	
		local speed
		local ts = .3
		local row = rand(1,5)
		local offset = row * 5
		local group = row1Group
		local scaleOffset = .6
		local xPosition
		
		for i = 1, params.spawnAmount do		
			--handles dynamic speed for each zombie
			if gameVarTable["enemiesAlive"] <= gameVarTable["maxEnemiesAlive"] then
			
				speed = levelConfig["level"..gameVarTable["currentLevel"]]["walkerSpeed"]
				xPosition = 0 + (i * rand(20, 40) * -1)
				ts = .3
				
				if speed >= 2 and speed <= 3 then
					ts = .35
				elseif speed >= 3 and speed <= 4 then
					ts = .45
				elseif speed >= 4 then
					ts = .55
				end
				
				--handles the row positioning, and group layering
				row = rand(1,5)
				offset = row * 5
				
				if row == 1 then
					group = row1Group
					scaleOffset = .996
				elseif row == 2 then
					group = row2Group
					scaleOffset = 1.022
				elseif row == 3 then
					group = row3Group
					scaleOffset = 1.048
				elseif row == 4 then
					group = row4Group
					scaleOffset = 1.074
				elseif row == 5 then
					group = row5Group
					scaleOffset = 1.1
				end	
				
				local spawns = spawn(
					{
						objTable = spawnTable,
						objType = "Enemy",
						Name = "Walker",
						group = group,
						spriteSheet = sheetData.getZomWalkerSheet(),
						xPosition = xPosition ,
						yPosition = 235 + offset,
						xScale = scaleOffset,
						yScale = scaleOffset,
						currentState = "movingRight",
						defaultOrientation = "right",
						moveSpeed = speed,
						timeScale = ts,
						grindPoints = levelConfig["level"..gameVarTable["currentLevel"]]["zombieGrindPoints"],
						barrierDamage = levelConfig["level"..gameVarTable["currentLevel"]]["zombieBarrierDamage"],
						puppyDamage = levelConfig["level"..gameVarTable["currentLevel"]]["zombiePuppyDamage"],
						sequenceData = {
							{ name="walkingRight", start=1, count=33, time=250, loopCount = 1},
							{ name="idle", start=35, count=22,time=250, loopCount = 0},
							{ name="attacking", start=58, count=29, time=250, loopCount = 0},
							{ name="dangling", frames={1}, time=250, loopCount = 0}
						}
					}
				)
			else -- add zombie count to spawn after more are killed (don't spawn all off screen)
				gameVarTable["zombiesLeftToSpawn"] = gameVarTable["zombiesLeftToSpawn"] + 1
			end
		end
	end
	
	-----BLOOD SPAWN
	local function spawnBlood(params)
		local sheetNumber
		local sheet 
		for i = 1, params.spawnAmount do
			sheetNumber = rand(1,5)
			if sheetNumber == 1 then
				sheet = sheetData.getBloodSheet()
			elseif sheetNumber == 2 then
				sheet = sheetData.getBloodSheet2()
			elseif sheetNumber == 3 then
				sheet = sheetData.getBloodSheet3()
			elseif sheetNumber == 4 then
				sheet = sheetData.getBloodSheet4()
			elseif sheetNumber == 5 then
				sheet = sheetData.getBloodSheet5()
			end
		
			local spawns = spawn(
				{
					objTable = bloodTable,
					objType = "Blood",
					Name = "Blood",
					group = level1Group,
					spriteSheet = sheet,
					xPosition = params.x,
					yPosition = 270,
					xScale = 1,
					yScale = 1,
					timeScale = .3,
					currentState = "splat",
					moveSpeed = 5,
					sequenceData = {
						{ name="splat", frames={ 1 }, time=150, loopCount = params.loopCount}
					}
				}
			)
		end
	end
	
	---barrels
	local function spawnFireBarrel(params)
	
		for i = 1, params.spawnAmount do
			local spawns = spawn(
				{
					objTable = spawnTable,
					objType = "Barrel",
					Name = "FireBarrel",
					group = level1Group,
					spriteSheet = sheetData.getFireBarrelSheet(),
					xPosition = params.x,
					yPosition = params.y,
					xScale = .5,
					yScale = .5,
					timeScale = .3,
					currentState = "stationary",
					moveSpeed = 5,
					sequenceData = {
						{ name="stationary", frames={1}, time=150, loopCount = 1}
					}
				}
			)
		end
	end
	---
	local function spawnOilBarrel(params)
	
		for i = 1, params.spawnAmount do
			local spawns = spawn(
				{
					objTable = spawnTable,
					objType = "Barrel",
					Name = "OilBarrel",
					group = level1Group,
					spriteSheet = sheetData.getOilBarrelSheet(),
					xPosition = params.x,
					yPosition = params.y,
					xScale = .5,
					yScale = .5,
					timeScale = .3,
					currentState = "stationary",
					moveSpeed = 5,
					sequenceData = {
						{ name="stationary", frames={1}, time=150, loopCount = 1}
					}
				}
			)
		end
	end
	--
	local function spawnAcidBarrel(params)
	
		for i = 1, params.spawnAmount do
			local spawns = spawn(
				{
					objTable = spawnTable,
					objType = "Barrel",
					Name = "WasteBarrel",
					group = level1Group,
					spriteSheet = sheetData.getAcidBarrelSheet(),
					xPosition = params.x,
					yPosition = params.y,
					xScale = .5,
					yScale = .5,
					timeScale = .3,
					currentState = "stationary",
					moveSpeed = 5,
					sequenceData = {
						{ name="stationary", frames={1}, time=150, loopCount = 1}
					}
				}
			)
		end
	end
	--
	
	--------------------------------
--BARRELS-----------------------
--------------------------------

local function moveBarrels()
	for i, v in pairs(spawnTable) do
		if (spawnTable[i] ~= nil) and (spawnTable[i].objType == "Barrel") then
			if spawnTable[i].isFalling == false
			and spawnTable[i].isReadyToAct == false then
				if spawnTable[i].y < 70 then
					spawnTable[i].y = spawnTable[i].y + barrelFallSpeed	
					if spawnTable[i].y >= 70 then
						spawnTable[i].y = 70
					end
				elseif spawnTable[i].x <= 500 then
					spawnTable[i].x = spawnTable[i].x + gameVarTable["conveyorSpeed"]
					if spawnTable[i].x >= 200 and spawnTable[i].x <= 250 and not spawnTable[i].isGassed then
						spawnTable[i].isGassed = true
					end
				elseif (spawnTable[i].x >= 500) then
					display.remove(spawnTable[i])
					spawnTable[i] = nil
				end
			end
		end
	end
end

local conveyorCount = 0
local randSpawn

local function timeConveyorBeltSpawns()
	
	if not exiting then
		--spawns something every second at this pace
		if conveyorCount < gameVarTable["conveyorWaitTime"] then
			conveyorCount = conveyorCount + 1
		else
			
			if not spawnPuppyNext then
				--increase as conveyor spawns get more random 
				randSpawn = rand(1,3)
				--spawn different item based on random number?
				if randSpawn == 1 then
					spawnAcidBarrel({spawnAmount = 1, x=35, y=50})
				elseif randSpawn == 2 then
					spawnOilBarrel({spawnAmount = 1, x=35, y=50})
				elseif randSpawn == 3 then
					spawnFireBarrel({spawnAmount = 1, x=35, y=50})
				end
				conveyorCount = 0
			else
				spawnPuppy({spawnAmount = 1})
				conveyorCount = 0
				spawnPuppyNext = false
			end
		end
		
		moveBarrels()
	end
end
	
local spawnTheWalkers = function () return spawnWalkers({spawnAmount = rand(1,2)}) end
local spawnTheWalkerNoEyes = function () return spawnWalkerNoEyes({spawnAmount = rand(1,2)}) end
local spawnTheCrawlers = function () return spawnCrawlers({spawnAmount = rand(1,3)}) end
--timerStash.spawnWalkerTimer = timer.performWithDelay(4000,spawnTheWalkers,0)
--timerStash.spawnWalkerNoEyesTimer = timer.performWithDelay(4000,spawnTheWalkerNoEyes,0)
--timerStash.spawnCrawlerTimer = timer.performWithDelay(5000,spawnTheCrawlers,0)

------------------------------------------
----EXPLOSION/PARTICLE EFFECTS------------
------------------------------------------
local function explosion (theX, theY, particletype, count)  -- blood is BOOL
        local particleCount = count-- number of particles per explosion 
        for  i = 1, particleCount do
                local theParticle = {}
                theParticle.object = display.newRect(theX,theY,3,3)
                if particletype == "blood" then
                     theParticle.object:setFillColor(250,0,0)
                elseif particletype == "waste" then
                    theParticle.object:setFillColor(25,250,0)
                end
                theParticle.xMove = rand (-5,5)
                theParticle.yMove = rand (5) * - 1
                theParticle.gravity = 0.5
                table.insert(particles, theParticle)
        end
end

----------------------------------------------------
--Hardcoding barricades for now - make dynamic later
----------------------------------------------------
local barricade = display.newImage ("Images/LevelObjects/Barricade2.png")
barricade.x = 250
barricade.y = 250
barricade.xScale = .25
barricade.yScale = .25
barricade.health = levelConfig["level"..gameVarTable["currentLevel"]]["barricadeHealth"]
barricade.damageReceived = 0
barricade.healthPercent = 100
--
local barricade2 = display.newImage ("Images/LevelObjects/Barricade2.png")
barricade2.x = 335
barricade2.y = 250
barricade2.xScale = .25
barricade2.yScale = .25
barricade2.health = levelConfig["level"..gameVarTable["currentLevel"]]["barricadeHealth"]
barricade2.damageReceived = 0
barricade2.healthPercent = 100
--
local barricade3 = display.newImage ("Images/LevelObjects/Barricade2.png")
barricade3.x = 410
barricade3.y = 250
barricade3.xScale = .25
barricade3.yScale = .25
barricade3.health = levelConfig["level"..gameVarTable["currentLevel"]]["barricadeHealth"]
barricade3.damageReceived = 0
barricade3.healthPercent = 100
---									 
local leftbutton = display.newImage("Images/ButtonIconsEtc/greenarrow.png")
leftbutton.x = 430
leftbutton.y = 290
leftbutton.xScale = .8
leftbutton.yScale = .8
leftbutton.id = "left"
leftbutton:scale(-1, 1);

local rightbutton = display.newImage("Images/ButtonIconsEtc/greenarrow.png")
rightbutton.x = 480
rightbutton.y = 290
rightbutton.xScale = .8
rightbutton.yScale = .8
rightbutton.id = "right"
---

function moveCraneHorizontal (event)
	if event.phase == "began" then
		display:getCurrentStage():setFocus(event.target)
		if not craneGrabPressed then
			if event.target.id == "left" then
				motionx = -1 * gameVarTable["craneSpeed"]
				motiony = 0
				canMoveHand = true
			elseif event.target.id == "right" then
				motionx = gameVarTable["craneSpeed"]
				motiony = 0
				canMoveHand = true
			end
		end
		prevx = event.x
        prevy = event.y
	elseif event.phase == "moved" then
		--detect direction
		local dx = prevx - event.x
		local dy = prevy - event.y
		local distance = dx * dx + dy * dy
		local string_dir = ""
		local angle = math.atan2(dy,dx) * 57.2957795
		
		if (angle>=22*-1 and angle<23) or (angle>=23 and angle<68) or (angle>=67*-1 and angle<22*-1) then
			string_dir = "left"
		elseif (angle>=113 and angle<158) or (angle>=135 or angle<157*-1) or (angle>=157*-1 and angle<112*-1) then
			string_dir = "right"
		end

		if not craneGrabPressed then
			if string_dir == "left" then
				motionx = -1 * gameVarTable["craneSpeed"]
				motiony = 0
				canMoveHand = true
			elseif string_dir == "right" then
				motionx = gameVarTable["craneSpeed"]
				motiony = 0
				canMoveHand = true
			end
		end
	elseif event.phase == "ended" then
		motionx = 0
		display:getCurrentStage():setFocus(nil)
	end
end
leftbutton:addEventListener("touch", moveCraneHorizontal )
rightbutton:addEventListener("touch", moveCraneHorizontal )
---
local dropbutton = display.newImage("Images/ControlPanel/ControlPanelButton.png")
dropbutton.x = 5
dropbutton.y = 290
dropbutton.xScale = .5
dropbutton.yScale = .5

local fistbutton = display.newImage("Images/LevelObjects/fistbutton.png")
fistbutton.x = 75
fistbutton.y = 290
fistbutton.xScale = .5
fistbutton.yScale = .5
---
local pausebutton = display.newImage("Images/LevelObjects/pausebutton.png")
pausebutton.x = 490; pausebutton.y = 15
pausebutton.xScale = .5; pausebutton.yScale = .5
---
---------------------
--Pause Menu Assets--
---------------------
local pausemenubg = display.newImage("Images/LevelSelect/levelselection1.png")
pausemenubg.x = 240
pausemenubg.y = 100
pausemenubg.xScale = 1
pausemenubg.yScale = 1
pausemenubg.isVisible = false
---
local mainmenubutton = display.newImage("Images/PauseMenu/mainmenubutton.png")
mainmenubutton.x = 200
mainmenubutton.y = 140
mainmenubutton.xScale = .4
mainmenubutton.yScale = .4
mainmenubutton.isVisible = false
---
local restartbutton = display.newImage("Images/PauseMenu/restartbutton.png")
restartbutton.x = 290
restartbutton.y = 140
restartbutton.xScale = .325
restartbutton.yScale = .325
restartbutton.isVisible = false
---------------------------------------------
--Conveyor Belts--
------------------------------------------

local grindcup = display.newImage ("Images/LevelObjects/ZombieGrinder.png")
grindcup.x = 30
grindcup.y = 200

---
local pauseText = display.newText("Paused", 210, 25, "Let's Eat", 15)
	  pauseText:setTextColor(0,0,0)
	  pauseText.isVisible = false
---eventually will end up rewriting to use the ui.newButton function
local closeBtn = ui.newButton{
	defaultSrc = "Images/LevelSelect/closebtn.png",
	defaultX = 44,
	defaultY = 44,
	overSrc = "Images/LevelSelect/closebtn-over.png",
	overX = 50,
	overY = 54,
	onEvent = onCloseTouch,
	id = "CloseButton",
	text = "",
	font = "Helvetica",
	textColor = { 255, 255, 255, 255 },
	size = 16,
	emboss = false
}

closeBtn.x = 80
closeBtn.y = 175
closeBtn.isVisible = false

local function closePauseMenu()
	pausemenubg.isVisible = false
	mainmenubutton.isVisible = false
	restartbutton.isVisible = false
	pauseText.isVisible = false
	closeBtn.isVisible = false
end

local function openPauseMenu()
	pausemenubg.isVisible = true
	mainmenubutton.isVisible = true
	restartbutton.isVisible = true
	pauseText.isVisible = true
	closeBtn.isVisible = true
end

local function unpauseLevel(event)
	if event.phase == "ended" then
		closePauseMenu()
		exiting = false
        gameVarTable["canPause"] = false
	end
end

local function pauseLevel(event)
	print(event.phase)
	
	if event.phase == "began" then
		display:getCurrentStage():setFocus(event.target)
		gameVarTable["canPause"] = true
	elseif event.phase == "ended" and gameVarTable["canPause"] then	
		if not exiting then
            exiting = true
            --any other wierd pausing issues go here
            openPauseMenu()
		end
	end
end

-- Show alert with two buttons
local mainMenuAlert
local restartLevelAlert 

-- Handler that gets notified when the alert closes
local function onMainMenuComplete( event )
	print(event.action)
        if "clicked" == event.action then
                local i = event.index
                print (event.index)
				if 1 == i then
                    -- Do nothing; dialog will simply dismiss
                elseif 2 == i then
                    --Go
					print(tostring(gameVarTable["gotoMainMenuBool"]).." " ..tostring(exiting))
                    if not gameVarTable["gotoMainMenuBool"] and exiting then
						gameVarTable["gotoMainMenuBool"] = true
						mainMenuAlert = nil --do we need???
					end   
                end
        end
end

-- Handler that gets notified when the alert closes
local function onRestartLevelComplete( event )
        if "clicked" == event.action then
                local i = event.index
                
				if 1 == i then
                    -- Do nothing; dialog will simply dismiss
                elseif 2 == i then
                    --Go
					if not gameVarTable["restartLevelBool"] and exiting then
						gameVarTable["restartLevelBool"] = true
						restartLevelAlert = nil --do we need???
					end  
                end
        end
end

local function gotoMainMenu(event)
	mainMenuAlert = native.showAlert( "Main Menu", "Are you sure you want to exit the game?", { "No!", "Yes Dammit!" }, onMainMenuComplete )
end

local function restartLevel(event)
	restartLevelAlert = native.showAlert( "Restart Level?", "Are you sure you want to restart the level?", { "No!", "Yes, Dammit!" }, onRestartLevelComplete )
end

local function slamFistPunch(event)
    if event.phase == "began" and not gameVarTable["canPunch"] then
        gameVarTable["canPunch"] = true
    elseif event.phase == "ended" and gameVarTable["canPunch"] then
        if gameVarTable["canPunch"] and spawnTable[1].currentState == "empty" and
		gameVarTable["handEnergy"] >= gameVarTable["energyRequiredToPunch"] then
            gameVarTable["handEnergy"] = gameVarTable["handEnergy"] - gameVarTable["energyRequiredToPunch"]
			spawnTable[1].currentState = "punching"  
			spawnTable[1]:setSequence("punch")
			spawnTable[1]:play()
        end
    end
    
end

local function touchdropbutton2(event)
	if spawnTable[1].y <= gameVarTable["craneMinYPosition"] and event.phase == "began" then
		canDrop2 = true 
	end
	if event.phase == "ended" and canDrop2 then
		if not gameVarTable["canDrop"] and gameVarTable["zombiesInCrane"] <= 0 and 
		gameVarTable["handEnergy"] >= gameVarTable["energyRequiredToGrab"] then
			if (not gameVarTable["craneGrabPressed"]) then
				gameVarTable["craneGrabPressed"] = true
				motionx = 0
				motiony = gameVarTable["craneDropSpeed"]
				spawnTable[1]:setSequence("grab")
				spawnTable[1]:play()
				gameVarTable["handEnergy"] = gameVarTable["handEnergy"] - gameVarTable["energyRequiredToGrab"]
			end
		elseif gameVarTable["canDrop"] then
			if (not gameVarTable["craneDropPressed"]) then
				gameVarTable["craneDropPressed"] = true
				motionx = 0
				motiony = 0
			end
		end
	end
	
end

pausebutton:addEventListener("touch", pauseLevel)
closeBtn:addEventListener("touch", unpauseLevel)
mainmenubutton:addEventListener("touch", gotoMainMenu)
restartbutton:addEventListener("touch", restartLevel)
fistbutton:addEventListener("touch", slamFistPunch)
dropbutton:addEventListener("touch", touchdropbutton2)

row1Group:insert( barricade )
row1Group:insert( barricade2 )
row1Group:insert( barricade3 )
level1Group:insert( grindcup )
--level1Group:insert( rightconveyorbelt )
menuGroup:insert( fistbutton )
menuGroup:insert( dropbutton ) 
menuGroup:insert( leftbutton )
menuGroup:insert( rightbutton )
menuGroup:insert( pausemenubg )
menuGroup:insert( mainmenubutton )
menuGroup:insert( restartbutton )
menuGroup:insert( pauseText )
menuGroup:insert( closeBtn )
menuGroup:insert( pausebutton )

--add barricades to barricadeTable
barricadeTable[1] = barricade
barricadeTable[2] = barricade2
barricadeTable[3] = barricade3


------------------
--SCREEN/UI TEXT--
------------------
--levelText is always on the top-middle, indicating what the current level is
local levelText = display.newText("Level " ..gameVarTable["currentLevel"], 250, 5, "Let's Eat", 25)
	  levelText:setTextColor(255,255,0)
	  
--grindText gets fired on the grind- can be changed to w/e we need
local grindText = display.newText("Grind!!!!", 210, 10, "Let's Eat", 30)
	  grindText:setTextColor(255,0,0)
	  grindText.isVisible = false
	  
--hurryText gets fired close to level fail- can be changed to w/e we need
local hurryText = display.newText("Hurry, the zombies are escaping!!!!", 180, 10, "Let's Eat", 20)
	  hurryText:setTextColor(255,0,0)
	  hurryText.isVisible = false
	  
local waveText = display.newText("Wave 1", 155, 20, "Let's Eat", 30)
	  waveText:setTextColor(0,0,0)
	  
local function hideText(event)
	if waveText ~= nil then
		waveText.isVisible = false
		if hideTextTimer ~= nil then
			timer.cancel(hideTextTimer)
			hideTextTimer = nil
		end
	end
	if gameText ~= nil then
		gameText.isVisible = false
		if gameTextTimer ~= nil then
			timer.cancel(gameTextTimer)
			gameTextTimer = nil
		end
	end
	if grindText ~= nil then
		grindText.isVisible = false
	end
end

local gameText 
local gameTextTimer
local resetGrabTimer --Resets the "grab"
local hideTextTimer --Hides the blood text

-- show's text to the screen, then removes with a timer after a few seconds
local function showGameText(params)
	
	if gameText == nil then
		gameText = display.newText(params.text, params.x, params.y, "Let's Eat", params.fontSize)
		gameText:setTextColor(params.rValue,params.gValue,params.bValue)
		gameText.isVisible = true
		gameTextTimer = timer.performWithDelay(2000,hideText,0)
	else
		gameText.text = params.text
		gameText.isVisible = true
	end
end
	  
--barrier texts for now to show health on them- change to health bars
local barricadeHealth = display.newRect(235,200,25,5)
	  barricadeHealth:setFillColor(0,250,0)
	  barricadeHealth:setReferencePoint(display.TopLeftReferencePoint)
	  
local barricade2Health = display.newRect(315,200,25,5)
	  barricade2Health:setFillColor(0,250,0)
	  barricade2Health:setReferencePoint(display.TopLeftReferencePoint)

local barricade3Health = display.newRect(390,200,25,5)
	  barricade3Health:setFillColor(0,250,0)  
	  barricade3Health:setReferencePoint(display.BottomLeftReferencePoint)

menuGroup:insert( levelText )
menuGroup:insert( grindText )
menuGroup:insert( hurryText )
menuGroup:insert( waveText  )
menuGroup:insert( barricadeHealth )
menuGroup:insert( barricade2Health )
menuGroup:insert( barricade3Health )
------------------

--Grind Button
local canGrind = false

local function touchgrindbutton (event)
	local i, v, r, s
	
	if event.phase == "began" then
		canGrind = true
	elseif event.phase == "ended" and canGrind then
		audio.play( audioStash.grindSound1 )
		
		for i, v in pairs(spawnTable) do
			if spawnTable[i].currentState == "inGrinder" then
				if (spawnTable[i] ~= nil) then
					--get points for grinding, and then remove the zombies in the grinder
					pointsInLevelTotal = pointsInLevelTotal + spawnTable[i].grindPoints
					display.remove(spawnTable[i])
					spawnTable[i] = nil	
					gameVarTable["enemiesAlive"] = gameVarTable["enemiesAlive"] - 1
					if gameVarTable["zombiesLeftToSpawn"] >= 1 then
						gameVarTable["zombiesLeftToSpawn"] = gameVarTable["zombiesLeftToSpawn"] - 1
						spawnWalkers({spawnAmount = 1})
					end
					gameVarTable["amountGrinded"] = gameVarTable["amountGrinded"] + 1
					gameVarTable["coinsCollected"] = gameVarTable["coinsCollected"] + 10
				end
				--spawn one blood splurt for all zombies in the grinder
				--spawnBlood({spawnAmount = 1, x= 20, y = 120, loopCount = 1})
				
				--Pops up grind text, and hides it after a few seconds
				grindText.isVisible = true
				hideTextTimer = timer.performWithDelay(2000,hideText,0)
				
			end
		end	
		gameVarTable["coinsCollected"] = gameVarTable["coinsCollected"] + gameVarTable["limbsInGrinder"]
		gameVarTable["limbsInGrinder"] = 0
		canGrind = false
	end
end
grindcup:addEventListener("touch", touchgrindbutton)
local canDrop2 = false

local function stop (event)
	if not exiting and event.phase == "ended" then
		motionx = 0
		motiony = 0
		canDrop2 = false
		spawnTable[1].isMoving = false
	end	
end
Runtime:addEventListener("touch", stop )

local canTouchBarrel = false
local canMoveCoin = false

gameVarTable["maxHandTouchRange"] = 59
gameVarTable["minBarrelTouchRange"] = 70

local function onLeverTouch( event )
	local phase = event.phase
	local t = event.target
	
	if not exiting then
		--for the hand
		if "began" == phase then
			t.isFocus = true
			-- Store initial position
			t.x0 = event.x - t.x
			t.y0 = event.y - t.y
			prevx = event.x
			prevy = event.y
			if (event.y >= gameVarTable["minBarrelTouchRange"]) and not canTouchBarrel and event.y <= 120 then
				canTouchBarrel = true
				canMoveCoin = false
			elseif event.y >= 0 and event.y <= gameVarTable["maxHandTouchRange"] and not canMoveCoin and (event.x + 10 >= spawnTable[1].x and event.x <= spawnTable[1].x) or (event.x - 10 <= spawnTable[1].x and event.x >= spawnTable[1].x) then
				canTouchBarrel = false
				canMoveCoin = false
				spawnTable[1].isMoving = true
			else
				canTouchBarrel = false
				canMoveCoin = true
			end
			
			print(event.x .." " ..event.y)
			-- open pause menu
			if event.x >= 450 and (event.y >= 0 and event.y <= 50) then 
				exiting = true
			    openPauseMenu()
			end
		
		elseif "ended" == phase then
			motionx = 0
			motiony = 0
			canTouchBarrel = false
			canMoveCoin = false
		elseif t.isFocus then
			if "moved" == phase then
			print(event.x .." " ..event.y)
				local dx = prevx - event.x
				local dy = prevy - event.y
				local distance = dx * dx + dy * dy
				
				if event.y >= 155 then
					canTouchBarrel = false
				end	

				if (canTouchBarrel or canMoveCoin) and not spawnTable[1].isMoving then
					local string_dir = ""
					local angle = math.atan2(dy,dx) * 57.2957795
					
					if (angle>=157*-1 and angle<112*-1) or (angle>=112*-1 and angle<67*-1) or (angle>=67*-1 and angle<22*-1) then
						string_dir="Downward"
					end
					---detection for the barrels
					for i, v in pairs(spawnTable) do
						if spawnTable[i] ~= nil and spawnTable[i].objType == "Barrel" and string_dir == "Downward" and not spawnTable[i].isFalling and canTouchBarrel then
							if event.x >= spawnTable[i].x - gameVarTable["barrelTouchRegion"] and event.x <= spawnTable[i].x then
								spawnTable[i].isFalling = true
							elseif event.x <= spawnTable[i].x + gameVarTable["barrelTouchRegion"] and event.x >= spawnTable[i].x then
								spawnTable[i].isFalling = true
							end
						elseif spawnTable[i].objType == "Puppy" then
							if event.y <= 100 then
								if event.x >= spawnTable[i].x - gameVarTable["barrelTouchRegion"] and event.x <= spawnTable[i].x then
									spawnTable[i].isFalling = true
								elseif event.x <= spawnTable[i].x + gameVarTable["barrelTouchRegion"] and event.x >= spawnTable[i].x then
									spawnTable[i].isFalling = true
								end
							end
						elseif spawnTable[i].objType == "Limb" and canMoveCoin then
							if (event.x >= spawnTable[i].x - 25 and event.x <= spawnTable[i].x) or (event.x <= spawnTable[i].x + 25 and event.x >= spawnTable[i].x) then
								if (event.y >= spawnTable[i].y - 25 and event.y <= spawnTable[i].x) or (event.y <= spawnTable[i].y + 25 and event.y >= spawnTable[i].x) then
									spawnTable[i].isMoving = true
									motionx = 0
									motiony = 0
								end
							end
						end
					end
				end
			end
		end
	end
end
 
backgroundImage:addEventListener("touch", onLeverTouch)
--[[ ]]--

--------------------------------------------------------
----------------------------------------------------------------------
--CRANE MOVEMENT
----------------------------------------------------------------------

local function resetGrab(event)
	gameVarTable["craneGrabPressed"] = false
	timer.cancel(resetGrabTimer)
	resetGrabTimer = nil
	spawnTable[1].currentState = "empty"
end

--TODO: Figure out how to search a table for a name value, to obtain a handle on crane object dynamically 
----------
--Clean up
----------
local function clean()
	local i, v
	local r, s
	local x, y
	
	--remove all event listeners first-	
	grindcup:removeEventListener("touch", touchgrindbutton)
	--replace with bg image
	backgroundImage:removeEventListener("touch", onLeverTouch)
	pausebutton:removeEventListener("touch", pauseLevel)
	closeBtn:removeEventListener("touch", unpauseLevel)
	mainmenubutton:removeEventListener("touch", gotoMainMenu)
	restartbutton:removeEventListener("touch", restartLevel)
	--remove runtime Event Listener for "Stop" method
	Runtime:removeEventListener("touch", stop)
	
	--audio
	audio.stop()
	cancelAllAudio()
	--tables
        
        for i, v in pairs(particles) do
		if (particles[i] ~= nil) then
			display.remove(particles[i])
			particles[i] = nil
		end
	end
	
	for r, s in pairs(bloodTable) do
		if (bloodTable[r] ~= nil) then
			display.remove(bloodTable[r])
			bloodTable[r] = nil
		end
	end
	
	for r, s in pairs(explosionTable) do
		if (explosionTable[r] ~= nil) then
			display.remove(explosionTable[r])
			explosionTable[r] = nil
		end
	end
	
	--level timers (clean manually)
	if firePowerTimer ~= nil and firePowerTimer ~= 0 then
		timer.cancel(firePowerTimer)
		firePowerTimer = nil
	end
	if loadCannonTimer ~= nil then
		timer.cancel(loadCannonTimer)
		loadCannonTimer = nil
	end
	if resetGrabTimer ~= nil then
		timer.cancel(resetGrabTimer)
		resetGrabTimer = nil
	end
	if hideTextTimer ~= nil then
		timer.cancel(hideTextTimer)
		hideTextTimer = nil
	end
	--
	--cancel all timers contained in table in main.lua (timerStash)
	cancelAllTimers()
	
	--do spawn table last
	for x, y in pairs(spawnTable) do
		if x >= 1 then
			if (spawnTable[x] ~= nil) then
				display.remove(spawnTable[x])
				spawnTable[x] = nil
			end
		end
	end
	
	display.remove(menuGroup)
	menuGroup = nil
	display.remove(row1Group)
	row1Group = nil
	display.remove(row2Group)
	row2Group = nil
	display.remove(row3Group)
	row3Group = nil
	display.remove(row4Group)
	row4Group = nil
	display.remove(row5Group)
	row5Group = nil
	
	spawnTable = nil
	bloodTable = nil
	explosionTable = nil
	barricadeTable = nil
	gameVarTable = nil
	collectgarbage( "collect" )
end
---------------------------------------------
--Basic AI
---------------------------------------------
local puppyLanded = false 
local animStarted = false
gameVarTable["zombiesInGrinder"] = 0

local function resetIsStopped()
    local i, v

	if not exiting then
		for i, v in pairs(spawnTable) do
			if spawnTable[i] ~= nil then
				if spawnTable[i].objType == "Enemy" then
					if spawnTable[i].isStopped then
						if spawnTable[i].currentState == "movingRight" then             
							spawnTable[i].isStopped = false
						end
					end
			   end
			end
		end
	end
end

local isShaking = false
local shakeDir = "down"
local shakeCount = 0


local function makeShake(event)
	if isShaking then
		shakeCount = shakeCount + 1
		
		if shakeCount <= 10 then
			if shakeDir == "down" then
				--comment the next line, and uncomment the one after that
				backgroundImage.y = backgroundImage.y - 5
				--backgroundImage.x = backgroundImage.x - 5
				shakeDir = "up"				
			elseif shakeDir == "up" then
				--comment the next line, and uncomment the one after that
				backgroundImage.y = backgroundImage.y + 5
				--backgroundImage.x = backgroundImage.x + 5
				shakeDir = "down"
			end
		else 
			isShaking = false
			shakeCount = 0
			shakeDir = "down"
			timer.cancel(shakeScreen)
			shakeScreen = nil
			gameVarTable["canPunchKill"]  = true
		end
	end
end

local function ShakeScreen()
	--backgroundImage.x = backgroundImage.x -5 
	if not isShaking then
		isShaking = true
		shakeScreen = timer.performWithDelay(1,makeShake,0)
	end
end

local function updateLayers()
	row1Group:toFront();
	row2Group:toFront();
	row3Group:toFront();
	row4Group:toFront();
	row5Group:toFront();
	menuGroup:toFront();
	spawnTable[1]:toFront()
end

local timeCounter = 0

local function spawnWave()
	gameVarTable["currentWave"] = gameVarTable["currentWave"] + 1
	waveText.text = ("wave " ..gameVarTable["currentWave"])
	waveText.isVisible = true
	hideTextTimer = timer.performWithDelay(2000,hideText,0)
	
	if gameVarTable["currentWave"] <= gameVarTable["maxWaveNumber"] then
		if gameVarTable["currentWave"] == 1 then
			spawnWalkers({spawnAmount = levelConfig["level"..gameVarTable["currentLevel"]]["wave1SpawnAmt"]})
		elseif gameVarTable["currentWave"] == 2 then
			spawnWalkers({spawnAmount = levelConfig["level"..gameVarTable["currentLevel"]]["wave2SpawnAmt"]})
		elseif gameVarTable["currentWave"] == 3 then
			spawnWalkers({spawnAmount = levelConfig["level"..gameVarTable["currentLevel"]]["wave3SpawnAmt"]})
		elseif gameVarTable["currentWave"] == 4 then
			spawnWalkers({spawnAmount = levelConfig["level"..gameVarTable["currentLevel"]]["wave4SpawnAmt"]}) 
		else
			spawnWalkers({spawnAmount = levelConfig["level"..gameVarTable["currentLevel"]]["wave" ..gameVarTable["currentWave"] .."SpawnAmt"]})
		end
	end
	timeCounter = 0
end
local goToResultsTimer
local goToFailedLevelTimer

local function goToFailedLevel()
	timer.cancel(goToFailedLevelTimer)
	goToFailedLevelTimer = nil
	director:changeScene( "LuaFiles.levelfailed" ) 
end

local function goToResults()
	timer.cancel(goToResultsTimer)
	goToResultsTimer = nil
	director:changeScene( "LuaFiles.results" ) 
end

local function updateHandBar()
	if not exiting then
		if spawnTable[1] ~= nil then
			
			handBar.x = spawnTable[1].x + 3; 
			handBar.y = spawnTable[1].y - 180
			if (handBar.x <= gameVarTable["craneMinXPosition"] + 3) then
				handBar.x = gameVarTable["craneMinXPosition"];
			end
			
			if gameVarTable["handEnergy"] >= gameVarTable["energyRequiredToGrab"] then 
				spawnTable[2]:setSequence("green")
				spawnTable[2]:play()
			elseif gameVarTable["handEnergy"] >= gameVarTable["energyRequiredToPunch"] then
				spawnTable[2]:setSequence("yellow")
				spawnTable[2]:play()
			else
				spawnTable[2]:setSequence("red")
				spawnTable[2]:play()
			end
			--regenerates the Hand Energy
			if handEnergyRegenCount >= 1 then
				handEnergyRegenCount = handEnergyRegenCount - 1
			elseif handEnergyRegenCount == 0 then
				if gameVarTable["handEnergy"] <= gameVarTable["maxHandEnergy"] - 1 then
					gameVarTable["handEnergy"] = gameVarTable["handEnergy"] + 1
					handEnergyRegenCount = gameVarTable["handEnergyRegenRate"]
				end
			end
		end
	end
end

local function updateParticles()
	if not exiting then
		-- PARTICLES MOVING
		for i,val in pairs(particles) do
		   -- move each particle
		   val.yMove = val.yMove + val.gravity
		   val.object.x = val.object.x + val.xMove
		   val.object.y = val.object.y + val.yMove * 2
 		   
		   -- remove particles that are out of bound                            
		   if val.object.y > 320 or val.object.x > 480 or val.object.x < 0 then 
				val.object:removeSelf();
				particles [i] = nil
		   end
		end            
	end
end

local function checkWinningConditions()
	if not exiting then
		if (gameVarTable["currentWave"] >= gameVarTable["maxWaveNumber"] + 1) and
			gameVarTable["enemiesAlive"] <= 0 then
			
			--maxlevelUnlocked, currentLevel, amountGrinded, amountPunched, barrelKills, pointsTotal
			exiting = true;
			if gameVarTable["maxLevelUnlocked"] == gameVarTable["currentLevel"] then
				gameVarTable["maxLevelUnlocked"] = gameVarTable["currentLevel"] + 1
			end
			gameVarTable["currentLevel"] = gameVarTable["currentLevel"] + 1
			file = gameVarTable["maxLevelUnlocked"] .."," ..gameVarTable["currentLevel"] .."," ..gameVarTable["amountGrinded"] .."," ..gameVarTable["amountPunched"] .."," ..gameVarTable["barrelKills"] .."," ..pointsInLevelTotal
			saveFile("game.txt", file)
			
			showGameText({text = "Level Complete", x = 200, y = 150, fontSize = 20, rValue = 255, gValue = 0, bValue = 0})
			clean()
			goToResultsTimer = timer.performWithDelay(2000,goToResults,0)
		end
	end
end

local function updateHandCrane()
	if spawnTable[1].currentState == "empty" then --will handle empty state
		--Move left and right only if hand is at resting position
		if spawnTable[1].y <= gameVarTable["craneMinYPosition"] then
			spawnTable[1].x = spawnTable[1].x + motionx	
			gameVarTable["canPunch"] = true
		end		
	
		if gameVarTable["craneGrabPressed"] then
			--Handles the actual downard then back upward motion	
			if gameVarTable["craneGrabPressed"] and not gameVarTable["craneRetracting"] then
					spawnTable[1].y = spawnTable[1].y + gameVarTable["craneVerticalSpeed"]
					gameVarTable["canPunch"] = false
			elseif gameVarTable["craneRetracting"] then
					spawnTable[1].y = spawnTable[1].y - gameVarTable["craneVerticalSpeed"]
					gameVarTable["canPunch"] = false
			end	
		end	
	
		--Sets min and max Y positions for hand
		if spawnTable[1].y <= gameVarTable["craneMinYPosition"] then
			--Returned back to start position.
			spawnTable[1].y = gameVarTable["craneMinYPosition"]
			gameVarTable["craneGrabPressed"] = false
			gameVarTable["craneRetracting"] = false
			gameVarTable["canPunch"] = true
			if gameVarTable["zombiesInCrane"] >= 1 then
					gameVarTable["canDrop"] = true
					spawnTable[1].currentState = "readyToDrop"
			end				
		elseif spawnTable[1].y >= gameVarTable["craneMaxYPosition"]  then
			--Hit bottom, and is now retracting back to the top.
			spawnTable[1].y = gameVarTable["craneMaxYPosition"] 
			motiony = 5
			gameVarTable["craneRetracting"] = true
		end		
	
		--Sets min and max X positions for hand
		if spawnTable[1].x <= gameVarTable["craneMinXPosition"] then
			spawnTable[1].x = gameVarTable["craneMinXPosition"]
		elseif spawnTable[1].x >= gameVarTable["craneMaxXPosition"] then
			spawnTable[1].x = gameVarTable["craneMaxXPosition"]
		end
	elseif spawnTable[1].currentState == "punching" then
	    if spawnTable[1].y <= gameVarTable["craneMaxYPosition"]  + 10 and not gameVarTable["craneRetracting"]  then
			 spawnTable[1].y = spawnTable[1].y + gameVarTable["craneVerticalSpeed"]  * 1.5
	    elseif spawnTable[1].y >= gameVarTable["craneMaxYPosition"]  or gameVarTable["craneRetracting"] then
			spawnTable[1].y = spawnTable[1].y - gameVarTable["craneVerticalSpeed"] * 1.5
			
			if not gameVarTable["craneRetracting"]  then
				ShakeScreen()
				gameVarTable["craneRetracting"] = true
			end
	    end
				
							
	    if spawnTable[1].y <= gameVarTable["craneMinYPosition"] then
			--Returned back to start position.
			spawnTable[1].y = gameVarTable["craneMinYPosition"]
			gameVarTable["canPunch"] = true
			spawnTable[1]:setSequence("idle")
			spawnTable[1]:play()
			spawnTable[1].currentState = "empty"
	    end
		   
	elseif spawnTable[1].currentState == "readyToDrop" then --will handle dropping zombies 

		--should still be able to move left and right before you drop the zombies
		spawnTable[1].x = spawnTable[1].x + motionx	
		
		--Sets min and max X positions for hand
		if spawnTable[1].x <= gameVarTable["craneMinXPosition"] then
			spawnTable[1].x = gameVarTable["craneMinXPosition"]
		elseif spawnTable[1].x >= gameVarTable["craneMaxXPosition"] then
			spawnTable[1].x = gameVarTable["craneMaxXPosition"]
		end
	end
end

local function explosionSpriteListener(event)
	local t = event.target
	t.isPlaying = true
	if event.phase == "ended" then
		t:removeEventListener("sprite", explosionSpriteListener)
		display.remove(t)
		display.remove(spawnTable[t.Name])
		spawnTable[t.Name] = nil
		t = nil
	end
	
end

local alreadyAttacking = false

local function touchPuppyToAttack(event)
	local t = event.target
	if event.phase == "ended" then
		if (t.y == 280) then
			t.currentState = "CrackPuppyAttack"
			t.isFalling = false
			--t.isReadyToAct = false
		end
	end
	return true
end

local function bombPuppySpriteListener(event)
	local t = event.target
	t.isPlaying = true
	
	if event.phase == "loop" then
		t:removeEventListener("sprite", bombPuppySpriteListener)
		t.isAttackingFlag = false
		t.isPlaying = false
		
		if t.fatLevel == 1 then
			t:setSequence("bombIdleFat1")
			t:play()
		elseif t.fatLevel == 2 then
			t:setSequence("bombIdleFat2")
			t:play()
		elseif t.fatLevel == 3 then
			t:setSequence("bombIdleFat3")
			t:play()
		elseif t.fatLevel == 4 then
			t:setSequence("bombIdleFat4")
			t:play()
		elseif t.fatLevel == 5 then
			t:setSequence("bombIdleFat5")
			t:play()
		end
	end
end

local function checkCollisions()
	local i, v
	
	if not exiting then
		for i, v in pairs(spawnTable) do
			if spawnTable[i] ~= nil then
				--Added in the isFalling check to allow puppies to fall in here before they fall in the other block of code
				if spawnTable[i].objType == "Explosion" then
					if spawnTable[i].isPlaying == false then
						spawnTable[i].isPlaying = true
						spawnTable[i]:setSequence("explode")
						spawnTable[i]:play()
						spawnTable[i]:addEventListener("sprite", explosionSpriteListener)
						spawnTable[i].isPlaying = true
					end
				elseif spawnTable[i].objType == "Limb" and not spawnTable[i].isMoving then
					if spawnTable[i].direction == nil then
						spawnTable[i].xMove = rand (-10,10)
						spawnTable[i].yMove = rand (10) * - 1
						spawnTable[i].gravity = 0.5
						if spawnTable[i].xMove <= 0 then
							spawnTable[i].direction = "Left"
						elseif spawnTable[i].xMove >= 0 then
							spawnTable[i].direction = "Right"
						end
					else 		   
						-- remove particles that are out of bound 
						if spawnTable[i].maxYStopPoint == nil then
							spawnTable[i].maxYStopPoint = rand(250,300)
						end
						
						if spawnTable[i].y >= spawnTable[i].maxYStopPoint then
							spawnTable[i].y = spawnTable[i].maxYStopPoint
							spawnTable[i].xMove = 0
							spawnTable[i].yMove = 0
						elseif spawnTable[i].x > 480 or spawnTable[i].x < 0 then 
							spawnTable[i]:removeSelf();
							spawnTable[i] = nil
						else
							spawnTable[i].yMove = spawnTable[i].yMove + spawnTable[i].gravity
							spawnTable[i].x = spawnTable[i].x + spawnTable[i].xMove
							spawnTable[i].y = spawnTable[i].y + spawnTable[i].yMove * 2
						end
					end
				elseif spawnTable[i].objType == "Siren" then
					if spawnTable[i].isPlaying == false then
						spawnTable[i].isPlaying = true
						spawnTable[i]:setSequence("play")
						spawnTable[i]:play()
					end
				elseif spawnTable[i].objType == "Limb" and spawnTable[i].isMoving then
					local squareroot = math.sqrt

					local distanceX = 0
					local distanceY = 0
					
					distanceX = (grindcup.x - 20) - spawnTable[i].x
					distanceY = (grindcup.y - 20) - spawnTable[i].y
					

					if (spawnTable[i].x >= -40 and spawnTable[i].x <= 50) and (spawnTable[i].y >= 150 and spawnTable[i].y <= 200) then
						gameVarTable["limbsInGrinder"] = gameVarTable["limbsInGrinder"] + 1
						display.remove(spawnTable[i])
						spawnTable[i] = nil
						numCoins = numCoins - 1						
					else
						spawnTable[i].x = spawnTable[i].x + (distanceX * .10)
						spawnTable[i].y = spawnTable[i].y + (distanceY * .10)
					end
				elseif spawnTable[i].objType == "Barrel" or spawnTable[i].isFalling == true then

					if spawnTable[i].canDestroy == true then
					
						if spawnTable[i] ~= nil then
							display.remove(spawnTable[i])
							spawnTable[i] = nil
						end
					elseif spawnTable[i].isFalling and spawnTable[i].y <= 265 then
						spawnTable[i].y = spawnTable[i].y + barrelFallSpeed
					elseif spawnTable[i].y >= 265 then
						if not spawnTable[i].isReadyToAct then
							--swap animation to exploded animation, then take out zombies in region
							spawnTable[i].isReadyToAct = true
							spawnTable[i].isFalling = false
							if spawnTable[i].objType == "Barrel" then
								spawnTable[i].canDestroy = true
							end
							spawnTable[i].destroyCount = 0
							-- blood is BOOLEAN, if true then particles will be red, otherwise white
							if (spawnTable[i].objType == "Barrel") then
								spawnExplosion({spawnAmount = 1, x=spawnTable[i].x,y=spawnTable[i].y - 20})

								--explosion(spawnTable[i].x, spawnTable[i].y, "waste", 20)
								--PERFORMANCE CHECK: runs through a check of every zombie within screen region, once per barrel drop, when it hits the ground and explodes.
								for t, u in pairs(spawnTable) do
									if spawnTable[t].objType == "Enemy" and spawnTable[t] ~= nil 
									and	(spawnTable[t].currentState == "movingRight" or spawnTable[t].currentState == "attacking") 
									and	spawnTable[t].x >= 30 and spawnTable[t].x <= 480 then							
										if spawnTable[t].x + gameVarTable["barrelAreaOfEffect"] >= spawnTable[i].x 
										and	spawnTable[t].x <= spawnTable[i].x then
											spawnTable[t].flaggedForRemoval = true
											gameVarTable["enemiesAlive"] = gameVarTable["enemiesAlive"] - 1
											gameVarTable["barrelKills"] = gameVarTable["barrelKills"] + 1
											if gameVarTable["zombiesLeftToSpawn"] >= 1 then
												gameVarTable["zombiesLeftToSpawn"] = gameVarTable["zombiesLeftToSpawn"] - 1
												spawnWalkers({spawnAmount = 1})
											end
											spawnLevelDrop({randomNum = 1, x= spawnTable[t].x, y= spawnTable[t].y})
											
										elseif spawnTable[t].x - gameVarTable["barrelAreaOfEffect"] <= spawnTable[i].x 
										and spawnTable[t].x >= spawnTable[i].x then
											spawnTable[t].flaggedForRemoval = true
											gameVarTable["enemiesAlive"] = gameVarTable["enemiesAlive"] - 1
											gameVarTable["barrelKills"] = gameVarTable["barrelKills"] + 1
											if gameVarTable["zombiesLeftToSpawn"] >= 1 then
												gameVarTable["zombiesLeftToSpawn"] = gameVarTable["zombiesLeftToSpawn"] - 1
												spawnWalkers({spawnAmount = 1})
											end
											spawnLevelDrop({randomNum = 1, x= spawnTable[t].x, y= spawnTable[t].y})
											
										end
										if spawnTable[t].flaggedForRemoval == true then
											display.remove(spawnTable[t])
											spawnTable[t] = nil
										end
									end
								end
							end
						end
					elseif spawnTable[i].x >= 500 then
						if spawnTable[i] ~= nil then
							display.remove(spawnTable[i])
							spawnTable[i] = nil
						end
					end
				elseif spawnTable[i].objType == "Puppy" then
					if spawnTable[i].y <= 60 and not spawnTable[i].isReadyToAct then
						spawnTable[i].y = spawnTable[i].y + barrelFallSpeed
					elseif not spawnTable[i].isReadyToAct then
						spawnTable[i].x = spawnTable[i].x + gameVarTable["conveyorSpeed"]
					end	

					--Destroy at the end of conveyor
					if spawnTable[i].x >= 480 then
						spawnTable[i].flaggedForRemoval = true
					end
					
					if spawnTable[i].currentState == "normal" then
						--start anim
						if not spawnTable[i].isPlaying then
							spawnTable[i].isPlaying = true
							spawnTable[i]:setSequence("idle")
							spawnTable[i]:play()
						end
						
						if spawnTable[i].x >= 150 and spawnTable[i].x <= 250 and not spawnTable[i].isGassed then
							local randPuppy = rand(1,2)
							
							if randPuppy == 1 then
								print("CrackPuppyIdle")
								spawnTable[i].currentState = "CrackPuppyIdle"
								--replace with crack puppy idle
								spawnTable[i]:setSequence("crackIdle")
								spawnTable[i]:play()
							elseif randPuppy == 2 then
								print("BombPuppyIdle")
								spawnTable[i].currentState = "CrackPuppyIdle"
								--replace with bomb puppy idle
								spawnTable[i]:setSequence("crackIdle")
								spawnTable[i]:play()
								spawnTable[i].isAttackingFlag = false
								spawnTable[i].isPlaying = false
							end
							spawnTable[i].isGassed = true
						end							
					elseif spawnTable[i].currentState == "BombPuppyIdle" then
						spawnTable[i].xScale = .8
						spawnTable[i].yScale = .8
						
						if spawnTable[i].isReadyToAct then
						
							if spawnTable[i].fatLevel == nil then
								spawnTable[i].fatLevel = 1
								spawnTable[i].hasEaten = 0
							end
							--replace with better way of checking tables
							for t, u in pairs(spawnTable) do
								if spawnTable[t].objType == "Enemy" and spawnTable[i] ~= nil then
									if spawnTable[t].x <= spawnTable[i].x and spawnTable[t].x + 50 >= spawnTable[i].x and not spawnTable[i].isAttackingFlag then
										print("isAttacking")
										if spawnTable[i].fatLevel == 1 then
											spawnTable[i]:setSequence("bombAttackFat1")
											spawnTable[i]:play()
										elseif spawnTable[i].fatLevel == 2 then
											spawnTable[i]:setSequence("bombAttackFat2")
											spawnTable[i]:play()
										elseif spawnTable[i].fatLevel == 3 then
											spawnTable[i]:setSequence("bombAttackFat3")
											spawnTable[i]:play()
										elseif spawnTable[i].fatLevel == 4 then
											spawnTable[i]:setSequence("bombAttackFat4")
											spawnTable[i]:play()
										elseif spawnTable[i].fatLevel == 5 then
											spawnTable[i]:setSequence("bombAttackFat5")
											spawnTable[i]:play()
										end
										spawnTable[i]:addEventListener("sprite", bombPuppySpriteListener)
										spawnTable[i].isAttackingFlag = true
									elseif spawnTable[t].x <= spawnTable[i].x and spawnTable[t].x + 20 >= spawnTable[i].x then
										spawnTable[t].flaggedForRemoval = true
										spawnTable[i].hasEaten = spawnTable[i].hasEaten + 1
										gameVarTable["enemiesAlive"] = gameVarTable["enemiesAlive"] - 1
										if spawnTable[i].hasEaten >= spawnTable[i].fatLevel * 3 then
											spawnTable[i].fatLevel = spawnTable[i].fatLevel + 1
											
											if spawnTable[i].fatLevel >= 6 then
												spawnTable[i].flaggedForRemoval = true
												spawnExplosion({spawnAmount = 1, x=spawnTable[i].x,y=spawnTable[i].y - 20})
												spawnExplosion({spawnAmount = 1, x=spawnTable[i].x - 50,y=spawnTable[i].y - 20})
												spawnExplosion({spawnAmount = 1, x=spawnTable[i].x - 100,y=spawnTable[i].y - 20})
												spawnExplosion({spawnAmount = 1, x=spawnTable[i].x + 50,y=spawnTable[i].y - 20})
												spawnExplosion({spawnAmount = 1, x=spawnTable[i].x + 100,y=spawnTable[i].y - 20})
												display.remove(spawnTable[i])
												spawnTable[i] = nil
											end
										end
									end
								elseif spawnTable[t].objType == "Enemy" and spawnTable[i] == nil then
									spawnTable[t].flaggedForRemoval = true
									gameVarTable["enemiesAlive"] = 0
								end
							end
						end
					elseif spawnTable[i].currentState == "CrackPuppyIdle" then
						spawnTable[i].xScale = .8
						spawnTable[i].yScale = .8
						if not spawnTable[i].isPlayingHelpFlag and spawnTable[i].isPlaying then
							spawnTable[i]:addEventListener("touch", touchPuppyToAttack)
							spawnTable[i].isPlaying = false
							spawnTable[i].isAttackingFlag = false
						end
					elseif spawnTable[i].currentState == "CrackPuppyAttack" then--attack!
						
						spawnTable[i].x = spawnTable[i].x - 5
						spawnTable[i].y = spawnTable[i].y + rand(-5,5)
						
						if not spawnTable[i].isAttackingFlag then
							spawnTable[i].xScale = 1
							spawnTable[i].yScale = 1
							spawnTable[i]:setSequence("crackAttack")
							spawnTable[i]:play()
							spawnTable[i]:removeEventListener("touch", touchPuppyToAttack)
							spawnTable[i].isAttackingFlag = true
						end
						
						--print(spawnTable[i].x .. " " ..spawnTable[i].y)
						if (spawnTable[i].x >= 470) then
							spawnTable[i].x = 470
						elseif (spawnTable[i].x <= -25) then
							spawnTable[i].flaggedForRemoval = true
						end
						if (spawnTable[i].y >= 275) then
							spawnTable[i].y = 275
						elseif (spawnTable[i].y <= 240) then
							spawnTable[i].y = 240
						end
						
						
						--program attack against zombies
						for z, x in pairs(spawnTable) do
							if spawnTable[z].objType == "Enemy" and spawnTable[z].currentState ~= inGrinder and spawnTable[z].currentState ~= isInHand and spawnTable[z].currentState ~= isPickedUp then
								if spawnTable[z].x + 10 >= spawnTable[i].x and spawnTable[z].x <= spawnTable[i].x then
									if spawnTable[z] ~= nil then
										
										spawnTable[z].flaggedForRemoval = true
										gameVarTable["enemiesAlive"] = gameVarTable["enemiesAlive"] - 1 
										if gameVarTable["zombiesLeftToSpawn"] >= 1 then
										gameVarTable["zombiesLeftToSpawn"] = gameVarTable["zombiesLeftToSpawn"] - 1
											spawnWalkers({spawnAmount = 1})
										end
										spawnLevelDrop({randomNum = 1, x= spawnTable[z].x, y= spawnTable[z].y})
									end
								elseif spawnTable[z].x - 10 <= spawnTable[i].x and spawnTable[z].x >= spawnTable[i].x then
									if spawnTable[z] ~= nil then
										
										spawnTable[z].flaggedForRemoval = true
										gameVarTable["enemiesAlive"] = gameVarTable["enemiesAlive"] - 1 
										if gameVarTable["zombiesLeftToSpawn"] >= 1 then
										gameVarTable["zombiesLeftToSpawn"] = gameVarTable["zombiesLeftToSpawn"] - 1
											spawnWalkers({spawnAmount = 1})
										end
										spawnLevelDrop({randomNum = 1, x= spawnTable[z].x, y= spawnTable[z].y})
									end
								end
								if spawnTable[z].flaggedForRemoval then
									display.remove(spawnTable[z])
									spawnTable[z] = nil
								end
							end
						end
					end
				elseif spawnTable[i].objType == "Enemy" then
					--handles dropping the zombies from the crane hand--------------
					if spawnTable[i].isPickedUp and gameVarTable["canDrop"] then			
						if gameVarTable["craneDropPressed"] then 
							if spawnTable[i].isPickedUp then
								spawnTable[i].x = spawnTable[1].x
								spawnTable[i].y = spawnTable[1].y
								spawnTable[i].isPickedUp = false							
								spawnTable[i].currentState = "dropped"
								gameVarTable["zombiesInCrane"] = gameVarTable["zombiesInCrane"] - 1
								spawnTable[i].isInHand = false
								spawnTable[i]:setSequence("dangling")
								spawnTable[i]:play()
							end
							
							if gameVarTable["zombiesInCrane"] <= 0 then
								gameVarTable["craneDropPressed"] = false	
								gameVarTable["canDrop"] = false
								resetGrabTimer = timer.performWithDelay(50,resetGrab,0)
								spawnTable[1].amountCarrying = 0
							end
						end					
					end
					--handles the punching collision----------------------------------------
					if (spawnTable[1].currentState == "punching" and spawnTable[i].currentState ~= "inGrinder") then
						if spawnTable[i].x + gameVarTable["punchAreaOfEffect"] >= spawnTable[1].x and
						   spawnTable[i].x <= spawnTable[1].x and 
						   spawnTable[1].y >= gameVarTable["craneMaxYPosition"] then
							   explosion(spawnTable[i].x, spawnTable[i].y, "blood", 5)
							   spawnBlood({spawnAmount = 1, x= spawnTable[i].x, y = spawnTable[i].y, loopCount = 1})
							   updateLayers()
							   spawnTable[i].flaggedForRemoval = true
							   gameVarTable["enemiesAlive"] = gameVarTable["enemiesAlive"] - 1 
							   gameVarTable["amountPunched"] = gameVarTable["amountPunched"] + 1
							   if gameVarTable["zombiesLeftToSpawn"] >= 1 then
									gameVarTable["zombiesLeftToSpawn"] = gameVarTable["zombiesLeftToSpawn"] - 1
									spawnWalkers({spawnAmount = 1})
								end
								--spawnLevelDrop({randomNum = 3, x= spawnTable[i].x, y= spawnTable[i].y})
						elseif spawnTable[i].x - gameVarTable["punchAreaOfEffect"] <= spawnTable[1].x and
							spawnTable[i].x >= spawnTable[1].x and
							spawnTable[1].y >= gameVarTable["craneMaxYPosition"] then
							   explosion(spawnTable[i].x, spawnTable[i].y, "blood", 5)
							   spawnBlood({spawnAmount = 1, x= spawnTable[i].x, y = spawnTable[i].y, loopCount = 1})
							   updateLayers()
							   spawnTable[i].flaggedForRemoval = true
							   gameVarTable["enemiesAlive"] = gameVarTable["enemiesAlive"] - 1
							   gameVarTable["amountPunched"] = gameVarTable["amountPunched"] + 1
							   if gameVarTable["zombiesLeftToSpawn"] >= 1 then
									gameVarTable["zombiesLeftToSpawn"] = gameVarTable["zombiesLeftToSpawn"] - 1
									spawnWalkers({spawnAmount = 1})
								end
								--spawnLevelDrop({randomNum = 3, x= spawnTable[i].x, y= spawnTable[i].y})
						end
					end
					
					if spawnTable[1].y >= spawnTable[i].y - 50 and not gameVarTable["craneRetracting"] then
						if spawnTable[1].x >= spawnTable[i].x - 40
						and spawnTable[1].x <= spawnTable[i].x + 40 then
							if spawnTable[i].currentState ~= "dropped" and 
							spawnTable[i].currentState ~= "inGrinder" and
							spawnTable[1].currentState ~= "punching" then
								--check for accuracy and max amount to be picked up
								if not spawnTable[i].isPickedUp then
									if spawnTable[1].amountCarrying <= spawnTable[1].minCarry then
										spawnTable[i].currentState = "pickedUp"
										spawnTable[i].isPickedUp = true
										spawnTable[1].amountCarrying = spawnTable[1].amountCarrying + 1
										resetIsStopped()
									elseif spawnTable[1].amountCarrying < spawnTable[1].maxCarry then
										--determine roll for pickup
										checkRoll = rand(0,1)
										if checkRoll == 1 then
											spawnTable[1].amountCarrying = spawnTable[1].amountCarrying + 1
											spawnTable[i].currentState = "pickedUp"
											spawnTable[i].isPickedUp = true
										end
									end
								end
							end
						end
					end
					if spawnTable[i].currentState == "dropped" then
						spawnTable[i]:pause()
						if  spawnTable[i].y >= grindcup.y and spawnTable[i].x <= grindcup.x + 35 
						and spawnTable[i].x >= grindcup.x - 35 then
							if spawnTable[i].currentState ~= "inGrinder" then
								gameVarTable["zombiesInGrinder"] = gameVarTable["zombiesInGrinder"] + 1
								spawnTable[i].currentState = "inGrinder"
							end	
						elseif spawnTable[i].y <= spawnTable[i].startingY then
							spawnTable[i].y = spawnTable[i].y + 10
						else
							--check for collision with the grindcup, if not and it hits the ground 
							--then change state to walkingRight again
							spawnTable[i]:setSequence("walkingRight")
							spawnTable[i]:play()
							spawnTable[i].currentState = "movingRight"
						end			
					elseif spawnTable[i].currentState == "pickedUp" then --Put picked up conditions here
						--Removes them from the display, maybe add counter to determine how many are in hand at the moment?
						spawnTable[i].isEating = false
						if (spawnTable[i].isInHand == false) then
							spawnTable[i].isInHand = true
							gameVarTable["zombiesInCrane"] = gameVarTable["zombiesInCrane"] + 1
							spawnTable[i]:setSequence("dangling")
							spawnTable[i]:play()
						end
						
						spawnTable[i].x = spawnTable[1].x + 10
						spawnTable[i].y = spawnTable[1].y + 35
						--default variables back since picked up
						if spawnTable[i].isEating then
							spawnTable[i].isEating = false
						end
					elseif spawnTable[i].currentState == "attacking" then --Put attacking conditions here
						--------------------------------
						--Barricades--------------------
						--------------------------------
						if barricadeTable[3] ~= nil then
							if spawnTable[i].x >= barricadeTable[3].x -20 then --attacking 3rd barrier
								barricadeTable[3].damageReceived = barricadeTable[3].damageReceived + spawnTable[i].barrierDamage
								barricadeTable[3].healthPercent =  1 / (barricadeTable[3].health /(barricadeTable[3].health - barricadeTable[3].damageReceived))
								barricade3Health:setReferencePoint(display.BottomLeftReferencePoint)
								barricade3Health.width = 25*barricadeTable[3].healthPercent
								barricade3Health.x = 390
								barricade3Health.y = 205
								if barricadeTable[3].health - barricadeTable[3].damageReceived >= barricadeTable[3].health * .75 then
									barricade3Health:setFillColor(0,250,0)
								elseif barricadeTable[3].health - barricadeTable[3].damageReceived >= barricadeTable[3].health * .50 then
									barricade3Health:setFillColor(250,250,0)
								elseif barricadeTable[3].health - barricadeTable[3].damageReceived >= barricadeTable[3].health * .25 then
									barricade3Health:setFillColor(250,0,0)
								elseif barricadeTable[3].health - barricadeTable[3].damageReceived <= 0 then
									--just remove instead
									display.remove(barricade3Health)
									barricade3Health = nil
								end

								if barricadeTable[3].damageReceived >= barricadeTable[3].health then
									--reset to move continue moving right
									for i, v in pairs(spawnTable) do
										if spawnTable[i].objType == "Enemy" and spawnTable[i].currentState == "attacking" then
											if spawnTable[i].x >= barricadeTable[3].x -20 then
												spawnTable[i].currentState = "movingRight"
												spawnTable[i].isStopped = false
												spawnTable[i]:setSequence("walkingRight")
												spawnTable[i]:play()
											end
										end
									end
									display.remove(barricadeTable[3])
									barricadeTable[3] = nil
									resetIsStopped()
								end
							end
						end
						
						if barricadeTable[2] ~= nil then
							if spawnTable[i].x >= barricadeTable[2].x -20 then --attacking 2nd barrier
								barricadeTable[2].damageReceived = barricadeTable[2].damageReceived + spawnTable[i].barrierDamage
								barricadeTable[2].healthPercent =  1 / (barricadeTable[2].health /(barricadeTable[2].health - barricadeTable[2].damageReceived))
								barricade2Health:setReferencePoint(display.BottomLeftReferencePoint)
								barricade2Health.width = 25*barricadeTable[2].healthPercent
								barricade2Health.x = 315
								barricade2Health.y = 205
								if barricadeTable[2].health - barricadeTable[2].damageReceived >= barricadeTable[2].health * .75 then
									barricade2Health:setFillColor(0,250,0)
								elseif barricadeTable[2].health - barricadeTable[2].damageReceived >= barricadeTable[2].health * .50 then
									barricade2Health:setFillColor(250,250,0)
								elseif barricadeTable[2].health - barricadeTable[2].damageReceived >= barricadeTable[2].health * .25 then
									barricade2Health:setFillColor(250,0,0)
								elseif barricadeTable[2].health - barricadeTable[2].damageReceived <= 0 then
									--just remove instead
									display.remove(barricade2Health)
									barricade2Health = nil
								end
								
								if barricadeTable[2].damageReceived >= barricadeTable[2].health then
									--reset to move continue moving right
									for i, v in pairs(spawnTable) do
										if spawnTable[i].objType == "Enemy" and spawnTable[i].currentState == "attacking" then
											if spawnTable[i].x >= barricadeTable[2].x -20 then
												spawnTable[i].currentState = "movingRight"
												spawnTable[i].isStopped = false
												spawnTable[i]:setSequence("walkingRight")
												spawnTable[i]:play()
											end
										end
									end
									display.remove(barricadeTable[2])
									barricadeTable[2] = nil
									resetIsStopped()
								end
							end
						end
						
						if barricadeTable[1] ~= nil then
							if spawnTable[i].x >= barricadeTable[1].x -20 then --attacking 1st barrier
								barricadeTable[1].damageReceived = barricadeTable[1].damageReceived + spawnTable[i].barrierDamage
								barricadeTable[1].healthPercent =  1 / (barricadeTable[1].health /(barricadeTable[1].health - barricadeTable[1].damageReceived))
								barricadeHealth:setReferencePoint(display.BottomLeftReferencePoint)
								barricadeHealth.width = 25*barricadeTable[1].healthPercent
								barricadeHealth.x = 235
								barricadeHealth.y = 205
								if (barricadeTable[1].health - barricadeTable[1].damageReceived) >= (barricadeTable[1].health * .75) then
									barricadeHealth:setFillColor(0,250,0)
								elseif barricadeTable[1].health - barricadeTable[1].damageReceived >= barricadeTable[1].health * .50 then
									barricadeHealth:setFillColor(250,250,0)
								elseif barricadeTable[1].health - barricadeTable[1].damageReceived >= barricadeTable[1].health * .25 then
									barricadeHealth:setFillColor(250,0,0)
								elseif barricadeTable[1].health - barricadeTable[1].damageReceived <= 0 then
									--just remove instead
									display.remove(barricadeHealth)
									barricadeHealth = nil
								end
								
								if barricadeTable[1].damageReceived >= barricadeTable[1].health then
									--reset to move continue moving right
									for i, v in pairs(spawnTable) do
										if spawnTable[i].objType == "Enemy" and spawnTable[i].currentState == "attacking" then
											if spawnTable[i].x >= barricadeTable[1].x -20 then
												spawnTable[i].currentState = "movingRight"
												spawnTable[i].isStopped = false
												spawnTable[i]:setSequence("walkingRight")
												spawnTable[i]:play()
											end
										end
									end
									--then remove barrier
									display.remove(barricadeTable[1])
									barricadeTable[1] = nil
									resetIsStopped()
								end
							end
						end
						
					elseif spawnTable[i].currentState == "movingRight" then --Put movingRight conditional checks here
						
						for a, b in pairs(spawnTable) do
							if spawnTable[a].objType == "Enemy" then
								if spawnTable[a].y == spawnTable[i].y then
									if spawnTable[i].x + gameVarTable["walkerXBounds"] >= spawnTable[a].x and
									spawnTable[i].x <= spawnTable[a].x and 
									spawnTable[a].currentState == "attacking" then --and???
										if not spawnTable[i].isStopped and not spawnTable[i].isStoppedFlag then
											spawnTable[i]:setSequence("idle")
											spawnTable[i]:play()
											spawnTable[i].isStoppedFlag = true
										end
										spawnTable[i].isStopped = true
									elseif spawnTable[i].x + gameVarTable["walkerXBounds"] >= spawnTable[a].x and
									spawnTable[i].x <= spawnTable[a].x and
									spawnTable[a].isStopped then
										spawnTable[i].isStopped = true
										if not spawnTable[i].isStopped and not spawnTable[i].isStoppedFlag then
											spawnTable[i]:setSequence("idle")
											spawnTable[i]:play()
											spawnTable[i].isStoppedFlag = true
										end
									elseif spawnTable[i].x + gameVarTable["walkerXBounds"] >= spawnTable[a].x and
									spawnTable[i].x <= spawnTable[a].x and 
									spawnTable[a].currentState == "movingRight" then --and???
										--spawnTable[i].moveSpeed = spawnTable[a].moveSpeed
									end
								end
							end
						end	
						
						if not spawnTable[i].isStopped then
							spawnTable[i].x = spawnTable[i].x + spawnTable[i].moveSpeed
						else
							spawnTable[i].x = spawnTable[i].x
						end
						
						if barricadeTable[3] ~= nil then
							if spawnTable[i].x >= barricadeTable[3].x -20 then --attacking 3rd barrier
								spawnTable[i].x = barricadeTable[3].x -20
								spawnTable[i].currentState = "attacking"
								spawnTable[i]:setSequence("attacking")
								spawnTable[i]:play()
							end
						end

						if barricadeTable[2] ~= nil then
							if spawnTable[i].x >= barricadeTable[2].x and 
							spawnTable[i].x <= barricadeTable[3].x - 20 then --between 2 and 3 barrier
								spawnTable[i].x = spawnTable[i].x + spawnTable[i].moveSpeed
							elseif spawnTable[i].x >= barricadeTable[2].x -20 then --attacking 2nd barrier
								spawnTable[i].x = barricadeTable[2].x -20
								spawnTable[i].currentState = "attacking"
								spawnTable[i]:setSequence("attacking")
								spawnTable[i]:play()
							end
						end	
						
						if barricadeTable[1] ~= nil then
							if spawnTable[i].x >= barricadeTable[1].x and
							spawnTable[i].x <= barricadeTable[2].x - 20 then --between 1 and 2 barrier
								spawnTable[i].x = spawnTable[i].x + spawnTable[i].moveSpeed
							elseif spawnTable[i].x >= barricadeTable[1].x -20 then --attacking 1st barrier
								spawnTable[i].x = barricadeTable[1].x -20
								spawnTable[i].currentState = "attacking"
								spawnTable[i]:setSequence("attacking")
								spawnTable[i]:play()
							end
						end	
						spawnTable[i]:play()				
					end
				
					
					--Check if object should be removed after passing a certain point on the screen
					if spawnTable[i].x >= 500 then
						if (spawnTable[i] ~= nil) then
							display.remove(spawnTable[i])
							spawnTable[i] = nil
						end
						exiting = true;
						clean()
						showGameText({text = "Level Failed", x = 180, y = 150, fontSize = 25, rValue = 255, gValue = 0, bValue = 0})
						goToFailedLevelTimer = timer.performWithDelay(2000,goToFailedLevel,0)
						
					end
					
					if not exiting then
						if spawnTable[i].flaggedForRemoval == true then
							display.remove(spawnTable[i])
							spawnTable[i] = nil
						end
					end
				end
			end
		end
		--resets any enemies stuck in the "stopped" motion
		resetIsStopped()
	end
end

local function update (event)
	local i,v, d,e, g,h, t,u, b,c
	local checkRoll
	local file	
	updateLayers()
	if not exiting then
		if gameVarTable["enemiesAlive"] == 0 then
			spawnWave()
		end
		
		timeConveyorBeltSpawns()
		moveCatwalk()
		--[[ redo after background image has been saved in usable format
		if gameVarTable["scrollBackground"] then
			scrollBackground()
		end	
		]]--
		--For the monitor to update in real time
		if (gameVarTable["coinsCollected"] >= gameVarTable["costForPuppy"]) then
			puppyCuteImage.isVisible = true
			--monitorText.isVisible = false
			gameVarTable["puppyIsDisabled"] = false
			monitorText.text = gameVarTable["coinsCollected"]
		else
			monitorText.isVisible = true
			if gameVarTable["coinsCollected"] == 0 then
				monitorText.text = "0";
			else 
				monitorText.text = gameVarTable["coinsCollected"]
			end
			gameVarTable["puppyIsDisabled"] = true
			puppyCuteImage.isVisible = false
		end
		timeCounter = timeCounter + 1
		
		if timeCounter == 100 then
			
		elseif timeCounter >= levelConfig["level"..gameVarTable["currentLevel"]]["waveTimer"] then
			if gameVarTable["currentWave"] <= gameVarTable["maxWaveNumber"] then
				timeCounter = 0
				spawnWave()
			end
		end
	elseif exiting then
		if gameVarTable["gotoMainMenuBool"] == true then
			clean()
			director:changeScene( "LuaFiles.mainmenu" )
		elseif gameVarTable["restartLevelBool"] == true then
			clean()
			director:changeScene( "LuaFiles.loadlevel")
		end
            resetIsStopped()
	end
	
	if not exiting then
		checkWinningConditions()
		updateHandBar()
		updateParticles()
		checkCollisions()
	end			
	
	if not exiting then
		updateHandCrane()
	end	
end

timerStash.makeFrameUpdateTimer = timer.performWithDelay(1,update,0)
row1Group:toFront();
row2Group:toFront();
row3Group:toFront();
row4Group:toFront();
row5Group:toFront();
menuGroup:toFront();
spawnTable[1]:toFront()
return level1Group

end


