module(..., package.seeall)

--Sprite Sheets add extras when they come in--
	
--crane hand (stationary, only have 1 png image atm)
local handGrabSheetOptions = {
	frames = 
	{
		--FRAME 1:
		{
			x = 0,
			y = 0,
			width = 75,
			height = 105
		},
		--FRAME 2:
		{
			x = 75,
			y = 0,
			width = 74,
			height = 105
		},
		--FRAME 3:
		{
			x = 149,
			y = 0,
			width = 71,
			height = 105
		},
		--FRAME 4:
		{
			x = 220,
			y = 0,
			width = 67,
			height = 105
		},
		--FRAME 5:
		{
			x = 287,
			y = 0,
			width = 63,
			height = 105
		},
		--FRAME 6:
		{
			x = 350,
			y = 0,
			width = 57,
			height = 105
		},
		--FRAME 7:
		{
			x = 407,
			y = 0,
			width = 51,
			height = 105
		},
	},
	
	sheetContentWidth = 458,
	sheetContentHeight = 105
}

local handGrabSheetData = {
	width = 41,
	height = 56,
	numFrames = 7,
	sheetContentWidth = 256,
	sheetContentHeight = 64
}

local handGrabSheet = graphics.newImageSheet( "Images/AlliedObjects/handgrabsheet.png", handGrabSheetOptions)

function getHandGrabSheet()
	return handGrabSheet
end
---------------
local normalPuppySheetOptions = {
	frames = 
	{
		{	--FRAME 1
            x=0, y=0, width=123, height=183
        },
        {	--FRAME 2
            x=0, y=183, width=120, height=181
        },
        {	--FRAME 3
			x=120, y=183, width=116, height=180
        },
        {	--FRAME 4
            x=348, y=183, width=112, height=179
        },
        {	--FRAME 5
            x=0, y=364, width=107, height=178
        },
        {	--FRAME 6
			x=0, y=542, width=111, height=176
        },
        {	--FRAME 7
			x=226, y=542, width=114, height=174
        },
        {	--FRAME 8
			x=0, y=718, width=117, height=171
        },
        {	--FRAME 9
			x=117, y=718, width=121, height=169
        },
        {	--FRAME 10
			x=238, y=718, width=123, height=168
        },
        {	--FRAME 11
			x=340, y=542, width=118, height=172
        },
        {	--FRAME 12
			x=111, y=542, width=115, height=175
        },
        {	--FRAME 13
			x=324, y=364, width=111, height=177
        },
        {	--FRAME 14
			x=215, y=364, width=109, height=178
        },
        {	--FRAME 15
			x=107, y=364, width=108, height=178
        },
        {	--FRAME 16
			x=236, y=183, width=112, height=179
        },
        {	--FRAME 17
			x=362, y=0, width=115, height=181
        },
        {	--FRAME 18
			x=244, y=0, width=118, height=182
        },
        {	--FRAME 19
			x=123, y=0, width=121, height=182
        },
	},
	
	sheetContentWidth = 512,
	sheetContentHeight = 1024
}

local normalPuppySheet = graphics.newImageSheet( "Images/AlliedObjects/normalPuppySheet.png", normalPuppySheetOptions)

function getNormalPuppySheet()
	return normalPuppySheet
end
---------------
local crackPuppyIdleSheetData = {
	width = 96,
	height = 68,
	numFrames = 30,
	sheetContentWidth = 576,
	sheetContentHeight = 340
}

local crackPuppyIdleSheet = graphics.newImageSheet( "Images/AlliedObjects/crackpuppyidle.png", crackPuppyIdleSheetData)

function getCrackPuppyIdleSheet()
	return crackPuppyIdleSheet
end

---------------
local crackPuppyAttackSheetData = {
	width = 110,
	height = 80,
	numFrames = 8,
	sheetContentWidth = 880,
	sheetContentHeight = 80
}

local crackPuppyAttackSheet = graphics.newImageSheet( "Images/AlliedObjects/crackpuppyattack.png", crackPuppyAttackSheetData)

function getCrackPuppyAttackSheet()
	return crackPuppyAttackSheet
end
--------------------
local bombPuppyFat1SheetData = {
	width = 251,
	height = 182,
	numFrames = 38,
	sheetContentWidth = 1757,
	sheetContentHeight = 1092
}

local bombPuppyFat1Sheet = graphics.newImageSheet( "Images/AlliedObjects/bombpuppyfat1.png", bombPuppyFat1SheetData)

function getBombPuppyFat1Sheet()
	return bombPuppyFat1Sheet
end
--------------------
local bombPuppyFat2SheetData = {
	width = 220,
	height = 160,
	numFrames = 54,
	sheetContentWidth = 1760,
	sheetContentHeight = 1120
}

