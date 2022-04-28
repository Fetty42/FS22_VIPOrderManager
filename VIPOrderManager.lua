-- Author: Fetty42
-- Date: 16.04.2022
-- Version: 1.0.0.0

local dbPrintfOn = false

local function dbPrintf(...)
	if dbPrintfOn then
    	print(string.format(...))
	end
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

VIPOrderManager.existingProductionAndAnimalOutputs = {}	-- 
VIPOrderManager.VIPOrders 			= {}	-- List of orders {level, entries{[Name] = {fillTypeName, quantity, fillLevel, payout, targetStation}}}

VIPOrderManager.outputLines 		= {}	-- Output lines for the draw() function (text, size, bold, colorId, x, y)
VIPOrderManager.infoHud 			= nil	-- VID Order Info HUD
VIPOrderManager.OrderDlg			= nil

source(Utils.getFilename("VIPOrderManagerDefaults.lua", VIPOrderManager.dir))
source(Utils.getFilename("InfoHUD.lua", VIPOrderManager.dir))
source(VIPOrderManager.dir .. "gui/OrderFrame.lua")

function VIPOrderManager:loadMap(name)
    dbPrintf("call VIPOrderManager:loadMap()");

	if g_currentMission:getIsClient() then
		Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, VIPOrderManager.registerActionEvents);
		Enterable.onRegisterActionEvents = Utils.appendedFunction(Enterable.onRegisterActionEvents, VIPOrderManager.registerActionEvents);
		-- VIPOrderManager.eventName = {};

		FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, VIPOrderManager.saveSettings);
		FSBaseMission.onFinishedLoading = Utils.appendedFunction(FSBaseMission.onFinishedLoading, VIPOrderManager.loadSettings);
		--VIPOrderManager:loadSettings();

		SellingStation.addFillLevelFromTool = Utils.overwrittenFunction(SellingStation.addFillLevelFromTool, VIPOrderManager.sellingStation_addFillLevelFromTool)	
	end
end;


function VIPOrderManager:registerActionEvents()
	dbPrintf("call VIPOrderManager:registerActionEvents()");

	if self.isClient then --isOwner
		-- local result, actionEventId = InputBinding.registerActionEvent(g_inputBinding, 'ShowCurrentVIPOrder',self, VIPOrderManager.ShowCurrentVIPOrder ,false ,true ,false ,true)
		local result, actionEventId = g_inputBinding:registerActionEvent('ShowCurrentVIPOrder',InputBinding.NO_EVENT_TARGET, VIPOrderManager.ShowCurrentVIPOrder ,false ,true ,false ,true)
		dbPrintf("Result=%s | actionEventId=%s | self.isClient=%s", result, actionEventId, self.isClient)
		if result and actionEventId then
			g_inputBinding:setActionEventTextVisibility(actionEventId, true)
			g_inputBinding:setActionEventActive(actionEventId, true)
			g_inputBinding:setActionEventTextPriority(actionEventId, GS_PRIO_VERY_LOW) -- GS_PRIO_VERY_HIGH, GS_PRIO_HIGH, GS_PRIO_LOW, GS_PRIO_VERY_LOW

			-- table.insert(VIPOrderManager.eventName, actionEventId);
			-- g_inputBinding.events[actionEventId].displayIsVisible = true;
			dbPrintf("Action event inserted successfully")
		end
		local result2, actionEventId2 = g_inputBinding:registerActionEvent('ShowVIPOrderDlg',InputBinding.NO_EVENT_TARGET, VIPOrderManager.ShowVIPOrderDlg ,false ,true ,false ,true)
		dbPrintf("Result2=%s | actionEventId2=%s | self.isClient=%s", result2, actionEventId2, self.isClient)
		if result2 and actionEventId2 then
			g_inputBinding:setActionEventTextVisibility(actionEventId2, true)
			g_inputBinding:setActionEventActive(actionEventId2, true)
			g_inputBinding:setActionEventTextPriority(actionEventId2, GS_PRIO_VERY_LOW) -- GS_PRIO_VERY_HIGH, GS_PRIO_HIGH, GS_PRIO_LOW, GS_PRIO_VERY_LOW

			-- table.insert(VIPOrderManager.eventName, actionEventId2);
			-- g_inputBinding.events[actionEventId2].displayIsVisible = true;
			dbPrintf("Action event inserted successfully")
		end

		if infoHud == nil then
			infoHud = InfoHUD.new()
			infoHud:setVisible(true)
		end
		-- hud:delete()
	end
