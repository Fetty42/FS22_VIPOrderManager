-- Author: Fetty42
-- Date: 20.10.2024
-- Version: 1.4.0.0

local dbPrintfOn = false
local dbInfoPrintfOn = false

local function dbInfoPrintf(...)
	if dbInfoPrintfOn then
    	print(string.format(...))
	end
end

local function dbPrintf(...)
	if dbPrintfOn then
    	print(string.format(...))
	end
end

local function dbPrintHeader(ftName)
	if dbPrintfOn then
    	print(string.format("Call %s: g_currentMission:getIsServer()=%s | g_currentMission:getIsClient()=%s", ftName, g_currentMission:getIsServer(), g_currentMission:getIsClient()))
	end
end

local function Printf(...)
   	print(string.format(...))
end

VIPOrderManager = {}; -- Class

-- update delay
VIPOrderManager.updateDelta = 0;  		-- time since the last update
VIPOrderManager.updateRate = 1000;  	-- milliseconds until next update
VIPOrderManager.InitDone = false

-- Info display
VIPOrderManager.showVIPOrder = 1 -- 0=off, 1=Current, 2=Next
VIPOrderManager.infoDisplayPastTime = 0
VIPOrderManager.infoDisplayMaxShowTime = 20000	-- How long the info is displayed

-- Constants for output
VIPOrderManager.outputStartPoint = {x=0.01, y=0.40} -- links, mitte
VIPOrderManager.outputFontSize = 0.016 -- links, mitte
VIPOrderManager.colors = {}
VIPOrderManager.colors[1]  = {'col_white', {1, 1, 1, 1}}				
VIPOrderManager.colors[2]  = {'col_black', {0, 0, 0, 1}}				
VIPOrderManager.colors[3]  = {'col_grey', {0.7411, 0.7450, 0.7411, 1}}
VIPOrderManager.colors[4]  = {'col_blue', {0.0044, 0.15, 0.6376, 1}}	
VIPOrderManager.colors[5]  = {'col_red', {0.8796, 0.0061, 0.004, 1}}	
VIPOrderManager.colors[6]  = {'col_green', {0.0263, 0.3613, 0.0212, 1}}
VIPOrderManager.colors[7]  = {'col_yellow', {0.9301, 0.7605, 0.0232, 1}}
VIPOrderManager.colors[8]  = {'col_pink', {0.89, 0.03, 0.57, 1}}		
VIPOrderManager.colors[9]  = {'col_turquoise', {0.07, 0.57, 0.35, 1}}	
VIPOrderManager.colors[10] = {'col_brown', {0.1912, 0.1119, 0.0529, 1}}

-- global variables
VIPOrderManager.dir = g_currentModDirectory
VIPOrderManager.modName = g_currentModName

VIPOrderManager.existingProductionOutputs 		= {}	-- 1 --> existing | 2 --> self owned
VIPOrderManager.existingAnimalHusbandryOutputs 	= {}	-- 1 --> existing | 2 --> self owned
VIPOrderManager.VIPOrders 			= {}	-- List of orders {level, entries{[Name] = {fillTypeName, title, quantity, fillLevel, payout, targetStation, isAnimal, neededAgeInMonths}}}

VIPOrderManager.outputLines 		= {}	-- Output lines for the draw() function (text, size, bold, colorId, x, y)
VIPOrderManager.infoHud 			= nil	-- VID Order Info HUD
VIPOrderManager.OrderDlg			= nil

VIPOrderManager.successSound = createSample("success")
loadSample(VIPOrderManager.successSound, "data/sounds/ui/uiSuccess.ogg", false)
VIPOrderManager.failSound = createSample("fail")
loadSample(VIPOrderManager.failSound, "data/sounds/ui/uiFail.ogg", false)



source(Utils.getFilename("MyTools.lua", VIPOrderManager.dir))
source(Utils.getFilename("VIPOrderManagerDefaults.lua", VIPOrderManager.dir))
source(Utils.getFilename("InfoHUD.lua", VIPOrderManager.dir))
source(VIPOrderManager.dir .. "gui/OrderFrame.lua")

function VIPOrderManager:loadMap(name)
    dbPrintHeader("VIPOrderManager:loadMap()")

	if g_currentMission:getIsClient() then
		Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, VIPOrderManager.registerActionEvents);
		Enterable.onRegisterActionEvents = Utils.appendedFunction(Enterable.onRegisterActionEvents, VIPOrderManager.registerActionEvents);
		-- VIPOrderManager.eventName = {};

		FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, VIPOrderManager.saveSettings);
		FSBaseMission.onFinishedLoading = Utils.appendedFunction(FSBaseMission.onFinishedLoading, VIPOrderManager.loadSettings);
		--VIPOrderManager:loadSettings();

		SellingStation.addFillLevelFromTool = Utils.overwrittenFunction(SellingStation.addFillLevelFromTool, VIPOrderManager.sellingStation_addFillLevelFromTool)	

		g_messageCenter:subscribe(MessageType.HOUR_CHANGED, self.onHourChanged, self)
	end
	math.randomseed(getDate("%S")+getDate("%M"))
end;


function VIPOrderManager:onHourChanged(hour)
    dbPrintHeader("VIPOrderManager:onHourChanged()")

	if VIPOrderManager.VIPOrders ~= nil and VIPOrderManager.VIPOrders[1] ~= nil then
		local farmId = g_currentMission.player.farmId;
		local isWarning = false
		local currentVipOrder = VIPOrderManager.VIPOrders[1]

		-- prepare subType to fillType
		local subTypeIndexToFillTypeName

		for _,husbandry in pairs(g_currentMission.husbandrySystem.clusterHusbandries) do
			local placeable = husbandry:getPlaceable()
			if placeable.ownerFarmId == farmId then
				local placeableName = placeable:getName()

				dbPrintf("  - husbandry placeables:  Name=%s | AnimalType=%s | NumOfAnimals=%s | getNumOfClusters=%s", placeableName, husbandry.animalTypeName, placeable:getNumOfAnimals(), placeable:getNumOfClusters())

				for idx, cluster in ipairs(placeable:getClusters()) do
					dbPrintf("    - Cluster:  numAnimals=%s | age=%s | health=%s | subTypeName=%s | subTypeTitle=%s"
					, cluster.numAnimals, cluster.age, cluster.health, g_currentMission.animalSystem.subTypes[cluster.subTypeIndex].name, g_currentMission.animalSystem.subTypes[cluster.subTypeIndex].visuals[1].store.name)

					local orderEntry = currentVipOrder.entries[g_currentMission.animalSystem.subTypes[cluster.subTypeIndex].name]
					if orderEntry ~= nil then
                        dbPrintf("    --> fitting order entry exists with:  quantity=%s | fillLevel=%s | neededAgeInMonths=%s", orderEntry.quantity, orderEntry.fillLevel, orderEntry.neededAgeInMonths)
						if cluster.age == orderEntry.neededAgeInMonths and cluster.health >= 75 then
							local numAninmalsToSell = math.min(orderEntry.quantity - orderEntry.fillLevel, cluster.numAnimals)

							if numAninmalsToSell > 0 then
								local sellPrice = cluster:getSellPrice() * numAninmalsToSell
								
								cluster.numAnimals = cluster.numAnimals - numAninmalsToSell
							
								-- clean up
								if cluster.numAnimals <= 0 then
									table.remove(placeable:getClusters(), idx)
								end

								local msgTxt = string.format(g_i18n:getText("VIPOrderManager_AnimalsDelivered"), numAninmalsToSell, orderEntry.title)
								dbPrintf("  --> " .. msgTxt)
								g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_INFO, msgTxt)
								g_currentMission:addMoney(sellPrice, g_currentMission.player.farmId, MoneyType.SOLD_ANIMALS, true, true);

								orderEntry.fillLevel = orderEntry.fillLevel + numAninmalsToSell

								VIPOrderManager.showVIPOrder = 1;
								VIPOrderManager.infoDisplayPastTime = 0
								VIPOrderManager:UpdateOutputLines()
							end
						end
					end
				end
			end
		end
	end
end


function VIPOrderManager:registerActionEvents()
    -- dbPrintHeader("VIPOrderManager:registerActionEvents()")

	if g_currentMission:getIsClient() then --isOwner
		-- local result, actionEventId = InputBinding.registerActionEvent(g_inputBinding, 'ShowCurrentVIPOrder',self, VIPOrderManager.ShowCurrentVIPOrder ,false ,true ,false ,true)
		local result, actionEventId = g_inputBinding:registerActionEvent('ShowCurrentVIPOrder',InputBinding.NO_EVENT_TARGET, VIPOrderManager.ShowCurrentVIPOrder ,false ,true ,false ,true)
		dbPrintf("Result=%s | actionEventId=%s | g_currentMission:getIsClient()=%s", result, actionEventId, g_currentMission:getIsClient())
		if result and actionEventId then
			g_inputBinding:setActionEventTextVisibility(actionEventId, true)
			g_inputBinding:setActionEventActive(actionEventId, true)
			g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW) -- GS_PRIO_VERY_HIGH, GS_PRIO_HIGH, GS_PRIO_LOW, GS_PRIO_VERY_LOW

			-- table.insert(VIPOrderManager.eventName, actionEventId);
			-- g_inputBinding.events[actionEventId].displayIsVisible = true;
			dbPrintf("Action event inserted successfully")
		end
		local result2, actionEventId2 = g_inputBinding:registerActionEvent('ShowVIPOrderDlg',InputBinding.NO_EVENT_TARGET, VIPOrderManager.ShowVIPOrderDlg ,false ,true ,false ,true)
		dbPrintf("Result2=%s | actionEventId2=%s | g_currentMission:getIsClient()=%s", result2, actionEventId2, g_currentMission:getIsClient())
		if result2 and actionEventId2 then
			g_inputBinding:setActionEventTextVisibility(actionEventId2, true)
			g_inputBinding:setActionEventActive(actionEventId2, true)
			g_inputBinding:setActionEventTextPriority(actionEventId2, GS_PRIO_VERY_LOW) -- GS_PRIO_VERY_HIGH, GS_PRIO_HIGH, GS_PRIO_LOW, GS_PRIO_VERY_LOW

			-- table.insert(VIPOrderManager.eventName, actionEventId2);
			-- g_inputBinding.events[actionEventId2].displayIsVisible = true;
			dbPrintf("Action event inserted successfully")
		end

		if infoHud == nil then
