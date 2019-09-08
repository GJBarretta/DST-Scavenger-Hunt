local Button = require "widgets/button"
local AnimButton = require "widgets/animbutton"
local ImageButton = require "widgets/imagebutton"
local TextButton = require "widgets/textbutton"
local Text = require "widgets/text"
local Image = require "widgets/image"
local Widget = require "widgets/widget"
local Menu = require "widgets/menu"
local TileBG = require "widgets/tilebg"
local bingo_InvSlot = require "widgets/bingo_invSlot"
local bingo_ItemTile = require "widgets/bingo_itemTile"
local itemTableHandler = require "components/itemTableHandler"
local screenwidth, screenheight = TheSim:GetScreenSize()

local Screen = require "widgets/screen"
local TEMPLATES = require "widgets/templates"

local bingoBoard = Class(Widget, function(self, owner)

	self.owner = owner
	Widget._ctor(self, "bingoBoard")

	self.root = self:AddChild(Widget("ROOT"))
	self.root:SetVAnchor(ANCHOR_MIDDLE)
	self.root:SetHAnchor(ANCHOR_MIDDLE)
	self.root:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.root:SetPosition(0,0,0)

	self.root_top = self:AddChild(Widget("ROOT"))
	self.root_top:SetVAnchor(ANCHOR_TOP)
	self.root_top:SetHAnchor(ANCHOR_MIDDLE)
	self.root_top:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.root_top:SetPosition(0,-80,0)
	self.root_top:SetMaxPropUpscale(MAX_HUD_SCALE)
	
	self.boardShow = true
	self.menuShow = false
	self.controllerFocus = false

	self.inst:DoTaskInTime(1, function() 
		if ThePlayer.components.itemTableHandler.globList[1] == nil then
			ThePlayer.components.itemTableHandler:reset()
			self.inst:DoTaskInTime(0.2, function() self:menuDisplay() end)	
			self.inst:DoTaskInTime(0.4, function() self:boardDisplay() end)	
			self.inst:DoTaskInTime(0.45, function() self:Rebuild() end)
			self.inst:DoTaskInTime(0.5, function() self:StartUpdating() end)
		else 
			self.inst:DoTaskInTime(0.1, function() self:menuDisplay() end)
			self.inst:DoTaskInTime(0.2, function() self:boardDisplay() end)			
			self.inst:DoTaskInTime(0.35, function() self:Rebuild() end)
			self.inst:DoTaskInTime(0.4, function() self:StartUpdating() end)		
		end
	end)
end)

function bingoBoard:OnUpdate(dt)
	if ThePlayer.components.itemTableHandler.globTaggerUpdate == true then
		ThePlayer.components.itemTableHandler.globTaggerUpdate = false
		self:Rebuild()
		if ThePlayer.components.itemTableHandler.globWin == 2 then
			ThePlayer.components.itemTableHandler.globWin = ThePlayer.components.itemTableHandler.globWin + 1
			self:OnWin()
		end
		if ThePlayer.components.itemTableHandler.globWin == 4 then
			ThePlayer.components.itemTableHandler.globWin = ThePlayer.components.itemTableHandler.globWin + 1
			self:FullBoard()
		end
	end
end

function bingoBoard:OnGainFocus()
	if self.boardShow == true and self.controllerFocus == false then
		if not self.optionsMenu.OnGainFocus() then
			self.boardArrowR:Show()
			self.optionsMenuButton:Show()
		end
	end
end

function bingoBoard:OnLoseFocus()
	if self.boardShow == true and self.controllerFocus == false then
		self.boardArrowR:Hide()
		self.optionsMenuButton:Hide()
	end
	if self.boardShow ~= true and self.menuShow == false then
		self.optionsMenuButton:Hide()
	end
end

function bingoBoard:OnWin()

	local rand = math.random()
	
	if on_win == 2 or on_win == 4 then
		TheNet:Say(("BINGO: " .. ThePlayer.name .. " has gotten bingo!   \164\0\0" ),false) 
	end

	if on_win == 3 or on_win == 4 then
		self.winBanner = self.root_top:AddChild( Image("images/ui.xml", "update_banner.tex") )
		self.winBanner:SetScale(1,1,1)
		self.winBanner:SetSize(540, 150)
		self.winBanner:SetPosition(0, 0, 0)
		
		self.win_bg = self.winBanner:AddChild( Image("images/frontend.xml", "scribble_black.tex") )
		self.win_bg:SetScale(.8,.8,.8)
		self.win_bg:SetSize(540, 285)
		self.win_bg:SetPosition(0, -120, 0)
		self.win_bg:Hide()
		
		local wintext = ""
			
		self.bingoB = self.winBanner:AddChild(TextButton())
		self.bingoB:SetFont(TITLEFONT)
		self.bingoB:SetPosition(-150, 10, 0)
		self.bingoB:SetTextSize(55)
		self.bingoB:SetClickable(false)
		
		self.bingoI = self.winBanner:AddChild(TextButton())
		self.bingoI:SetFont(TITLEFONT)
		self.bingoI:SetPosition(-75, 10, 0)
		self.bingoI:SetTextSize(55)
		self.bingoI:SetClickable(false)
		
		self.bingoN = self.winBanner:AddChild(TextButton())
		self.bingoN:SetFont(TITLEFONT)
		self.bingoN:SetPosition(0, 10, 0)
		self.bingoN:SetTextSize(55)
		self.bingoN:SetClickable(false)
		
		self.bingoG = self.winBanner:AddChild(TextButton())
		self.bingoG:SetFont(TITLEFONT)
		self.bingoG:SetPosition(75, 10, 0)
		self.bingoG:SetTextSize(55)
		self.bingoG:SetClickable(false)
		
		self.bingoO = self.winBanner:AddChild(TextButton())
		self.bingoO:SetFont(TITLEFONT)
		self.bingoO:SetPosition(150, 10, 0)
		self.bingoO:SetTextSize(55)
		self.bingoO:SetClickable(false)
		
		self.inst:DoTaskInTime(1, function() 
			self.bingoB:SetColour(1,0,0,1)
			self.bingoB:SetText("B")
			if DoSound == 1 then
				ThePlayer.SoundEmitter:PlaySound("bingo_win/bingowin/winshort")
			end
		end)
		self.inst:DoTaskInTime(1.5, function() 
			self.bingoI:SetColour(1,0,0,1)
			self.bingoI:SetText("I")
			self.bingoB:SetColour(0,0,1,1)
			if DoSound == 1 then
				ThePlayer.SoundEmitter:PlaySound("bingo_win/bingowin/winshort")
			end
		end)
		self.inst:DoTaskInTime(2, function() 
			self.bingoN:SetColour(1,0,0,1)
			self.bingoN:SetText("N")
			self.bingoB:SetColour(0,0,1,1)
			self.bingoI:SetColour(0,0.50196,0,1)
			if DoSound == 1 then
				ThePlayer.SoundEmitter:PlaySound("bingo_win/bingowin/winshort")
			end
		end)
		self.inst:DoTaskInTime(2.5, function() 
			self.bingoG:SetColour(1,0,0,1)
			self.bingoG:SetText("G")
			self.bingoB:SetColour(0,0,1,1)
			self.bingoI:SetColour(0,0.50196,0,1)
			self.bingoN:SetColour(1,1,0,1)
			if DoSound == 1 then
				ThePlayer.SoundEmitter:PlaySound("bingo_win/bingowin/winshort")
			end
		end)
		self.inst:DoTaskInTime(3, function() 
			self.bingoO:SetColour(1,0,0,1)
			self.bingoO:SetText("O")
			self.bingoB:SetColour(0,0,1,1)
			self.bingoI:SetColour(0,0.50196,0,1) 
			self.bingoN:SetColour(1,1,0,1)
			self.bingoG:SetColour(1,0,1,1) 
			if DoSound == 1 then
				ThePlayer.SoundEmitter:PlaySound("bingo_win/bingowin/winshort")
			end
		end)
		
		self.inst:DoTaskInTime(4.5, function() 	
			if ThePlayer.components.itemTableHandler.storedDifficulty == 1 then
				if ThePlayer.prefab == "wes" then
					wintext = ("Wimp mode as Wes? What sort of trickery are you up to " .. ThePlayer.name .. "?")
				elseif rand < 0.25 then
					wintext = ("You got bingo! Congratulations " .. ThePlayer.name .. "! Why not give easy mode a try now? You have what it takes!")
				elseif rand >= 0.25 and rand < 0.5 then
					wintext = ("Way to go! " .. ThePlayer.prefab .. " is in good hands under your steely command. Keep up the good work!")
				elseif rand >= 0.5 and rand < 0.75 then
					wintext = ("Great job " .. ThePlayer.name .. "! Give it another go. I bet you're ready for easy mode now!")
				else
					wintext = ("You got bingo! Congrats! Why not go another round? Try easy mode this time!")
				end
			elseif ThePlayer.components.itemTableHandler.storedDifficulty == 2 then
				if ThePlayer.prefab == "wes" then
					wintext = ("Easy mode as Wes? What sort of trickery are you up to " .. ThePlayer.name .. "?")
				elseif rand < 0.25 then
					wintext = ("Bingo! Wonderful job " .. ThePlayer.name .. "!")
				elseif rand >= 0.25 and rand < 0.5 then
					wintext = ("Awesome job " .. ThePlayer.name .. "! Keep it up!")
				elseif rand >= 0.5 and rand < 0.75 then
					wintext = ("Awesome job " .. ThePlayer.name .. "! Keep it up!")
				else
					wintext = ("Bingo! Wonderful job " .. ThePlayer.name .. "!")
				end
			elseif ThePlayer.components.itemTableHandler.storedDifficulty == 3 then
				if ThePlayer.prefab == "wes" then
					wintext = ("You got bingo! Congratulations! You'll have to pantomime how you did it sometime.")
				elseif rand < 0.25 then
					wintext = ("You've gotten bingo! Congratulations " .. ThePlayer.name .. "!")
				elseif rand >= 0.25 and rand < 0.5 then
					wintext = ("Congratulations " .. ThePlayer.name .. "! You're the bees knees! Nothing can get in your way!")
				elseif rand >= 0.5 and rand < 0.75 then
					wintext = ("Bingo! You're becoming a Don't Starve phenom " .. ThePlayer.name .. "! Keep it up!")
				else
					wintext = (ThePlayer.name .. ", you're pretty swell! Great job!")
				end
			elseif ThePlayer.components.itemTableHandler.storedDifficulty == 4 then
				if rand < 0.25 then
					wintext = ("Amazing. Bingo with hard mode. Your skills are impressive!")
				elseif rand >= 0.25 and rand < 0.5 then
					wintext = ("Bingo with hard mode! You're a Don't Starve phenom " .. ThePlayer.name .. "!")
				elseif rand >= 0.5 and rand < 0.75 then
					wintext = ("Bingo with hard mode! You're a Don't Starve phenom " .. ThePlayer.name .. "!")
				else
					wintext = ("Bingo with hard mode! You're a Don't Starve phenom " .. ThePlayer.name .. "!")
				end
			
			elseif ThePlayer.components.itemTableHandler.storedDifficulty == 5 then
				if ThePlayer.prefab == "wes" then 
					wintext = (ThePlayer.name .. ", you've won extreme bingo with Wes. Simply amazing. Your skills are unmatched. Go spread your knowledge with the new batch of newbies and keep the Don't Starve tradition alive and strong!")
				else	
					if rand < 0.25 then
						wintext = ("You've won extreme bingo! " .. ThePlayer.name .. ", you're truly a master of Don't Starve!")
					elseif rand >= 0.25 and rand < 0.5 then
						wintext = ("You've beaten the game at its hardest. Incredible job " .. ThePlayer.name .. "!")
					elseif rand >= 0.5 and rand < 0.75 then
						wintext = ("You've beaten extreme bingo. You're a Don't Starve legend " .. ThePlayer.name .. "!")
					else
						wintext = ("You've won extreme bingo! You're truly a master of Don't Starve!")
					end
				end
			else	
				if rand < 0.25 then
					wintext = (ThePlayer.name .. ", you're pretty swell! Keep up the good work!")
				elseif rand >= 0.25 and rand < 0.5 then
					wintext = (ThePlayer.name .. ", you're the bees knees! Nothing can get in your way!")
				elseif rand >= 0.5 and rand < 0.75 then
					wintext = ("Congratulations " .. ThePlayer.name .. ", you've gotten bingo! Great job!")
				else
					wintext = (ThePlayer.name .. ", you did it! Congratulations!")
				end
			end	
			
			self.win_bg:Show()	
				
			self.winText = self.win_bg:AddChild(Text(TALKINGFONT, 35))
			self.winText:SetPosition(0, 0, 0)
			self.winText:SetString(wintext)
			self.winText:EnableWordWrap(true)
			self.winText:SetRegionSize(500, 265)
			self.winText:SetColour(1,1,1,1)
			
			if DoSound == 1 then
				ThePlayer.SoundEmitter:PlaySound("bingo_win/bingowin/winlong")
			end
		end)	

		if OnReward and TheNet:GetIsServerAdmin() then
			self:reward(false)
		end
		
		self.inst:DoTaskInTime(12, function() self.winBanner:Kill() end)
	end