end;


--  
function VIPOrderManager:ShowVIPOrderDlg(actionName, keyStatus, arg3, arg4, arg5)
	dbPrintf("call VIPOrderManager:ShowVIPOrderDlg()");

	VIPOrderManager.OrderDlg = nil
	g_gui:loadProfiles(VIPOrderManager.dir .. "gui/guiProfiles.xml")
	local orderFrame = OrderFrame.new(g_i18n) 
	g_gui:loadGui(VIPOrderManager.dir .. "gui/OrderFrame.xml", "OrderFrame", orderFrame)
	VIPOrderManager.OrderDlg = g_gui:showDialog("OrderFrame")

	if VIPOrderManager.OrderDlg ~= nil then
		VIPOrderManager.OrderDlg.target:setVIPOrders(VIPOrderManager.VIPOrders)
		
    end
end


-- Payout complete orders less a abort fee for incomplete orders. 
function VIPOrderManager:AbortCurrentVIPOrder()
	dbPrintf("call VIPOrderManager:AbortCurrentVIPOrder()");

	local sumAbortFee, sumPayout = VIPOrderManager:GetSumAbortFeeAndSumPayout()

	-- g_gui:showYesNoDialog({text=g_i18n:getText("tour_text_start"), title="", callback=self.reactToDialog, target=self})
	local msgText = string.format(g_i18n:getText("VIPOrderManager_DlgMsg_AbortCurrentVIPOrder"), g_i18n:formatMoney(sumAbortFee, 0, true), g_i18n:formatMoney(sumPayout, 0, true))
	g_gui:showYesNoDialog({text=msgText, title=g_i18n:getText("VIPOrderManager_DlgTitel_AbortCurrentVIPOrder"), callback=VIPOrderManager.reactToDialog_AbortCurrentVIPOrder, target=self})
end


function VIPOrderManager:reactToDialog_AbortCurrentVIPOrder(yes)
	dbPrintf("call VIPOrderManager:reactToDialog_AbortCurrentVIPOrder()");
    if yes then
		local sumAbortFee, sumPayout = VIPOrderManager:GetSumAbortFeeAndSumPayout()
	
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
	dbPrintf("call VIPOrderManager:GetSumAbortFeeAndSumPayout()");
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
	dbPrintf("call VIPOrderManager:RestockVIPOrders()");

	VIPOrderManager.ownFieldArea = VIPOrderManager:CalculateOwnFieldArea()
	VIPOrderManager:GetExistingProductionAndAnimalOutputs()

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

	-- print("** Start DebugUtil.printTableRecursively() ************************************************************")
	-- DebugUtil.printTableRecursively(VIPOrderManager.VIPOrders, ".", 0, 3)
	-- print("** End DebugUtil.printTableRecursively() **************************************************************\n")
end


