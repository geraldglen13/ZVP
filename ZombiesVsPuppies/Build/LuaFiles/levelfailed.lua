-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.

module(..., package.seeall)

-- Main function - MUST return a display.newGroup()
function new()
	local localGroup = display.newGroup()
	
	local backgroundImage = display.newImageRect( "Images/YouLose/gameoverback.png", 600, 320 )
	backgroundImage.x = 240; backgroundImage.y = 160
	
	local yesbutton = display.newImage ("Images/YouLose/yesbutton.png")
	yesbutton.x = 200
	yesbutton.y = 180
	yesbutton.xScale = .5
	yesbutton.yScale = .5
	
	local nobutton = display.newImage ("Images/YouLose/nobutton.png")
	nobutton.x = 300
	nobutton.y = 180
	nobutton.xScale = .5
	nobutton.yScale = .5
	
	
	---	
	localGroup:insert( backgroundImage )
	localGroup:insert( yesbutton )
	localGroup:insert( nobutton )
	---
	--touch events
	---
	function touchyesbutton (event)
		director:changeScene( "LuaFiles.loadlevel" )
	end
	yesbutton:addEventListener("touch", touchyesbutton)

	--
	function touchnobutton (event)
		director:changeScene( "LuaFiles.mainmenu" )
	end
	nobutton:addEventListener("touch", touchnobutton)
	
	-- MUST return a display.newGroup()
	return localGroup
end