end

function bingoBoard:FullBoard()
	self.FB_bg = self.root_top:AddChild( Image("images/frontend.xml", "scribble_black.tex") )
	self.FB_bg:SetScale(.8,.8,.8)
	self.FB_bg:SetSize(540, 285)
	self.FB_bg:SetPosition(0, -50, 0)
			
	local FBtexts = "You've gotten a full board... How? Why? Well, regardless, this is astonishing. You're the all-time Bingo champ, " .. ThePlayer.name .. ". Congratulations!"
		
	self.FBText = self.FB_bg:AddChild(Text(TALKINGFONT, 35))
	self.FBText:SetPosition(0, 0, 0)
	self.FBText:SetString(FBtexts)
	self.FBText:EnableWordWrap(true)
	self.FBText:SetRegionSize(500, 265)
	self.FBText:SetColour(1,1,1,1)
			
	if OnReward and TheNet:GetIsServerAdmin() then
		self:reward(true)
	end

	self.inst:DoTaskInTime(11, function() self.FB_bg:Kill() end)
end

function bingoBoard:reward(FullBoard)

	local rewardList = {}
	local count = 3
	local inst = nil
	local randChoice = math.random()

	if FullBoard then
		count = math.random(7,12)
	end	
	
	for k,v in pairs(ThePlayer.components.itemTableHandler.globList) do
		if ThePlayer.components.itemTableHandler.globTagger[k] == 1 then
			table.insert(rewardList, v)
		end
	end
	
	local task_time = 0
	
	for i=1,count do
		task_time = task_time + 0.4
		self.inst:DoTaskInTime(task_time, function()
			local choice = rewardList[math.random(#rewardList)]
			local kt = ThePlayer:GetPosition()
			local theta = math.random() * 2 * PI
			local radius = 6
			local offset = FindWalkableOffset(kt, theta, radius, 12, true)
			if offset then
				local loc = kt+offset
				local u,v,w = loc:Get()
				local fnstr = (string.format("SpawnPrefab('"..choice.."').Transform:SetPosition("..u..","..v..","..w..")"))			
				local x,y,z = TheSim:ProjectScreenPos(TheSim:GetPosition())
				
				if TheNet:GetIsClient() and TheNet:GetIsServerAdmin() then				
					TheNet:SendRemoteExecute(fnstr, x, z)
					SpawnPrefab("collapse_small").Transform:SetPosition(loc:Get())
				elseif TheNet:GetIsServerAdmin() then 
					SpawnPrefab(choice).Transform:SetPosition(loc:Get())
					SpawnPrefab("collapse_small").Transform:SetPosition(loc:Get())
				end
			end
		end)
	end
end

function bingoBoard:Rebuild()
	if self.board.slots ~= nil then
		self.board.slots:Kill()
	end

	self.board.slots = self.board:AddChild(Widget("SLOTS"))

	if self.board.inv then
		for k,v in pairs(self.board.inv) do
			v:Kill()
		end
	end

	self.board.inv = {}

	local HUD_ATLAS = "images/hud.xml"
	local maxSlots = 25
	local W = 66
	local H = 66
	local maxwidth = 1700
	local positions = 0
	local NUM_COLUMS = 5

	for k = 1, 25 do
		local inv_slot = "inv_slot.tex"

		if ThePlayer.components.itemTableHandler.globTagger[k] == 1 then
			inv_slot = "resource_needed.tex"
		end

		local height = math.floor(positions / NUM_COLUMS) * H
		local slot = bingo_InvSlot(k, HUD_ATLAS, inv_slot, self, ThePlayer.components.itemTableHandler.globList)
	 	self.board.inv[k] = self.board.slots:AddChild(slot)
		self.board.inv[k]:SetTile(bingo_ItemTile(ThePlayer.components.itemTableHandler.globList[k]))

		local remainder = positions % NUM_COLUMS
		local row = math.floor(positions / NUM_COLUMS) * H

		local x = W * remainder
		slot:SetPosition(x,-row,0)
		positions = positions + 1
	end
end

function bingoBoard:difficultyDisplay()		
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 1 then
		self.Wimp_bg:SetTint(1,1,1,0.8)
	else
		self.Wimp_bg:SetTint(1,1,1,0)
	end
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 2 then
		self.Easy_bg:SetTint(1,1,1,0.8)
	else
		self.Easy_bg:SetTint(1,1,1,0)
	end
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 3 then
		self.Medium_bg:SetTint(1,1,1,0.8)
	else
		self.Medium_bg:SetTint(1,1,1,0)
	end
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 4 then
		self.Hard_bg:SetTint(1,1,1,0.8)
	else
		self.Hard_bg:SetTint(1,1,1,0)
	end
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 5 then
		self.Master_bg:SetTint(1,1,1,0.8)
	else
		self.Master_bg:SetTint(1,1,1,0)
	end
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 6 then
		self.All_bg:SetTint(1,1,1,0.8)
	else
		self.All_bg:SetTint(1,1,1,0)
	end
end

function bingoBoard:checkboxUpdate()
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 1 then
		self.checkW_OW_button:Show()
		self.checkW_T_button:Show()
		self.checkW_M_button:Show()
	else
		self.checkW_OW_button:Hide()
		self.checkW_T_button:Hide()
		self.checkW_M_button:Hide()
	end
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 2 then
		self.checkE_OW_button:Show()
		self.checkE_T_button:Show()
		self.checkE_M_button:Show()
	else
		self.checkE_OW_button:Hide()
		self.checkE_T_button:Hide()
		self.checkE_M_button:Hide()
	end
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 3 then
		self.checkMe_OW_button:Show()
		self.checkMe_C_button:Show()
		self.checkMe_L_button:Show()
		self.checkMe_T_button:Show()
		self.checkMe_M_button:Show()
	else
		self.checkMe_OW_button:Hide()
		self.checkMe_C_button:Hide()
		self.checkMe_L_button:Hide()
		self.checkMe_T_button:Hide()
		self.checkMe_M_button:Hide()
	end
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 4 then
		self.checkH_OW_button:Show()
		self.checkH_C_button:Show()
		self.checkH_R_button:Show()
		self.checkH_L_button:Show()
		self.checkH_T_button:Show()
		self.checkH_M_button:Show()
	else
		self.checkH_OW_button:Hide()
		self.checkH_C_button:Hide()
		self.checkH_R_button:Hide()
		self.checkH_L_button:Hide()
		self.checkH_T_button:Hide()
		self.checkH_M_button:Hide()
	end
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 5 then
		self.checkMa_OW_button:Show()
		self.checkMa_C_button:Show()
		self.checkMa_R_button:Show()
		self.checkMa_L_button:Show()
		self.checkMa_T_button:Show()
		self.checkMa_M_button:Show()
	else
		self.checkMa_OW_button:Hide()
		self.checkMa_C_button:Hide()
		self.checkMa_R_button:Hide()
		self.checkMa_L_button:Hide()
		self.checkMa_T_button:Hide()
		self.checkMa_M_button:Hide()
	end
	if ThePlayer.components.itemTableHandler.options.globSwitchDifficulty == 6 then
		self.checkA_OW_button:Show()
		self.checkA_C_button:Show()
		self.checkA_R_button:Show()
		self.checkA_L_button:Show()
		self.checkA_T_button:Show()
		self.checkA_M_button:Show()
	else
		self.checkA_OW_button:Hide()
		self.checkA_C_button:Hide()
		self.checkA_R_button:Hide()
		self.checkA_L_button:Hide()
		self.checkA_T_button:Hide()
		self.checkA_M_button:Hide()
	end
end	

function bingoBoard:checkboxDisplay()		
	if (ThePlayer.components.itemTableHandler.options.checkCustomSeed % 2 == 0) then
		self.customSeedCheckBox:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {.75,.75}, {-126,-203})
	else
		self.customSeedCheckBox:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-126,-203})
	end

	if (ThePlayer.components.itemTableHandler.options.checkW_OW % 2 ~= 0) then
		self.checkW_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-145,82})
	else
		self.checkW_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-145,82})
	end 

	if (ThePlayer.components.itemTableHandler.options.checkW_T % 2 ~= 0) then
		self.checkW_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-145,-85})
	else
		self.checkW_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-145,-85})
	end

	if (ThePlayer.components.itemTableHandler.options.checkE_OW % 2 ~= 0) then
		self.checkE_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-90,82})
	else
		self.checkE_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-90,82})
	end

	if (ThePlayer.components.itemTableHandler.options.checkE_T % 2 ~= 0) then
		self.checkE_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-90,-85})
	else
		self.checkE_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-90,-85})
	end

	if (ThePlayer.components.itemTableHandler.options.checkMe_OW % 2 ~= 0) then
		self.checkMe_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,82})
	else
		self.checkMe_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-24,82})
	end

	if (ThePlayer.components.itemTableHandler.options.checkMe_C % 2 ~= 0) then
		self.checkMe_C_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,40})
	else
		self.checkMe_C_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-24,40})
	end

	if (ThePlayer.components.itemTableHandler.options.checkMe_L % 2 ~= 0) then
		self.checkMe_L_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-24,-47})
	else
		self.checkMe_L_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,-47})
	end

	if (ThePlayer.components.itemTableHandler.options.checkMe_T % 2 ~= 0) then
		self.checkMe_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-24,-85})
	else
		self.checkMe_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,-85})
	end

	if (ThePlayer.components.itemTableHandler.options.checkH_OW % 2 ~= 0) then
		self.checkH_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,82})
	else
		self.checkH_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,82})
	end

	if (ThePlayer.components.itemTableHandler.options.checkH_C % 2 ~= 0) then
		self.checkH_C_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,40})
	else
		self.checkH_C_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,40})
	end

	if (ThePlayer.components.itemTableHandler.options.checkH_R % 2 ~= 0) then
		self.checkH_R_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,-3})
	else
		self.checkH_R_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,-3})
	end

	if (ThePlayer.components.itemTableHandler.options.checkH_L % 2 ~= 0) then
		self.checkH_L_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,-47})
	else
		self.checkH_L_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,-47})
	end

	if (ThePlayer.components.itemTableHandler.options.checkH_T % 2 ~= 0) then
		self.checkH_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,-85})
	else
		self.checkH_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,-85})
	end

	if (ThePlayer.components.itemTableHandler.options.checkMa_OW % 2 ~= 0) then
		self.checkMa_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,82})
	else
		self.checkMa_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,82})
	end

	if (ThePlayer.components.itemTableHandler.options.checkMa_C % 2 ~= 0) then
		self.checkMa_C_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,40})
	else
		self.checkMa_C_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,40})
	end

	if (ThePlayer.components.itemTableHandler.options.checkMa_R % 2 ~= 0) then
		self.checkMa_R_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,-3})
	else
		self.checkMa_R_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,-3})
	end

	if (ThePlayer.components.itemTableHandler.options.checkMa_L % 2 ~= 0) then
		self.checkMa_L_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,-47})
	else
		self.checkMa_L_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,-47})
	end

	if (ThePlayer.components.itemTableHandler.options.checkMa_T % 2 ~= 0) then
		self.checkMa_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,-85})
	else
		self.checkMa_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,-85})
	end

	if (ThePlayer.components.itemTableHandler.options.checkA_OW % 2 ~= 0) then
		self.checkA_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,82})
	else
		self.checkA_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,82})
	end

	if (ThePlayer.components.itemTableHandler.options.checkA_C % 2 ~= 0) then
		self.checkA_C_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,38})
	else
		self.checkA_C_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,38})
	end

	if (ThePlayer.components.itemTableHandler.options.checkA_R % 2 ~= 0) then
		self.checkA_R_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,-3})
	else
		self.checkA_R_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,-3})
	end

	if (ThePlayer.components.itemTableHandler.options.checkA_L % 2 ~= 0) then
		self.checkA_L_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,-47})
	else
		self.checkA_L_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,-47})
	end

	if (ThePlayer.components.itemTableHandler.options.checkA_T % 2 ~= 0) then
		self.checkA_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,-85})
	else
		self.checkA_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,-85})
	end
	self:checkboxUpdate()