---@diagnostic disable-next-line: lowercase-global
			infoHud = InfoHUD.new()
			infoHud:setVisible(true)
		end
		-- hud:delete()
	end
end


--
function VIPOrderManager:ShowVIPOrderDlg(actionName, keyStatus, arg3, arg4, arg5)
    dbPrintHeader("VIPOrderManager:ShowVIPOrderDlg()")

	VIPOrderManager.OrderDlg = nil
	g_gui:loadProfiles(VIPOrderManager.dir .. "gui/guiProfiles.xml")
	local orderFrame = OrderFrame.new(g_i18n)
	g_gui:loadGui(VIPOrderManager.dir .. "gui/OrderFrame.xml", "OrderFrame", orderFrame)
	VIPOrderManager.OrderDlg = g_gui:showDialog("OrderFrame")

	if VIPOrderManager.OrderDlg ~= nil then
		VIPOrderManager.OrderDlg.target:setVIPOrders(VIPOrderManager.VIPOrders)
		
    end

	-- print("** Start DebugUtil.printTableRecursively() ************************************************************")
	-- print("g_currentMission:")
	-- DebugUtil.printTableRecursively(g_currentMission, ".", 0, 4)
	-- print("** End DebugUtil.printTableRecursively() **************************************************************")

end


-- Payout complete orders less a abort fee for incomplete orders.
function VIPOrderManager:AbortCurrentVIPOrder()
    dbPrintHeader("VIPOrderManager:AbortCurrentVIPOrder()")

	local sumAbortFee, sumPayout = VIPOrderManager:GetSumAbortFeeAndSumPayout()

	-- g_gui:showYesNoDialog({text=g_i18n:getText("tour_text_start"), title="", callback=self.reactToDialog, target=self})
	local msgText = string.format(g_i18n:getText("VIPOrderManager_DlgMsg_AbortCurrentVIPOrder"), g_i18n:formatMoney(sumAbortFee, 0, true), g_i18n:formatMoney(sumPayout, 0, true))
	g_gui:showYesNoDialog({text=msgText, title=g_i18n:getText("VIPOrderManager_DlgTitel_AbortCurrentVIPOrder"), callback=VIPOrderManager.reactToDialog_AbortCurrentVIPOrder, target=self})
end


function VIPOrderManager:reactToDialog_AbortCurrentVIPOrder(yes)
    dbPrintHeader("VIPOrderManager:reactToDialog_AbortCurrentVIPOrder()")

	if yes and VIPOrderManager.VIPOrders[1] ~= nil then
		local sumAbortFee, sumPayout = VIPOrderManager:GetSumAbortFeeAndSumPayout()
	
		playSample(VIPOrderManager.failSound ,1 ,1 ,1 ,0 ,0)

		-- show message and payout
		-- dbPrintf("  sumAbortFee=%s | sumPayout=%s", g_i18n:formatMoney(sumAbortFee, 0, true), g_i18n:formatMoney(sumPayout, 0, true))
		g_currentMission:addMoney(sumPayout, g_currentMission.player.farmId, MoneyType.MISSIONS, true, true);
		g_currentMission:addMoney(sumAbortFee, g_currentMission.player.farmId, MoneyType.MISSIONS, true, true);

		table.remove(VIPOrderManager.VIPOrders, 1)
		VIPOrderManager:RestockVIPOrders()
		if VIPOrderManager.OrderDlg ~= nil then
			VIPOrderManager.OrderDlg.target:setVIPOrders(VIPOrderManager.VIPOrders)
		end
    end
end


function VIPOrderManager:GetSumAbortFeeAndSumPayout()
    dbPrintHeader("VIPOrderManager:GetSumAbortFeeAndSumPayout()")

	local sumPayout = 0
	local sumAbortFee = 0

	for _, vipOrderEntry in pairs(VIPOrderManager.VIPOrders[1].entries) do
		local requiredQuantity = vipOrderEntry.quantity - math.ceil(vipOrderEntry.fillLevel)

		if requiredQuantity > 0 then
			-- incomplete order ==> calculate fee (10%)
			sumAbortFee = sumAbortFee - (vipOrderEntry.payout / 100 * VIPOrderManager.abortFeeInPercent)
		else
			-- complete order ==> calculate payout
			sumPayout = sumPayout + vipOrderEntry.payout
		end
	end
	return sumAbortFee, sumPayout
end


