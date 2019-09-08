local require = GLOBAL.require

Assets =
{
	Asset("ATLAS", "images/board_border_horz.xml"),
	Asset("IMAGE", "images/board_border_horz.tex"),
	Asset("ATLAS", "images/options_menu_bg.xml"),
	Asset("IMAGE", "images/options_menu_bg.tex"),
	Asset("SOUNDPACKAGE", "sound/bingo_win.fev"),
	Asset("SOUND", "sound/bingo_win_bank00.fsb")
}

AddPlayerPostInit(function(inst)
	inst:DoTaskInTime(0, function(inst)
		if inst == GLOBAL.ThePlayer then
			inst:AddComponent("itemTableHandler")
		end
	end)
end)

local function GetConfig(s,default)
	local c=GetModConfigData(s)
	if c==nil then
		c=default
	end
	if type(c)=="table" then
		c=c.option_data
	end
	return c
end

GLOBAL.boardLoc = GetConfig("BoardLoc", 2)
GLOBAL.boardScale = GetConfig("boardScale", 0.9)
GLOBAL.slotColor = GetConfig("slotColor", 1)
GLOBAL.on_win = GetConfig("OnWin", 3)
GLOBAL.OnReward = GetConfig("OnReward", true)
GLOBAL.DoSound = GetConfig("DoSound", 1)
GLOBAL.PRNG_def = GetConfig("PRNG_def", 1)
GLOBAL.controllerBoardPress = GetConfig("ControllerBoardPress", 3)
GLOBAL.controllerMenuPress = GetConfig("ControllerMenuPress", 4)

Toggle_Key = GetModConfigData("Toggle_Key")
if type(Toggle_Key) == "string" then
	Toggle_Key = Toggle_Key:lower():byte()
end

ControllerMenuKeyPress = GetModConfigData("ControllerMenuKeyPress")
if type(ControllerMenuKeyPress) == "string" then
	ControllerMenuKeyPress = Toggle_Key:lower():byte()
end

local BingoBoard = GLOBAL.require("widgets/bingoBoard")
local BingoShow = true
local control_BingoShow = false

local function IsDefaultScreen()
	return GLOBAL.TheFrontEnd:GetActiveScreen().name:find("HUD") ~= nil
		and not(GLOBAL.ThePlayer.HUD:IsControllerCraftingOpen() or GLOBAL.ThePlayer.HUD:IsControllerInventoryOpen())
end

local function ToggleBingo()
	if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
	if not IsDefaultScreen() then return end

	if BingoShow == true then
		if control_BingoShow == true then
			GLOBAL.TheInput:EnableMouse(false)
			GLOBAL.ThePlayer.components.playercontroller.UsingMouse = function(TipsOff) 
				return not GLOBAL.TheInput:ControllerAttached()
			end
			controls.bingoBoard.controllerSafetyGuard:Hide()
			controls.bingoBoard.optionsMenu:Hide()
			controls.bingoBoard.controlHelp:Hide()
			controls.bingoBoard.controlHelpText:Hide()
			controls.bingoBoard:Hide()
			controls.crafttabs:Show()
			controls.inv:Show()			
			
			controls.bingoBoard.menuShow = false
			controls.bingoBoard.controllerFocus = false
			BingoShow = false
			control_BingoShow = false
		else
			controls.bingoBoard:Hide()
			BingoShow = false
		end
	else
		controls.bingoBoard:Show()
		BingoShow = true
		if controls.bingoBoard.menuShow == true then
			controls.bingoBoard.optionsMenu:Hide()
			controls.bingoBoard.controlHelp:Hide()
			controls.bingoBoard.controlHelpText:Hide()
			controls.bingoBoard.menuShow = false
		end
	end
end