end

function bingoBoard:bingoSeedDisplay()
	self.bingoSeed:SetText(BingoSeed)
end

function bingoBoard:customSeedDisplay()
	self.cuSeOText:SetText(ThePlayer.components.itemTableHandler.options.cuSeO)
	self.cuSeTeText:SetText(ThePlayer.components.itemTableHandler.options.cuSeTe)
	self.cuSeHuText:SetText(ThePlayer.components.itemTableHandler.options.cuSeHu)
	self.cuSeThText:SetText(ThePlayer.components.itemTableHandler.options.cuSeTh)
	self.cuSeTeThText:SetText(ThePlayer.components.itemTableHandler.options.cuSeTeTh)
end

function bingoBoard:menuDisplay()

	self.controllerSafetyGuard = self.root:AddChild( Image("images/ui.xml", "blank.tex") )
	self.controllerSafetyGuard:SetSize(screenwidth * 2, screenheight * 2) 
	self.controllerSafetyGuard:SetPosition(0,0,0)
	self.controllerSafetyGuard:Hide()
	
	self.controlHelp = self.root_top:AddChild( Image("images/frontend.xml", "scribble_black.tex") )
    self.controlHelp:SetScale(.8,.8,.8)
	self.controlHelp:SetSize(520, 150)
    self.controlHelp:SetPosition(0, 0, 0)
    self.controlHelp:Hide()
	
	self.controlHelpText = self.controlHelp:AddChild(TextButton())
	self.controlHelpText:SetFont(TITLEFONT)
	self.controlHelpText:SetPosition(0, 3, 0)
	self.controlHelpText:SetTextSize(38)
	self.controlHelpText:SetColour(1,1,1,1)
	self.controlHelpText:SetClickable(false)
	self.controlHelpText:SetText("use a mouse to make your selections")
	self.controlHelpText:Hide()
	
	self.optionsMenu = self.root:AddChild( Image("images/options_menu_bg.xml", "options_menu_bg.tex") )
	self.optionsMenu:SetScale(.9,.9,.9)
	self.optionsMenu:SetPosition(0, -40, 0)
	self.optionsMenu:SetSize(700, 580)
	self.optionsMenu:SetTint(0.9,.9,.9,0.8)
	self.optionsMenu:Hide()

	self.DifficultyBorderTop = self.optionsMenu:AddChild( Image("images/ui.xml", "black.tex") )
	self.DifficultyBorderTop:SetScale(1,1,1)
	self.DifficultyBorderTop:SetSize(364, 5)
	self.DifficultyBorderTop:SetTint(1,1,1,1)
	self.DifficultyBorderTop:SetPosition(0,152,0)

	self.DifficultyBorderBottom = self.optionsMenu:AddChild( Image("images/ui.xml", "black.tex") )
	self.DifficultyBorderBottom:SetScale(1,1,1)
	self.DifficultyBorderBottom:SetSize(364, 5)
	self.DifficultyBorderBottom:SetTint(1,1,1,1)
	self.DifficultyBorderBottom:SetPosition(0,-142,0)

	self.DifficultyBorderLeft = self.optionsMenu:AddChild( Image("images/ui.xml", "black.tex") )
	self.DifficultyBorderLeft:SetScale(1,1,1)
	self.DifficultyBorderLeft:SetSize(5, 300)
	self.DifficultyBorderLeft:SetTint(1,1,1,1)
	self.DifficultyBorderLeft:SetPosition(-184,5,0)

	self.DifficultyBorderRight = self.optionsMenu:AddChild( Image("images/ui.xml", "black.tex") )
	self.DifficultyBorderRight:SetScale(1,1,1)
	self.DifficultyBorderRight:SetSize(5, 300)
	self.DifficultyBorderRight:SetTint(1,1,1,1)
	self.DifficultyBorderRight:SetPosition(184,5,0)

	self.whiteline1 = self.optionsMenu:AddChild( Image("images/ui.xml", "line_horizontal_white.tex") )
	self.whiteline1:SetScale(1,1,1)
	self.whiteline1:SetPosition(0, 163, 0)
	self.whiteline1:SetSize(300, 2.2)
	self.whiteline1:SetTint(1,1,1,0.6)

	self.whiteline2 = self.optionsMenu:AddChild( Image("images/ui.xml", "line_horizontal_white.tex") )
	self.whiteline2:SetScale(1,1,1)
	self.whiteline2:SetPosition(-3, -151, 0)
	self.whiteline2:SetSize(580, 2.2)
	self.whiteline2:SetTint(1,1,1,0.6)

	self.bingoControlPan = self.optionsMenu:AddChild(TextButton())
	self.bingoControlPan:SetFont(TITLEFONT)
	self.bingoControlPan:SetText("Bingo Control Panel")
	self.bingoControlPan:SetPosition(-1, 193, 0)
	self.bingoControlPan:SetTextSize(49)
	self.bingoControlPan:SetColour(0.9,0.8,0.6,1)
	self.bingoControlPan:SetClickable(false)
	
	self.resetBoardButton = self.optionsMenu:AddChild(ImageButton(UI_ATLAS, "button_large.tex", "button_large_over.tex", "button_large_disabled.tex", "button_large_onclick.tex"))		
	self.resetBoardButton:SetScale(0.9,.73,.75)
	self.resetBoardButton:SetPosition(0,-189,0)
	self.resetBoardButton:SetFont(BUTTONFONT)
	self.resetBoardButton:SetText("Reset Board")
	self.resetBoardButton:SetTextSize(45)
	self.resetBoardButton:SetOnClick( function()
		ThePlayer.components.itemTableHandler:reset()
		self.resetBoardButton:SetClickable(false)
		self.inst:DoTaskInTime(2, function() self:Rebuild() end)
		self.inst:DoTaskInTime(2, function() self:bingoSeedDisplay() end)
		self.inst:DoTaskInTime(2.1, function() self.resetBoardButton:SetClickable(true) end)
	end)

	self.bingoSeed = self.optionsMenu:AddChild(TextButton())
	self.bingoSeed:SetFont(NUMBERFONT)
	self.bingoSeed:SetText(BingoSeed)
	self.bingoSeed:SetPosition(-125, -170, 0)
	self.bingoSeed:SetTextSize(22)
	self.bingoSeed:SetColour(1,1,1,1)
	self.bingoSeed:SetClickable(false)

	self.bingoSeedText = self.optionsMenu:AddChild(TextButton())
	self.bingoSeedText:SetFont(TALKINGFONT)
	self.bingoSeedText:SetText("Bingo seed:")
	self.bingoSeedText:SetPosition(-190, -171, 0)
	self.bingoSeedText:SetTextSize(24)
	self.bingoSeedText:SetColour(1,1,1,1)
	self.bingoSeedText:SetClickable(false)

	self.customSeedText = self.optionsMenu:AddChild(TextButton())
	self.customSeedText:SetFont(TALKINGFONT)
	self.customSeedText:SetText("Custom seed:")
	self.customSeedText:SetPosition(-196, -200, 0)
	self.customSeedText:SetTextSize(24)
	self.customSeedText:SetColour(1,1,1,1)
	self.customSeedText:SetClickable(false)

	self.cuSeOText = self.optionsMenu:AddChild(TextButton())
	self.cuSeOText:SetFont(NUMBERFONT)
	self.cuSeOText:SetText("-")
	self.cuSeOText:SetPosition(118, -185, 0)
	self.cuSeOText:SetTextSize(22)
	self.cuSeOText:SetColour(1,1,1,1)
	self.cuSeOText:SetClickable(false)
		
	self.cuSeTeText = self.optionsMenu:AddChild(TextButton())
	self.cuSeTeText:SetFont(NUMBERFONT)
	self.cuSeTeText:SetText("-")
	self.cuSeTeText:SetPosition(152, -185, 0)
	self.cuSeTeText:SetTextSize(22)
	self.cuSeTeText:SetColour(1,1,1,1)
	self.cuSeTeText:SetClickable(false)
		
	self.cuSeHuText = self.optionsMenu:AddChild(TextButton())
	self.cuSeHuText:SetFont(NUMBERFONT)
	self.cuSeHuText:SetText("-")
	self.cuSeHuText:SetPosition(186, -185, 0)
	self.cuSeHuText:SetTextSize(22)
	self.cuSeHuText:SetColour(1,1,1,1)
	self.cuSeHuText:SetClickable(false)
		
	self.cuSeThText = self.optionsMenu:AddChild(TextButton())
	self.cuSeThText:SetFont(NUMBERFONT)
	self.cuSeThText:SetText("-")
	self.cuSeThText:SetPosition(218, -185, 0)
	self.cuSeThText:SetTextSize(22)
	self.cuSeThText:SetColour(1,1,1,1)
	self.cuSeThText:SetClickable(false)
		
	self.cuSeTeThText = self.optionsMenu:AddChild(TextButton())
	self.cuSeTeThText:SetFont(NUMBERFONT)
	self.cuSeTeThText:SetText("-")
	self.cuSeTeThText:SetPosition(251, -185, 0)
	self.cuSeTeThText:SetTextSize(22)
	self.cuSeTeThText:SetColour(1,1,1,1)
	self.cuSeTeThText:SetClickable(false)
		
	self.up_cuSeO = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "arrow2_up.tex", "arrow2_up_over.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", {1,1}, {430,-622}))
	self.up_cuSeO:SetScale(.27)
	self.up_cuSeO:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.cuSeO = ThePlayer.components.itemTableHandler.options.cuSeO + 1
		if ThePlayer.components.itemTableHandler.options.cuSeO > 9 then
			ThePlayer.components.itemTableHandler.options.cuSeO = 0
		end
		self:customSeedDisplay() 
	end)

	self.down_cuSeO = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "arrow2_down.tex", "arrow2_down_over.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", {1,1}, {430,-749}))
	self.down_cuSeO:SetScale(.27)
	self.down_cuSeO:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.cuSeO = ThePlayer.components.itemTableHandler.options.cuSeO - 1
		if ThePlayer.components.itemTableHandler.options.cuSeO < 0 then
			ThePlayer.components.itemTableHandler.options.cuSeO = 9
		end
		self:customSeedDisplay() 
	end)

	self.down_cuSeTe = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "arrow2_down.tex", "arrow2_down_over.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", {1,1}, {560,-749}))
	self.down_cuSeTe:SetScale(.27)
	self.down_cuSeTe:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.cuSeTe = ThePlayer.components.itemTableHandler.options.cuSeTe - 1
		if ThePlayer.components.itemTableHandler.options.cuSeTe < 0 then
			ThePlayer.components.itemTableHandler.options.cuSeTe = 9
		end
		self:customSeedDisplay() 
	end)

	self.up_cuSeTe = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "arrow2_up.tex", "arrow2_up_over.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", {1,1}, {560,-622}))
	self.up_cuSeTe:SetScale(.27)
	self.up_cuSeTe:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.cuSeTe = ThePlayer.components.itemTableHandler.options.cuSeTe + 1
		if ThePlayer.components.itemTableHandler.options.cuSeTe > 9 then
			ThePlayer.components.itemTableHandler.options.cuSeTe = 0
		end
		self:customSeedDisplay() 
	end)

	self.down_cuSeHu = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "arrow2_down.tex", "arrow2_down_over.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", {1,1}, {685,-749}))
	self.down_cuSeHu:SetScale(.27)
	self.down_cuSeHu:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.cuSeHu = ThePlayer.components.itemTableHandler.options.cuSeHu - 1
		if ThePlayer.components.itemTableHandler.options.cuSeHu < 0 then
			ThePlayer.components.itemTableHandler.options.cuSeHu = 9
		end
		self:customSeedDisplay() 
	end)

	self.up_cuSeHu = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "arrow2_up.tex", "arrow2_up_over.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", {1,1}, {685,-622}))
	self.up_cuSeHu:SetScale(.27)
	self.up_cuSeHu:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.cuSeHu = ThePlayer.components.itemTableHandler.options.cuSeHu + 1
		if ThePlayer.components.itemTableHandler.options.cuSeHu > 9 then
			ThePlayer.components.itemTableHandler.options.cuSeHu = 0
		end
		self:customSeedDisplay() 
	end)

	self.down_cuSeTh = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "arrow2_down.tex", "arrow2_down_over.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", {1,1}, {802,-749}))
	self.down_cuSeTh:SetScale(.27)
	self.down_cuSeTh:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.cuSeTh = ThePlayer.components.itemTableHandler.options.cuSeTh - 1
		if ThePlayer.components.itemTableHandler.options.cuSeTh < 0 then
			ThePlayer.components.itemTableHandler.options.cuSeTh = 9
		end
		self:customSeedDisplay() 
	end)

	self.up_cuSeTh = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "arrow2_up.tex", "arrow2_up_over.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", {1,1}, {802,-622}))
	self.up_cuSeTh:SetScale(.27)
	self.up_cuSeTh:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.cuSeTh = ThePlayer.components.itemTableHandler.options.cuSeTh + 1
		if ThePlayer.components.itemTableHandler.options.cuSeTh > 9 then
			ThePlayer.components.itemTableHandler.options.cuSeTh = 0
		end
		self:customSeedDisplay() 
	end)

	self.down_cuSeTeTh = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "arrow2_down.tex", "arrow2_down_over.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", "arrow2_down_down.tex", {1,1}, {925,-749}))
	self.down_cuSeTeTh:SetScale(.27)
	self.down_cuSeTeTh:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.cuSeTeTh = ThePlayer.components.itemTableHandler.options.cuSeTeTh - 1
		if ThePlayer.components.itemTableHandler.options.cuSeTeTh < 0 then
			ThePlayer.components.itemTableHandler.options.cuSeTeTh = 9
		end
		self:customSeedDisplay() 
	end)

	self.up_cuSeTeTh = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "arrow2_up.tex", "arrow2_up_over.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", "arrow2_up_down.tex", {1,1}, {925,-622}))
	self.up_cuSeTeTh:SetScale(.27)
	self.up_cuSeTeTh:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.cuSeTeTh = ThePlayer.components.itemTableHandler.options.cuSeTeTh + 1
		if ThePlayer.components.itemTableHandler.options.cuSeTeTh > 9 then
			ThePlayer.components.itemTableHandler.options.cuSeTeTh = 0
		end
		self:customSeedDisplay() 
	end)	
	
	self.bg_cover = self.optionsMenu:AddChild( Image("images/ui.xml", "black.tex") )
	self.bg_cover:SetScale(1,1,1)
	self.bg_cover:SetSize(370, 300,0)
	self.bg_cover:SetTint(1,1,1,0.6)
	self.bg_cover:SetPosition(0,5,0)

	self.Wimp_bg = self.optionsMenu:AddChild( Image("images/ui.xml", "black.tex") )
	self.Wimp_bg:SetScale(1,1,1)
	self.Wimp_bg:SetSize(67, 300,0)
	self.Wimp_bg:SetTint(1,1,1,0.6)
	self.Wimp_bg:SetPosition(-149,5,0)

	self.Easy_bg = self.optionsMenu:AddChild( Image("images/ui.xml", "black.tex") )
	self.Easy_bg:SetScale(1,1,1)
	self.Easy_bg:SetSize(47, 300)
	self.Easy_bg:SetTint(1,1,1,0.6)
	self.Easy_bg:SetPosition(-92,5,0)
		
	self.Medium_bg = self.optionsMenu:AddChild( Image("images/ui.xml", "black.tex") )
	self.Medium_bg:SetScale(1,1,1)
	self.Medium_bg:SetSize(80, 300)
	self.Medium_bg:SetTint(1,1,1,0.6)
	self.Medium_bg:SetPosition(-28,5,0)

	self.Hard_bg = self.optionsMenu:AddChild( Image("images/ui.xml", "black.tex") )
	self.Hard_bg:SetScale(1,1,1)
	self.Hard_bg:SetSize(58, 300)
	self.Hard_bg:SetTint(1,1,1,0.6)
	self.Hard_bg:SetPosition(41,5,0)

	self.Master_bg = self.optionsMenu:AddChild( Image("images/ui.xml", "black.tex") )
	self.Master_bg:SetScale(1,1,1)
	self.Master_bg:SetSize(66, 300)
	self.Master_bg:SetTint(1,1,1,0.6)
	self.Master_bg:SetPosition(103,5,0)

	self.All_bg = self.optionsMenu:AddChild( Image("images/ui.xml", "black.tex") )
	self.All_bg:SetScale(1,1,1)
	self.All_bg:SetSize(48, 300)
	self.All_bg:SetTint(1,1,1,0.6)
	self.All_bg:SetPosition(160,5,0)

	self:checkBoxes()

	self.wimpModeButton = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex"))
	self.wimpModeButton:SetText("Wimp")
	self.wimpModeButton:SetFont(UIFONT)
	self.wimpModeButton:SetTextSize(28)
	self.wimpModeButton:SetTextColour(0.9,0.8,0.6,1)
	self.wimpModeButton:SetTextFocusColour(1,1,1,1)
	self.wimpModeButton:SetHoverText("For complete newbies -- only chooses from the most basic items")
	self.wimpModeButton.hovertext:SetPosition(139,40,0)
	self.wimpModeButton.hovertext_bg:SetPosition(139,37,0)
	self.wimpModeButton:SetPosition(-146, 127)
	self.wimpModeButton:SetScale(1,1,1)
	self.wimpModeButton:SetOnClick( function() 
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 1
		self:difficultyDisplay()
		self:checkboxUpdate()
	end)

	self.easyModeButton = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex"))
	self.easyModeButton:SetText("Easy")
	self.easyModeButton:SetFont(UIFONT)
	self.easyModeButton:SetTextSize(28)
	self.easyModeButton:SetTextColour(0.9,0.8,0.6,1)
	self.easyModeButton:SetTextFocusColour(1,1,1,1)
	self.easyModeButton:SetHoverText("For those who are still learning the ropes -- only chooses from easy-to-get items")
	self.easyModeButton.hovertext:SetPosition(84,40,0)
	self.easyModeButton.hovertext_bg:SetPosition(84,37,0)
	self.easyModeButton:SetPosition(-90, 127)
	self.easyModeButton:SetOnClick( function()
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 2
		self:difficultyDisplay() 
		self:checkboxUpdate()
	end)

	self.mediumModeButton = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex"))
	self.mediumModeButton:SetText("Medium")
	self.mediumModeButton:SetFont(UIFONT)
	self.mediumModeButton:SetTextSize(28)
	self.mediumModeButton:SetTextColour(0.9,0.8,0.6,1)
	self.mediumModeButton:SetTextFocusColour(1,1,1,1)
	self.mediumModeButton:SetHoverText("For your average player -- only chooses from moderately difficult items")
	self.mediumModeButton.hovertext:SetPosition(23,40,0)
	self.mediumModeButton.hovertext_bg:SetPosition(23,37,0)
	self.mediumModeButton:SetPosition(-25, 127)
	self.mediumModeButton:SetOnClick( function()
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 3
		self:difficultyDisplay()
		self:checkboxUpdate()
	end)
	
	self.hardModeButton = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex"))
	self.hardModeButton:SetText("Hard")
	self.hardModeButton:SetFont(UIFONT)
	self.hardModeButton:SetTextSize(28)
	self.hardModeButton:SetTextColour(0.9,0.8,0.6,1)
	self.hardModeButton:SetTextFocusColour(1,1,1,1)
	self.hardModeButton:SetHoverText("Chooses from moderate and extreme items for a mix of both")
	self.hardModeButton.hovertext:SetPosition(-40,40,0)
	self.hardModeButton.hovertext_bg:SetPosition(-40,37,0)
	self.hardModeButton:SetPosition(43, 127)
	self.hardModeButton:SetOnClick( function()
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 4
		self:difficultyDisplay()
		self:checkboxUpdate()
	end)

	self.masterModeButton = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex"))
	self.masterModeButton:SetText("Extreme")
	self.masterModeButton:SetFont(UIFONT)
	self.masterModeButton:SetTextSize(28)
	self.masterModeButton:SetTextColour(0.9,0.8,0.6,1)
	self.masterModeButton:SetTextFocusColour(1,1,1,1)
	self.masterModeButton:SetHoverText("Only chooses from the most difficult items")
	self.masterModeButton.hovertext:SetPosition(-100,40,0)
		self.masterModeButton.hovertext:EnableWordWrap(true)
	self.masterModeButton.hovertext_bg:SetPosition(-100,37,0)
	self.masterModeButton:SetPosition(106, 127)
	self.masterModeButton:SetOnClick( function() 
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 5
		self:difficultyDisplay()
		self:checkboxUpdate()
	end)

	self.allModeButton = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "blank.tex", "blank.tex", "blank.tex"))
	self.allModeButton:SetText("All")
	self.allModeButton:SetFont(UIFONT)
	self.allModeButton:SetTextSize(28)
	self.allModeButton:SetTextColour(0.9,0.8,0.6,1)
	self.allModeButton:SetTextFocusColour(1,1,1,1)
	self.allModeButton:SetHoverText("Doesn't take difficulty into account -- chooses from all items")
	self.allModeButton.hovertext:SetPosition(-160,40,0)
	self.allModeButton.hovertext_bg:SetPosition(-160,37,0)
	self.allModeButton:SetPosition(160, 127)
	self.allModeButton:SetOnClick( function()  
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 6
		self:difficultyDisplay()
		self:checkboxUpdate()
	end)
	
	self.overworldButton = self.optionsMenu:AddChild(TextButton())
	self.overworldButton:SetFont(TALKINGFONT)
	self.overworldButton:SetText("Overworld")
	self.overworldButton:SetHoverText("Include/exclude items that can only be obtained from the overworld")
	self.overworldButton.hovertext:SetPosition(0,40,0)
	self.overworldButton.hovertext_bg:SetPosition(0,37,0)
	self.overworldButton:SetPosition(-228, 84, 0)
	self.overworldButton:SetTextSize(24)
	self.overworldButton:SetColour(1,1,1,1)

	self.cavesButton = self.optionsMenu:AddChild(TextButton())
	self.cavesButton:SetFont(TALKINGFONT)
	self.cavesButton:SetText("Caves")
	self.cavesButton:SetHoverText("Include/exclude items that can only be obtained from the caves")
	self.cavesButton.hovertext:SetPosition(0,40,0)
	self.cavesButton.hovertext_bg:SetPosition(0,37,0)
	self.cavesButton:SetPosition(-214, 42, 0)
	self.cavesButton:SetTextSize(24)
	self.cavesButton:SetColour(1,1,1,1)

	self.ruinsButton = self.optionsMenu:AddChild(TextButton())
	self.ruinsButton:SetFont(TALKINGFONT)
	self.ruinsButton:SetText("Ruins")
	self.ruinsButton:SetHoverText("Include/exclude items that can only be obtained from the ruins")
	self.ruinsButton.hovertext:SetPosition(0,40,0)
	self.ruinsButton.hovertext_bg:SetPosition(0,37,0)
	self.ruinsButton:SetPosition(-214, 0, 0)
	self.ruinsButton:SetTextSize(24)
	self.ruinsButton:SetColour(1,1,1,1)

	self.LongtermButton = self.optionsMenu:AddChild(TextButton())
	self.LongtermButton:SetFont(TALKINGFONT)
	self.LongtermButton:SetText("Longterm")
	self.LongtermButton:SetHoverText("Include/exclude items that are only accessible late-game or have a super low drop-chance")
	self.LongtermButton.hovertext:SetPosition(0,40,0)
	self.LongtermButton.hovertext_bg:SetPosition(0,37,0)
	self.LongtermButton:SetPosition(-227, -42, 0) 
	self.LongtermButton:SetTextSize(24)
	self.LongtermButton:SetColour(1,1,1,1)

	self.trinketsButton = self.optionsMenu:AddChild(TextButton())
	self.trinketsButton:SetFont(TALKINGFONT)
	self.trinketsButton:SetText("Trinkets")
	self.trinketsButton:SetHoverText("Include/exclude trinkets")
	self.trinketsButton.hovertext:SetPosition(0,40,0)
	self.trinketsButton.hovertext_bg:SetPosition(0,37,0)
	self.trinketsButton:SetPosition(-224, -81, 0)
	self.trinketsButton:SetTextSize(24)
	self.trinketsButton:SetColour(1,1,1,1)

	self.modsButton = self.optionsMenu:AddChild(TextButton())
	self.modsButton:SetFont(TALKINGFONT)
	self.modsButton:SetText("Mods")
	self.modsButton:SetHoverText("Include/exclude items from mods")
	self.modsButton.hovertext:SetPosition(0,40,0)
	self.modsButton.hovertext_bg:SetPosition(0,37,0)
	self.modsButton:SetPosition(-212, -120, 0)
	self.modsButton:SetTextSize(24)
	self.modsButton:SetColour(1,1,1,1)
	
	--self:checkBoxes()
	self:difficultyDisplay()
	self:customSeedDisplay()
	self:bingoSeedDisplay()