local bombPuppyFat2Sheet = graphics.newImageSheet( "Images/AlliedObjects/bombpuppyfat2.png", bombPuppyFat2SheetData)

function getBombPuppyFat2Sheet()
	return bombPuppyFat2Sheet
end
--------------------
local bombPuppyFat3SheetData = {
	width = 220,
	height = 160,
	numFrames = 53,
	sheetContentWidth = 1760,
	sheetContentHeight = 1120
}

local bombPuppyFat3Sheet = graphics.newImageSheet( "Images/AlliedObjects/bombpuppyfat3.png", bombPuppyFat3SheetData)

function getBombPuppyFat3Sheet()
	return bombPuppyFat3Sheet
end
--------------------
local bombPuppyFat4SheetData = {
	width = 220,
	height = 160,
	numFrames = 52,
	sheetContentWidth = 1760,
	sheetContentHeight = 1120
}

local bombPuppyFat4Sheet = graphics.newImageSheet( "Images/AlliedObjects/bombpuppyfat4.png", bombPuppyFat4SheetData)

function getBombPuppyFat4Sheet()
	return bombPuppyFat4Sheet
end
--------------------
local bombPuppyFat5SheetData = {
	width = 220,
	height = 160,
	numFrames = 50,
	sheetContentWidth = 1760,
	sheetContentHeight = 1120
}

local bombPuppyFat5Sheet = graphics.newImageSheet( "Images/AlliedObjects/bombpuppyfat5.png", bombPuppyFat5SheetData)

function getBombPuppyFat5Sheet()
	return bombPuppyFat5Sheet
end
--------------------
local handFistSheetOptions = {
	frames = 
	{
		--FRAME 1:
		{
			x = 0,
			y = 0,
			width = 54,
			height = 115
		},
		--FRAME 2:
		{
			x = 54,
			y = 0,
			width = 53,
			height = 115
		},
		--FRAME 3:
		{
			x = 107,
			y = 0,
			width = 51,
			height = 115
		},
		--FRAME 4:
		{
			x = 159,
			y = 0,
			width = 51,
			height = 115
		},
		--FRAME 5:
		{
			x = 210,
			y = 0,
			width = 50,
			height = 115
		},
		--FRAME 6:
		{
			x = 260,
			y = 0,
			width = 51,
			height = 115
		},
		--FRAME 7:
		{
			x = 311,
			y = 0,
			width = 50,
			height = 115
		},
		--FRAME 8:
		{
			x = 361,
			y = 0,
			width = 49,
			height = 115
		},
		--FRAME 9:
		{
			x = 410,
			y = 0,
			width = 48,
			height = 115
		},
		--FRAME 10:
		{
			x = 458,
			y = 0,
			width = 48,
			height = 115
		},
	},
	
	sheetContentWidth = 506,
	sheetContentHeight = 115
}

local handFistSheet = graphics.newImageSheet( "Images/AlliedObjects/handfistsheet.png", handFistSheetOptions)

function getHandFistSheet()
	return handFistSheet
end
---------------
----------------------------------------------
--BLOOD---
local bloodSheetData = {
	width = 150,
	height = 34,
	numFrames = 1,
	sheetContentWidth = 150,
	sheetContentHeight = 34
}

local bloodSheet = graphics.newImageSheet( "Images/BloodAndExplosions/stain1.png", bloodSheetData)

function getBloodSheet()
	return bloodSheet
end
---
local bloodSheet2Data = {
	width = 150,
	height = 34,
	numFrames = 1,
	sheetContentWidth = 150,
	sheetContentHeight = 34
}

local bloodSheet2 = graphics.newImageSheet( "Images/BloodAndExplosions/stain2.png", bloodSheet2Data)

function getBloodSheet2()
	return bloodSheet2
end
---
local bloodSheet3Data = {
	width = 100,
	height = 34,
	numFrames = 1,
	sheetContentWidth = 100,
	sheetContentHeight = 34
}

local bloodSheet3 = graphics.newImageSheet( "Images/BloodAndExplosions/stain3.png", bloodSheet3Data)

function getBloodSheet3()
	return bloodSheet3
end
---
local bloodSheet4Data = {
	width = 150,
	height = 32,
	numFrames = 1,
	sheetContentWidth = 150,
	sheetContentHeight = 32
}

local bloodSheet4 = graphics.newImageSheet( "Images/BloodAndExplosions/stain4.png", bloodSheet4Data)

function getBloodSheet4()
	return bloodSheet4
end
---
local bloodSheet5Data = {
	width = 150,
	height = 32,
	numFrames = 1,
	sheetContentWidth = 150,
	sheetContentHeight = 32
}

local bloodSheet5 = graphics.newImageSheet( "Images/BloodAndExplosions/stain5.png", bloodSheet5Data)

function getBloodSheet5()
	return bloodSheet5
