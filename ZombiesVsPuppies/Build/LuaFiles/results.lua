-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.

module(..., package.seeall)

-- Main function - MUST return a display.newGroup()
function new()

	local localGroup = display.newGroup()
	local menuGroup = display.newGroup()
	local resultsGroup = display.newGroup()
	local upgradeGroup = display.newGroup()
	
	local widget = require "widget"
	
	local resultsContainerTable = {}
	local resultsIconTable = {}
	local resultsTextTable = {}
	local resultsAmountTable = {}
	
	local nextLevel 
	
	local backgroundImage = display.newImageRect( "Images/Results/ResultsBG.png", 600, 320 )
	backgroundImage.x = 240; backgroundImage.y = 160
	
	local resultsTextImage = display.newImageRect( "Images/Results/ResultsText.png", 131,30)
	resultsTextImage.x = 50; resultsTextImage.y = 20;
	
	
	
	
	--RESULTS PAGE----------------------------------------
	----------------------------------------------------------
	
-------------------------
----ADVERTISEMENTS-------
-------------------------
	local ads = require "ads"
	local closeBtn 
	local close = false
	
	local onCloseTouch = function( event )
		if event.phase == "began" then
			closeBtn.xScale = .8
			closeBtn.yScale = .8
		elseif event.phase == "ended" then
			ads.hide()
			menuGroup:toFront() 
			if closeBtn ~= nil then
				display.remove(closeBtn)
				closeBtn = nil
			end
			close = true
			closeBtn:removeEventListener("touch", onCloseTouch)
			backgroundImage:removeEventListener("touch", onCloseTouch)
		end
	end
	
	local function showCloseButton(event)
		if not event.isError then
			closeBtn = display.newImageRect("Images/ButtonIconsEtc/closeAd.png", 50, 50 );
			
			closeBtn.x = 80; closeBtn.y = 30
			closeBtn.xScale = 1; closeBtn.yScale = 1
			menuGroup:insert(closeBtn)
			menuGroup:toFront() 
			closeBtn:addEventListener("touch", onCloseTouch)
			backgroundImage:addEventListener("touch", onCloseTouch)
		end
	end
	
	--showCloseButton()
	
	ads.init( "inneractive", "GeraldMendoza_Zom_Android", showCloseButton ) 
	--ads.show( "banner", { x=0, y=0, interval=60 } )
	ads.show( "banner", { x=0, y=0, interval=60 } )
	
	--ads.show( "text", { x=0, y=100, interval=60 } )
	-- hide all ads
	
	local function closeAds(event)
		if close == true then
			ads.hide()
			close = false
		end
	end
	
	timerStash.closeAdsTimer = timer.performWithDelay(1,closeAds,0)
	-------------------------------------
	local amountGrinded = 0
	local amountPunched = 0
	local barrelKills = 0
	--put these in too dammit!
	local puppiesSaved = 0
	local puppiesKilled = 0
	
	local amountGrindedText = display.newText("Zombies Grinded:", 50, 50, "Let's Eat", 20)
	amountGrindedText:setTextColor(255,0,0)
	--resultsTextTable[1] = amountGrindedText
	
	local amountGrindedAmountText = display.newText("0", 430, 50, "Let's Eat", 20)
	amountGrindedAmountText:setTextColor(255,0,0)
	--resultsAmountTable[1] = amountGrindedAmountText
	
	local puppiesSavedText = display.newText("Puppies Saved:", 50, 95, "Let's Eat", 20)
	puppiesSavedText:setTextColor(255,255,0)
	--resultsTextTable[2] = puppiesSavedText
	
	local puppiesSavedAmountText = display.newText("0", 430, 95, "Let's Eat", 20)
	puppiesSavedAmountText:setTextColor(255,255,0)
	--resultsAmountTable[2] = puppiesSavedAmountText
	
	local barrelKillsText = display.newText("Barrel Kills:", 50, 140, "Let's Eat", 20)
	barrelKillsText:setTextColor(0,255,255)
	--resultsTextTable[3] = barrelKillsText
	
	local barrelKillsAmountText = display.newText("0", 430, 140, "Let's Eat", 20)
	barrelKillsAmountText:setTextColor(0,255,255)
	--resultsAmountTable[3] = barrelKillsAmountText
	
	local amountPunchedText = display.newText("Zombies Smashed:", 50, 185, "Let's Eat", 20)
	amountPunchedText:setTextColor(0,0,255)
	--resultsTextTable[4] = amountPunchedText
	
	local amountPunchedAmountText = display.newText("0", 430, 185, "Let's Eat", 20)
	amountPunchedAmountText:setTextColor(0,0,255)
	--resultsAmountTable[4] = amountPunchedAmountText
	
	local puppiesKilledText = display.newText("Puppies Killed:", 50, 230, "Let's Eat", 20)
	puppiesKilledText:setTextColor(0,255,0)
	--resultsTextTable[5] = puppiesKilledText
	
	local puppiesKilledAmountText = display.newText("0", 430, 230, "Let's Eat", 20)
	puppiesKilledAmountText:setTextColor(0,255,0)
	--resultsAmountTable[5] = puppiesKilledAmountText
	--1st row
	
	--1st item
	--make a method for this madness
	--container
	local function buildResultsMenu()
		local i = 1
		
		for i = 1, 5 do
			resultsContainerTable[i] = display.newImageRect("Images/Results/LineItemBackground.png", 492, 53 );
			resultsContainerTable[i].x = 235; resultsContainerTable[i].y = 60 + (45 * (i-1));
			resultsContainerTable[i].xScale = 1; resultsContainerTable[i].yScale = .8;
		end
		
		resultsIconTable[1] = display.newImageRect("Images/Results/ZombieIcon.png",120,120);		
		resultsIconTable[2] = display.newImageRect("Images/Results/PuppyFlyingIcon.png",120,120);		
		resultsIconTable[3] = display.newImageRect("Images/Results/BarrelIcon.png",120,120);		
		resultsIconTable[4] = display.newImageRect("Images/Results/ZombieSmashIcon.png",120,120);		
		resultsIconTable[5] = display.newImageRect("Images/Results/PuppyFlyingIcon.png",120,120);
		
		for i = 1, 5 do
			resultsIconTable[i].x = 20; resultsIconTable[i].y = 60 + (45 * (i-1));
			resultsIconTable[i].xScale = .28; resultsIconTable[i].yScale = .28;
			
		end
	end
	
	buildResultsMenu()
	
	
	
	
	--UPGRADE PAGE BEGIN--------------------------------------
	
	-----------------------------------------
	
	---------------------------------
	local function clean()
		cancelAllTimers()
	end
	
	local upgrade
	local bloodPointsLogo
	local bloodPointsText = display.newText("0 BP" , 375, 55, "LithoComix", 20)
		bloodPointsText.isVisible = false
		
	local function buildUpgradeMenu()
		--This is the display rect for the Upgrade section
		upgrade = display.newImageRect( "Images/Upgrades/UpgradesBackground.png", 460, 250 )
		upgrade.x = 240; upgrade.y = 175
	
		--This is the amount of blood points/coins (player's score), displayed on the top-left of the screen	
		bloodPointsLogo = display.newImageRect( "Images/Upgrades/BloodPointsIcon.png", 225, 55 )
		bloodPointsLogo.x = 325; bloodPointsLogo.y = 65
		bloodPointsLogo.xScale = .18; bloodPointsLogo.yScale = .45
	
		
		
		upgradeGroup:insert(upgrade)
		upgradeGroup:insert(bloodPointsLogo)
		upgradeGroup:insert(bloodPointsText)
		bloodPointsText.isVisible = true
	end
	
	local function ShowUpgradeTab()
		localGroup.isVisible = false
		resultsGroup.isVisible = false
		buildUpgradeMenu()
	end
	
	local function goToUpgradePage(event)
		if event.target.id == "Continue" then
			--ShowUpgradeTab()
			clean()
			director:changeScene( "LuaFiles.loadlevel" )
		end
	end
	
	local function postFB(event)
		if event.phase == "release" then
			--Figure out FB event handling to post messages to FB
			local fbMessage = "I survived level 1 on Zombies Vs Puppies Lite!"
                    
			native.showWebPopup(0, 0, 320, 400, "http://www.facebook.com/dialog/feed?&display=touch&redirect_uri=http://www.geraldmendoza.com&link=http://www.geraldmendoza.com&name=TEST&caption=testCaption2&message=testMessage2", {urlRequest=popupListener})

			--native.showWebPopup(0, 0, 320, 480, "http://twitter.com/intent/tweet?text=I%20Just%20Farted!%20Eww!")
		end
		
		--return false
	end
	
	local function sendTweet(event)
		if event.phase == "release" then
			native.showWebPopup(0, 0, 320, 480, "http://twitter.com/intent/tweet?text=I%20Just%20Killed%20" ..amountGrindedAmountText.text .."%20 zombies in Puppies VS Zombies!")
		end
		
		--return true
	end
	--Continue/next button to go on Results page, forwards to next level/screen
	local Continue = widget.newButton{
        id = "Continue",
        left = 170,
        top = 285,
        label = "Continue",
        width = 150, height = 28,
        cornerRadius = 8, 
		onEvent = goToUpgradePage
    }
	
	local FBIcon =  ui.newButton{
		defaultSrc = "Images/ButtonIconsEtc/FBIcon.png",
		defaultX = 170,
		defaultY = 230,
		overSrc = "Images/ButtonIconsEtc/FBIcon.png",
		overX = 170,
		overY = 230,
		onEvent = postFB,
		id = "FBIcon",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		size = 5,
		emboss = false
	}
	FBIcon.x = 370; FBIcon.xScale = .25
	FBIcon.y = 290; FBIcon.yScale = .2
	
	local Tweet =  ui.newButton{
		defaultSrc = "Images/ButtonIconsEtc/TwitterIcon.png",
		defaultX = 170,
		defaultY = 230,
		overSrc = "Images/ButtonIconsEtc/TwitterIcon.png",
		overX = 170,
		overY = 230,
		onEvent = sendTweet,
		id = "Tweet",
		text = "",
		font = "Helvetica",
		textColor = { 255, 255, 255, 255 },
		size = 5,
		emboss = false
	}
	Tweet.x = 430; Tweet.xScale = .25
	Tweet.y = 290; Tweet.yScale = .25
	
--------------------------------------
--GROUPING----------------------------
	localGroup:insert(backgroundImage)
	
	resultsGroup:insert(Continue)	
	resultsGroup:insert(FBIcon)
	resultsGroup:insert(Tweet)
	
	for i=1, 5 do
		localGroup:insert(resultsContainerTable[i])	
		localGroup:insert(resultsIconTable[i])
	end
	
	resultsGroup:insert(amountGrindedText)
	resultsGroup:insert(amountGrindedAmountText)
	resultsGroup:insert(amountPunchedText)
	resultsGroup:insert(amountPunchedAmountText)
	resultsGroup:insert(barrelKillsText)
	resultsGroup:insert(barrelKillsAmountText)
	resultsGroup:insert(puppiesKilledText)
	resultsGroup:insert(puppiesKilledAmountText)
	resultsGroup:insert(puppiesSavedText)
	resultsGroup:insert(puppiesSavedAmountText)
	-------------------------------------------------------
	
	local function getResults()
		local file = loadFile ("game.txt")
		local count = 1
		local t = {}
		if file == "empty" then
			--set default params
			amountGrinded = 15
			amountPunched = 15
			barrelKills = 15
		else
			--parse results from file

			t = gameInfo.mysplit(file, ",")
			--max level unlocked, currentLevel,amountGrinded, amountPunched, barrelKills, BloodPoints
			for i,v in pairs(t) do
				if count == 2 then
					nextLevel = tonumber(v) + 1
				elseif count == 3 then
					amountGrinded = v
				elseif count == 4 then
					amountPunched = v
				elseif count == 5 then
					barrelKills = v
				elseif count == 6 then
					bloodPointsText.text = v .." BP"
				end
				count = count + 1
			end
		end
	end
	
	local currentAmountGrinded = 0
	local currentAmountPunched = 0
	local currentBarrelKills = 0
	
	getResults()
	
	--spiffy UI to update reslts
	local function updateResults()	
		if currentAmountGrinded < tonumber(amountGrinded) then
			currentAmountGrinded = currentAmountGrinded + 1
			amountGrindedAmountText.text = currentAmountGrinded
		end
		if currentAmountPunched < tonumber(amountPunched) and
		currentAmountGrinded == tonumber(amountGrinded) then
			currentAmountPunched = currentAmountPunched + 1
			amountPunchedAmountText.text = currentAmountPunched
		end
		if currentBarrelKills < tonumber(barrelKills) and
		currentAmountPunched == tonumber(amountPunched) then
			currentBarrelKills = currentBarrelKills + 1
			barrelKillsAmountText.text = currentBarrelKills
		end
	end
	
	audioStash.updateResultsTimer = timer.performWithDelay(100,updateResults,0)
	
	--defaulting visibility for first run through
	--then everything else is done based on tab switching
	ContinueButton = true
	---------------------------
	resultsGroup:toFront()
	-- MUST return a display.newGroup()
	return localGroup
end