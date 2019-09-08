require "mt19937"
require "itemList"
require "custom_itemList"

BingoSeed = (string.sub(os.time(),-5))

local function GotNewItem(inst, data)
	if data then
		if data.slot ~= nil or data.eslot ~= nil then
			local item = data.item.prefab
			for k,v in pairs(ThePlayer.components.itemTableHandler.globList) do		
				if v == item then
					if ThePlayer.components.itemTableHandler.globTagger[k] ~= 1 then
						ThePlayer.components.itemTableHandler.globTagger[k] = 1
						ThePlayer.components.itemTableHandler:evaluateList()
						inst:DoTaskInTime(0.4, function() 
							ThePlayer.components.itemTableHandler.globTaggerUpdate = true
							if DoSound == 1 then
								ThePlayer.SoundEmitter:PlaySound("bingo_win/bingowin/winshort")
							end
						end)
					end			
				end
			end
		end
	end
end

local function newactiveitem(inst, data)
	if data then
		if data.item ~= nil then
			local item = data.item.prefab
			for k,v in pairs(ThePlayer.components.itemTableHandler.globList) do		
				if v == item then
					if ThePlayer.components.itemTableHandler.globTagger[k] ~= 1 then
						ThePlayer.components.itemTableHandler.globTagger[k] = 1
						ThePlayer.components.itemTableHandler:evaluateList()
						inst:DoTaskInTime(0.4, function() 
							ThePlayer.components.itemTableHandler.globTaggerUpdate = true
							if DoSound == 1 then
								ThePlayer.SoundEmitter:PlaySound("bingo_win/bingowin/winshort")
							end
						end)
					end			
				end
			end
		end
	end
end 

local function clientstructure()
    local x,y,z = ThePlayer.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, 30)
    local closest = nil
    local closeness = nil
    for k,v in pairs(ents) do
		if v and v ~= nil and v.prefab and v.prefab ~= nil then
			if v:HasTag("structure") or v.prefab == "pottedfern" or v.prefab == "campfire" or v.prefab == "coldfire" then
				if closest == nil or ThePlayer:GetDistanceSqToInst(v) < closeness then
					closest = v.prefab
					closeness = ThePlayer:GetDistanceSqToInst(v)
				end
			end
        end
    end
    if closest and closest ~= nil then	
		for k,v in pairs(ThePlayer.components.itemTableHandler.globList) do		
			if v == closest then
				if ThePlayer.components.itemTableHandler.globTagger[k] ~= 1 then
					ThePlayer.components.itemTableHandler.globTagger[k] = 1
					ThePlayer.components.itemTableHandler:evaluateList()
					ThePlayer:DoTaskInTime(0.4, function() 
						ThePlayer.components.itemTableHandler.globTaggerUpdate = true
						if DoSound == 1 then
							ThePlayer.SoundEmitter:PlaySound("bingo_win/bingowin/winshort")
						end
					end)
				end			
			end
		end
    end
end