end
----------------------------------------------
---ZOMBIES---
----------------------------------------------
local zomWalkerSheetData = {
	width = 65,
	height = 100,
	numFrames = 87,
	sheetContentWidth = 650,
	sheetContentHeight = 900
}

local zomWalkerSheet = graphics.newImageSheet( "Images/Enemies/ZombieWalker.png", zomWalkerSheetData)

function getZomWalkerSheet()
	return zomWalkerSheet
end

local explosionSheetData =  {
	  width = 35,
	  height = 35,
	  numFrames = 42,
	  sheetContentWidth = 245,
	  sheetContentHeight = 210
}

local explosionSheet = graphics.newImageSheet( "Images/BloodAndExplosions/bigexplosion.png", explosionSheetData)

function getExplosionSheet()
	return explosionSheet
end
----------
--barrels-
----------
local oilBarrelSheetData =  {
	  width = 49,
	  height = 79,
	  numFrames = 1,
	  sheetContentWidth = 49,
	  sheetContentHeight = 79
}

local oilBarrelSheet = graphics.newImageSheet( "Images/LevelObjects/OilBarrel.png", oilBarrelSheetData)

function getOilBarrelSheet()
	return oilBarrelSheet
end
---
local acidBarrelSheetData =  {
	  width = 49,
	  height = 79,
	  numFrames = 1,
	  sheetContentWidth = 49,
	  sheetContentHeight = 79
}

local acidBarrelSheet = graphics.newImageSheet( "Images/LevelObjects/AcidBarrel.png", acidBarrelSheetData)

function getAcidBarrelSheet()
	return acidBarrelSheet
end
---
local fireBarrelSheetData =  {
	  width = 49,
	  height = 79,
	  numFrames = 1,
	  sheetContentWidth = 49,
	  sheetContentHeight = 79
}

local fireBarrelSheet = graphics.newImageSheet( "Images/LevelObjects/FireBarrel.png", fireBarrelSheetData)

function getFireBarrelSheet()
	return fireBarrelSheet
end
---
local handLightDisplaySheetData =  {
	  width = 11,
	  height = 33,
	  numFrames = 3,
	  sheetContentWidth = 33,
	  sheetContentHeight = 33
}

local handLightDisplaySheet = graphics.newImageSheet( "Images/AlliedObjects/Lights_strip3.png", handLightDisplaySheetData)

function getHandLightDisplaySheet()
	return handLightDisplaySheet
end

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
---
local redSirenSheetData = {
	width = 32,
	height = 24,
	numFrames = 11,
	sheetContentWidth = 352,
	sheetContentHeight = 24
}

local redSirenSheet = graphics.newImageSheet( "Images/LevelObjects/redSiren.png", redSirenSheetData)

function getRedSirenSheet()
	return redSirenSheet
end
---
local armLeftSheetData = {
	width = 45,
	height = 60,
	numFrames = 1,
	sheetContentWidth = 45,
	sheetContentHeight = 60
}

local armLeftSheet = graphics.newImageSheet( "Images/Limbs/bloodyarm2.png", armLeftSheetData)

function getArmLeftSheet()
	return armLeftSheet
end
---
local armRightSheetData = {
	width = 55,
	height = 25,
	numFrames = 1,
	sheetContentWidth = 55,
	sheetContentHeight = 25
}

local armRightSheet = graphics.newImageSheet( "Images/Limbs/bloodyarm.png", armRightSheetData)

function getArmRightSheet()
	return armRightSheet
end
---
local legLeftSheetData = {
	width = 53,
	height = 75,
	numFrames = 1,
	sheetContentWidth = 53,
	sheetContentHeight = 75
}

local legLeftSheet = graphics.newImageSheet( "Images/Limbs/bloodyleg2.png", legLeftSheetData)

function getLegLeftSheet()
	return legLeftSheet
end
---
local legRightSheetData = {
	width = 75,
	height = 70,
	numFrames = 1,
	sheetContentWidth = 75,
	sheetContentHeight = 70
}

local legRightSheet = graphics.newImageSheet( "Images/Limbs/bloodyleg.png", legRightSheetData)

function getLegRightSheet()
	return legRightSheet
end
----
local leverSheetData =  {
	  width = 173,
	  height = 147,
	  numFrames = 3,
	  sheetContentWidth = 519,
	  sheetContentHeight = 147
}

local leverSheet = graphics.newImageSheet( "Images/ControlPanel/ControlPanelLeverStrip.png", leverSheetData)

function getLeverSheet()
	return leverSheet
end

local leverSequenceData = {
					{ name="idle", frames={1}, time=100, loopCount=1 },
					{ name="left", frames={2}, time=100, loopCount=1 },
					{ name="right", frames={3}, time=100, loopCount=1 }					
				}

function getLeverSequenceData()
	return leverSequenceData
end