function VIPOrderManager:GetExistingProductionAndAnimalOutputs()
	dbPrintf("call VIPOrderManager:GetHusbandryPlaceableTypes()");
	VIPOrderManager.existingProductionAndAnimalOutputs = {}
	local farmId = g_currentMission.player.farmId;
	local isMilk = false
	local isLiquidManure = false
	local isManure = false
	local isEgg = false
	local isWool = false

	local isPig = false
	local isCow = false
	local isChicken = false
	local isSheep = false
	local isHorse = false

	for _,husbandry in pairs(g_currentMission.husbandrySystem.clusterHusbandries) do
		local placeable = husbandry:getPlaceable()
		if placeable.ownerFarmId == farmId then
			local name = placeable:getName()
			local specHusbandryLiquidManure = placeable.spec_husbandryLiquidManure
			local specHusbandryMilk = placeable.spec_husbandryMilk
			local specHusbandryStraw = placeable.spec_husbandryStraw
			local isManureActive = false
			if specHusbandryStraw ~= nil then
				isManureActive = specHusbandryStraw.isManureActive
			end

			dbPrintf("  - husbandry placeables:  Name=%s | AnimalType=%s | specMilk=%s | specLiquidManure=%s | specStraw=%s | isManureActive=%s", name, husbandry.animalTypeName, tostring(specHusbandryMilk), tostring(specHusbandryLiquidManure), tostring(specHusbandryStraw), isManureActive)

			isCow = husbandry.animalTypeName == "COW" or isCow
			isPig = husbandry.animalTypeName == "PIG" or isPig
			isChicken = husbandry.animalTypeName == "CHICKEN" or isChicken
			isSheep = husbandry.animalTypeName == "SHEEP" or isSheep
			isHorse = husbandry.animalTypeName == "HORSE" or isHorse

			isMilk = specHusbandryMilk ~= nil or isMilk
			isLiquidManure = specHusbandryLiquidManure ~= nil or isLiquidManure
			isManure = isManureActive or isManure
			isEgg = isChicken
			isWool = isSheep
		end
	end

	if isMilk then
		VIPOrderManager.existingProductionAndAnimalOutputs.MILK = true	
	end
	if isLiquidManure then
		VIPOrderManager.existingProductionAndAnimalOutputs.LIQUIDMANURE = true	
	end
	if isManure then
		VIPOrderManager.existingProductionAndAnimalOutputs.MANURE = true	
	end
	if isEgg then
		VIPOrderManager.existingProductionAndAnimalOutputs.EGG = true	
	end
	if isWool then
		VIPOrderManager.existingProductionAndAnimalOutputs.WOOL = true	
	end

	local isCow = false
	local isChicken = false
	local isSheep = false
	local isHorse = false

	if g_currentMission.productionChainManager.farmIds[farmId] ~= nil and g_currentMission.productionChainManager.farmIds[farmId].productionPoints ~= nil then
		for _, productionPoint in pairs(g_currentMission.productionChainManager.farmIds[farmId].productionPoints) do
			
			for fillTypeId, fillLevel in pairs(productionPoint.storage.fillLevels) do
				local name = productionPoint.owningPlaceable:getName()
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
				dbPrintf("  - Production: Name=%s  | fillTypeName=%s | fillTypeTitle=%s | isInput=%s", name, fillTypeName, fillTypeTitle, isInput)
				if not isInput then
					VIPOrderManager.existingProductionAndAnimalOutputs[fillTypeName] = true	
				end
			end
		end
	end

	DebugUtil.printTableRecursively(VIPOrderManager.existingProductionAndAnimalOutputs, ".", 0, 3)
end