local itemTableHandler = Class(function(self, inst)

	self.inst = inst

	self.filepath_globList = "session/"..(TheNet:GetSessionIdentifier() or "INVALID_SESSION").."/bingoGL_data_OW_"..(TheNet:GetUserID() or "INVALID_USERID")
	self.filepath_globTagger = "session/"..(TheNet:GetSessionIdentifier() or "INVALID_SESSION").."/bingoGT_data_OW_"..(TheNet:GetUserID() or "INVALID_USERID")
	self.filepath_globWin = "session/"..(TheNet:GetSessionIdentifier() or "INVALID_SESSION").."/bingoGW_data_OW_"..(TheNet:GetUserID() or "INVALID_USERID")
	self.filepath_storedDiff = "session/"..(TheNet:GetSessionIdentifier() or "INVALID_SESSION").."/bingoSD_data_OW_"..(TheNet:GetUserID() or "INVALID_USERID")
	self.filepath_options = "session/"..(TheNet:GetSessionIdentifier() or "INVALID_SESSION").."/bingoOPT_data_OW_"..(TheNet:GetUserID() or "INVALID_USERID")
	
	if TheWorld:HasTag("cave") then
		self.filepath_globList = "session/"..(TheNet:GetSessionIdentifier() or "INVALID_SESSION").."/bingoGL_data_"..(TheNet:GetUserID() or "INVALID_USERID")
		self.filepath_globTagger = "session/"..(TheNet:GetSessionIdentifier() or "INVALID_SESSION").."/bingoGT_data_"..(TheNet:GetUserID() or "INVALID_USERID")
		self.filepath_globWin = "session/"..(TheNet:GetSessionIdentifier() or "INVALID_SESSION").."/bingoGW_data_"..(TheNet:GetUserID() or "INVALID_USERID")
		self.filepath_storedDiff = "session/"..(TheNet:GetSessionIdentifier() or "INVALID_SESSION").."/bingoSD_data_"..(TheNet:GetUserID() or "INVALID_USERID")
		self.filepath_options = "session/"..(TheNet:GetSessionIdentifier() or "INVALID_SESSION").."/bingoOPT_data_"..(TheNet:GetUserID() or "INVALID_USERID")
	end

	self.globList = {}
	self.globTagger = {}
	self.globTaggerUpdate = false
	self.globWin = 1
	self.storedDifficulty = 3
	
	for k = 1,25 do
		self.globTagger[k] = 0
	end

	self.options =
	{
		["globSwitchDifficulty"] = 3,
		["checkCustomSeed"] = 1,
		["cuSeO"] = 0,
		["cuSeTe"] = 0,
		["cuSeHu"] = 0,
		["cuSeTh"] = 0,
		["cuSeTeTh"] = 0,
		["checkW_OW"] = 2,
		["checkW_M"] = 2,
		["checkW_T"] = 2,
		["checkW_L"] = 2,
		["checkE_OW"] = 2,
		["checkE_M"] = 2,
		["checkE_T"] = 2,
		["checkE_L"] = 2,
		["checkMe_OW"] = 2,
		["checkMe_C"] = 2,
		["checkMe_M"] = 2,
		["checkMe_T"] = 2,
		["checkMe_L"] = 2,
		["checkH_OW"] = 2,
		["checkH_C"] = 2,
		["checkH_R"] = 2,
		["checkH_M"] = 2,
		["checkH_T"] = 2,
		["checkH_L"] = 2,
		["checkMa_OW"] = 2,
		["checkMa_C"] = 2,
		["checkMa_R"] = 2,
		["checkMa_M"] = 2,
		["checkMa_T"] = 2,
		["checkMa_L"] = 2,
		["checkA_OW"] = 2,
		["checkA_C"] = 2,
		["checkA_R"] = 2,
		["checkA_M"] = 2,
		["checkA_T"] = 2,
		["checkA_L"] = 2,	
	}

	self:OnLoad()	
	
	inst:ListenForEvent( "gotnewitem",GotNewItem)
    inst:ListenForEvent( "equip",GotNewItem)
    inst:ListenForEvent( "newactiveitem",newactiveitem)

	if TheNet:GetIsServer() then
		inst:ListenForEvent( "buildstructure",newactiveitem)
	else
		inst:ListenForEvent( "buildsuccess",clientstructure)
	end

	self.inst:StartUpdatingComponent(self)
end)

function itemTableHandler:OnSave() 
	local globList = json.encode(self.globList)
	TheSim:SetPersistentString(self.filepath_globList, globList, true)
	
	local globTagger = json.encode(self.globTagger)
	TheSim:SetPersistentString(self.filepath_globTagger, globTagger, true)
	
	local storedDiff = json.encode(self.storedDifficulty)
	TheSim:SetPersistentString(self.filepath_storedDiff, storedDiff, true)
	
	local globWin = json.encode(self.globWin)
	TheSim:SetPersistentString(self.filepath_globWin, globWin, true)
	
	local options = json.encode(self.options)
	TheSim:SetPersistentString(self.filepath_options, options, true)