end

function bingoBoard:boardDisplay()

	self.boardParent = self:AddChild( Image("images/ui.xml", "blank.tex") )
	self.boardParent:SetSize(241, 281,0)
	self.boardParent:SetScale(boardScale,boardScale,boardScale)

	if boardLoc == 2 then 
		for k,v in pairs(ModManager:GetEnabledModNames()) do
			if v == "workshop-345692228" or v == "workshop-369082786"  or v == "workshop-565979581" or v == "workshop-590987536" or v == "workshop-548587862" or v == "workshop-690644114" then
				boardLoc = 1
			end
		end 
	end

	local combStat = false
	
	for k,v in pairs(ModManager:GetEnabledModNames()) do
		if v == "workshop-376333686" then
			combStat = true
		end
	end 

	if boardLoc == 1 or boardLoc == 2 or boardLoc == 3 then --top right
		if combStat == false then
			if boardLoc == 1 then
				if boardScale == 0.85 then
					self.boardParent:SetPosition(-135, -235, 0)				
				elseif boardScale == 0.9 then
					self.boardParent:SetPosition(-140, -243, 0)				
				elseif boardScale == 1 then
					self.boardParent:SetPosition(-155, -260, 0)		
				else
					self.boardParent:SetPosition(-165, -270, 0)				
				end	
			else
				if boardScale == 0.85 then
					self.boardParent:SetPosition(-185, -60, 0)				
				elseif boardScale == 0.9 then
					self.boardParent:SetPosition(-190, -65, 0)				
				elseif boardScale == 1 then
					self.boardParent:SetPosition(-203, -76, 0)		
				else
					self.boardParent:SetPosition(-215, -90, 0)				
				end	
			end			
		else
			if boardLoc == 1 then
				if boardScale == 0.85 then
					self.boardParent:SetPosition(-190, -235, 0)				
				elseif boardScale == 0.9 then
					self.boardParent:SetPosition(-200, -243, 0)				
				elseif boardScale == 1 then
					self.boardParent:SetPosition(-215, -260, 0)		
				else
					self.boardParent:SetPosition(-225, -270, 0)				
				end	
			else
				if boardScale == 0.85 then
					self.boardParent:SetPosition(-200, -60, 0)				
				elseif boardScale == 0.9 then
					self.boardParent:SetPosition(-210, -65, 0)				
				elseif boardScale == 1 then
					self.boardParent:SetPosition(-220, -76, 0)		
				else
					self.boardParent:SetPosition(-230, -90, 0)				
				end	
			end		
		end
	elseif boardLoc == 4 then -- top middle
		if boardScale == 0.85 then
			self.boardParent:SetPosition(0, -120, 0)				
		elseif boardScale == 0.9 then
			self.boardParent:SetPosition(0, -130, 0)				
		elseif boardScale == 1 then
			self.boardParent:SetPosition(0, -140, 0)		
		else
			self.boardParent:SetPosition(0, -150, 0)				
		end	
	elseif boardLoc == 5 then --top left
		if boardScale == 0.85 then
			self.boardParent:SetPosition(160, -120, 0)					
		elseif boardScale == 0.9 then
			self.boardParent:SetPosition(170, -125, 0)					
		elseif boardScale == 1 then
			self.boardParent:SetPosition(190, -140, 0)				
		else
			self.boardParent:SetPosition(200, -155, 0)				
		end	
	else
		if boardScale == 0.85 then --bottom right
			self.boardParent:SetPosition(-255, 170, 0)					
		elseif boardScale == 0.9 then
			self.boardParent:SetPosition(-260, 180, 0)						
		elseif boardScale == 1 then
			self.boardParent:SetPosition(-275, 190, 0)					
		else
			self.boardParent:SetPosition(-285, 195, 0)					
		end	
	end

	self.boardBorder = self.boardParent:AddChild( Image("images/board_border_horz.xml", "board_border_horz.tex" ) )
	self.boardBorder:SetSize(258, 264) 
	self.boardBorder:SetPosition(-1, 1) 
	
	self.boardBG = self.boardParent:AddChild( Image("images/ui.xml", "black.tex") )
	self.boardBG:SetScale(1,1,1)
	self.boardBG:SetSize(195, 226)
	self.boardBG:SetTint(1,1,1,0.6)
	self.boardBG:SetPosition(0,1,0) --upper left

	self.board = self.boardParent:AddChild( Image("images/ui.xml", "blank.tex") )
	self.board:SetScale(.57,.57,.57)
	self.board:SetPosition(-76,62,0)

	self.boardArrowR = self.boardParent:AddChild(ImageButton(UI_ATLAS, "crafting_inventory_arrow_r_idle.tex", "crafting_inventory_arrow_r_hl.tex", "arrow_right_disabled.tex"))
	self.boardArrowR:SetScale(0.45,0.45,0.45)
	self.boardArrowR:SetPosition(112,70,0)
	self.boardArrowR:SetTooltip('hide board')
	self.boardArrowR:Hide()
	self.boardArrowR:SetOnClick( function() 
		if self.boardShow == true then
			self.boardShow = false
			self.board:Hide()
			self.boardBG:Hide()
			self.boardTitle:Hide()
			self.boardBorder:Hide()
			self.boardParent:SetSize(1,1,0)
			self.boardArrowR:SetTooltip('show board')
			self.boardArrowR:SetTextures(UI_ATLAS, "crafting_inventory_arrow_l_idle.tex", "crafting_inventory_arrow_l_hl.tex", "arrow_left_disabled.tex")
		else
			self.boardShow = true
			self.boardParent:SetSize(241, 281,0)
			self.board:Show()
			self.boardBG:Show()
			self.boardTitle:Show()
			self.boardBorder:Show()
			self.boardArrowR:SetTooltip('hide board')
			self.boardArrowR:SetTextures(UI_ATLAS, "crafting_inventory_arrow_r_idle.tex", "crafting_inventory_arrow_r_hl.tex", "arrow_right_disabled.tex")
		end
	end)

	self.optionsMenuButton = self.boardParent:AddChild(ImageButton("images/button_icons.xml", "configure_mod.tex", "configure_mod.tex", "configure_mod.tex"))
	self.optionsMenuButton:SetScale(0.1,0.1,0.1)
	if boardLoc == 1 then
		self.optionsMenuButton:SetPosition(55,127,0)	
	else
		self.optionsMenuButton:SetPosition(112,-66,0)
	end
	self.optionsMenuButton:SetTooltip('show settings menu')
	self.optionsMenuButton:Hide()
	self.optionsMenuButton:SetOnClick( function() 
		if self.menuShow == false then
			self.menuShow = true
			self.optionsMenu:Show()
			self.optionsMenuButton:SetTooltip('hide settings menu')
		else
			self.menuShow = false
			self.optionsMenu:Hide()
			self.optionsMenuButton:SetTooltip('show settings menu')
		end
	end)

	self.boardTitle = self.boardParent:AddChild(TextButton())
	self.boardTitle:SetFont(TITLEFONT)
	self.boardTitle:SetText("B     I     N     G     O")
	self.boardTitle:SetTextSize(30)
	self.boardTitle:SetColour(0.9,0.8,0.6,1)
	self.boardTitle:SetPosition(0, 93, 0)
	self.boardTitle:SetClickable(false) 