function VIPOrderManager:calculateAndFillOrder(VIPOrder, orderLevel)
	dbPrintf("call VIPOrderManager:calculateAndFillOrder()");

	local usableFillTypes = {};
	VIPOrderManager:GetUsableFillTypes(usableFillTypes, orderLevel)

	-- set the special corrections faktors depending on the current order level and the own field area
	-- for level=1, 20, 1 do
	-- 	local factorCount =     ((1 + level*0.04)-0.04)
	-- 	local factorQuantity =  ((1 + level*level*0.005) - 0.005)
	-- 	local factorPayout =   1/ ((1 + level*0.05) - 0.05)
	-- 	dbPrintf("Level %2i: factorCount=%f | factorQuantity=%f | factorPayout=%f",
	-- 		level, factorCount, factorQuantity, factorPayout)
	-- end

	
	local specCorFactorCount = ((1 + orderLevel * 0.04) - 0.04)
	local specCorFactorQuantity = ((1 + orderLevel*orderLevel*0.005) - 0.005)
	local specCorFactorPayout = 1.0 / ((1 + orderLevel*0.05) - 0.05)
	dbPrintf("\nCreate new VIP Order: Level %s", orderLevel)
	dbPrintf("  Initial basic correction factors:")
	dbPrintf("    - Count factor    = %.2f", specCorFactorCount)
	dbPrintf("    - Quantity factor = %.2f", specCorFactorQuantity)
	dbPrintf("    - Payout factor   = %.2f", specCorFactorPayout)

	local ownFieldSizeFactor = ((1 + VIPOrderManager.ownFieldArea*0.3)-0.3)
	dbPrintf("  Basic correction factors adjusted by the size of the own fields:")
	dbPrintf("    - own field size        = " .. VIPOrderManager.ownFieldArea)
	dbPrintf("    - own field size factor = " .. ownFieldSizeFactor)
	dbPrintf("    - adjusted quantity factor from %.2f to %.2f", specCorFactorQuantity, specCorFactorQuantity * ownFieldSizeFactor)
	dbPrintf("    - adjusted payout factor from   %.2f to %.2f", specCorFactorPayout, specCorFactorPayout / ownFieldSizeFactor)
	local specCorFactorQuantity = specCorFactorQuantity * ownFieldSizeFactor
	local specCorFactorPayout = specCorFactorPayout / ownFieldSizeFactor

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
	local countFillTypes = #usableFillTypes
	local countOrderItems = math.floor(math.random(VIPOrderManager.countOrderItemsRange.min, VIPOrderManager.countOrderItemsRange.max) * specCorFactorCount + 0.5)
	dbPrintf("  Calculate order item count:")
	dbPrintf("    - min count      = " .. VIPOrderManager.countOrderItemsRange.min)
	dbPrintf("    - max count      = " .. VIPOrderManager.countOrderItemsRange.max)
	dbPrintf("    - Count factor   = " .. specCorFactorCount)
	dbPrintf("    ==> Count order items = " .. countOrderItems)

	local maxLimitedOrderItems = math.floor(orderLevel / 100 * VIPOrderManager.isLimitedPercentage)
	dbPrintf("  Max allowed limited order items: %s percent from %s = %s", VIPOrderManager.isLimitedPercentage, orderLevel, maxLimitedOrderItems)
	
	local i = 0
	while (i < countOrderItems) do
		i = i + 1
		dbPrintf(string.format("\n  %s. Order Item:", i))
		
		local fillType = nil
		local ftConfig = nil
		local isLimitedFillType = nil
		repeat
			fillType = usableFillTypes[math.random(1, countFillTypes)]
			ftConfig = VIPOrderManager:GetFillTypeConfig(fillType.name)

			isLimitedFillType = true
			if ftConfig.isLimited ~= nil then
				isLimitedFillType = ftConfig.isLimited
			end

		until(maxLimitedOrderItems > 0 or not isLimitedFillType)
		if isLimitedFillType then
			maxLimitedOrderItems = maxLimitedOrderItems -1
			dbPrintf("  --> choose limited filltype")
		end

		local quantityCorrectionFactor = 1
		if ftConfig.quantityCorrectionFactor ~= nil then
			quantityCorrectionFactor = ftConfig.quantityCorrectionFactor
		end
		dbPrintf("    - FillType: %s (%s) | filltype quantity factor = %.2f", fillType.name, fillType.title, quantityCorrectionFactor)

		local randomQuantityFaktor = math.random(VIPOrderManager.quantityFactor.min, VIPOrderManager.quantityFactor.max) * specCorFactorQuantity
		local randomPayoutFactor = math.random(VIPOrderManager.payoutFactor.min, VIPOrderManager.payoutFactor.max) * specCorFactorPayout / quantityCorrectionFactor
		local orderItemQuantity = math.floor(randomQuantityFaktor * 1000 / fillType.pricePerLiter * quantityCorrectionFactor)
		dbPrintf("    - final quantity factor = %.2f", randomQuantityFaktor)
		dbPrintf("    - final payout factor   = %.2f", randomPayoutFactor)
		

		if orderItemQuantity > 1000 then
			orderItemQuantity = math.floor(orderItemQuantity / 1000) * 1000
		elseif orderItemQuantity > 100 then
			orderItemQuantity = math.floor(orderItemQuantity / 100) * 100
		elseif orderItemQuantity > 10 then
			orderItemQuantity = math.floor(orderItemQuantity / 10) * 10
		end 
		dbPrintf("    ==> Quantity = %.2f * 1000 / %.2f * %.2f = %s", randomQuantityFaktor, fillType.pricePerLiter, quantityCorrectionFactor, orderItemQuantity)
		
		local orderItemPayout = math.floor(orderItemQuantity * fillType.pricePerLiter * randomPayoutFactor/100)*100
		dbPrintf("    ==> Payout   = %.2f * %.2f * %.2f = %s", orderItemQuantity, fillType.pricePerLiter, randomPayoutFactor, orderItemPayout)

		-- target station
		local targetStation = fillType.acceptingStations[math.random(1, #fillType.acceptingStations)]
		dbPrintf("    ==> target station = %s", targetStation.owningPlaceable:getName())

		if VIPOrder[fillType.name] ~= nil then
			if allowSumQuantitySameFT then
				-- Summ double entries
				VIPOrder[fillType.name].quantity = VIPOrder[fillType.name].quantity + orderItemQuantity/2
				VIPOrder[fillType.name].payout = VIPOrder[fillType.name].payout + orderItemPayout/2
				dbPrintf("  Double --> Sum order items")
			else
				i = i - 1 	-- try again
				dbPrintf("  Double --> discard current order item and try again")
			end
		else
			VIPOrder[fillType.name] = {fillTypeName=fillType.name, quantity=orderItemQuantity, fillLevel=0, payout=orderItemPayout, targetStation=targetStation}
		end
	end
end


function VIPOrderManager:CalculateOwnFieldArea()
	dbPrintf("\ncall VIPOrderManager:CalculateOwnFieldArea()");

	-- Calculate full farmland
	local farmlands = g_farmlandManager:getOwnedFarmlandIdsByFarmId(g_currentMission.player.farmId)
	
	local fieldAreaOverall = 0.0
	for i, id in pairs(farmlands) do
		farmland = g_farmlandManager:getFarmlandById(id)

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
		fieldAreaOverall = fieldAreaOverall + fieldAreaSum

		dbPrintf("  --> %s. Owned Farmland: id=%s | FieldCount=%s | FieldAreaSum=%s", i, farmland.id, fieldCount, g_i18n:formatArea(fieldAreaSum, 2))
	end
	dbPrintf("  ==> Field Area Overall: %s\n", g_i18n:formatArea(fieldAreaOverall, 2))

	-- if fieldAreaOverall > 0.01 then
	-- 	return math.ceil(fieldAreaOverall*100)/100
	-- else
	-- 	return 0
	-- end

	return VIPOrderManager:round(fieldAreaOverall, 2)
end


function VIPOrderManager:GetFillTypeConfig(ftName)
	local ftConfig = VIPOrderManager.ftConfigs[ftName]
	if ftConfig == nil then
		if g_fruitTypeManager:getFruitTypeByName(ftName) ~= nil then
			ftConfig = VIPOrderManager.ftConfigs["DEFAULT_FRUITTYPE"]
		else
			ftConfig = VIPOrderManager.ftConfigs["DEFAULT_FILLTYPE"]
		end
		VIPOrderManager.ftConfigs[ftName] = ftConfig
	end
	-- dbPrintf("GetFillTypeConfig: ftName=%s --> ftConfig=%s (isUnknown=%s)", ftName, tostring(ftConfig), tostring(ftConfig.isUnknown))
	
	return ftConfig
end


function VIPOrderManager:GetUsableFillTypes(usableFillTypes, orderLevel)
	dbPrintf("\ncall VIPOrderManager:GetUsableFillTypes()");
	
	local sellableFillTypes = VIPOrderManager:getAllSellableFillTypes()

	-- Validate FillTypes	
	dbPrintf("\nNot usable filltypes:")
	for index, sft in pairs(sellableFillTypes) do    
        dbPrintf("  Validate FillTypes: " .. index .. " --> " .. sft.name .. " (" .. sft.title .. ")")
		local notUsableWarning = nil
		local tempNameOutput = string.format("%s (%s)", sft.name, sft.title)
		local defaultWarningText = string.format("  - %-40s | pricePerLiterMax=%f | ", tempNameOutput, sft.priceMax)
		local takeTheFillTypeExplicitly = false
		local ftConfig = nil
		ftConfig = VIPOrderManager:GetFillTypeConfig(sft.name)


		-- not allowed
		if notUsableWarning == nil and not ftConfig.isAllowed then
			notUsableWarning = "Not usable, because is not allowed"
        end

		-- needed fruit type not available
		-- local neededFruitType = VIPOrderManager.fillTypesNeededFruitType[sft.name]
		-- if notUsableWarning == nil and neededFruitType and g_fruitTypeManager:getFruitTypeByName(neededFruitType) == nil then
		-- 	notUsableWarning = string.format("Not usable, because needed fruittype (%s) is missing", neededFruitType)
		-- end

		-- not sell able
		if notUsableWarning == nil and not sft.showOnPriceTable then
            notUsableWarning = "Not usable, because not show on price list"
        end

		--  without sell price
		if notUsableWarning == nil and sft.priceMax == 0 then
			if VIPOrderManager.fillTypesNoPriceList[sft.name] == 1 and sft.pricePerLiter > 0 then
				sft.priceMax = sft.pricePerLiter
			else
	            notUsableWarning = "Not usable, because no price per liter defined"
			end
        end

        --  "order level" not high enough
		local minOrderLevel = ftConfig.minOrderLevel
		if ftConfig.minOrderLevelIfProductionExists ~= nil and VIPOrderManager.existingProductionAndAnimalOutputs[sft.name] then
			dbPrintf("  - Overwrite MinOrderLevel as production/animal husbandry allready owned: %s --> %s", ftConfig.minOrderLevel, ftConfig.minOrderLevelIfProductionExists)
			minOrderLevel = ftConfig.minOrderLevelIfProductionExists
		end
		if notUsableWarning == nil and minOrderLevel > orderLevel then
			if ftConfig.isUnknown ~= nil and ftConfig.isUnknown then
				--  unknown filltype
				notUsableWarning = string.format("Not usable, because current VIP-Order level (%s) is for new fill types not high enough (needs %s)", orderLevel, minOrderLevel)
			else
				notUsableWarning = string.format("Not usable, because current VIP-Order level (%s) is not high enough (needs %s)", orderLevel, minOrderLevel)
			end
        end

		if notUsableWarning == nil then
            ftdata = {}
            ftdata.pricePerLiter = sft.priceMax
            ftdata.name = sft.name
            ftdata.title=sft.title
			ftdata.acceptingStations=sft.acceptingStations
            table.insert(usableFillTypes, ftdata)
        else
            dbPrintf(defaultWarningText .. notUsableWarning)
        end
	end
	
	dbPrintf("\nUsable filltypes:")
	for _, v in pairs(usableFillTypes) do    
		local tempNameOutput = string.format("%s (%s)", v.name, v.title)
		
		local stationList = ""
		for i=1, #v.acceptingStations do
			if stationList ~= "" then
				stationList = stationList .. ", "
			end
			stationList = stationList .. v.acceptingStations[i].owningPlaceable:getName()
		end
		
		dbPrintf("  - %-40s | price=%f | Stations=%s", tempNameOutput, v.pricePerLiter, stationList)
	end
end


function VIPOrderManager:getAllSellableFillTypes()
	-- dbPrintf("\ncall VIPOrderManager:getAllSellableFillTypes()");
	local sellableFillTypes = {}

	for _, station in pairs(g_currentMission.storageSystem.unloadingStations) do
		-- dbPrintf("Station: getName=%s | typeName=%s | categoryName=%s | isSellingPoint=%s | currentSavegameId=%s", 
		-- 	station.owningPlaceable:getName(), tostring(station.owningPlaceable.typeName), tostring(station.owningPlaceable.storeItem.categoryName), tostring(station.isSellingPoint), station.owningPlaceable.currentSavegameId)
		-- PRODUCTIONPOINTS, SILOS, ANIMALPENS

		if station.isSellingPoint ~= nil and station.isSellingPoint == true then
			for fillTypeIndex, isAccepted in pairs(station.acceptedFillTypes) do
				local fillType = g_fillTypeManager:getFillTypeByIndex(fillTypeIndex)
                local fruitType = g_fruitTypeManager:getFruitTypeByName(fillType.name)
				if isAccepted == true then
				
					-- Unknown filltype
					local extraMsg = ""
					if VIPOrderManager.ftConfigs[fillType.name] == nil then
						extraMsg = " *** Unknown filltype without configuration ***"
					end
					
					-- dbPrintf("  - filltype: %s (%s)%s", fillType.name, fillType.title, extraMsg)
					local price = station:getEffectiveFillTypePrice(fillTypeIndex)

					if sellableFillTypes[fillTypeIndex] == nil then
                        sellableFillTypes[fillTypeIndex] = {}
						sellableFillTypes[fillTypeIndex].priceMin = price
						sellableFillTypes[fillTypeIndex].priceMax = price
						sellableFillTypes[fillTypeIndex].acceptingStations = {}
						sellableFillTypes[fillTypeIndex].name = fillType.name
						sellableFillTypes[fillTypeIndex].title = fillType.title
						sellableFillTypes[fillTypeIndex].pricePerLiter = fillType.pricePerLiter
                        sellableFillTypes[fillTypeIndex].showOnPriceTable = fillType.showOnPriceTable
					else
						if price > sellableFillTypes[fillTypeIndex].priceMax then
							sellableFillTypes[fillTypeIndex].priceMax = price
						end
						if price < sellableFillTypes[fillTypeIndex].priceMin then
							sellableFillTypes[fillTypeIndex].priceMin = price
						end
					end
					table.insert(sellableFillTypes[fillTypeIndex].acceptingStations, station)
				end
			end
		end
	end
	return sellableFillTypes
end


function VIPOrderManager:ShowCurrentVIPOrder()
	-- dbPrintf("\ncall VIPOrderManager:ShowCurrentVIPOrder()");

	-- dbPrintf("  current showVIPOrder=%s | new showVIPOrder=%s", VIPOrderManager.showVIPOrder,  (VIPOrderManager.showVIPOrder + 1) % 4)

	VIPOrderManager.showVIPOrder = (VIPOrderManager.showVIPOrder + 1) % 3	-- only 0, 1 or 2
	if VIPOrderManager.showVIPOrder > 0 then
		VIPOrderManager:UpdateOutputLines();
	end
	VIPOrderManager.infoDisplayPastTime = 0
end


function VIPOrderManager:GetPayoutTotal(orderEntries)
	local payoutTotal = 0
	for _, entry in pairs(orderEntries) do
		payoutTotal = payoutTotal + entry.payout
	end
	return payoutTotal
end

-- return: boolean, IsOrderCompleted
function VIPOrderManager:UpdateOutputLines()
	-- dbPrintf("call VIPOrderManager:UpdateOutputLines()");
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
	-- 	local fillTypeTitle = g_fillTypeManager:getFillTypeByName(vipOrderEntry.fillTypeName).title
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
		local fillTypeTitle = g_fillTypeManager:getFillTypeByName(vipOrderEntry.fillTypeName).title
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

	return isOrderCompleted and VIPOrderManager:getCountElements(VIPOrder.entries) > 0
end


function VIPOrderManager:MakePayout(orderEntries)
	-- dbPrintf("\ncall VIPOrderManager:MakePayout()");

	-- show message
	g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_OK, g_i18n:getText("VIPOrderManager_OrderCompleted"))

	-- Pay out profit
	local payoutTotal = VIPOrderManager:GetPayoutTotal(orderEntries)
	g_currentMission:addMoney(payoutTotal, g_currentMission.player.farmId, MoneyType.MISSIONS, true, true);
end


function VIPOrderManager:update(dt)
    VIPOrderManager.updateDelta = VIPOrderManager.updateDelta + dt;
	VIPOrderManager.infoDisplayPastTime = VIPOrderManager.infoDisplayPastTime + dt

	if VIPOrderManager.updateDelta > VIPOrderManager.updateRate and VIPOrderManager.InitDone then
		VIPOrderManager.updateDelta = 0;

		if VIPOrderManager.infoDisplayPastTime > VIPOrderManager.infoDisplayMaxShowTime then
			VIPOrderManager.showVIPOrder = 0;
			VIPOrderManager.infoDisplayPastTime = 0
		end

		if g_currentMission:getIsClient() and g_gui.currentGui == nil then
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
		infoHud:setVisible(VIPOrderManager.showVIPOrder > 0)
	end

end


function VIPOrderManager:draw()
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
	setTextColor(unpack(VIPOrderManager.colors[colorId][2]))
	setTextBold(bold)
	setTextAlignment(align)
	renderText(x, y, size, text)
	
	-- Back to defaults
	setTextBold(false)
	setTextColor(unpack(VIPOrderManager.colors[1][2])) --Back to default color which is white
	setTextAlignment(RenderText.ALIGN_LEFT)
end


function VIPOrderManager:saveSettings()
	-- dbPrintf("call VIPOrderManager:saveSettings()");
	
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
	setXMLInt(xmlFile, settingKey..".maxVIPOrdersCount", VIPOrderManager.maxVIPOrdersCount);
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
			setXMLString(xmlFile, entryKey.."#fillTypeTitle_OnlyAsInfo", g_fillTypeManager:getFillTypeByName(orderEntry.fillTypeName).title)
			if orderEntry.targetStation ~= nil then
				setXMLInt(xmlFile, entryKey.."#targetStationSavegameId", orderEntry.targetStation.owningPlaceable.currentSavegameId)
				setXMLString(xmlFile, entryKey.."#targetStationName_OnlyAsInfo", orderEntry.targetStation.owningPlaceable:getName())
			end
			iEntry = iEntry + 1
		end
		iOrder = iOrder + 1
	end

	-- Write unknown filltypes as info
	-- isUnknown=true, isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.0, isLimited=false}
	local i = 0
	for ftName, config in pairs(VIPOrderManager.ftConfigs) do
		if config.isUnknown ~= nil and config.isUnknown and ftName ~= "DEFAULT_FRUITTYPE" and ftName ~= "DEFAULT_FILLTYPE" then
			local localKey = string.format("%s.UnknownFilltypesInfos.UnknownFilltypesInfo(%d)", key, i)
			setXMLString(xmlFile, localKey.."#ftName", ftName)
			setXMLBool(xmlFile, localKey.."#isAllowed", config.isAllowed)
			setXMLInt(xmlFile, localKey.."#minOrderLevel", config.minOrderLevel)
			setXMLFloat(xmlFile, localKey.."#quantityCorrectionFactor", config.quantityCorrectionFactor)
			setXMLBool(xmlFile, localKey.."#isLimited", config.isLimited)
			if config.minOrderLevelIfProductionExists ~= nil then
				setXMLInt(xmlFile, localKey.."#minOrderLevelIfProductionExists", config.minOrderLevelIfProductionExists)
			end
			setXMLString(xmlFile, localKey.."#title", g_fillTypeManager:getFillTypeByName(ftName).title)
			i = i + 1
		end
	end
	
	saveXMLFile(xmlFile);
	delete(xmlFile);
