-- Version: 1.1
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.

module(..., package.seeall)

local localGroup

-- Main function - MUST return a display.newGroup()
function new()
	
	localGroup = display.newGroup()
	local theTimer
	local loadingImage
	
	local showLoadingScreen = function()
		loadingImage = display.newImageRect( "Images/Loading/loading.png", 600, 320 )
		loadingImage.x = 240; loadingImage.y = 160
		
		local goToLevel = function()
			director:changeScene( "LuaFiles.level" )
		end
		
		theTimer = timer.performWithDelay( 1000, goToLevel, 1 )
	end
	
	showLoadingScreen()
	
	clean = function()
		if theTimer then timer.cancel( theTimer ); 
		end
		
		if loadingImage then
			display.remove( loadingImage )
			loadingImage = nil
		end
	end
	
	-- MUST return a display.newGroup()
	return localGroup
end