end

--]]

function bingoBoard:checkBoxes()

	self.customSeedCheckBox = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-125,-203}))
  	self.customSeedCheckBox:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkCustomSeed = ThePlayer.components.itemTableHandler.options.checkCustomSeed + 1		
		if (ThePlayer.components.itemTableHandler.options.checkCustomSeed % 2 == 0) then
			self.customSeedCheckBox:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {.75,.75}, {-126,-203})
		else
			self.customSeedCheckBox:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {.75,.75}, {-126,-203})
		end
	end) 

	self.checkW_OW_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {.75,.75}, {-145,82}))
  	self.checkW_OW_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkW_OW = ThePlayer.components.itemTableHandler.options.checkW_OW + 1		
		if (ThePlayer.components.itemTableHandler.options.checkW_OW % 2 ~= 0) then
			self.checkW_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-145,82})
		else
			self.checkW_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-145,82})
		end 
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 1
		self:difficultyDisplay()
	end)

	self.checkW_T_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-145,-85}))
  	self.checkW_T_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkW_T = ThePlayer.components.itemTableHandler.options.checkW_T + 1	
		if (ThePlayer.components.itemTableHandler.options.checkW_T % 2 ~= 0) then
			self.checkW_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-145,-85})
		else
			self.checkW_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-145,-85})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 1
		self:difficultyDisplay()
	end)

	self.checkW_M_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-145,-123}))
	self.checkW_M_button:SetTooltip("This is currently disabled. Sorry.")