end

function VIPOrderManager:loadSettings()
	dbPrintf("call VIPOrderManager:loadSettings()")

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
							local fillTypeName = getXMLString(xmlFile, entryKey.."#fillTypeName")
							local quantity = getXMLInt(xmlFile, entryKey.."#quantity")
							local fillLevel = Utils.getNoNil(getXMLInt(xmlFile, entryKey.."#fillLevel"), 0)
							local payout = getXMLInt(xmlFile, entryKey.."#payout")
							local targetStationSavegameId = getXMLInt(xmlFile, entryKey.."#targetStationSavegameId")
							local targetStationName = getXMLString(xmlFile, entryKey.."#targetStationName_OnlyAsInfo")
							-- dbPrintf("loadSettings: %s | %s", targetStationSavegameId, targetStationName)
							local targetStation = VIPOrderManager:getStationBySavegameId(targetStationSavegameId)
							if targetStation ~= nil then
								-- dbPrintf("  --> %s | %s", targetStation, targetStation.owningPlaceable:getName())
							end
			
							vipOrder.entries[fillTypeName] = {fillTypeName=fillTypeName, quantity=quantity, fillLevel=fillLevel, payout=payout, targetStation=targetStation}
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
	for _, station in pairs(g_currentMission.storageSystem.unloadingStations) do
		if station.owningPlaceable ~= nil and station.owningPlaceable.currentSavegameId == targetStationSavegameId then
			return station
		end
	end
	return nil