end

function itemTableHandler:OnLoad() 
	local cb = function(success, globList)
		if success then
			self.globList = json.decode(globList)
		end
	end
	TheSim:GetPersistentString(self.filepath_globList, cb)

	local cb = function(success, globTagger)
		if success then
			self.globTagger = json.decode(globTagger)
		end
	end
	TheSim:GetPersistentString(self.filepath_globTagger, cb)

	local cb = function(success, storedDiff)
		if success then
			self.storedDifficulty = json.decode(storedDiff)
		end
	end
	TheSim:GetPersistentString(self.filepath_storedDiff, cb)
	
	local cb = function(success, globWin)
		if success then
			self.globWin = json.decode(globWin)
		end
	end
	TheSim:GetPersistentString(self.filepath_globWin, cb)
	
	local cb = function(success, options)
		if success then
			self.options = json.decode(options)
		end
	end
	TheSim:GetPersistentString(self.filepath_options, cb)
end

function itemTableHandler:shuffleORIG(array)
	BingoSeed = (string.sub(os.time(),-5))
	if self.options.checkCustomSeed  % 2 == 0 then
		BingoSeed = (self.options.cuSeO .. self.options.cuSeTe .. self.options.cuSeHu .. self.options.cuSeTh .. self.options.cuSeTeTh)
	end
	math.randomseed(BingoSeed)
	local arrayCount = #array
	for f = arrayCount, 1, -1 do
		math.random(os.time())
        	local j = math.random(f)
        	array[f], array[j] = array[j], array[f]
    	end
   return array
end

function itemTableHandler:shuffleCUST(array)
	BingoSeed = tonumber(string.sub(os.time(),-5))

	if self.options.checkCustomSeed  % 2 == 0 then
		BingoSeed = tonumber(self.options.cuSeO .. self.options.cuSeTe .. self.options.cuSeHu .. self.options.cuSeTh .. self.options.cuSeTeTh)
	end
	local mt = mt19937(BingoSeed)
	local arrayCount = #array
	for f = arrayCount, 1, -1 do
        	local j = mt:get(1, arrayCount)
			if j == 0 then j = 5 end
        	array[f], array[j] = array[j], array[f]
    	end
   return array
end

function itemTableHandler:evaluateList()

	local horz = 1
	local vert = 1
	local count = 0
			
--evaluating rows
	if self.globWin == 1 then
		for i = 1,5 do
			if self.globWin ~= 1 then
				break
			end
			for j = 1,5 do
				if self.globTagger[horz] == 1 then 
					horz = horz + 1
					count = count + 1
					if count == 5 then
						self.globWin = self.globWin + 1
						break
					end
				else 
					count = 0
					vert = vert + 1
					horz = ((vert - 1) * 5) + 1
					if vert > 5 then
						horz = 1
						vert = 1
					end
					break
				end
			end
		end
	end

--evaluating columns
	if self.globWin == 1 then
		for i = 1,5 do
			if self.globWin ~= 1 then
				break
			end
			for j = 1,5 do
				if self.globTagger[vert] == 1 then 
					vert = vert + 5
					count = count + 1
					if count == 5 then
						self.globWin = self.globWin + 1
						break
					end
				else 
					count = 0
					horz = horz + 1
					vert = horz
					if horz > 5 then
						horz = 1
						vert = 1
					end
					break
				end
			end
		end
	end

--evaluating 1,25 diagonal
	if self.globWin == 1 then
		for k = 1, 5 do
			if self.globTagger[horz] == 1 then
				horz = horz + 6
				count = count + 1
				if count == 5 then
					self.globWin = self.globWin + 1
					break
				end
			else 
				horz = 5
				count = 0
				break
			end
		end
	end