--[[
  	self.checkW_M_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.checkW_M = ThePlayer.components.itemTableHandler.checkW_M + 1	 
		if (ThePlayer.components.itemTableHandler.checkW_M % 2 ~= 0) then
			self.checkW_M_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-145,-123})
		else
			self.checkW_M_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-145,-123})
		end
	end)
--]]
	self.checkE_OW_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-90,82}))
  	self.checkE_OW_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkE_OW = ThePlayer.components.itemTableHandler.options.checkE_OW + 1 
		if (ThePlayer.components.itemTableHandler.options.checkE_OW % 2 ~= 0) then
			self.checkE_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-90,82})
		else
			self.checkE_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-90,82})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 2
		self:difficultyDisplay()
	end)

	self.checkE_T_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-90,-85}))
  	self.checkE_T_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkE_T = ThePlayer.components.itemTableHandler.options.checkE_T + 1
		if (ThePlayer.components.itemTableHandler.options.checkE_T % 2 ~= 0) then
			self.checkE_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-90,-85})
		else
			self.checkE_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-90,-85})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 2
		self:difficultyDisplay()
	end)

	self.checkE_M_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-90,-123}))
	self.checkE_M_button:SetTooltip("This is currently disabled. Sorry.")
--[[
  	self.checkE_M_button:SetOnClick(function() 
	ThePlayer.components.itemTableHandler.checkE_M = ThePlayer.components.itemTableHandler.checkE_M + 1
		if (ThePlayer.components.itemTableHandler.checkE_M % 2 ~= 0) then
			self.checkE_M_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-90,-123})
		else
			self.checkE_M_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-90,-123})
		end
	end)