function VIPOrderManager:RestockVIPOrders()
    dbPrintHeader("VIPOrderManager:RestockVIPOrders()")

	if g_currentMission:getIsClient() and g_currentMission.player.farmId > 0 then
		-- new VIPOrder	
		local orderLevel = 0
		if #VIPOrderManager.VIPOrders > 0 then
			orderLevel = VIPOrderManager.VIPOrders[#VIPOrderManager.VIPOrders].level
		end
		while (#VIPOrderManager.VIPOrders < VIPOrderManager.maxVIPOrdersCount) do
			local newEntries = {}
			orderLevel = orderLevel + 1
			dbPrintf("  - Create new VIPOrder with level " .. orderLevel)
			VIPOrderManager:calculateAndFillOrder(newEntries, orderLevel)
			table.insert(VIPOrderManager.VIPOrders, {level = orderLevel, entries = newEntries})
		end
		self.showVIPOrder = 1
		self.infoDisplayPastTime = 0
		VIPOrderManager:UpdateOutputLines()
	end
	-- print("** Start DebugUtil.printTableRecursively() ************************************************************")
	-- DebugUtil.printTableRecursively(VIPOrderManager.VIPOrders, ".", 0, 3)
	-- print("** End DebugUtil.printTableRecursively() **************************************************************")
end


function VIPOrderManager:GetExistingProductionAndAnimalHusbandryOutputs()
    dbPrintHeader("VIPOrderManager:GetExistingProductionAndAnimalHusbandryOutputs()")

	VIPOrderManager.existingProductionOutputs = {}
	VIPOrderManager.existingAnimalHusbandryOutputs = {}
	local farmId = g_currentMission.player.farmId;
	local isMilk = 0
	local isLiquidManure = 0
	local isManure = 0
	local foundAnimalTypeNames = {}
	
	-- look for own husbandries
	dbPrintf("  - Num cluster Husbandries: %s", MyTools:getCountElements(g_currentMission.husbandrySystem.clusterHusbandries))
	for _,husbandry in pairs(g_currentMission.husbandrySystem.clusterHusbandries) do
		local placeable = husbandry:getPlaceable()
		local selfOwned = placeable.ownerFarmId == farmId

		local name = placeable:getName()
		local specHusbandryLiquidManure = placeable.spec_husbandryLiquidManure
		local specHusbandryMilk = placeable.spec_husbandryMilk
		local specHusbandryStraw = placeable.spec_husbandryStraw
		local isManureActive = false
		if specHusbandryStraw ~= nil then
			isManureActive = specHusbandryStraw.isManureActive
		end

		dbPrintf("  - husbandry placeables:  Name=%s | selfOwned=%s | AnimalType=%s | specMilk=%s | specLiquidManure=%s | specStraw=%s | isManureActive=%s", name, selfOwned, husbandry.animalTypeName, tostring(specHusbandryMilk), tostring(specHusbandryLiquidManure), tostring(specHusbandryStraw), isManureActive)

		-- remember for later to list all animal subtypes
		foundAnimalTypeNames[husbandry.animalTypeName] = math.max(foundAnimalTypeNames[husbandry.animalTypeName] or 0, selfOwned and 2 or 1)

		isMilk = specHusbandryMilk ~= nil and math.max(isMilk, selfOwned and 2 or 1) or isMilk
		isLiquidManure = specHusbandryLiquidManure ~= nil and math.max(isLiquidManure, selfOwned and 2 or 1) or isLiquidManure
		isManure = isManureActive and math.max(isManure, selfOwned and 2 or 1) or isManure
	end

	-- insert animal output products
	if isMilk > 0 then
		VIPOrderManager.existingAnimalHusbandryOutputs.MILK = isMilk	
	end
	if isLiquidManure > 0 then
		VIPOrderManager.existingAnimalHusbandryOutputs.LIQUIDMANURE = isLiquidManure	
	end
	if isManure > 0 then
		VIPOrderManager.existingAnimalHusbandryOutputs.MANURE = isManure	
	end
	if foundAnimalTypeNames["CHICKEN"] ~= nil then
		VIPOrderManager.existingAnimalHusbandryOutputs.EGG = foundAnimalTypeNames["CHICKEN"]
	end
	if foundAnimalTypeNames["SHEEP"] ~= nil then
		VIPOrderManager.existingAnimalHusbandryOutputs.WOOL = foundAnimalTypeNames["SHEEP"]
	end
	if foundAnimalTypeNames["GOAT"] ~= nil then
		VIPOrderManager.existingAnimalHusbandryOutputs.GOATMILK = foundAnimalTypeNames["GOAT"]
	end

	-- insert animal fill types
	for i, fillTypeIdx in pairs(g_fillTypeManager:getFillTypesByCategoryNames("ANIMAL HORSE")) do
        local fillType = g_fillTypeManager:getFillTypeByIndex(fillTypeIdx)
        local animalSubType = g_currentMission.animalSystem.fillTypeIndexToSubType[fillTypeIdx]

		if animalSubType ~= nil then
			local animalName = g_currentMission.animalSystem.typeIndexToName[animalSubType.typeIndex]
			if foundAnimalTypeNames[animalName] ~= nil then
				VIPOrderManager.existingAnimalHusbandryOutputs[fillType.name] = foundAnimalTypeNames[animalName]
			end
		end
	end

	-- look for own productions and insert output products
	dbPrintf("")
	dbPrintf("  - Num Production Points: %s", g_currentMission.productionChainManager:getNumOfProductionPoints())
	-- if g_currentMission.productionChainManager.farmIds[farmId] ~= nil and g_currentMission.productionChainManager.farmIds[farmId].productionPoints ~= nil then
	-- 	for _, productionPoint in pairs(g_currentMission.productionChainManager.farmIds[farmId].productionPoints) do
	if g_currentMission.productionChainManager.productionPoints ~= nil then
		for _, productionPoint in pairs(g_currentMission.productionChainManager.productionPoints) do
			
			local selfOwned = productionPoint:getOwnerFarmId() == farmId
			local name = productionPoint.owningPlaceable:getName()
			dbPrintf("  - Production: Name=%s  | farmId=%s | selfOwned=%s", name, productionPoint:getOwnerFarmId(), selfOwned)
			
			for fillTypeId, fillLevel in pairs(productionPoint.storage.fillLevels) do
				local fillTypeId = fillTypeId
				local fillTypeName = g_currentMission.fillTypeManager.fillTypes[fillTypeId].name
				local fillTypeTitle = g_currentMission.fillTypeManager.fillTypes[fillTypeId].title
				local isInput = false
				
				-- prüfen ob input type
				if productionPoint.inputFillTypeIds[fillTypeId] ~= nil then
					isInput = productionPoint.inputFillTypeIds[fillTypeId]
				end
				
				for _, production in pairs(productionPoint.activeProductions) do
					for _, input in pairs(production.inputs) do
						-- status 3 = läuft nicht weil ausgang voll
						if input.type == fillTypeId then
							isInput = true
						end
					end
				end
				if not isInput then
					dbPrintf("    - fillTypeName=%s | fillTypeTitle=%s | isInput=%s", fillTypeName, fillTypeTitle, isInput)
					VIPOrderManager.existingProductionOutputs[fillTypeName] = math.max(VIPOrderManager.existingProductionOutputs[fillTypeName] or 0, selfOwned and 2 or 1)
				end
			end
		end
	end

	-- if dbPrintfOn then
	-- 	DebugUtil.printTableRecursively(VIPOrderManager.existingAnimalHusbandryOutputs, ".", 0, 3)
	-- 	DebugUtil.printTableRecursively(VIPOrderManager.existingProductionOutputs, ".", 0, 3)
	-- end
end


function VIPOrderManager:calculateAndFillOrder(VIPOrder, orderLevel)
    dbPrintHeader("VIPOrderManager:calculateAndFillOrder()")

	local relevantFillTypes = {};
	VIPOrderManager:GetRelevantFillTypes(relevantFillTypes)

	-- set the special corrections faktors depending on the current order level and the own field area
	-- for level=1, 20, 1 do
	-- 	local factorCount =     ((1 + level*0.04)-0.04)
	-- 	local factorQuantity =  ((1 + level*level*0.005) - 0.005)
	-- 	local factorPayout =   1/ ((1 + level*0.05) - 0.05)
	-- 	dbPrintf("Level %2i: factorCount=%f | factorQuantity=%f | factorPayout=%f",
	-- 		level, factorCount, factorQuantity, factorPayout)
	-- end

	
	local specCorFactorCount = orderLevel^(1/4)
	local specCorFactorQuantity = orderLevel^(1/3)
	local specCorFactorPayout = (1.0 / (specCorFactorQuantity*specCorFactorCount))*1.1
	dbPrintf("Create new VIP Order: Level %s", orderLevel)
	dbPrintf("  Initial basic correction factors:")
	dbPrintf("    - Count factor    = %.2f", specCorFactorCount)
	dbPrintf("    - Quantity factor = %.2f", specCorFactorQuantity)
	dbPrintf("    - Payout factor   = %.2f", specCorFactorPayout)

	local ownFieldSizeFactor = math.max(1, VIPOrderManager.ownFieldArea^(1/2))
	dbPrintf("  Basic correction factors adjusted by the size of the own fields:")
	dbPrintf("    - own field size        = " .. VIPOrderManager.ownFieldArea)
	dbPrintf("    - own field size factor = " .. ownFieldSizeFactor)
	dbPrintf("    - adjusted quantity factor from %.2f to %.2f", specCorFactorQuantity, specCorFactorQuantity * ownFieldSizeFactor)
	dbPrintf("    - adjusted payout factor from   %.2f to %.2f", specCorFactorPayout, (1.0 / (specCorFactorQuantity*specCorFactorCount))*1.1)
	local specCorFactorQuantity = specCorFactorQuantity * ownFieldSizeFactor
	local specCorFactorPayout = (1.0 / (specCorFactorQuantity*specCorFactorCount))*1.1

	-- if necessary overright by Correction factors for easier beginning
	if VIPOrderManager.orderLevelCorrectionFactors[orderLevel] ~= nil then
		specCorFactorCount = VIPOrderManager.orderLevelCorrectionFactors[orderLevel][1]
		specCorFactorQuantity = VIPOrderManager.orderLevelCorrectionFactors[orderLevel][2]
		specCorFactorPayout = VIPOrderManager.orderLevelCorrectionFactors[orderLevel][3]
		dbPrintf("  If necessary overright by Correction factors for easier beginning:")
		dbPrintf("    - Count factor    = %.2f", specCorFactorCount)
		dbPrintf("    - Quantity factor = %.2f", specCorFactorQuantity)
		dbPrintf("    - Payout factor   = %.2f", specCorFactorPayout)
	end

	-- create random order items
	local countFillTypes = #relevantFillTypes
	local countOrderItems = math.floor(math.random(VIPOrderManager.countOrderItemsRange.min, VIPOrderManager.countOrderItemsRange.max) * specCorFactorCount + 0.5)
	dbPrintf("  Calculate order item count:")
	dbPrintf("    - min count      = " .. VIPOrderManager.countOrderItemsRange.min)
	dbPrintf("    - max count      = " .. VIPOrderManager.countOrderItemsRange.max)
	dbPrintf("    - Count factor   = " .. specCorFactorCount)
	dbPrintf("    ==> Count order items = " .. countOrderItems)

	-- local maxLimitedOrderItems = math.floor(orderLevel / 100 * VIPOrderManager.isLimitedPercentage)
	local activeLimits ={}
	-- dbPrintf("  Max allowed limited order items: %s percent from %s = %s", VIPOrderManager.isLimitedPercentage, orderLevel, maxLimitedOrderItems)
	
	local i = 0
	while (i < countOrderItems) do
		i = i + 1
		dbPrintf(string.format("  %s. Order Item:", i))

		-- dice group name
		local groupNameSetting = nil
		repeat
			local isNextTryForGroup = false
			groupNameSetting = VIPOrderManager.groupNameSettings[math.random(1, #VIPOrderManager.groupNameSettings)]

			local random = math.random() * 100
			isNextTryForGroup = random > groupNameSetting.probability
	
		until(not isNextTryForGroup)

		dbPrintf("  - diced group: %s", groupNameSetting.groupName)


		-- dice fill type
		local fillType = nil
		local relevantFillType = nil
		local numPrioTrysForGroup = VIPOrderManager.numPrioTrysForGroup
		repeat
			local isNextTry = false
			relevantFillType = relevantFillTypes[math.random(1, countFillTypes)]
			local ftConfig = relevantFillType.ftConfig

			-- is animal but not first subtype
			if not isNextTry and relevantFillType.isAnimal then
			 	if relevantFillType.animalTypeCount == 1 then
					-- select animal sub type to be used
					local searchAnimalTypeIndex = relevantFillType.animalTypeIndex
					repeat
						relevantFillType = relevantFillTypes[math.random(1, countFillTypes)]
					until(relevantFillType.isAnimal == nil or not relevantFillType.isAnimal or relevantFillType.animalTypeIndex ~= searchAnimalTypeIndex)
					ftConfig = relevantFillType.ftConfig
				else					
					dbPrintf("    - animal %s (%s) is not first subtype of '%s '(Count=%s)", relevantFillType.name, relevantFillType.title, relevantFillType.animalTypeName, relevantFillType.animalTypeCount)
					isNextTry = true
				end
			end

			-- is not usable
			if not isNextTry and not relevantFillType.isUsable ~= nil and not relevantFillType.isUsable then
				isNextTry = true
				dbPrintf("    - ft  %s (%s) is not usable because: %s", relevantFillType.name, relevantFillType.title, relevantFillType.notUsableMsg)
			end
			
			-- is order-level high enough?
			if not isNextTry and ftConfig.minOrderLevel > orderLevel then
				isNextTry = true
				dbPrintf("    - ft  %s (%s) requireds a minimum order-level from %s. The current order-level is %s --> isNextTry=%s", relevantFillType.name, relevantFillType.title, ftConfig.minOrderLevel, orderLevel, isNextTry)	
			end
			
			-- animal orders wished?
			if not isNextTry and not VIPOrderManager.isAnimalOrdersWished and relevantFillType.isAnimal then
				isNextTry = true
				dbPrintf("    - ft  %s (%s) is animal but animals are not wished --> isNextTry=%s", relevantFillType.name, relevantFillType.title, isNextTry)	
			end

			-- Exists probability
			if not isNextTry and ftConfig.probability ~= nil and ftConfig.probability < 100 then
				local probability = ftConfig.probability
				local random = math.random() * 100
				isNextTry = random > probability
				dbPrintf("    - ft  %s (%s) has probability: probability=%s, random=%s --> isNextTry=%s", relevantFillType.name, relevantFillType.title, probability, random, isNextTry)	
			end

			-- limited group?
			if not isNextTry and ftConfig.groupName ~= nil and VIPOrderManager.limitedGroupsPercent[ftConfig.groupName] ~= nil then
                if activeLimits[ftConfig.groupName] == nil then
                    activeLimits[ftConfig.groupName] = math.max(1, math.floor(countOrderItems / 100 * VIPOrderManager.limitedGroupsPercent[ftConfig.groupName]))
                end

                dbPrintf("      - Existing limited order for group '%s': %s percent from %s (min 1) --> even more available: %s", ftConfig.groupName, VIPOrderManager.limitedGroupsPercent[ftConfig.groupName], countOrderItems, activeLimits[ftConfig.groupName])
				if activeLimits[ftConfig.groupName] <= 0 then
					isNextTry = true
                    dbPrintf("      - ft %s (%s) is limited by group '%s' --> next try", relevantFillType.name, relevantFillType.title, ftConfig.groupName)
				else
                    activeLimits[ftConfig.groupName] = activeLimits[ftConfig.groupName] -1
                    dbPrintf("      --> choose limited filltype: %s (%s)", relevantFillType.name, relevantFillType.title)
                end
            end

			if not isNextTry and groupNameSetting.groupName ~= ftConfig.groupName then
				if numPrioTrysForGroup > 0 then
				numPrioTrysForGroup = numPrioTrysForGroup - 1
				dbPrintf("  -> Searching for '%s', diced %s (%s) = '%s' -> try again", groupNameSetting.groupName, relevantFillType.name, relevantFillType.title, ftConfig.groupName)
				isNextTry = true
				else
					dbPrintf("  -> Last searching for '%s' failed!", groupNameSetting.groupName)
				end
			end

		until(not isNextTry)

		local quantityCorrectionFactor = 1
		if relevantFillType.ftConfig.quantityCorrectionFactor ~= nil then
			quantityCorrectionFactor = relevantFillType.ftConfig.quantityCorrectionFactor
		end
		
		dbPrintf("    - FillType: %s (%s)| groupName = %s | filltype quantity factor = %.2f", relevantFillType.name, relevantFillType.title, relevantFillType.ftConfig.groupName, quantityCorrectionFactor)

		local randomQuantityFaktor = math.random(VIPOrderManager.quantityFactor.min, VIPOrderManager.quantityFactor.max) * specCorFactorQuantity
		local randomPayoutFactor = math.random(VIPOrderManager.payoutFactor.min, VIPOrderManager.payoutFactor.max) * specCorFactorPayout / quantityCorrectionFactor
		local orderItemQuantity = math.floor(randomQuantityFaktor * 1000 / relevantFillType.priceMax * quantityCorrectionFactor)
		
		-- special animal calculations
		local orderItemNeededAgeInMonths = nil
		if relevantFillType.isAnimal then
			orderItemNeededAgeInMonths = VIPOrderManager:getRandomNeededAgeInMonth(relevantFillType.name)
			--
            -- relevantFillType.priceMax = VIPOrderManager:GetAnimalSellPriceByFillTypeIdxAndAge(g_fillTypeManager:getFillTypeIndexByName(relevantFillType.name), orderItemNeededAgeInMonths)
			-- orderItemQuantity = math.floor(randomQuantityFaktor * 1000 / relevantFillType.priceMax * quantityCorrectionFactor)   -- keine Verwendung von SellPrice, da zu Sprunghaft!
		end

		dbPrintf("    - final quantity factor = %.2f", randomQuantityFaktor)
		dbPrintf("    - final payout factor   = %.2f", randomPayoutFactor)
		

		if orderItemQuantity > 1000 then
			orderItemQuantity = math.floor(orderItemQuantity / 1000) * 1000
		elseif orderItemQuantity > 100 then
			orderItemQuantity = math.floor(orderItemQuantity / 100) * 100
		elseif orderItemQuantity > 10 then
			orderItemQuantity = math.floor(orderItemQuantity / 10) * 10
		end
		dbPrintf("    ==> Quantity = %.2f * 1000 / %.2f * %.2f = %s", randomQuantityFaktor, relevantFillType.priceMax, quantityCorrectionFactor, orderItemQuantity)
		
		local orderItemPayout = math.floor(orderItemQuantity * relevantFillType.priceMax * randomPayoutFactor/100)*100
		dbPrintf("    ==> Payout   = %.2f * %.2f * %.2f = %s", orderItemQuantity, relevantFillType.priceMax, randomPayoutFactor, orderItemPayout)

		-- target station
		local orderItemTargetStation = nil
		if #relevantFillType.acceptingStations > 0 then
			orderItemTargetStation = relevantFillType.acceptingStations[math.random(1, #relevantFillType.acceptingStations)]
			dbPrintf("    ==> target station = %s", orderItemTargetStation.owningPlaceable:getName())
		end

		if VIPOrder[relevantFillType.name] ~= nil then
			if VIPOrderManager.allowSumQuantitySameFT and not relevantFillType.isAnimal then
				-- Summ double entries
				VIPOrder[relevantFillType.name].quantity = VIPOrder[relevantFillType.name].quantity + orderItemQuantity/2
				VIPOrder[relevantFillType.name].payout = VIPOrder[relevantFillType.name].payout + orderItemPayout/2
				dbPrintf("  Double --> Sum order items")
			else
				i = i - 1 	-- try again
				dbPrintf("  Double --> discard current order item and try again")
			end
		else
			local orderItemTitle = relevantFillType.title
			if relevantFillType.isAnimal then
				orderItemTitle = VIPOrderManager:GetAnimalTitleByFillTypeIdx(g_fillTypeManager:getFillTypeIndexByName(relevantFillType.name), orderItemNeededAgeInMonths)
			end
			
			VIPOrder[relevantFillType.name] = {fillTypeName=relevantFillType.name, title=orderItemTitle, quantity=orderItemQuantity, fillLevel=0, payout=orderItemPayout, targetStation=orderItemTargetStation, isAnimal=relevantFillType.isAnimal, neededAgeInMonths=orderItemNeededAgeInMonths}
		end
	end
end


-- animalSubType.sellPrice.keyframes[]
--  [1] = verkaufspreis
--  time = ab alter
function VIPOrderManager:GetAnimalSellPriceByFillTypeIdxAndAge(fillTypeIdx, neededAgeInMonths)
	local animalSubType = g_currentMission.animalSystem.fillTypeIndexToSubType[fillTypeIdx]
	local animalSellPrice = 0
	local animalAge = neededAgeInMonths == nil and 0 or neededAgeInMonths
	
	for i, sellPriceKeyframe in pairs(animalSubType.sellPrice.keyframes) do
		if animalAge >= sellPriceKeyframe.time then
			animalSellPrice = sellPriceKeyframe[1]
		end
	end
	return animalSellPrice
end

-- animalSubType.input.food.keyframes[]
--  [1] = menge futter
--  time = ab alter
function VIPOrderManager:GetAnimalFoodConsumptionPerMonthByFillTypeIdxAndAge(fillTypeIdx, neededAgeInMonths)
	local animalSubType = g_currentMission.animalSystem.fillTypeIndexToSubType[fillTypeIdx]
	local animalFoodConsumptionPerMonth = 0
	local animalAge = neededAgeInMonths == nil and 0 or neededAgeInMonths
	
	for i, foodKeyframe in pairs(animalSubType.input.food.keyframes) do
		if animalAge >= foodKeyframe.time then
			animalFoodConsumptionPerMonth = foodKeyframe[1]
		end
	end
	return animalFoodConsumptionPerMonth
end


function VIPOrderManager:GetAnimalFoodConsumptionPerMonthStringByFillTypeIdx(fillTypeIdx)
	local animalSubType = g_currentMission.animalSystem.fillTypeIndexToSubType[fillTypeIdx]
	local animalFoodConsumptionPerMonth = 0
	local animalAge = neededAgeInMonths == nil and 0 or neededAgeInMonths
	
	local output = "Monthly Food Consumption per Age:"
	for i, foodKeyframe in pairs(animalSubType.input.food.keyframes) do
		local str = string.format("%s->%s | ", foodKeyframe.time, foodKeyframe[1])
		output = output .. str
	end
	return output
end



function VIPOrderManager:getRandomNeededAgeInMonth(fillTypeName)
	local animalSubType = g_currentMission.animalSystem.nameToSubType[fillTypeName]
    local possibleAges = {}

	while #possibleAges == 0 do
		local desiredDiff = math.random(VIPOrderManager.rangeAnimalAgeDifInMonths.min, VIPOrderManager.rangeAnimalAgeDifInMonths.max)
		for i, visual in pairs(animalSubType.visuals) do
			if visual.store.canBeBought then
                local minAge = visual.minAge
                if #animalSubType.visuals > i then
                    local nextMinAge = animalSubType.visuals[i+1].minAge
                    local possibleMaxDiff = nextMinAge - minAge - 1

                    if possibleMaxDiff >= desiredDiff then
                        table.insert(possibleAges, minAge + desiredDiff)
                    end
                else
                    table.insert(possibleAges, minAge + desiredDiff)
                end
            end
		end
	end

	local neededAge = possibleAges[math.random(1, #possibleAges)]
	return neededAge
end


function VIPOrderManager:CalculateOwnFieldArea()
    dbPrintHeader("VIPOrderManager:CalculateOwnFieldArea()")

	-- Calculate full farmland
	local farmlands = g_farmlandManager:getOwnedFarmlandIdsByFarmId(g_currentMission.player.farmId)
	
	local fieldAreaOverall = 0.0
	for i, id in pairs(farmlands) do
		local farmland = g_farmlandManager:getFarmlandById(id)

		-- Fields area
		local fieldCount = 0
		local fieldAreaSum = 0.0
        local fields = g_fieldManager.farmlandIdFieldMapping[farmland.id]
		if fields ~= nil then
			for fieldIndex, field in pairs(fields) do
				fieldCount = fieldCount + 1
				fieldAreaSum = fieldAreaSum + field.fieldArea
				dbPrintf("  Field: fieldId=%s | name=%s | fieldArea =%s", field.fieldId, field.name, g_i18n:formatArea(field.fieldArea, 2))
			end
		end

		if fieldCount > 0 and fieldAreaSum <= 0.01 and farmland.totalFieldArea ~= nil then
			dbPrintf("  sum single field sizes to small --> using farmland.totalFieldArea")
			fieldAreaSum = farmland.totalFieldArea
		end

		fieldAreaOverall = fieldAreaOverall + fieldAreaSum

		dbPrintf("  --> %s. Owned Farmland: id=%s | FieldCount=%s | FieldAreaSum=%s", i, farmland.id, fieldCount, g_i18n:formatArea(fieldAreaSum, 2))
	end
	dbPrintf("  ==> Field Area Overall: %s", g_i18n:formatArea(fieldAreaOverall, 2))

	-- if fieldAreaOverall > 0.01 then
	-- 	return math.ceil(fieldAreaOverall*100)/100
	-- else
	-- 	return 0
	-- end

	return MyTools:round(fieldAreaOverall, 2)
end


function VIPOrderManager:GetFillTypeConfig(possibleFT)
    -- dbPrintHeader("VIPOrderManager:GetFillTypeConfig()")

	local ftName = possibleFT.name
	local isAnimal = possibleFT.isAnimal
	local ftConfig = VIPOrderManager.ftConfigs[ftName]

	if ftConfig == nil then
		if g_fruitTypeManager:getFruitTypeByName(ftName) ~= nil and not isAnimal then
			ftConfig = VIPOrderManager.ftConfigs["DEFAULT_FRUITTYPE"]
			dbInfoPrintf("VIPOrderManager - '%s': fruit type without config. Take config 'DEFAULT_FRUITTYPE'", ftName)
		elseif isAnimal then
			local configName = "ANIMALTYPE_" .. string.upper(possibleFT.animalTypeName)
			if VIPOrderManager.ftConfigs[configName] == nil then
				configName = "DEFAULT_ANIMALTYPE"
				if possibleFT.animalTypeCount == 1 then -- print only once
					dbInfoPrintf("VIPOrderManager - '%s': animal type without config. Take config 'DEFAULT_ANIMALTYPE'", animalTypeName)
				end
			end
			
			ftConfig = VIPOrderManager.ftConfigs[configName]
		else
			ftConfig = VIPOrderManager.ftConfigs["DEFAULT_FILLTYPE"]
			dbInfoPrintf("VIPOrderManager - '%s': fill type without config. Take config 'DEFAULT_FILLTYPE'", ftName)
		end

		VIPOrderManager.ftConfigs[ftName] = ftConfig
	end

	local ftConfigCopy = MyTools:deepcopy(ftConfig)
	ftConfigCopy.minOrderLevel = ftConfig.minOrderLevel[1]
	ftConfigCopy.probability = ftConfig.probability[1]
	ftConfigCopy.msg = {}

	if VIPOrderManager.defaultGroupNameOverwriting[ftName] ~= nil then
		ftConfigCopy.groupName = VIPOrderManager.defaultGroupNameOverwriting[ftName]
	end


	-- ftconfig overwrite for minOrderLevel and probability if fitting AnimalHusbandry already exists
	if VIPOrderManager.existingAnimalHusbandryOutputs[ftName] and (possibleFT.isUsable == nil or possibleFT.isUsable) then
		local existingOrSelfOwnedLevel = VIPOrderManager.existingAnimalHusbandryOutputs[ftName]

		if ftConfig.minOrderLevel ~= nil and ftConfig.minOrderLevel[2] ~= nil and ftConfig.minOrderLevel[3] ~= nil then
			local msg
			ftConfigCopy.minOrderLevel = ftConfig.minOrderLevel[existingOrSelfOwnedLevel+1]
			if existingOrSelfOwnedLevel == 1 then
				msg = string.format("Decrease 'minOrderLevel' as animal husbandry already exists but is not owned: %s --> %s", ftConfig.minOrderLevel[1], ftConfigCopy.minOrderLevel)
			else
				msg = string.format("Decrease 'minOrderLevel' as animal husbandry is already owned: %s --> %s", ftConfig.minOrderLevel[1], ftConfigCopy.minOrderLevel)
			end
			dbPrintf("    - " .. msg)
			table.insert(ftConfigCopy.msg, msg)
		end

		if ftConfig.probability  ~= nil and ftConfig.probability[2] ~= nil and ftConfig.probability[3] ~= nil then
			local msg
			ftConfigCopy.probability = ftConfig.probability[existingOrSelfOwnedLevel+1]
			if existingOrSelfOwnedLevel == 1 then
				msg = string.format("Increase 'Probability' as animal husbandry already exists but is not owned: %s --> %s", ftConfig.probability[1], ftConfigCopy.probability)
			else
				msg = string.format("Increase 'Probability' as animal husbandry is already owned: %s --> %s", ftConfig.probability[1], ftConfigCopy.probability)
			end
			dbPrintf("    - " .. msg)
			table.insert(ftConfigCopy.msg, msg)
		end
	end

	-- ftconfig overwrite for minOrderLevel and probability if fitting Production already exists
	if VIPOrderManager.existingProductionOutputs[ftName] and ftConfigCopy.msg[1] == nil and (possibleFT.isUsable == nil or possibleFT.isUsable) then
		local existingOrSelfOwnedLevel = VIPOrderManager.existingProductionOutputs[ftName]

		if ftConfig.minOrderLevel ~= nil and ftConfig.minOrderLevel[2] ~= nil and ftConfig.minOrderLevel[3] ~= nil then
			local msg
			ftConfigCopy.minOrderLevel = ftConfig.minOrderLevel[existingOrSelfOwnedLevel+1]
			if existingOrSelfOwnedLevel == 1 then
				msg = string.format("Decrease 'minOrderLevel' as production already exists but is not owned: %s --> %s", ftConfig.minOrderLevel[1], ftConfigCopy.minOrderLevel)
			else
				msg = string.format("Decrease 'minOrderLevel' as production is already owned: %s --> %s", ftConfig.minOrderLevel[1], ftConfigCopy.minOrderLevel)
			end
			dbPrintf("    - " .. msg)
			table.insert(ftConfigCopy.msg, msg)
		end

		if ftConfig.probability  ~= nil and ftConfig.probability[2] ~= nil and ftConfig.probability[3] ~= nil then
			local msg
			ftConfigCopy.probability = ftConfig.probability[existingOrSelfOwnedLevel+1]
			if existingOrSelfOwnedLevel == 1 then
				msg = string.format("Increase 'Probability' as production already exists but is not owned: %s --> %s", ftConfig.probability[1], ftConfigCopy.probability)
			else
				msg = string.format("Increase 'Probability' as production is already owned: %s --> %s", ftConfig.probability[1], ftConfigCopy.probability)
			end
			dbPrintf("    - " .. msg)
			table.insert(ftConfigCopy.msg, msg)
		end
	end

	-- ftconfig overwrite for quantityCorrectionFactor if FS22_MaizePlus mod is present and loaded
	local isMaizePlus = g_modManager:getModByName("FS22_MaizePlus") ~= nil and g_modIsLoaded["FS22_MaizePlus"]
	local isTerraLifePlus = g_modManager:getModByName("FS22_TerraLifePlus") ~= nil and g_modIsLoaded["FS22_TerraLifePlus"] and VIPOrderManager:isTerraLife()
	if isMaizePlus or isTerraLifePlus then
		if ftConfig.quantityCorrectionFactorMaizePlus ~= nil then
			ftConfigCopy.quantityCorrectionFactor = ftConfig.quantityCorrectionFactorMaizePlus
			local msg = string.format("Overwrite 'quantityCorrectionFactor' as MOD MaizePlus/TerraLifePlus is in use: %s --> %s", ftConfig.quantityCorrectionFactor, ftConfigCopy.quantityCorrectionFactor)
			dbPrintf("    - " .. msg)
			table.insert(ftConfigCopy.msg, msg)
		end

		if ftConfig.probabilityMaizePlus ~= nil then
			local msg = string.format("Overwrite 'probability' as MOD MaizePlus/TerraLifePlus is in use: %s --> %s", ftConfigCopy.probability, ftConfig.probabilityMaizePlus)
			ftConfigCopy.probability = ftConfig.probabilityMaizePlus
			dbPrintf("    - " .. msg)
			table.insert(ftConfigCopy.msg, msg)
		end
	end

	return ftConfigCopy
end


function VIPOrderManager:GetRelevantFillTypes(relevantFillTypes)
	dbPrintHeader("VIPOrderManager:GetRelevantFillTypes()")

	VIPOrderManager.ownFieldArea = VIPOrderManager:CalculateOwnFieldArea()
	VIPOrderManager:GetExistingProductionAndAnimalHusbandryOutputs()


	local possibleFillTypes = {}
	VIPOrderManager:addAllSellableFillTypes(possibleFillTypes)
	VIPOrderManager:addAllAnimalFillTypes(possibleFillTypes)

	if dbPrintfOn then
		dbPrintf("  Possible filltypes:")
		for index, possibleFT in pairs(possibleFillTypes) do
			local tempNameOutput = string.format("%s (%s)", possibleFT.name, possibleFT.title)
			dbPrintf("  - %-50s: priceMax=%5.3f | pricePerLiter=%5.3f | literPerSqm=%5.3f| Stations=%s", tempNameOutput, possibleFT.priceMax, possibleFT.pricePerLiter, possibleFT.literPerSqm, possibleFT.acceptingStationsString)
		end
		dbPrintf("")
	end

	-- Validate FillTypes	
	dbPrintf("Validating filltypes:")
	for index, possibleFT in pairs(possibleFillTypes) do
		dbPrintf("  Validate FillTypes: " .. index .. " --> " .. possibleFT.name .. " (" .. possibleFT.title .. ")")
		local notUsableWarning = nil
		local tempNameOutput = string.format("%s (%s)", possibleFT.name, possibleFT.title)
		local defaultWarningText = string.format("  - %-50s | pricePerLiterMax=%f | ", tempNameOutput, possibleFT.priceMax)
		local ftConfig = VIPOrderManager:GetFillTypeConfig(possibleFT)
		possibleFT.ftConfig = ftConfig

		-- not allowed
		if notUsableWarning == nil and not ftConfig.isAllowed then
			notUsableWarning = "Not usable, because is not allowed per definition"
        end

		-- not allowed because probability == 0
		if notUsableWarning == nil and ftConfig.probability == 0 then
			notUsableWarning = "Not usable, because probability = 0"
        end


		-- existing fruittype is not useable
		local fruitType = g_fruitTypeManager:getFruitTypeByName(possibleFT.name)
		if notUsableWarning == nil and fruitType ~= nil and not fruitType.shownOnMap then
			notUsableWarning = string.format("Not usable, because the current map does not support this existing fruittype (not shown on map)")
        end

		-- needed original fruit type not available on this map
		local neededFruitType = ftConfig.neededFruittype
		if notUsableWarning == nil and neededFruitType ~= nil and g_fruitTypeManager:getFruitTypeByName(neededFruitType) == nil then
			notUsableWarning = string.format("Not usable, because needed fruittype (%s) is missing", neededFruitType)
		end

		-- not sell able
		if notUsableWarning == nil and not possibleFT.showOnPriceTable then
            notUsableWarning = "Not usable, because not show on price list"
        end

		--  without sell price
		if notUsableWarning == nil and possibleFT.priceMax <= 0 then
			if VIPOrderManager.fillTypesNoPriceList[possibleFT.name] == 1 and possibleFT.pricePerLiter > 0 then
				possibleFT.priceMax = possibleFT.pricePerLiter
			else
	            notUsableWarning = "Not usable, because no or negative price per liter defined"
			end
        end

		possibleFT.isUsable = true
		possibleFT.notUsableMsg = ""
		if notUsableWarning ~= nil then
            dbPrintf(defaultWarningText .. notUsableWarning)
			possibleFT.isUsable = false
			possibleFT.notUsableMsg = notUsableWarning
		end
		table.insert(relevantFillTypes, possibleFT)
	end
	
	-- output relevant filltypes
	dbPrintf("")
	dbPrintf("Relevant filltypes:")
	for _, v in pairs(relevantFillTypes) do
		local tempNameOutput = string.format("%s (%s)", v.name, v.title)
		dbPrintf("  - %-50s | isUsable=%-5s | price=%9s | minOrderLevel=%s | probability=%3s | Stations=%s | ConfigMsg=%s | notUsableMsg=%s", tempNameOutput, v.isUsable, string.format("%.4f", v.priceMax), v.ftConfig.minOrderLevel, v.ftConfig.probability, tostring(v.acceptingStationsString), v.ftConfig.msg, v.notUsableMsg)
	end
	dbPrintf("")
	dbPrintf("")
end


function VIPOrderManager:addAllSellableFillTypes(possibleFillTypes)
    dbPrintHeader("VIPOrderManager:addAllSellableFillTypes()")

	for _, station in pairs(g_currentMission.storageSystem.unloadingStations) do
		local placeable = station.owningPlaceable
        local production = placeable.spec_productionPoint
		dbPrintf("Station: getName=%s | typeName=%s | categoryName=%s | isSellingPoint=%s | currentSavegameId=%s | placeable.ownerFarmId=%s | g_currentMission:getFarmId()=%s",
			placeable:getName(), tostring(placeable.typeName), tostring(placeable.storeItem.categoryName), tostring(station.isSellingPoint), placeable.currentSavegameId, placeable.ownerFarmId, g_currentMission:getFarmId())
		-- PRODUCTIONPOINTS, SILOS, ANIMALPENS

		if station.isSellingPoint ~= nil and station.isSellingPoint == true and (VIPOrderManager.acceptOwnPlaceableProductionPointsAsSellingStation or placeable.ownerFarmId ~= g_currentMission:getFarmId()) then
			for fillTypeIndex, isAccepted in pairs(station.acceptedFillTypes) do
				local fillType = g_fillTypeManager:getFillTypeByIndex(fillTypeIndex)

				-- accept for own placeable production points only fill types that are not also loadable at the same time
                if isAccepted
				  and placeable.ownerFarmId == g_currentMission:getFarmId()
				  and production ~= nil
				  and production.productionPoint.loadingStation ~= nil
				  and production.productionPoint.loadingStation.supportedFillTypes[fillTypeIndex] then
					isAccepted = false
					dbPrintf("  - own placeable production point: filltype %s-%s (%s) is not supported as it is also loadable", fillTypeIndex, fillType.name, fillType.title)
				end

				if isAccepted == true then
				
					-- Unknown filltype
					local extraMsg = ""
					if VIPOrderManager.ftConfigs[fillType.name] == nil then
						extraMsg = " *** Unknown filltype without configuration ***"
					end
					
					dbPrintf("  - filltype: %s-%s (%s)%s", fillTypeIndex, fillType.name, fillType.title, extraMsg)
					local price = station:getEffectiveFillTypePrice(fillTypeIndex)

					if possibleFillTypes[fillTypeIndex] == nil then
                        possibleFillTypes[fillTypeIndex] = {}
						possibleFillTypes[fillTypeIndex].priceMax = price
						possibleFillTypes[fillTypeIndex].acceptingStations = {}
						possibleFillTypes[fillTypeIndex].acceptingStationsString =""
						possibleFillTypes[fillTypeIndex].name = fillType.name
						possibleFillTypes[fillTypeIndex].title = fillType.title
						possibleFillTypes[fillTypeIndex].pricePerLiter = fillType.pricePerLiter
                        possibleFillTypes[fillTypeIndex].showOnPriceTable = fillType.showOnPriceTable
						possibleFillTypes[fillTypeIndex].literPerSqm = g_fruitTypeManager:getFillTypeLiterPerSqm(fillTypeIndex, 0)
						possibleFillTypes[fillTypeIndex].isFruitType = g_fruitTypeManager:getFruitTypeByName(fillType.name) ~= nil
					else
						if price > possibleFillTypes[fillTypeIndex].priceMax then
							possibleFillTypes[fillTypeIndex].priceMax = price
						end
					end

					-- append station to station list and to stationString
					table.insert(possibleFillTypes[fillTypeIndex].acceptingStations, station)
					if possibleFillTypes[fillTypeIndex].acceptingStationsString ~= "" then
						possibleFillTypes[fillTypeIndex].acceptingStationsString = possibleFillTypes[fillTypeIndex].acceptingStationsString .. ", "
					end
					possibleFillTypes[fillTypeIndex].acceptingStationsString = possibleFillTypes[fillTypeIndex].acceptingStationsString .. station.owningPlaceable:getName()
				end
			end
		else
			dbPrintf("  - Station not relevant: Name=%s | isSellingPoint=%s | placeable.ownerFarmId=%s", placeable:getName(), station.isSellingPoint, placeable.ownerFarmId)
		end
	end
	return possibleFillTypes
end


function VIPOrderManager:addAllAnimalFillTypes(possibleFillTypes)
    dbPrintHeader("VIPOrderManager:addAllAnimalFillTypes()")

    local animalTypeIndexes = {}

	for i, fillTypeIdx in pairs(g_fillTypeManager:getFillTypesByCategoryNames("ANIMAL HORSE")) do
        local fillType = g_fillTypeManager:getFillTypeByIndex(fillTypeIdx)
        local animalSubType = g_currentMission.animalSystem.fillTypeIndexToSubType[fillTypeIdx]
		if animalSubType == nil then
			dbPrintf("VIPOrderManager:addAllAnimalFillTypes warning: animal filltype without animalSubType: %s-%s (%s)",fillTypeIdx, fillType.name, fillType.title)
		else
			local animalStoreTitle = VIPOrderManager:GetAnimalTitleByFillTypeIdx(fillTypeIdx)

			-- get animal species
			local animalType = g_currentMission.animalSystem:getTypeByIndex(animalSubType.typeIndex)
			local animalTypeName = animalType.name
	

			-- print("** Start DebugUtil.printTableRecursively() ************************************************************")
			-- print("fillType:")
			-- DebugUtil.printTableRecursively(fillType, ".", 0, 3)
			-- print("** End DebugUtil.printTableRecursively() **************************************************************")

			-- print("** Start DebugUtil.printTableRecursively() ************************************************************")
			-- print("g_currentMission.animalSystem:")
			-- DebugUtil.printTableRecursively(g_currentMission.animalSystem, ".", 0, 1)
			-- print("** End DebugUtil.printTableRecursively() **************************************************************")

			-- printf("FillType: %s (%s) - animalTypeIndex=%s | MinBuyPrice=%s", fillType.name, fillType.title, animalSubType.typeIndex, animalSubType.buyPrice.keyframes[1][1])
			-- for ii, visual in pairs(animalSubType.visuals) do
			--     printf("  - canBeBought=%s | minAge=%s | name=%s", visual.store.canBeBought, visual.minAge, visual.store.name)
			-- end

			-- Unknown filltype
			local extraMsg = ""
			if VIPOrderManager.ftConfigs[fillType.name] == nil then
				extraMsg = " *** Unknown filltype without configuration ***"
			end
			
			dbPrintf("  - filltype: %s-%s (%s) %s", fillTypeIdx, fillType.name, animalStoreTitle, extraMsg)
			-- local price = animalSubType.buyPrice.keyframes[1][1]
			local price = math.floor(math.random(VIPOrderManager.rangeAnimalDummyPrice.min, VIPOrderManager.rangeAnimalDummyPrice.max))

			if possibleFillTypes[fillTypeIdx] == nil then
				possibleFillTypes[fillTypeIdx] = {}
			else
				dbPrintf("VIPOrderManager:addAllAnimalFillTypes warning: animal filltype already exists: %s-%s (%s)", fillTypeIdx, fillType.name, animalStoreTitle)
			end
			possibleFillTypes[fillTypeIdx].priceMax = price
			possibleFillTypes[fillTypeIdx].acceptingStations = {}
			possibleFillTypes[fillTypeIdx].name = fillType.name
			possibleFillTypes[fillTypeIdx].title = animalStoreTitle
			possibleFillTypes[fillTypeIdx].pricePerLiter = fillType.pricePerLiter
			possibleFillTypes[fillTypeIdx].showOnPriceTable = true
			possibleFillTypes[fillTypeIdx].literPerSqm = 0
			-- only for animals
			possibleFillTypes[fillTypeIdx].isAnimal = true
			possibleFillTypes[fillTypeIdx].animalTypeIndex = animalSubType.typeIndex
            possibleFillTypes[fillTypeIdx].animalTypeName = animalTypeName

            -- count animal subtypes
            if animalTypeIndexes[animalSubType.typeIndex] == nil then
                animalTypeIndexes[animalSubType.typeIndex] = 1
            else
                animalTypeIndexes[animalSubType.typeIndex] = animalTypeIndexes[animalSubType.typeIndex] + 1
            end
                possibleFillTypes[fillTypeIdx].animalTypeCount = animalTypeIndexes[animalSubType.typeIndex]
		end
	end
end


function VIPOrderManager:ShowCurrentVIPOrder()
    dbPrintHeader("VIPOrderManager:ShowCurrentVIPOrder()")

	-- dbPrintf("  current showVIPOrder=%s | new showVIPOrder=%s", VIPOrderManager.showVIPOrder,  (VIPOrderManager.showVIPOrder + 1) % 4)

	VIPOrderManager.showVIPOrder = (VIPOrderManager.showVIPOrder + 1) % 3	-- only 0, 1 or 2
	if VIPOrderManager.showVIPOrder > 0 then
		VIPOrderManager:UpdateOutputLines();
	end
	VIPOrderManager.infoDisplayPastTime = 0
end


function VIPOrderManager:GetPayoutTotal(orderEntries)
    dbPrintHeader("VIPOrderManager:GetPayoutTotal()")

	local payoutTotal = 0
	for _, entry in pairs(orderEntries) do
		payoutTotal = payoutTotal + entry.payout
	end
	return payoutTotal
end

-- return: boolean, IsOrderCompleted
function VIPOrderManager:UpdateOutputLines()
    -- dbPrintHeader("VIPOrderManager:UpdateOutputLines()")

	if #VIPOrderManager.VIPOrders < 2 then
		return
	end

	local posX = VIPOrderManager.outputStartPoint.x
	local posY = VIPOrderManager.outputStartPoint.y
	local fontSize = VIPOrderManager.outputFontSize
	local isOrderCompleted = true
	local payoutTotal = 0
	VIPOrderManager.outputLines = {}	-- Output lines for the draw() function (text, size, bold, colorId, x, y)

	local title = g_i18n:getText("VIPOrderManager_CurrentVIPOrder")
	local VIPOrder = VIPOrderManager.VIPOrders[1]
	
	if VIPOrderManager.showVIPOrder == 2 then
		VIPOrder = VIPOrderManager.VIPOrders[2]
		title = g_i18n:getText("VIPOrderManager_NextVIPOrder")
	end
	local level = VIPOrder.level

	-- calculate max text widths
	-- local maxTitelTextWidth = 0
	-- local maxQuantityTextWidth = 0
	-- for _, vipOrderEntry in pairs(VIPOrder) do
	-- 	local fillTypeTitle = vipOrderEntry.title
	-- 	local titelTextWidth = getTextWidth(fontSize, "  " .. fillTypeTitle .. "  ")
	-- 	local requiredQuantity = vipOrderEntry.quantity - math.ceil(vipOrderEntry.fillLevel)
	-- 	local quantityTextWidth = getTextWidth(fontSize, g_i18n:formatNumber(requiredQuantity, 0))

	-- 	if titelTextWidth > maxTitelTextWidth then
	-- 		maxTitelTextWidth = titelTextWidth
	-- 	end

	-- 	if quantityTextWidth > maxQuantityTextWidth then
	-- 		maxQuantityTextWidth = quantityTextWidth
	-- 	end
	-- end
	local headerLine = string.format("%s (Level: %s):", title, level)
	table.insert(VIPOrderManager.outputLines, {text = headerLine, size = fontSize, bold = true, align=RenderText.ALIGN_LEFT, colorId = 7, x = posX, y = posY})
	posY = posY - fontSize
	
	local maxTextWidth = getTextWidth(fontSize, headerLine) + 0.005
	local posXIncrease = getTextWidth(fontSize, "  999.999  ")

	for _, vipOrderEntry in pairs(VIPOrder.entries) do
		local fillTypeTitle = vipOrderEntry.title
		local requiredQuantity = vipOrderEntry.quantity - math.ceil(vipOrderEntry.fillLevel)
	
		local line = string.format("  %s ", g_i18n:formatNumber(requiredQuantity, 0))
		local fillLevelColor = 7;
		if requiredQuantity <= 0 then
			fillLevelColor = 6
		end
		table.insert(VIPOrderManager.outputLines, {text = line, size = fontSize, bold = false, align=RenderText.ALIGN_RIGHT, colorId = fillLevelColor, x = posX + posXIncrease, y = posY})
		
		local line = string.format("  %s", fillTypeTitle)
		if vipOrderEntry.targetStation ~= nil then
			line = line .. " --> " .. vipOrderEntry.targetStation.owningPlaceable:getName()
		end
		table.insert(VIPOrderManager.outputLines, {text = line, size = fontSize, bold = false, align=RenderText.ALIGN_LEFT, colorId = fillLevelColor, x = posX + posXIncrease, y = posY})
		posY = posY - fontSize
		local textWidth = getTextWidth(fontSize, line)
		if (textWidth + posXIncrease > maxTextWidth) then
			maxTextWidth = textWidth + posXIncrease
		end

		isOrderCompleted = isOrderCompleted and requiredQuantity <= 0
		payoutTotal = payoutTotal + vipOrderEntry.payout
	end
	
	local line = string.format(g_i18n:getText("VIPOrderManager_Payout"), g_i18n:formatMoney(payoutTotal, 0, true)) --, false))	-- g_i18n:formatMoney(value, bool Währung ausgeben, bool Währung vor dem Betrag?)
	table.insert(VIPOrderManager.outputLines, {text = line, size = fontSize, bold = true, align=RenderText.ALIGN_LEFT, colorId = 7, x = posX, y = posY})
	posY = posY - fontSize

	if infoHud ~= nil then
		infoHud:setPosition(VIPOrderManager.outputStartPoint.x - 0.005, VIPOrderManager.outputStartPoint.y + 0.005 + fontSize)
		infoHud:setDimension(maxTextWidth + 0.01, VIPOrderManager.outputStartPoint.y - posY + fontSize)
	end

	return isOrderCompleted and MyTools:getCountElements(VIPOrder.entries) > 0
end


function VIPOrderManager:MakePayout(orderEntries)
    dbPrintHeader("VIPOrderManager:MakePayout()")

	playSample(VIPOrderManager.successSound ,1 ,1 ,1 ,0 ,0)
	
	-- show message
	g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_OK, g_i18n:getText("VIPOrderManager_OrderCompleted"))

	-- Pay out profit
	local payoutTotal = VIPOrderManager:GetPayoutTotal(orderEntries)
	g_currentMission:addMoney(payoutTotal, g_currentMission.player.farmId, MoneyType.MISSIONS, true, true);
end


function VIPOrderManager:update(dt)
    -- dbPrintHeader("VIPOrderManager:update()")

	VIPOrderManager.updateDelta = VIPOrderManager.updateDelta + dt;
	VIPOrderManager.infoDisplayPastTime = VIPOrderManager.infoDisplayPastTime + dt

	if VIPOrderManager.updateDelta > VIPOrderManager.updateRate and VIPOrderManager.InitDone then
		VIPOrderManager.updateDelta = 0;

		if VIPOrderManager.infoDisplayPastTime > VIPOrderManager.infoDisplayMaxShowTime then
			VIPOrderManager.showVIPOrder = 0;
			VIPOrderManager.infoDisplayPastTime = 0
		end

		if g_currentMission:getIsClient() and g_gui.currentGui == nil and g_currentMission.player.farmId > 0 then
			local isOrderCompleted = VIPOrderManager:UpdateOutputLines()
			if isOrderCompleted then
				VIPOrderManager:MakePayout(VIPOrderManager.VIPOrders[1].entries)
				table.remove(VIPOrderManager.VIPOrders, 1)
			end
			if #VIPOrderManager.VIPOrders < VIPOrderManager.maxVIPOrdersCount then
				VIPOrderManager:RestockVIPOrders()
			end
		end
	end

	if infoHud ~= nil then
		if #VIPOrderManager.VIPOrders > 0  and #VIPOrderManager.outputLines > 0 then
			infoHud:setVisible(VIPOrderManager.showVIPOrder > 0)
		else
			infoHud:setVisible(false)
		end
	end
end


function VIPOrderManager:draw()
    -- dbPrintHeader("VIPOrderManager:draw()")

	-- Only render when no other GUI is open
    if g_gui.currentGuiName ~= "InGameMenu" and VIPOrderManager.showVIPOrder > 0 and VIPOrderManager.InitDone then --if g_gui.currentGui == nil
		for _, line in ipairs(VIPOrderManager.outputLines) do
			VIPOrderManager:renderText(line.x, line.y, line.size, line.text, line.bold, line.colorId, line.align)
		end;
	end
	
	if infoHud ~= nil then
		infoHud:draw()
	end
end


function VIPOrderManager:renderText(x, y, size, text, bold, colorId, align)
    -- dbPrintHeader("VIPOrderManager:renderText()")

	setTextColor(table.unpack(VIPOrderManager.colors[colorId][2]))
	setTextBold(bold)
	setTextAlignment(align)
	renderText(x, y, size, text)
	
	-- Back to defaults
	setTextBold(false)
	setTextColor(table.unpack(VIPOrderManager.colors[1][2])) --Back to default color which is white
	setTextAlignment(RenderText.ALIGN_LEFT)
end


function VIPOrderManager:saveSettings()
    dbPrintHeader("VIPOrderManager:saveSettings()")
	
	local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory.."/";
	if savegameFolderPath == nil then
		savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex.."/");
	end;
	local key = "VIPOrderManager";
	local storePlace = g_currentMission.storeSpawnPlaces[1];
	local xmlFile = createXMLFile(key, savegameFolderPath.."VIPOrderManager.xml", key);
	-- setXMLString(xmlFile, key.."#XMLFileVersion", "1.0");
	setXMLString(xmlFile, key.."#XMLFileVersion", "2.0");

	local settingKey = string.format("%s.Settings", key)
	-- setXMLInt(xmlFile, key.."#orderLevel", VIPOrderManager.currentOrderLevel);
	setXMLInt(xmlFile, settingKey..".maxVIPOrdersCount", VIPOrderManager.maxVIPOrdersCount)
	setXMLBool(xmlFile, settingKey..".isAnimalOrdersWished", VIPOrderManager.isAnimalOrdersWished)
	setXMLInt(xmlFile, settingKey..".countOrderItemsRange#Min", VIPOrderManager.countOrderItemsRange.min)
	setXMLInt(xmlFile, settingKey..".countOrderItemsRange#Max", VIPOrderManager.countOrderItemsRange.max)
	setXMLInt(xmlFile, settingKey..".quantityFactor#Min", VIPOrderManager.quantityFactor.min)
	setXMLInt(xmlFile, settingKey..".quantityFactor#Max", VIPOrderManager.quantityFactor.max)
	setXMLInt(xmlFile, settingKey..".payoutFactor#Min", VIPOrderManager.payoutFactor.min)
	setXMLInt(xmlFile, settingKey..".payoutFactor#Max", VIPOrderManager.payoutFactor.max)

	local iOrder = 0
	for _, vipOrder in pairs(VIPOrderManager.VIPOrders) do
		local orderKey = string.format("%s.VIPOrders.VIPOrder(%d)", key, iOrder)
		setXMLInt(xmlFile, orderKey.."#level", vipOrder.level)

		local iEntry = 0
		for _, orderEntry in pairs(vipOrder.entries) do
			local entryKey = string.format("%s.entry(%d)", orderKey, iEntry)
			setXMLString(xmlFile, entryKey.."#fillTypeName", orderEntry.fillTypeName)
			setXMLInt(xmlFile, entryKey.."#quantity", orderEntry.quantity)
			setXMLInt(xmlFile, entryKey.."#fillLevel", math.ceil(orderEntry.fillLevel))
			setXMLInt(xmlFile, entryKey.."#payout", orderEntry.payout)

			setXMLString(xmlFile, entryKey.."#fillTypeTitle_OnlyAsInfo", orderEntry.title)
			if orderEntry.targetStation ~= nil then
				setXMLInt(xmlFile, entryKey.."#targetStationSavegameId", orderEntry.targetStation.owningPlaceable.currentSavegameId)
				setXMLString(xmlFile, entryKey.."#targetStationName_OnlyAsInfo", orderEntry.targetStation.owningPlaceable:getName())
			end

			-- for animal
			if orderEntry.isAnimal then
				setXMLBool(xmlFile, entryKey.."#isAnimal", orderEntry.isAnimal)
				setXMLInt(xmlFile, entryKey.."#neededAgeInMonths", orderEntry.neededAgeInMonths)
			end
			
			iEntry = iEntry + 1
		end
		iOrder = iOrder + 1
	end
	saveXMLFile(xmlFile);
	delete(xmlFile);
end

function VIPOrderManager:loadSettings()
    dbPrintHeader("VIPOrderManager:loadSettings()")

	local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory
	if savegameFolderPath == nil then
		savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex)
	end;
	savegameFolderPath = savegameFolderPath.."/"
	local key = "VIPOrderManager"

	if fileExists(savegameFolderPath.."VIPOrderManager.xml") then
		local xmlFile = loadXMLFile(key, savegameFolderPath.."VIPOrderManager.xml")

		local XMLFileVersion = getXMLString(xmlFile, key.."#XMLFileVersion")

		if XMLFileVersion == "2.0" then
			local settingKey = string.format("%s.Settings", key)
			VIPOrderManager.maxVIPOrdersCount = Utils.getNoNil(getXMLInt(xmlFile, settingKey..".maxVIPOrdersCount"), VIPOrderManager.maxVIPOrdersCount)
			VIPOrderManager.isAnimalOrdersWished = Utils.getNoNil(getXMLBool(xmlFile, settingKey..".isAnimalOrdersWished"), VIPOrderManager.isAnimalOrdersWished)

			VIPOrderManager.countOrderItemsRange.min = Utils.getNoNil(getXMLInt(xmlFile, settingKey..".countOrderItemsRange#Min"), VIPOrderManager.countOrderItemsRange.min)
			VIPOrderManager.countOrderItemsRange.max = Utils.getNoNil(getXMLInt(xmlFile, settingKey..".countOrderItemsRange#Max"), VIPOrderManager.countOrderItemsRange.max)
			VIPOrderManager.quantityFactor.min = Utils.getNoNil(getXMLInt(xmlFile, settingKey..".quantityFactor#Min"), VIPOrderManager.quantityFactor.min)
			VIPOrderManager.quantityFactor.max = Utils.getNoNil(getXMLInt(xmlFile, settingKey..".quantityFactor#Max"), VIPOrderManager.quantityFactor.max)
			VIPOrderManager.payoutFactor.min = Utils.getNoNil(getXMLInt(xmlFile, settingKey..".payoutFactor#Min"), VIPOrderManager.payoutFactor.min)
			VIPOrderManager.payoutFactor.max = Utils.getNoNil(getXMLInt(xmlFile, settingKey..".payoutFactor#Max"), VIPOrderManager.payoutFactor.max)

			local iOrder = 0
			while true do
				local orderKey = string.format("%s.VIPOrders.VIPOrder(%d)", key, iOrder)
				if hasXMLProperty(xmlFile, orderKey) then
					local vipOrder = {level=nil, entries={}}
					local level = getXMLInt(xmlFile, orderKey.."#level")
					vipOrder.level = level
		
					local iEntry = 0
					while true do
						local entryKey = string.format("%s.entry(%d)", orderKey, iEntry)
						if hasXMLProperty(xmlFile, entryKey) then
							local error = false
							local fillTypeName = getXMLString(xmlFile, entryKey.."#fillTypeName")
							local quantity = getXMLInt(xmlFile, entryKey.."#quantity")
							local fillLevel = Utils.getNoNil(getXMLInt(xmlFile, entryKey.."#fillLevel"), 0)
							local payout = getXMLInt(xmlFile, entryKey.."#payout")

							-- for animal
							local isAnimal = getXMLBool(xmlFile, entryKey.."#isAnimal")
							local neededAgeInMonths = getXMLInt(xmlFile, entryKey.."#neededAgeInMonths")

							local targetStationSavegameId = getXMLInt(xmlFile, entryKey.."#targetStationSavegameId")
							local targetStationName = getXMLString(xmlFile, entryKey.."#targetStationName_OnlyAsInfo")
							-- dbPrintf("loadSettings: %s | %s", targetStationSavegameId, targetStationName)
							local targetStation = VIPOrderManager:getStationBySavegameId(targetStationSavegameId)
							
							-- check if target station still exists
							if targetStationName ~= nil and targetStation == nil then								
								print(string.format("VIPOrderManager: Warning, the target station \"%s\" no longer exists", targetStationName))
							end
							-- check if filltype still exists
							local fillType = g_fillTypeManager:getFillTypeByName(fillTypeName)
							if fillType == nil then
								error = true
								print(string.format("VIPOrderManager: Warning, the filltype \"%s\" no longer exists", fillTypeName))
							else
								local ftTitle
								if isAnimal then
									ftTitle = VIPOrderManager:GetAnimalTitleByFillTypeIdx(fillType.index, neededAgeInMonths)
								else
									ftTitle = fillType.title
								end
								vipOrder.entries[fillTypeName] = {fillTypeName=fillTypeName, title=ftTitle, quantity=quantity, fillLevel=fillLevel, payout=payout, targetStation=targetStation, isAnimal=isAnimal, neededAgeInMonths=neededAgeInMonths}
							end
							iEntry = iEntry + 1
						else
							break
						end
					end
					table.insert(VIPOrderManager.VIPOrders, vipOrder)
					iOrder = iOrder + 1
				else
					break
				end
			end
		end

		delete(xmlFile);
	end;

	VIPOrderManager.InitDone = true
	return VIPOrderManager.isLoaded;
end


function VIPOrderManager:getStationBySavegameId(targetStationSavegameId)
    dbPrintHeader("VIPOrderManager:getStationBySavegameId()")

	for _, station in pairs(g_currentMission.storageSystem.unloadingStations) do
		if station.owningPlaceable ~= nil and station.owningPlaceable.currentSavegameId == targetStationSavegameId then
			return station
		end
	end
	return nil
end


function VIPOrderManager:GetAnimalTitleByFillTypeIdx(fillTypeIdx, neededAgeInMonths)
	local animalSubType = g_currentMission.animalSystem.fillTypeIndexToSubType[fillTypeIdx]
	local animalStoreTitle = "Unknown animal title"
	local animalAge = neededAgeInMonths == nil and 0 or neededAgeInMonths
	
	for i, visual in pairs(animalSubType.visuals) do
		if animalAge >= visual.minAge then
			animalStoreTitle = visual.store.name
		end
	end

	if neededAgeInMonths ~= nil then
		animalStoreTitle = animalStoreTitle .. string.format(" (%s %s)", neededAgeInMonths, g_i18n:getText("VIPOrderManager_Months"))
	end

	return animalStoreTitle
end


-- Observe "SellingStation.addFillLevelFromTool" when products are sold at points of sale
function VIPOrderManager.sellingStation_addFillLevelFromTool(station, superFunc, farmId, deltaFillLevel, fillType, fillInfo, toolType)
    dbPrintHeader("VIPOrderManager:sellingStation_addFillLevelFromTool()")

	local moved = 0
	moved = superFunc(station, farmId, deltaFillLevel, fillType, fillInfo, toolType)

	local ft = g_fillTypeManager:getFillTypeByIndex(fillType)
	local stationCategoryName = ""
	if station.owningPlaceable ~= nil and station.owningPlaceable.storeItem ~= nil then
		stationCategoryName = station.owningPlaceable.storeItem.categoryName
	end
	-- dbPrintf("  stationCategoryName=%s | moved=%s | deltaFillLevel=%s | ftName=%s (%s) | ftIndex=%s | toolType=%s", tostring(stationCategoryName), tostring(moved), tostring(deltaFillLevel), ft.name, ft.title, tostring(fillType), tostring(toolType))

	if moved > 0 and VIPOrderManager.VIPOrders ~= nil and VIPOrderManager.VIPOrders[1] ~= nil then
        local orderEntry = VIPOrderManager.VIPOrders[1].entries[ft.name]
        -- dbPrintf("  Anzahl Order Items=%s", TyTools:getCountElements(VIPOrderManager.currentVIPOrder))
		if orderEntry ~= nil then
			if orderEntry.targetStation == nil or orderEntry.targetStation == station then
				orderEntry.fillLevel = math.min(orderEntry.fillLevel + moved, orderEntry.quantity)
				VIPOrderManager.showVIPOrder = 1;
				VIPOrderManager.infoDisplayPastTime = 0
				VIPOrderManager:UpdateOutputLines()
			end
		end
	end

    return moved
end


function VIPOrderManager:isTerraLife()
	local mapDirectory = g_mpLoadingScreen.missionInfo.map.baseDirectory
	if mapDirectory == "" then
		--wenn mapDirectory leer ist, handelt es sich um die Basemaps
		return false
	elseif fileExists(mapDirectory .. "dlcDesc.xml") then
		--wenn dlcDesc existiert, handelt es sich um DLC-Map
		return false
	else
		local path = mapDirectory .. "modDesc.xml"
		local xmlFile = XMLFile.load("TempDesc", path)
		if xmlFile:hasProperty("moddesc.terraLife") then
			return true
		else
			return false
		end
		xmlFile:delete()
	end
end


function VIPOrderManager:onLoad(savegame)end;
function VIPOrderManager:onUpdate(dt)end;
function VIPOrderManager:deleteMap()end;
function VIPOrderManager:keyEvent(unicode, sym, modifier, isDown)end;
function VIPOrderManager:mouseEvent(posX, posY, isDown, isUp, button)end;

addModEventListener(VIPOrderManager);