--evaluating 5,21 diagonal
	if self.globWin == 1 then
		for k = 1, 5 do
			if self.globTagger[horz] == 1 then
				horz = horz + 4
				count = count + 1
				if count == 5 then
					self.globWin = self.globWin + 1
					break
				end
			else 
				break
			end
		end
	end
	
	if self.globWin == 3 then
		count = 0
		for k = 1, 25 do
			if self.globTagger[k] == 1 then
				count = count + 1
			end
		end
		if count == 25 then
			self.globWin = self.globWin + 1
		end
	end			
end

function itemTableHandler:reset()

	self.globWin = 1
	local tempList = {}
	local invItem = 1
	local randNum = math.random()
		
	for k = 1,25 do
		self.globTagger[k] = 0
	end
	
	if customList[1] == nil then
		self.storedDifficulty = self.options.globSwitchDifficulty
	else
		self.storedDifficulty = 9
	end

	if customList[1] ~= nil then
		for k,v in pairs(customList) do
			invItem = SpawnPrefab(v)
			if invItem ~= nil then
				if TheNet:GetIsServer() then
					if invItem:IsValid() or invItem.components.inventoryitem or invItem:HasTag("structure") or v.prefab == "pottedfern" or v.prefab == "campfire" or v.prefab == "coldfire" then
						table.insert(tempList, v)
					else
						print(v .. ' is not an inventory item or structure, so it will not be included.')
					end	
				else
					if invItem:IsValid() or invItem:HasTag("structure") or v.prefab == "pottedfern" or v.prefab == "campfire" or v.prefab == "coldfire" then	
						table.insert(tempList, v)	
					else
						print(v .. ' is not an inventory item or structure, so it will not be included.')
					end	
				end
			end
		invItem:Remove()
		end
	end
	if only_use_custom_list == false then
		if self.options.globSwitchDifficulty == 1 then
			if self.options.checkW_OW % 2 == 0 then
				for k,v in pairs(W_OW) do
					table.insert(tempList, v)
				end
				for k,v in pairs(W_OW_STR) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkW_M % 2 ~= 0 then
				for k,v in pairs(ModManager.loadedprefabs) do
					for k,v in pairs(Prefabs[v].deps) do
						invItem = SpawnPrefab(v)
						if invItem ~= nil then
							if TheNet:GetIsServer() then
								if invItem:IsValid() or invItem.components.inventoryitem or invItem:HasTag("structure") then
									table.insert(tempList, v)
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							else
								if invItem:IsValid() or invItem:HasTag("structure") then	
									table.insert(tempList, v)	
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							end
						end
					invItem:Remove()
					end
				end
			end
			if self.options.checkW_T % 2 ~= 0 then
				for k,v in pairs(trinkets_all) do
					table.insert(tempList, v)
				end
			end
		elseif self.options.globSwitchDifficulty == 2 then
			if self.options.checkE_OW % 2 == 0 then
				for k,v in pairs(E_OW) do
					table.insert(tempList, v)
				end
				for k,v in pairs(E_OW_STR) do
					table.insert(tempList, v)
				end
				--[[
				if ThePlayer.prefab ~= "Wickerbottom" then
					table.insert(tempList, "papyrus")
				end 
				if ThePlayer.prefab == "Wickerbottom" then
					table.insert(tempList, "book_gardening")
				end
				--]]
			end
			if self.options.checkE_M % 2 ~= 0 then
				for k,v in pairs(ModManager.loadedprefabs) do
					for k,v in pairs(Prefabs[v].deps) do
						invItem = SpawnPrefab(v)
						if invItem ~= nil then
							if TheNet:GetIsServer() then
								if invItem:IsValid() or invItem.components.inventoryitem or invItem:HasTag("structure") then
									table.insert(tempList, v)
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							else
								if invItem:IsValid() or invItem:HasTag("structure") then	
									table.insert(tempList, v)	
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							end
						end
					invItem:Remove()
					end
				end
			end
			if self.options.checkE_T % 2 ~= 0 then
				for k,v in pairs(trinkets_all) do
					table.insert(tempList, v)
				end
			end
		elseif self.options.globSwitchDifficulty == 3 then
			if self.options.checkMe_OW % 2 == 0 then
				for k,v in pairs(Me_OW_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Me_OW_ST_STR) do
					table.insert(tempList, v)
				end
				--[[
				if ThePlayer.prefab == "Wickerbottom" then
					table.insert(tempList, "book_birds")
				end
				--]]
			end
			if self.options.checkMe_OW % 2 == 0 and self.options.checkMe_L % 2 ~= 0 then
				for k,v in pairs(Me_OW_LT) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkMe_OW % 2 ~= 0 then
				for k,v in pairs(Me_BASE) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkMe_C % 2 == 0 then
				for k,v in pairs(Me_C_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Me_C_ST_STR) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkMe_M % 2 ~= 0 then
				for k,v in pairs(ModManager.loadedprefabs) do
					for k,v in pairs(Prefabs[v].deps) do
						invItem = SpawnPrefab(v)
						if invItem ~= nil then
							if TheNet:GetIsServer() then
								if invItem:IsValid() or invItem.components.inventoryitem or invItem:HasTag("structure") then
									table.insert(tempList, v)
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							else
								if invItem:IsValid() or invItem:HasTag("structure") then	
									table.insert(tempList, v)	
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							end
						end
					invItem:Remove()
					end
				end
			end
			if self.options.checkMe_T % 2 ~= 0 then
				for k,v in pairs(trinkets_all) do
					table.insert(tempList, v)
				end
			end
		elseif self.options.globSwitchDifficulty == 4 then
			if self.options.checkH_OW % 2 == 0 then
				for k,v in pairs(Me_OW_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_OW_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Me_OW_ST_STR) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_OW_ST_STR) do
					table.insert(tempList, v)
				end
				--[[
				if ThePlayer.prefab ~= "Wilson" then
					table.insert(tempList, "resurrectionstatue")
				end 
				--]]
				if randNum < 0.25 then
					table.insert(tempList, "tallbirdegg")				
				elseif  0.25 <= randNum and randNum < 0.5 then
					table.insert(tempList, "tallbirdegg_cooked")				
				else
					table.insert(tempList, "tallbirdegg_cracked")				
				end
			end
			if self.options.checkH_OW % 2 == 0 and self.options.checkH_L % 2 ~= 0 then
				for k,v in pairs(Me_OW_LT) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_OW_LT) do
					table.insert(tempList, v)
				end
				--[[
				if ThePlayer.prefab ~= "Webber" then
					table.insert(tempList, "spidereggsack")
				end
				--]]
			end
			if self.options.checkH_OW % 2 ~= 0 then
				for k,v in pairs(Me_BASE) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_BASE_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_BASE_ST_STR) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkH_C % 2 == 0 then
				for k,v in pairs(Me_C_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_C_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Me_C_ST_STR) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_C_ST_STR) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkH_C % 2 == 0 and self.options.checkH_L % 2 ~= 0 then
				for k,v in pairs(Ma_C_LT) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_C_LT_STR) do
					table.insert(tempList, v)
				end
			end	
			if self.options.checkH_R % 2 == 0 and self.options.checkH_C % 2 ~= 0 then
				for k,v in pairs(Ma_R_ST) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkH_R % 2 == 0 and self.options.checkH_C % 2 == 0 then
				for k,v in pairs(Ma_C_R_ST) do
					table.insert(tempList, v)
				end
			end		
			if self.options.checkH_R % 2 == 0 and self.options.checkH_OW % 2 == 0 then
				for k,v in pairs(Ma_R_OW) do
					table.insert(tempList, v)
				end
			end	
			if self.options.checkH_M % 2 ~= 0 then
				for k,v in pairs(ModManager.loadedprefabs) do
					for k,v in pairs(Prefabs[v].deps) do
						invItem = SpawnPrefab(v)
						if invItem ~= nil then
							if TheNet:GetIsServer() then
								if invItem:IsValid() or invItem.components.inventoryitem or invItem:HasTag("structure") then
									table.insert(tempList, v)
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							else
								if invItem:IsValid() or invItem:HasTag("structure") then	
									table.insert(tempList, v)	
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							end
						end
					invItem:Remove()
					end
				end
			end
			if self.options.checkH_T % 2 ~= 0 then
				for k,v in pairs(trinkets_all) do
					table.insert(tempList, v)
				end
			end
		elseif self.options.globSwitchDifficulty == 5 then
			if self.options.checkMa_OW % 2 == 0 then
				for k,v in pairs(Ma_OW_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_OW_ST_STR) do
					table.insert(tempList, v)
				end
				--[[
				if ThePlayer.prefab ~= "Wilson" then
					table.insert(tempList, "resurrectionstatue")
				end 
				--]]
				if randNum < 0.25 then
					table.insert(tempList, "tallbirdegg")				
				elseif  0.25 <= randNum and randNum < 0.5 then
					table.insert(tempList, "tallbirdegg_cooked")				
				else
					table.insert(tempList, "tallbirdegg_cracked")				
				end
			end
			if self.options.checkMa_OW % 2 == 0 and self.options.checkMa_L % 2 ~= 0 then
				for k,v in pairs(Ma_OW_LT) do
					table.insert(tempList, v)
				end
				--[[
				if ThePlayer.prefab ~= "Webber" then
					table.insert(tempList, "spidereggsack")
				end
				--]]
			end
			if self.options.checkMa_OW % 2 ~= 0 then
				for k,v in pairs(Ma_BASE_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_BASE_ST_STR) do
					table.insert(tempList, v)
				end
				--[[
				if ThePlayer.prefab == "Wickerbottom" then
					table.insert(tempList, "book_sleep")
					table.insert(tempList, "book_brimstone")
					table.insert(tempList, "book_tentacles")
				end
				if ThePlayer.prefab ~= "Wilson" then
					table.insert(tempList, "resurrectionstatue")
				end 
				--]]
			end
			if self.options.checkMa_OW % 2 ~= 0 and self.options.checkMa_L % 2 ~= 0 then
				for k,v in pairs(Ma_BASE_LT) do
					table.insert(tempList, v)
				end
				--[[
				if ThePlayer.prefab ~= "Webber" then
					table.insert(tempList, "spidereggsack")
				end
				--]]
			end
			if self.options.checkMa_C % 2 == 0 and self.options.checkMa_L % 2 ~= 0 then
				for k,v in pairs(Ma_C_LT) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_C_LT_STR) do
					table.insert(tempList, v)
				end
			end					
			if self.options.checkMa_C % 2 == 0 and self.options.checkMa_R % 2 ~= 0 then
				for k,v in pairs(Ma_C_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(Ma_C_ST_STR) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkMa_R % 2 == 0 and self.options.checkMa_C % 2 ~= 0 then
				for k,v in pairs(Ma_R_ST) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkMa_R % 2 == 0 and self.options.checkMa_C % 2 == 0 then
				for k,v in pairs(Ma_C_R_ST) do
					table.insert(tempList, v)
				end
			end		
			if self.options.checkMa_R % 2 == 0 and self.options.checkMa_OW % 2 == 0 then
				for k,v in pairs(Ma_R_OW) do
					table.insert(tempList, v)
				end
			end				
			
			if self.options.checkMa_M % 2 ~= 0 then
				for k,v in pairs(ModManager.loadedprefabs) do
					for k,v in pairs(Prefabs[v].deps) do
						invItem = SpawnPrefab(v)
						if invItem ~= nil then
							if TheNet:GetIsServer() then
								if invItem:IsValid() or invItem.components.inventoryitem or invItem:HasTag("structure") then
									table.insert(tempList, v)
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							else
								if invItem:IsValid() or invItem:HasTag("structure") then	
									table.insert(tempList, v)	
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							end
						end
					invItem:Remove()
					end
				end
			end
			if self.options.checkMa_T % 2 ~= 0 then
				for k,v in pairs(trinkets_all) do
					table.insert(tempList, v)
				end
			end
		elseif self.options.globSwitchDifficulty == 6 then
			if self.options.checkA_OW % 2 == 0 then
				for k,v in pairs(A_OW_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(A_OW_ST_STR) do
					table.insert(tempList, v)
				end
				--[[
				if ThePlayer.prefab ~= "Wickerbottom" then
					table.insert(tempList, "papyrus")
				end
				if ThePlayer.prefab == "Wickerbottom" then
					table.insert(tempList, "book_birds")
					table.insert(tempList, "book_gardening")
					table.insert(tempList, "book_sleep")
					table.insert(tempList, "book_tentacles")
					table.insert(tempList, "book_brimstone")
				end
				if ThePlayer.prefab ~= "Wilson" then
					table.insert(tempList, "resurrectionstatue")
				end 
				--]]
			end
			if self.options.checkA_OW % 2 == 0 and self.options.checkA_L % 2 == 0 then
				for k,v in pairs(A_OW_LT) do
					table.insert(tempList, v)
				end
				--[[
				if ThePlayer.prefab ~= "Webber" then
					table.insert(tempList, "spidereggsack")
				end
				--]]
			end
			if self.options.checkA_OW % 2 ~= 0 then
				for k,v in pairs(A_BASE_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(A_BASE_ST_STR) do
					table.insert(tempList, v)
				end
				--[[
				if ThePlayer.prefab ~= "Webber" then
					table.insert(tempList, "spidereggsack")
				end
				if ThePlayer.prefab ~= "Wickerbottom" then
					table.insert(tempList, "papyrus")
				end
				if ThePlayer.prefab == "Wickerbottom" then
					table.insert(tempList, "book_sleep")
					table.insert(tempList, "book_tentacles")
					table.insert(tempList, "book_brimstone")
				end
				--]]
			end
			if self.options.checkA_OW % 2 ~= 0 and self.options.checkA_L % 2 ~= 0 then
				for k,v in pairs(A_BASE_LT) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkA_C % 2 == 0 then
				for k,v in pairs(A_C_ST) do
					table.insert(tempList, v)
				end
				for k,v in pairs(A_C_ST_STR) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkA_R % 2 == 0 then
				for k,v in pairs(A_R_ST) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkA_R % 2 == 0 and self.options.checkA_L % 2 ~= 0 then
				for k,v in pairs(A_R_LT) do
					table.insert(tempList, v)
				end
			end
			if self.options.checkA_M % 2 ~= 0 then
				for k,v in pairs(ModManager.loadedprefabs) do
					for k,v in pairs(Prefabs[v].deps) do
						invItem = SpawnPrefab(v)
						if invItem ~= nil then
							if TheNet:GetIsServer() then
								if invItem:IsValid() or invItem.components.inventoryitem or invItem:HasTag("structure") then
									table.insert(tempList, v)
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							else
								if invItem:IsValid() or invItem:HasTag("structure") then	
									table.insert(tempList, v)	
								else
									print(v .. ' is not an inventory item or structure, so it will not be included.')
								end	
							end
						end
					invItem:Remove()
					end
				end
			end
			if self.options.checkA_T % 2 == 0 then
				for k,v in pairs(trinkets_all) do
					table.insert(tempList, v)
				end
			end
		end
	end

	if PRNG_def == 2 then
		self:shuffleORIG(tempList)	
	else
		self:shuffleCUST(tempList)
	end
	
	for k = 1, 25 do
		self.globList[k] = tempList[k]
	end
end

return itemTableHandler