end


function VIPOrderManager:round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
end


-- Observe "SellingStation.addFillLevelFromTool" when products are sold at points of sale
function VIPOrderManager.sellingStation_addFillLevelFromTool(station, superFunc, farmId, deltaFillLevel, fillType, fillInfo, toolType)
	local moved = 0
	moved = superFunc(station, farmId, deltaFillLevel, fillType, fillInfo, toolType)

	local ft = g_fillTypeManager:getFillTypeByIndex(fillType)
	local stationCategoryName = ""
	if station.owningPlaceable ~= nil and station.owningPlaceable.storeItem ~= nil then
		stationCategoryName = station.owningPlaceable.storeItem.categoryName
	end
	-- dbPrintf("  stationCategoryName=%s | moved=%s | deltaFillLevel=%s | ftName=%s (%s) | ftIndex=%s | toolType=%s", tostring(stationCategoryName), tostring(moved), tostring(deltaFillLevel), ft.name, ft.title, tostring(fillType), tostring(toolType))

	if moved > 0 then
        local orderEntry = VIPOrderManager.VIPOrders[1].entries[ft.name]
        -- dbPrintf("  Anzahl Order Items=%s", VIPOrderManager:getCountElements(VIPOrderManager.currentVIPOrder))
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

function VIPOrderManager:getCountElements(myTable)
	local i = 0
	for _, _ in pairs(myTable) do
		i = i + 1
	end
	return i	
end


function VIPOrderManager:onLoad(savegame)end;
function VIPOrderManager:onUpdate(dt)end;
function VIPOrderManager:deleteMap()end;
function VIPOrderManager:keyEvent(unicode, sym, modifier, isDown)end;
function VIPOrderManager:mouseEvent(posX, posY, isDown, isUp, button)end;

addModEventListener(VIPOrderManager);