--]]
	self.checkMe_OW_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-24,82}))
  	self.checkMe_OW_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkMe_OW = ThePlayer.components.itemTableHandler.options.checkMe_OW + 1
		if (ThePlayer.components.itemTableHandler.options.checkMe_OW % 2 ~= 0) then
			self.checkMe_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,82})
		else
			self.checkMe_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-24,82})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 3
		self:difficultyDisplay()
	end)

	self.checkMe_C_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-24,40}))
  	self.checkMe_C_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkMe_C = ThePlayer.components.itemTableHandler.options.checkMe_C + 1
		if (ThePlayer.components.itemTableHandler.options.checkMe_C % 2 ~= 0) then
			self.checkMe_C_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,40})
		else
			self.checkMe_C_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-24,40})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 3
		self:difficultyDisplay()
	end)

	self.checkMe_L_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,-47}))
  	self.checkMe_L_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkMe_L = ThePlayer.components.itemTableHandler.options.checkMe_L + 1
		if (ThePlayer.components.itemTableHandler.options.checkMe_L % 2 ~= 0) then
			self.checkMe_L_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-24,-47})
		else
			self.checkMe_L_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,-47})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 3
		self:difficultyDisplay()
	end)

	self.checkMe_T_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,-85}))
  	self.checkMe_T_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkMe_T = ThePlayer.components.itemTableHandler.options.checkMe_T + 1
		if (ThePlayer.components.itemTableHandler.options.checkMe_T % 2 ~= 0) then
			self.checkMe_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-24,-85})
		else
			self.checkMe_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,-85})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 3
		self:difficultyDisplay()
	end)

	self.checkMe_M_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,-123}))
	self.checkMe_M_button:SetTooltip("This is currently disabled. Sorry.")
