-- Version: 1.1
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.

module(..., package.seeall)
local menuGroup

-- Main function - MUST return a display.newGroup()
function new()	
	
	menuGroup  = display.newGroup()
	local ui = ui
	local playTween
	local isLevelSelection = false
	-- AUDIO
	audioStash.tapSound = audio.loadSound( "Sounds/click.wav" )
	audioStash.tapSound2 = audio.loadSound( "Sounds/click2.wav" )
	
	--Table for levels
	local level = {}
	
	local drawScreen = function()
	
	-- BACKGROUND IMAGE
	local backgroundImage = display.newImageRect( "Images/MainMenu/mainmenu.png", 600, 320 )
	backgroundImage.x = 240; backgroundImage.y = 160
	
	menuGroup:insert( backgroundImage )
	
	-------------------------
	--CHECK AVAILABLE LEVELS-
	-------------------------
	--Function for open levels
	local function goLevel (event)
        director:changeScene(event.target.scene)
	end
	
	--Check to see if a file for the current level already exists, if it
	--doesn't then create it and set the current level to 1.
	gameInfo.reloadFile()
	local currentLevel = gameInfo.getMaxLevelUnlocked()
	--Starting X position for levels
	local startX = 150
	
	local screenBloodSplatData = {
	width = 246,
	height = 325,
	numFrames = 51,
	sheetContentWidth = 12546,
	sheetContentHeight = 325
	}

	local screenBloodSplatSheet = graphics.newImageSheet( "Images/BloodAndExplosions/screenBloodSplat.png", screenBloodSplatData)

	function getScreenBloodSplatDataSheet()
		return screenBloodSplatSheet
	end
	
	local screenBloodSplatData2 = {
	width = 248,
	height = 325,
	numFrames = 11,
	sheetContentWidth = 2728,
	sheetContentHeight = 325
	}

	local screenBloodSplatSheet2 = graphics.newImageSheet( "Images/BloodAndExplosions/screenBloodSplat.png", screenBloodSplatData)

	function getScreenBloodSplatDataSheet2()
		return screenBloodSplatSheet2
	end
	
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
		end
	elseif params.objType == "Barrel" then
		object.isFalling = false
		object.isExploded = false
		object.isGassed = false
	end
	
	if params.objType == "Explosion" then
		object.isPlaying = false
	end
	
	return object