local function controller_ToggleBingo()
	if GLOBAL.TheInput:ControllerAttached() then 
		if type(GLOBAL.ThePlayer) ~= "table" or type(GLOBAL.ThePlayer.HUD) ~= "table" then return end
		if not IsDefaultScreen() then return end

		if BingoShow == true and controls.bingoBoard.menuShow == false then	
		
			GLOBAL.TheInput:EnableMouse(not controller)
			GLOBAL.ThePlayer.components.playercontroller.UsingMouse = function(TipsOn) 
				return true
			end
			
			controls.crafttabs:CloseControllerCrafting()
			controls.crafttabs:Hide()
			controls.inv:Hide()
			controls.bingoBoard.controllerSafetyGuard:Show()
			controls.bingoBoard.optionsMenu:Show()			
			controls.bingoBoard.controlHelp:Show()
			controls.bingoBoard.controlHelpText:Show()
			
			controls.bingoBoard.controllerFocus = true
			controls.bingoBoard.menuShow = true	
			control_BingoShow = true		
			
		elseif BingoShow == true and controls.bingoBoard.menuShow == true then
		
			GLOBAL.TheInput:EnableMouse(false)
			GLOBAL.ThePlayer.components.playercontroller.UsingMouse = function(TipsOff) 
				return not GLOBAL.TheInput:ControllerAttached()
			end
			
			controls.bingoBoard.controllerSafetyGuard:Hide()	
			controls.bingoBoard:Hide()
			controls.bingoBoard.optionsMenu:Hide()
			controls.bingoBoard.controlHelp:Hide()
			controls.bingoBoard.controlHelpText:Hide()
			controls.crafttabs:Show()
			controls.inv:Show()
			
			BingoShow = false
			control_BingoShow = false
			controls.bingoBoard.menuShow = false		
			controls.bingoBoard.controllerFocus = false	
			
		else

			GLOBAL.TheInput:EnableMouse(not controller)
			GLOBAL.ThePlayer.components.playercontroller.UsingMouse = function(TipsOn) 
				return true
			end	
			
			if controls.bingoBoard.menuShow == false then
				controls.bingoBoard.optionsMenu:Show()
				controls.bingoBoard.menuShow = true
				controls.bingoBoard.controlHelp:Show()
				controls.bingoBoard.controlHelpText:Show()
			end
			
			controls.crafttabs:CloseControllerCrafting()
			controls.crafttabs:Hide()
			controls.inv:Hide()		
			controls.bingoBoard:Show()
			controls.bingoBoard.controllerSafetyGuard:Show()
			
			controls.bingoBoard.controllerFocus = true
			BingoShow = true
			control_BingoShow = true
		end
	end
end


local function AddBingo(self)
	controls = self
	if controls then
		if GLOBAL.boardLoc == 1 or GLOBAL.boardLoc == 2 or GLOBAL.boardLoc == 3 then   
			if controls.sidepanel then
				controls.bingoBoard = controls.sidepanel:AddChild(BingoBoard())
			else 
				controls.bingoBoard = controls:AddChild(BingoBoard())
			end
		elseif  GLOBAL.boardLoc == 4 then --top middle
			if controls.top_root then
				controls.bingoBoard = controls.top_root:AddChild(BingoBoard())
			else 
				controls.bingoBoard = controls:AddChild(BingoBoard())
			end		
		elseif  GLOBAL.boardLoc == 5 then -- top left
			if controls.topleft_root then
				controls.bingoBoard = controls.topleft_root:AddChild(BingoBoard())
			else 
				controls.bingoBoard = controls:AddChild(BingoBoard())
			end
		elseif  GLOBAL.boardLoc == 6 then -- bottom right
			if controls.bottomright_root then
				controls.bingoBoard = controls.bottomright_root:AddChild(BingoBoard())
			else 
				controls.bingoBoard = controls:AddChild(BingoBoard())
			end
		else
			return
		end
	end

	GLOBAL.TheInput:AddKeyDownHandler(Toggle_Key, ToggleBingo)
	GLOBAL.TheInput:AddKeyDownHandler(ControllerMenuKeyPress, controller_ToggleBingo)


	if GLOBAL.controllerBoardPress == 1 then
		GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_MENU_MISC_1, function(down)
			if down then
				ToggleBingo()
			end
		end)
	elseif GLOBAL.controllerBoardPress == 2 then
		GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_MENU_MISC_2, function(down)
			if down then
				ToggleBingo()
			end
		end)
	elseif  GLOBAL.controllerBoardPress == 3 then
		GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_MENU_MISC_3, function(down)
			if down then
				ToggleBingo()
			end
		end)
	elseif  GLOBAL.controllerBoardPress == 4 then
			GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_MENU_MISC_4, function(down)
			if down then
				ToggleBingo()
			end
		end)
	end
	
	if GLOBAL.controllerMenuPress == 1 then
		GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_MENU_MISC_1, function(down)
			if down then
				controller_ToggleBingo()
			end
		end)
	elseif GLOBAL.controllerMenuPress == 2 then
		GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_MENU_MISC_2, function(down)
			if down then
				controller_ToggleBingo()
			end
		end)
	elseif  GLOBAL.controllerMenuPress == 3 then
		GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_MENU_MISC_3, function(down)
			if down then
				controller_ToggleBingo()
			end
		end)
	elseif  GLOBAL.controllerMenuPress == 4 then
		GLOBAL.TheInput:AddControlHandler(GLOBAL.CONTROL_MENU_MISC_4, function(down)
			if down then
				controller_ToggleBingo()
			end
		end)
	end	
end

AddClassPostConstruct("widgets/controls", AddBingo)