--[[
  	self.checkMe_M_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.checkMe_M = ThePlayer.components.itemTableHandler.checkMe_M + 1
		if (ThePlayer.components.itemTableHandler.checkMe_M % 2 ~= 0) then
			self.checkMe_M_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {-24,-123})
		else
			self.checkMe_M_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {-24,-123})
		end
	end)
--]]
	self.checkH_OW_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,82}))
  	self.checkH_OW_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkH_OW = ThePlayer.components.itemTableHandler.options.checkH_OW + 1
		if (ThePlayer.components.itemTableHandler.options.checkH_OW % 2 ~= 0) then
			self.checkH_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,82})
		else
			self.checkH_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,82})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 4
		self:difficultyDisplay()
	end)

	self.checkH_C_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,40}))
  	self.checkH_C_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkH_C = ThePlayer.components.itemTableHandler.options.checkH_C + 1
		if (ThePlayer.components.itemTableHandler.options.checkH_C % 2 ~= 0) then
			self.checkH_C_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,40})
		else
			self.checkH_C_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,40})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 4
		self:difficultyDisplay()
	end)

	self.checkH_R_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,-3}))
  	self.checkH_R_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkH_R = ThePlayer.components.itemTableHandler.options.checkH_R + 1
		if (ThePlayer.components.itemTableHandler.options.checkH_R % 2 ~= 0) then
			self.checkH_R_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,-3})
		else
			self.checkH_R_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,-3})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 4
		self:difficultyDisplay()
	end)

	self.checkH_L_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,-47}))
  	self.checkH_L_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkH_L = ThePlayer.components.itemTableHandler.options.checkH_L + 1
		if (ThePlayer.components.itemTableHandler.options.checkH_L % 2 ~= 0) then
			self.checkH_L_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,-47})
		else
			self.checkH_L_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,-47})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 4
		self:difficultyDisplay()
	end)

	self.checkH_T_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,-85}))
  	self.checkH_T_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkH_T = ThePlayer.components.itemTableHandler.options.checkH_T + 1 
		if (ThePlayer.components.itemTableHandler.options.checkH_T % 2 ~= 0) then
			self.checkH_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,-85})
		else
			self.checkH_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,-85})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 4
		self:difficultyDisplay()
	end)

	self.checkH_M_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,-123}))
	self.checkH_M_button:SetTooltip("This is currently disabled. Sorry.")
--[[
  	self.checkH_M_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.checkH_M = ThePlayer.components.itemTableHandler.checkH_M + 1
		if (ThePlayer.components.itemTableHandler.checkH_M % 2 ~= 0) then
			self.checkH_M_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {43,-123})
		else
			self.checkH_M_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {43,-123})
		end
	end)
--]]
	self.checkMa_OW_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,82}))
  	self.checkMa_OW_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkMa_OW = ThePlayer.components.itemTableHandler.options.checkMa_OW + 1
		if (ThePlayer.components.itemTableHandler.options.checkMa_OW % 2 ~= 0) then
			self.checkMa_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,82})
		else
			self.checkMa_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,82})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 5
		self:difficultyDisplay()
	end)

	self.checkMa_C_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,40}))
  	self.checkMa_C_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkMa_C = ThePlayer.components.itemTableHandler.options.checkMa_C + 1
		if (ThePlayer.components.itemTableHandler.options.checkMa_C % 2 ~= 0) then
			self.checkMa_C_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,40})
		else
			self.checkMa_C_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,40})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 5
		self:difficultyDisplay()
	end)

	self.checkMa_R_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,-3}))
  	self.checkMa_R_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkMa_R = ThePlayer.components.itemTableHandler.options.checkMa_R + 1
		if (ThePlayer.components.itemTableHandler.options.checkMa_R % 2 ~= 0) then
			self.checkMa_R_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,-3})
		else
			self.checkMa_R_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,-3})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 5
		self:difficultyDisplay()
	end)

	self.checkMa_L_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,-47}))
  	self.checkMa_L_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkMa_L = ThePlayer.components.itemTableHandler.options.checkMa_L + 1
		if (ThePlayer.components.itemTableHandler.options.checkMa_L % 2 ~= 0) then
			self.checkMa_L_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,-47})
		else
			self.checkMa_L_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,-47})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 5
		self:difficultyDisplay()
	end)

	self.checkMa_T_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,-85}))
  	self.checkMa_T_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkMa_T = ThePlayer.components.itemTableHandler.options.checkMa_T + 1
		if (ThePlayer.components.itemTableHandler.options.checkMa_T % 2 ~= 0) then
			self.checkMa_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,-85})
		else
			self.checkMa_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,-85})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 5
		self:difficultyDisplay()
	end)

	self.checkMa_M_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,-123}))
	self.checkMa_M_button:SetTooltip("This is currently disabled. Sorry.")
--[[
  	self.checkMa_M_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.checkMa_M = ThePlayer.components.itemTableHandler.checkMa_M + 1
		if (ThePlayer.components.itemTableHandler.checkMa_M % 2 ~= 0) then
			self.checkMa_M_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {106,-123})
		else
			self.checkMa_M_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {106,-123})
		end
	end)
--]]
	self.checkA_OW_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,82})) 
  	self.checkA_OW_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkA_OW = ThePlayer.components.itemTableHandler.options.checkA_OW + 1
		if (ThePlayer.components.itemTableHandler.options.checkA_OW % 2 ~= 0) then
			self.checkA_OW_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,82})
		else
			self.checkA_OW_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,82})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 6
		self:difficultyDisplay()
	end)

	self.checkA_C_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,38}))
  	self.checkA_C_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkA_C = ThePlayer.components.itemTableHandler.options.checkA_C + 1
		if (ThePlayer.components.itemTableHandler.options.checkA_C % 2 ~= 0) then
			self.checkA_C_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,38})
		else
			self.checkA_C_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,38})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 6
		self:difficultyDisplay()
	end)

	self.checkA_R_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,-3}))
  	self.checkA_R_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkA_R = ThePlayer.components.itemTableHandler.options.checkA_R + 1
		if (ThePlayer.components.itemTableHandler.options.checkA_R % 2 ~= 0) then
			self.checkA_R_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,-3})
		else
			self.checkA_R_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,-3})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 6
		self:difficultyDisplay()
	end)

	self.checkA_L_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,-47}))
  	self.checkA_L_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkA_L = ThePlayer.components.itemTableHandler.options.checkA_L + 1
		if (ThePlayer.components.itemTableHandler.options.checkA_L % 2 ~= 0) then
			self.checkA_L_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,-47})
		else
			self.checkA_L_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,-47})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 6
		self:difficultyDisplay()
	end)

	self.checkA_T_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,-85}))
  	self.checkA_T_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.options.checkA_T = ThePlayer.components.itemTableHandler.options.checkA_T + 1
		if (ThePlayer.components.itemTableHandler.options.checkA_T % 2 ~= 0) then
			self.checkA_T_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,-85})
		else
			self.checkA_T_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,-85})
		end
		ThePlayer.components.itemTableHandler.options.globSwitchDifficulty = 6
		self:difficultyDisplay()
	end)

	self.checkA_M_button = self.optionsMenu:AddChild(ImageButton("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,-123}))
	self.checkA_M_button:SetTooltip("This is currently disabled. Sorry.")
--[[
  	self.checkA_M_button:SetOnClick(function() 
		ThePlayer.components.itemTableHandler.checkA_M = ThePlayer.components.itemTableHandler.checkA_M + 1
		if (ThePlayer.components.itemTableHandler.checkA_M % 2 ~= 0) then
			self.checkA_M_button:SetTextures("images/ui.xml", "checkbox_on.tex", "checkbox_on_highlight.tex", "checkbox_on_disabled.tex", nil, nil, {0.75,0.75}, {160,-123})
		else
			self.checkA_M_button:SetTextures("images/ui.xml", "checkbox_off.tex", "checkbox_off_highlight.tex", "checkbox_off_disabled.tex", nil, nil, {0.75,0.75}, {160,-123})
		end
	end)
--]]	
	self:checkboxDisplay()	

end

return bingoBoard