end


	
	local function spawnScreenBloodSplat()
		local spawnr = spawn(
					{
						objTable = level,
						objType = "Blood",
						Name = "Blood",
						group = menuGroup,
						spriteSheet = getScreenBloodSplatDataSheet2(),
						xPosition = 200,
						yPosition = 200,
						xScale = 1,
						yScale = 1,
						timeScale = .3,
						currentState = "empty",
						moveSpeed = 5,
						isPlaying = false,
						sequenceData = {
							{ name="splat", frames={ 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51}, time=250, loopCount = 1}
						}
					}
				)
				
		level[1] = spawnr
		level[1]:setSequence("splat")
		level[1]:play()
	end
	
	local onLevelTouch = function( event )
		if event.phase == "release" and event.id ~= "locked" then
			audio.play( audioStash.tapSound )
			gameInfo.saveCurrentLevel({level=event.id})
			director:changeScene("LuaFiles.loadlevel");
			
			--spawnScreenBloodSplat()
			--timerStash.doobieTimer = timer.performWithDelay( 20000, function() director:changeScene("LuaFiles.loadlevel"); end, 1 )
			
			
		end
	end
 
	--Load level icons accordingly
	local function setupLevels()
	
		if currentLevel == nil then
			currentLevel = 1
		end
		
		for i = 1, 5 do
			if tonumber(currentLevel) >= i then
			
					level[i] = ui.newButton{
					defaultSrc = "Images/LevelSelect/level"..i.."btn.png",
					defaultX = startX,
					defaultY = 190,
					overSrc = "Images/LevelSelect/level"..i.."btn-over.png",
					overX = startX,
					overY = 190,
					onEvent = onLevelTouch,
					id = i,
					text = "",
					font = "Helvetica",
					textColor = { 255, 255, 255, 255 },
					size = 5,
					emboss = false
					}
					--positioning of the level select buttons
					level[i].x = startX + (i * 60) - 75
					level[i].y = 150
					level[i].xScale = .35
					level[i].yScale = .35
					
					menuGroup:insert( level[i] )							
			elseif tonumber(currentLevel) < i then
				level[i] = ui.newButton{
				defaultSrc = "Images/LevelSelect/lockedlevel.png",
				defaultX = startX,
				defaultY = 190,
				overSrc = "Images/LevelSelect/lockedlevel-over.png",
				overX = startX,
				overY = 190,
				onEvent = onLevelTouch,
				id = "locked",
				text = "",
				font = "Helvetica",
				textColor = { 255, 255, 255, 255 },
				size = 5,
				emboss = false
				}
				--positioning of the level select buttons
				level[i].x = startX + (i * 60) - 75
				level[i].y = 150
				level[i].xScale = .35
				level[i].yScale = .35
				
				menuGroup:insert( level[i] )
			end
		end
	end
		
	-- PLAY BUTTON
	local playBtn
		
	local onPlayTouch = function( event )
		if event.phase == "release" and not isLevelSelection and playBtn.isActive then
			
			audio.play( audioStash.tapSound )
			
			-- Bring Up Level Selection Screen
			
			isLevelSelection = true
			
			local shadeRect = display.newRect( 0, 0, 480, 320 )
			shadeRect:setFillColor( 0, 0, 0, 255 )
			shadeRect.alpha = 0
			menuGroup:insert( shadeRect )
			transitionStash.shadeRectTransition = transition.to( shadeRect, { time=100, alpha=0.85 } )
			
			local levelSelectionBg = display.newImageRect( "Images/LevelSelect/levelselection.png", 392, 392 )
			levelSelectionBg.x = 240; levelSelectionBg.y = 160
			levelSelectionBg.isVisible = false
			menuGroup:insert( levelSelectionBg )
			timerStash.levelSelectionBgTimer = timer.performWithDelay( 200, function() levelSelectionBg.isVisible = true; end, 1 )

			setupLevels()
				
			local closeBtn
			
			local onCloseTouch = function( event )
				if event.phase == "release" then
					
					audio.play( audioStash.tapSound2 )
					
					-- unload level selection screen
					display.remove( levelSelectionBg ); levelSelectionBg = nil
					display.remove( shadeRect ); shadeRect = nil
					display.remove( closeBtn ); closeBtn = nil
					
					for i, v in pairs(level) do
						display.remove(level[i]); level[i] = nil
					end
					isLevelSelection = false
					playBtn.isActive = true
				end
			end
			
			closeBtn = ui.newButton{
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
			
			closeBtn.x = 85; closeBtn.y = 245
			closeBtn.isVisible = false
			
			menuGroup:insert( closeBtn )
			timerStash.closeBtnTimer = timer.performWithDelay( 201, function() closeBtn.isVisible = true; end, 1 )
			
		end
	end
		
		playBtn = ui.newButton{
			defaultSrc = "Images/MainMenu/playbtn.png",
			defaultX = 71,
			defaultY = 46,
			overSrc = "Images/MainMenu/playbtn-over.png",
			overX = 97,
			overY = 77,
			onEvent = onPlayTouch,
			id = "PlayButton",
			text = "",
			font = "Helvetica",
			textColor = { 255, 255, 255, 255 },
			size = 16,
			emboss = false
		}
		
		playBtn:setReferencePoint( display.BottomCenterReferencePoint )
		playBtn.x = 378 playBtn.y = 440
		
		menuGroup:insert( playBtn )
		
		
		-- SLIDE PLAY AND OPENFEINT BUTTON FROM THE BOTTOM:
		local setPlayBtn = function()
			transitionStash.playTweenTransition = transition.to( playBtn, { time=100, x=378, y=325 } )
		end
		
		transitionStash.playTweenTransition = transition.to( playBtn, { time=500, y=320, onComplete=setPlayBtn, transition=easing.inOutExpo } )
		
	end
	
	drawScreen()
	
	clean = function()
		
		--Runtime:removeEventListener( "enterFrame", monitorMem )
		--if playTween then transition.cancel( playTween ); end
		--cancel all transitions 
		cancelAllTransitions()
		
		--cancel all timers contained in table in main.lua (timerStash)
		cancelAllTimers()
		
		audio.stop()
		cancelAllAudio()
		collectgarbage( "collect" )
	end
	
	-- MUST return a display.newGroup()
	return menuGroup
end
