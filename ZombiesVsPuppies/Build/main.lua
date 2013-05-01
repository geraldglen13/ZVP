-- Version: 1.1
-- 
-- Sample code is MIT licensed, see http://developer.anscamobile.com/code/license
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.

-- SOME INITIAL SETTINGS
display.setStatusBar( display.HiddenStatusBar ) --Hide status bar from the beginning

local oldTimerCancel = timer.cancel
timer.cancel = function(t) if t then oldTimerCancel(t) end end

local oldRemove = display.remove
display.remove = function( o )
	if o ~= nil then
		
		Runtime:removeEventListener( "enterFrame", o )
		oldRemove( o )
		o = nil
	end
end


-- Import director class
local director = require("director")
local ui = require( "ui" )
local movieclip = require( "movieclip" )

-- Create a main group
local mainGroup = display.newGroup()

-------------------------
local border = 5

---------------------------
--EGO / Save & Load Files--
---------------------------
ego = require ("ego")
saveFile = ego.saveFile
loadFile = ego.loadFile

gameInfo = require ("LuaFiles.helperfunctions")

-----------------------------------
--Timer/Transition/Audio clean up--
-----------------------------------
audioStash = {}
timerStash = {}
transitionStash = {}

function cancelAllTimers()
    local k, v

    for k,v in pairs(timerStash) do
		if timerStash[k] ~= nil then
			timer.cancel( v )
			v = nil; k = nil
		end
    end

    timerStash = nil
    timerStash = {}
end

function cancelAllTransitions()
    local k, v

    for k,v in pairs(transitionStash) do
        transition.cancel( v )
        v = nil; k = nil
    end

    transitionStash = nil
    transitionStash = {}
end

function cancelAllAudio()
    local k, v

    for k,v in pairs(audioStash) do
        audio.dispose( v )
        v = nil; k = nil
    end

    audioStash = nil
    audioStash = {}
end

-----------------------
--Main function--------
-----------------------
local function main()	
	pointsInLevelTotal = 0
	-- Add the group from director class
	mainGroup:insert(director.directorView)	
	director:changeScene( "LuaFiles.loadmainmenu" )	
	return true
end

--[[
local monitorMem = function()

    collectgarbage()
    print( "MemUsage: " .. collectgarbage("count") )

    local textMem = system.getInfo( "textureMemoryUsed" ) / 1000000
    print( "TexMem:   " .. textMem )
end

Runtime:addEventListener( "enterFrame", monitorMem )
]]--

-- Begin
main()


