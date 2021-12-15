
VIPOrderManager = {}; -- Class

-- Constants for filltype selection
-- VIPOrderManager.fillTypesBlackListe = {CROP_WINDROW=1, SEEDS=1, FORAGE_MIXING=1, FERTILIZER=1, PIGFOOD=1, LIME=1, ALFALFA=1, CLOVER=1, SALT=1, SUGARCANE=1, SILOGRASS=1, SILOCLOVER=1, SILOALFALFA=1}	-- fill types will not be used 
-- VIPOrderManager.fillTypesBlackListePattern = {"SEED_"}
VIPOrderManager.fillTypesBlackListe = {SUGARCANE=1, SILOGRASS=1, COTTON=1, SILOCLOVER=1, SILOALFALFA=1, BEETPULP=1}	-- fill types will not be used 
VIPOrderManager.fillTypesBlackListePattern = {}
VIPOrderManager.fillTypesNeededFruitType = {ALFALFA_WINDROW="ALFALFA", DRYALFALFA_WINDROW="ALFALFA", ALFALFA_FERMENTED="ALFALFA", CLOVER_WINDROW="CLOVER", DRYCLOVER_WINDROW="CLOVER", CLOVER_FERMENTED="CLOVER", Carrot="CARROT"} -- filltype check for maps who not support MaizePlus
VIPOrderManager.fillTypesNeededDifficultyFaktor = {EGG=2, STRAW=2, SILAGE=3, LIQUIDMANURE=4, MANURE=4, MISCANTHUS=4, MILK=5, WOOL=5, WOODCHIPS=5, SUGARBEET=5, GRAPE=5, OLIVE=6, POTATO=6, CARROT=6, ONION=6, FORAGE=6, CCMRAW=10}	-- fill types will only used if Dif-factor Equal or greater
VIPOrderManager.fillTypesNeededDifficultyFaktorPattern = {_WINDROW=2, _FERMENTED=3}	-- fill types will only used if Dif-factor Equal or greater
VIPOrderManager.fillTypesNoPriceList = {STRAW=1, DRYGRASS_WINDROW=1, GRASS_WINDROW=1}
VIPOrderManager.minOrderLevelForNotBasicFillTypes = 3
-- Constants for order items calculation

-- for smal orders
-- VIPOrderManager.countOrderItemsRange = {min=3, max=4}
-- VIPOrderManager.quantityFactor = {min=3, max=6}
-- VIPOrderManager.payoutFactor = {min=9, max=14}

-- for large orders
VIPOrderManager.countOrderItemsRange = {min=2, max=3}
VIPOrderManager.quantityFactor = {min=7, max=9}
VIPOrderManager.payoutFactor = {min=9, max=11}

VIPOrderManager.fillTypesQuantityCorrectionFactor = {LIQUIDMANURE=0.3, MANURE=0.3, STRAW=0.5, MILK=0.7, EGG=0.7, WOOL=0.7, FORAGE=0.4, CHOPPEDMAIZE=0.5, CHAFF=0.5, MISCANTHUS=0.5}	-- default is 1.0 
VIPOrderManager.fillTypesQuantityCorrectionFactorPattern = {_WINDROW=0.4, _FERMENTED=0.4, SILAGE=0.4}	-- default is 1.0 


-- Depending on the OrderLeven, special correction factors for count, quantity and payout
VIPOrderManager.orderLevelCorrectionFactors = {}
VIPOrderManager.orderLevelCorrectionFactors[1] = {1.0, 0.25, 2.0}
VIPOrderManager.orderLevelCorrectionFactors[2] = {1.0, 0.50, 1.75}
VIPOrderManager.orderLevelCorrectionFactors[3] = {1.0, 0.75, 1.5}
VIPOrderManager.orderLevelCorrectionFactors[4] = {1.0, 1.00, 1.25}

-- update delay
VIPOrderManager.updateDelta = 0;  	-- time since the last update
VIPOrderManager.updateRate = 1000;  	-- milliseconds until next update

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
VIPOrderManager.currentVIPOrder = {}	-- [Name] = {fillTypeName, quantity, fillLevel, payout{}
VIPOrderManager.nextVIPOrder = {}	-- [Name] = {fillTypeName, quantity, fillLevel, payout}
VIPOrderManager.outputLines = {}	-- Output lines for the draw() function (text, size, bold, colorId, x, y)
VIPOrderManager.orderLevel = 0	-- will be increased by 1 with each orders generation


function VIPOrderManager:loadMap(name)
  print("call VIPOrderManager:loadMap()");

  Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, VIPOrderManager.registerActionEvents);
  Drivable.onRegisterActionEvents = Utils.appendedFunction(Drivable.onRegisterActionEvents, VIPOrderManager.registerActionEvents);
  VIPOrderManager.eventName = {};

  FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, VIPOrderManager.saveSettings);
  VIPOrderManager:loadSettings();

  SellingStation.addFillLevelFromTool = Utils.overwrittenFunction(SellingStation.addFillLevelFromTool, VIPOrderManager.sellingStation_addFillLevelFromTool)	
end;


function VIPOrderManager:registerActionEvents()
	-- print("call VIPOrderManager:registerActionEvents()");

	-- local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'CreateAndShowNewVIPOrder',self, VIPOrderManager.CreateAndShowNewVIPOrder ,false ,true ,false ,true)
	-- if result then
    --     table.insert(VIPOrderManager.eventName, eventName);
	-- 	g_inputBinding.events[eventName].displayIsVisible = false;
    -- end
	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'ShowCurrentVIPOrder',self, VIPOrderManager.ShowCurrentVIPOrder ,false ,true ,false ,true)
	if result then
		-- print("  insert action event");
        table.insert(VIPOrderManager.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = true;
    end
end;


-- function VIPOrderManager:CreateAndShowNewVIPOrder(actionName, keyStatus, arg3, arg4, arg5)
-- 	-- print("call VIPOrderManager:CreateAndShowNewVIPOrder()");

-- 	VIPOrderManager:CreateNewVIPOrder()
-- 	VIPOrderManager:UpdateOutputLines()
-- end


function VIPOrderManager:CreateNewVIPOrder()
	-- print("call VIPOrderManager:CreateNewVIPOrder()");
	
	local usableFillTypes = {};
	VIPOrderManager:GetUsableFillTypes(usableFillTypes)

	self.currentVIPOrder = {}
	if self.nextVIPOrder ~= nil and VIPOrderManager:getCountElements(self.nextVIPOrder) > 0 then
		self.currentVIPOrder = self.nextVIPOrder
	else
		VIPOrderManager:calculateAndFillOrder(self.currentVIPOrder, usableFillTypes)
	end
	self.nextVIPOrder = {}
	VIPOrderManager:calculateAndFillOrder(self.nextVIPOrder, usableFillTypes)

	self.showVIPOrder = 1
	self.infoDisplayPastTime = 0
end


function VIPOrderManager:CreateNextVIPOrder()
	-- print("call VIPOrderManager:CreateNextVIPOrder()");
	
	local usableFillTypes = {};
	VIPOrderManager:GetUsableFillTypes(usableFillTypes)

	self.nextVIPOrder = {}
	VIPOrderManager:calculateAndFillOrder(self.nextVIPOrder, usableFillTypes)

	self.showVIPOrder = 2
	self.infoDisplayPastTime = 0
end



function VIPOrderManager:calculateAndFillOrder(VIPOrder, usableFillTypes)
	print("call VIPOrderManager:calculateAndFillOrder()");

	VIPOrderManager.orderLevel  = VIPOrderManager.orderLevel + 1

	-- set the special corrections faktors depending on the current order level
	local specialCorrectionFactorCount = 1.0
	local specialCorrectionFactorQuantity = 1.0
	local specialCorrectionFactorPayout = 1.0
	if VIPOrderManager.orderLevelCorrectionFactors[VIPOrderManager.orderLevel] ~= nil then
		specialCorrectionFactorCount = VIPOrderManager.orderLevelCorrectionFactors[VIPOrderManager.orderLevel][1]
		specialCorrectionFactorQuantity = VIPOrderManager.orderLevelCorrectionFactors[VIPOrderManager.orderLevel][2]
		specialCorrectionFactorPayout = VIPOrderManager.orderLevelCorrectionFactors[VIPOrderManager.orderLevel][3]
	end
	print(string.format("  special correction faktors: orderLevel=%s | count=%s | quantity=%s | payout=%s", VIPOrderManager.orderLevel, specialCorrectionFactorCount, specialCorrectionFactorQuantity, specialCorrectionFactorPayout))

	-- create random order items
	local countFillTypes = #usableFillTypes
	local countOrderItems = math.floor(math.random(VIPOrderManager.countOrderItemsRange.min, VIPOrderManager.countOrderItemsRange.max) * (2*(1 + VIPOrderManager.orderLevel*0.02)-1) + 0.5) * specialCorrectionFactorCount
	local maxCountWindrowOrFermented = math.random(1, math.max(1, math.floor(countOrderItems*0.4)));
	print(string.format("  countOrderItems=%s | orderLevel=%s | maxCountWindrowOrFermented=%s", countOrderItems, VIPOrderManager.orderLevel, maxCountWindrowOrFermented))
	for i=1, countOrderItems do
		local fillType = usableFillTypes[math.random(1, countFillTypes)]
		
		-- Limit number of WINDROW or FERMENTED order entrys
		if VIPOrder[fillType.name] == nil then
			while maxCountWindrowOrFermented == 0 and (string.find(fillType.name, "_WINDROW") ~= nil or string.find(fillType.name, "_FERMENTED") ~= nil) do
			fillType = usableFillTypes[math.random(1, countFillTypes)]
			end
			if string.find(fillType.name, "_WINDROW") ~= nil or string.find(fillType.name, "_FERMENTED") ~= nil then
				maxCountWindrowOrFermented = maxCountWindrowOrFermented - 1
			end
		end


		local quantityCorrectionFactor = VIPOrderManager.fillTypesQuantityCorrectionFactor[fillType.name] or 1.0
		for pattern, correction in pairs(VIPOrderManager.fillTypesQuantityCorrectionFactorPattern) do
			if string.find(fillType.name, pattern) ~= nil then
				quantityCorrectionFactor = correction
			end
		end

		local randomQuantityFaktor = math.random(VIPOrderManager.quantityFactor.min, VIPOrderManager.quantityFactor.max) * 1000 * (0.2*(VIPOrderManager.orderLevel*VIPOrderManager.orderLevel*0.02+1)+0.8) * specialCorrectionFactorQuantity
		local randomPayoutFactor = math.random(VIPOrderManager.payoutFactor.min, VIPOrderManager.payoutFactor.max) / (0.15*(VIPOrderManager.orderLevel*VIPOrderManager.orderLevel*0.02+1)+0.8) * specialCorrectionFactorPayout
		local orderItemQuantity = math.floor(randomQuantityFaktor / fillType.pricePerLiter * quantityCorrectionFactor)
		if orderItemQuantity > 1000 then
			orderItemQuantity = math.floor(orderItemQuantity / 1000) * 1000
		elseif orderItemQuantity > 100 then
			orderItemQuantity = math.floor(orderItemQuantity / 100) * 100
		elseif orderItemQuantity > 10 then
			orderItemQuantity = math.floor(orderItemQuantity / 10) * 10
		end 
		local orderItemPayout = math.floor(orderItemQuantity * fillType.pricePerLiter * randomPayoutFactor/100)*100

		print(string.format("  %s.Order item: Name=%s | Title=%s | Quantity=%s | Payout=%s | quantityCorrectionFactor=%s | randomQuantityFaktor=%s | randomPayoutFactor=%s", i, fillType.name, fillType.title, orderItemQuantity, orderItemPayout, quantityCorrectionFactor, randomQuantityFaktor, randomPayoutFactor))

		if VIPOrder[fillType.name] ~= nil then
			-- Summ double entries
			print("--> double entry")
			VIPOrder[fillType.name].quantity = VIPOrder[fillType.name].quantity + orderItemQuantity/2
			VIPOrder[fillType.name].payout = VIPOrder[fillType.name].payout + orderItemPayout/2
			countOrderItems = countOrderItems + 1
		else
			VIPOrder[fillType.name] = {fillTypeName=fillType.name, quantity=orderItemQuantity, fillLevel=0, payout=orderItemPayout}
		end
	end
end


function VIPOrderManager:GetUsableFillTypes(usableFillTypes)
	print("call VIPOrderManager:GetUsableFillTypes()");

	local sellableFillTypes = VIPOrderManager.getAllSellableFillTypes()

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
				print(string.format("  Field: fieldId=%s | name=%s | fieldArea =%s", field.fieldId, field.name, g_i18n:formatArea(field.fieldArea, 2)))
			end
		end
		fieldAreaOverall = fieldAreaOverall + fieldAreaSum

		print(string.format("%s. Owned Farmland: Name/id=%s/%s | FieldCount=%s | FieldAreaSum=%s", i, farmland.name, farmland.id, fieldCount, g_i18n:formatArea(fieldAreaSum, 2)))
	end
	print(string.format("Field Area Overall: %s", g_i18n:formatArea(fieldAreaOverall, 2)))
	print();
	
	-- Validate FillTypes	
	for index, sft in pairs(sellableFillTypes) do    
        local notUsableWarning = nil
		local tempNameOutput = string.format("  - %s (%s)", sft.name, sft.title)
		local defaultWarningText = string.format("  - %-40s | pricePerLiterMax=%f | ", tempNameOutput, sft.priceMax)
		local takeTheFillTypeExplicitly = false

		-- not sell able
		if notUsableWarning == nil and not sft.showOnPriceTable then
            notUsableWarning = "Not usable, because not show on price list"
        end

		-- needed fruit type not available
		local neededFruitType = VIPOrderManager.fillTypesNeededFruitType[sft.name]
		if notUsableWarning == nil and neededFruitType and g_fruitTypeManager:getFruitTypeByName(neededFruitType) == nil then
			notUsableWarning = string.format("Not usable, because needed fruittype (%s) is missing", neededFruitType)
		end

		-- on blacklist
		if notUsableWarning == nil and VIPOrderManager.fillTypesBlackListe[sft.name] == 1 then
			notUsableWarning = "Not usable, because is on black list"
        end
        if notUsableWarning == nil then
			for _, pattern in pairs(VIPOrderManager.fillTypesBlackListePattern) do
				if string.find(sft.name, pattern) ~= nil then
					notUsableWarning = "Not usable, because is on pattern black list (Pattern)"
					break
				end
			end
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
		if notUsableWarning == nil and VIPOrderManager.fillTypesNeededDifficultyFaktor[sft.name] ~= nil then
			if VIPOrderManager.fillTypesNeededDifficultyFaktor[sft.name] > VIPOrderManager.orderLevel then
            	notUsableWarning = "Not usable, because orderLevel is not high enough"
			else
				takeTheFillTypeExplicitly = true
			end
        end
        if notUsableWarning == nil then
			for pattern, neededOrderLevel in pairs(VIPOrderManager.fillTypesNeededDifficultyFaktorPattern) do
				if string.find(sft.name, pattern) ~= nil then
					if neededOrderLevel >  VIPOrderManager.orderLevel then
						notUsableWarning = "Not usable, because orderLevel is not high enough (Pattern)"
						break
					else
						takeTheFillTypeExplicitly = true
					end
				end
			end
		end

        -- filltype without matching fruit type
		-- print(string.format("  Filltype-Name=%s | FruitType=%s | OrderLevel=%s | minOrderLevelForNotBasicFillTypes=%s", sft.name, tostring(g_fruitTypeManager:getFruitTypeByName(sft.name)), VIPOrderManager.orderLevel, VIPOrderManager.minOrderLevelForNotBasicFillTypes))
		if notUsableWarning == nil  and not takeTheFillTypeExplicitly then
			if g_fruitTypeManager:getFruitTypeByName(sft.name) == nil and VIPOrderManager.minOrderLevelForNotBasicFillTypes > VIPOrderManager.orderLevel then
				notUsableWarning = string.format("Not usable, because a fill type without matching fruit type need a higher 'order level' (min. %s)", VIPOrderManager.minOrderLevelForNotBasicFillTypes)
			end
		end

		if notUsableWarning == nil then
            ftdata = {}
            ftdata.pricePerLiter = sft.priceMax
            ftdata.name = sft.name
            ftdata.title=sft.title
            table.insert(usableFillTypes, ftdata)
        else
            print(defaultWarningText .. notUsableWarning)
        end
	end
	
	print("")
	print("Usable fill types:")
	for _, v in pairs(usableFillTypes) do    
		local tempNameOutput = string.format("  - %s (%s)", v.name, v.title)
		print(string.format(" - %-40s | price=%f", tempNameOutput, v.pricePerLiter));
	end
	print("")
end


function VIPOrderManager:getAllSellableFillTypes()
	print("call VIPOrderManager:getAllSellableFillTypes()");
	local sellableFillTypes = {}

	for _,station in pairs(g_currentMission.storageSystem.unloadingStations) do

		if station.isSellingPoint ~= nil and station.isSellingPoint == true then
			for fillTypeIndex, isAccepted in pairs(station.acceptedFillTypes) do
				local fillType = g_fillTypeManager:getFillTypeByIndex(fillTypeIndex)
                local fruitType = g_fruitTypeManager:getFruitTypeByName(fillType.name)
				if isAccepted == true then

					local price = station:getEffectiveFillTypePrice(fillTypeIndex)


					if sellableFillTypes[fillTypeIndex] == nil then
                        sellableFillTypes[fillTypeIndex] = {}
						sellableFillTypes[fillTypeIndex].priceMin = price
						sellableFillTypes[fillTypeIndex].priceMax = price
						sellableFillTypes[fillTypeIndex].stationNames = {}
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

					table.insert(sellableFillTypes[fillTypeIndex].stationNames, station.stationName)
				end
			end
		end
	end
	return sellableFillTypes
end


function VIPOrderManager:ShowCurrentVIPOrder()
	print("call VIPOrderManager:ShowCurrentVIPOrder()");

	-- print(string.format("  current showVIPOrder=%s | new showVIPOrder=%s", VIPOrderManager.showVIPOrder,  (VIPOrderManager.showVIPOrder + 1) % 4))

	VIPOrderManager.showVIPOrder = (VIPOrderManager.showVIPOrder + 1) % 3	-- only 0, 1 or 2
	if VIPOrderManager.showVIPOrder > 0 then
		VIPOrderManager:UpdateOutputLines();
	end
	VIPOrderManager.infoDisplayPastTime = 0
end


function VIPOrderManager:GetPayoutTotal()
	local payoutTotal = 0
	for _, vipOrder in pairs(VIPOrderManager.currentVIPOrder) do
		payoutTotal = payoutTotal + vipOrder.payout
	end
	return payoutTotal
end

-- return: boolean, IsOrderCompleted
function VIPOrderManager:UpdateOutputLines()
	-- print("call VIPOrderManager:UpdateOutputLines()");
	local payoutTotal = 0
	local posX = VIPOrderManager.outputStartPoint.x
	local posY = VIPOrderManager.outputStartPoint.y
	local fontSize = VIPOrderManager.outputFontSize
	local maxTitelTextWidth = 0
	local maxQuantityTextWidth = 0
	local isOrderCompleted = true
	local payoutTotal = 0
	VIPOrderManager.outputLines = {}	-- Output lines for the draw() function (text, size, bold, colorId, x, y)

	local title = "Current VIP Order"
	local VIPOrder = VIPOrderManager.currentVIPOrder
	local level = VIPOrderManager.orderLevel - 1
	if VIPOrderManager.showVIPOrder == 2 then
		VIPOrder = VIPOrderManager.nextVIPOrder
		title = "Next VIP Order"
		level = VIPOrderManager.orderLevel
	end


	-- calculate max text widths
	for _, vipOrderEntry in pairs(VIPOrder) do
		local fillTypeTitle = g_fillTypeManager:getFillTypeByName(vipOrderEntry.fillTypeName).title
		local titelTextWidth = getTextWidth(fontSize, "  " .. fillTypeTitle .. "  ")
		local quantityTextWidth = getTextWidth(fontSize, string.format("%s", vipOrderEntry.quantity - vipOrderEntry.fillLevel))

		if titelTextWidth > maxTitelTextWidth then
			maxTitelTextWidth = titelTextWidth
		end

		if quantityTextWidth > maxQuantityTextWidth then
			maxQuantityTextWidth = quantityTextWidth
		end
	end

	table.insert(VIPOrderManager.outputLines, {text = string.format("%s (Level: %s):", title, level), size = fontSize, bold = true, align=RenderText.ALIGN_LEFT, colorId = 7, x = posX, y = posY})
	posY = posY - fontSize
	
	for _, vipOrderEntry in pairs(VIPOrder) do
		local fillTypeTitle = g_fillTypeManager:getFillTypeByName(vipOrderEntry.fillTypeName).title
		local posXIncrease=0
	
		local line = string.format("  %s ", g_i18n:formatNumber(vipOrderEntry.quantity - vipOrderEntry.fillLevel, 0))
		local fillLevelColor = 7;
		if vipOrderEntry.fillLevel >= vipOrderEntry.quantity then
			fillLevelColor = 6
		end
		posXIncrease = getTextWidth(fontSize, "  999.999  ")
		table.insert(VIPOrderManager.outputLines, {text = line, size = fontSize, bold = false, align=RenderText.ALIGN_RIGHT, colorId = fillLevelColor, x = posX + posXIncrease, y = posY})

		local line = string.format("  %s", fillTypeTitle)
		table.insert(VIPOrderManager.outputLines, {text = line, size = fontSize, bold = false, align=RenderText.ALIGN_LEFT, colorId = fillLevelColor, x = posX + posXIncrease, y = posY})
		posY = posY - fontSize

		isOrderCompleted = isOrderCompleted and (vipOrderEntry.fillLevel >= vipOrderEntry.quantity)
		payoutTotal = payoutTotal + vipOrderEntry.payout
	end
	
	local line = string.format("Payout: %s", g_i18n:formatMoney(payoutTotal, 0, true)) --, false))	-- g_i18n:formatMoney(value, bool Währung ausgeben, bool Währung vor dem Betrag?)
	table.insert(VIPOrderManager.outputLines, {text = line, size = fontSize, bold = true, align=RenderText.ALIGN_LEFT, colorId = 7, x = posX, y = posY})
	return isOrderCompleted and VIPOrderManager:getCountElements(VIPOrder) > 0
end


-- -- return: boolean, IsOrderCompleted
-- function VIPOrderManager:UpdateOutputLines()
-- 	-- print("call VIPOrderManager:UpdateOutputLines()");
-- 	local payoutTotal = 0
-- 	local posX = VIPOrderManager.outputStartPoint.x
-- 	local posY = VIPOrderManager.outputStartPoint.y
-- 	local fontSize = VIPOrderManager.outputFontSize
-- 	local maxTitelTextWidth = 0
-- 	local maxQuantityTextWidth = 0
-- 	local isOrderCompleted = true
-- 	local payoutTotal = 0
-- 	VIPOrderManager.outputLines = {}	-- Output lines for the draw() function (text, size, bold, colorId, x, y)

-- 	local title = "Current VIP Order"
-- 	local VIPOrder = VIPOrderManager.currentVIPOrder
-- 	local level = VIPOrderManager.orderLevel - 1
-- 	if VIPOrderManager.showVIPOrder == 2 then
-- 		VIPOrder = VIPOrderManager.nextVIPOrder
-- 		title = "Next VIP Order"
-- 		level = VIPOrderManager.orderLevel
-- 	end


-- 	-- calculate max text widths
-- 	for _, vipOrderEntry in pairs(VIPOrder) do
-- 		local fillTypeTitle = g_fillTypeManager:getFillTypeByName(vipOrderEntry.fillTypeName).title
-- 		local titelTextWidth = getTextWidth(fontSize, "  " .. fillTypeTitle .. "  ")
-- 		local quantityTextWidth = getTextWidth(fontSize, string.format("%s", vipOrderEntry.quantity))

-- 		if titelTextWidth > maxTitelTextWidth then
-- 			maxTitelTextWidth = titelTextWidth
-- 		end

-- 		if quantityTextWidth > maxQuantityTextWidth then
-- 			maxQuantityTextWidth = quantityTextWidth
-- 		end
-- 	end

-- 	table.insert(VIPOrderManager.outputLines, {text = string.format("%s (Level: %s):", title, level), size = fontSize, bold = true, align=RenderText.ALIGN_LEFT, colorId = 7, x = posX, y = posY})
-- 	posY = posY - fontSize
	
-- 	for _, vipOrderEntry in pairs(VIPOrder) do
-- 		local fillTypeTitle = g_fillTypeManager:getFillTypeByName(vipOrderEntry.fillTypeName).title

-- 		local posXIncrease=0
	
-- 		local line = string.format("%s /  ", g_i18n:formatNumber(vipOrderEntry.fillLevel, 0))
-- 		local fillLevelColor = 7;
-- 		if vipOrderEntry.fillLevel >= vipOrderEntry.quantity then
-- 			fillLevelColor = 6
-- 		end
-- 		posXIncrease = maxQuantityTextWidth + getTextWidth(fontSize, "  /  ")
-- 		table.insert(VIPOrderManager.outputLines, {text = line, size = fontSize, bold = false, align=RenderText.ALIGN_RIGHT, colorId = fillLevelColor, x = posX + posXIncrease, y = posY})
-- 		local line = string.format("%s", g_i18n:formatNumber(vipOrderEntry.quantity, 0))	-- , g_i18n:getVolumeUnit(false))
-- 		posXIncrease = posXIncrease + maxQuantityTextWidth
-- 		table.insert(VIPOrderManager.outputLines, {text = line, size = fontSize, bold = false, align=RenderText.ALIGN_RIGHT, colorId = 7, x = posX + posXIncrease, y = posY})

-- 		local line = string.format("  %s", fillTypeTitle)
-- 		table.insert(VIPOrderManager.outputLines, {text = line, size = fontSize, bold = false, align=RenderText.ALIGN_LEFT, colorId = 7, x = posX + posXIncrease, y = posY})
-- 		posY = posY - fontSize

-- 		isOrderCompleted = isOrderCompleted and (vipOrderEntry.fillLevel >= vipOrderEntry.quantity)
-- 		payoutTotal = payoutTotal + vipOrderEntry.payout
-- 	end
	
-- 	local line = string.format("Payout: %s", g_i18n:formatMoney(payoutTotal, 0, true)) --, false))	-- g_i18n:formatMoney(value, bool Währung ausgeben, bool Währung vor dem Betrag?)
-- 	table.insert(VIPOrderManager.outputLines, {text = line, size = fontSize, bold = true, align=RenderText.ALIGN_LEFT, colorId = 7, x = posX, y = posY})
-- 	return isOrderCompleted and VIPOrderManager:getCountElements(VIPOrder) > 0
-- end


function VIPOrderManager:MakePayout()
	print("call VIPOrderManager:MakePayout()");

	-- show message
	g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_OK, "VIP order was completed.")

	-- Pay out profit
	local payoutTotal = VIPOrderManager:GetPayoutTotal()
	g_currentMission:addMoney(payoutTotal, g_currentMission.player.farmId, MoneyType.MISSIONS, true, true);
end


function VIPOrderManager:update(dt)
    VIPOrderManager.updateDelta = VIPOrderManager.updateDelta + dt;
	VIPOrderManager.infoDisplayPastTime = VIPOrderManager.infoDisplayPastTime + dt

	if VIPOrderManager.updateDelta > VIPOrderManager.updateRate then
		VIPOrderManager.updateDelta = 0;

		if VIPOrderManager.infoDisplayPastTime > VIPOrderManager.infoDisplayMaxShowTime then
			VIPOrderManager.showVIPOrder = 0;
			VIPOrderManager.infoDisplayPastTime = 0
		end

		if g_currentMission:getIsClient() and g_gui.currentGui == nil then
			local isOrderCompleted = VIPOrderManager:UpdateOutputLines()
			if isOrderCompleted then
				VIPOrderManager:MakePayout()
				VIPOrderManager.currentVIPOrder = {}
			end
			if VIPOrderManager:getCountElements(VIPOrderManager.currentVIPOrder) == 0 then
				VIPOrderManager:CreateNewVIPOrder()
			end
			if VIPOrderManager:getCountElements(VIPOrderManager.nextVIPOrder) == 0 then
				VIPOrderManager:CreateNextVIPOrder()
			end
		end;
	end;
end;


function VIPOrderManager:draw()
	-- Only render when no other GUI is open
    if g_gui.currentGuiName ~= "InGameMenu" and VIPOrderManager.showVIPOrder > 0 then --if g_gui.currentGui == nil
		for _, line in ipairs(VIPOrderManager.outputLines) do
			VIPOrderManager:renderText(line.x, line.y, line.size, line.text, line.bold, line.colorId, line.align)
		end;
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
	print("call VIPOrderManager:saveSettings()");
	local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory.."/";
	if savegameFolderPath == nil then
		savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex.."/");
	end;
	local key = "VIPOrderManager";
	local storePlace = g_currentMission.storeSpawnPlaces[1];
	local xmlFile = createXMLFile(key, savegameFolderPath.."VIPOrderManager.xml", key);
	setXMLString(xmlFile, key.."#XMLFileVersion", "1.0");
	setXMLInt(xmlFile, key.."#orderLevel", VIPOrderManager.orderLevel);
	setXMLInt(xmlFile, key..".countOrderItemsRange#Min", VIPOrderManager.countOrderItemsRange.min)
	setXMLInt(xmlFile, key..".countOrderItemsRange#Max", VIPOrderManager.countOrderItemsRange.max)
	setXMLInt(xmlFile, key..".quantityFactor#Min", VIPOrderManager.quantityFactor.min)
	setXMLInt(xmlFile, key..".quantityFactor#Max", VIPOrderManager.quantityFactor.max)
	setXMLInt(xmlFile, key..".payoutFactor#Min", VIPOrderManager.payoutFactor.min)
	setXMLInt(xmlFile, key..".payoutFactor#Max", VIPOrderManager.payoutFactor.max)

	local i = 0
	for _, vipOrder in pairs(VIPOrderManager.currentVIPOrder) do
		local localKey = string.format("%s.currentorder(%d)", key, i)
		setXMLString(xmlFile, localKey.."#fillTypeName", vipOrder.fillTypeName)
		setXMLInt(xmlFile, localKey.."#quantity", vipOrder.quantity)
		setXMLInt(xmlFile, localKey.."#fillLevel", vipOrder.fillLevel)
		setXMLInt(xmlFile, localKey.."#payout", vipOrder.payout)
		setXMLString(xmlFile, localKey.."#fillTypeTitle_OnlyAsInfo", g_fillTypeManager:getFillTypeByName(vipOrder.fillTypeName).title)
		i = i + 1
	end

	i = 0
	for _, vipOrder in pairs(VIPOrderManager.nextVIPOrder) do
		local localKey = string.format("%s.nextorder(%d)", key, i)
		setXMLString(xmlFile, localKey.."#fillTypeName", vipOrder.fillTypeName)
		setXMLInt(xmlFile, localKey.."#quantity", vipOrder.quantity)
		setXMLInt(xmlFile, localKey.."#fillLevel", vipOrder.fillLevel)
		setXMLInt(xmlFile, localKey.."#payout", vipOrder.payout)
		setXMLString(xmlFile, localKey.."#fillTypeTitle_OnlyAsInfo", g_fillTypeManager:getFillTypeByName(vipOrder.fillTypeName).title)
		i = i + 1
	end

	saveXMLFile(xmlFile);
	delete(xmlFile);
end

function VIPOrderManager:loadSettings()
	print("call VIPOrderManager:loadSettings()")
	local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory
	if savegameFolderPath == nil then
		savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex)
	end;
	savegameFolderPath = savegameFolderPath.."/"
	local key = "VIPOrderManager"

	if fileExists(savegameFolderPath.."VIPOrderManager.xml") then
		local xmlFile = loadXMLFile(key, savegameFolderPath.."VIPOrderManager.xml")

		local XMLFileVersion = getXMLString(xmlFile, key.."#XMLFileVersion")
		VIPOrderManager.orderLevel = Utils.getNoNil(getXMLInt(xmlFile, key.."#orderLevel"), 1)
		VIPOrderManager.countOrderItemsRange.min = Utils.getNoNil(getXMLInt(xmlFile, key..".countOrderItemsRange#Min"), VIPOrderManager.countOrderItemsRange.min)
		VIPOrderManager.countOrderItemsRange.max = Utils.getNoNil(getXMLInt(xmlFile, key..".countOrderItemsRange#Max"), VIPOrderManager.countOrderItemsRange.max)
		VIPOrderManager.quantityFactor.min = Utils.getNoNil(getXMLInt(xmlFile, key..".quantityFactor#Min"), VIPOrderManager.quantityFactor.min)
		VIPOrderManager.quantityFactor.max = Utils.getNoNil(getXMLInt(xmlFile, key..".quantityFactor#Max"), VIPOrderManager.quantityFactor.max)
		VIPOrderManager.payoutFactor.min = Utils.getNoNil(getXMLInt(xmlFile, key..".payoutFactor#Min"), VIPOrderManager.payoutFactor.min)
		VIPOrderManager.payoutFactor.max = Utils.getNoNil(getXMLInt(xmlFile, key..".payoutFactor#Max"), VIPOrderManager.payoutFactor.max)

		local index = 0
		while true do
			local localKey = string.format("%s.currentorder(%d)", key, index)
			if hasXMLProperty(xmlFile, localKey) then
				local fillTypeName = getXMLString(xmlFile, localKey.."#fillTypeName")
				local quantity = getXMLInt(xmlFile, localKey.."#quantity")
				local fillLevel = Utils.getNoNil(getXMLInt(xmlFile, localKey.."#fillLevel"), 0)
				local payout = getXMLInt(xmlFile, localKey.."#payout")
				VIPOrderManager.currentVIPOrder[fillTypeName] = {fillTypeName=fillTypeName, quantity=quantity, fillLevel=fillLevel, payout=payout}
				index = index + 1
			else
				break
			end
		end

		index = 0
		while true do
			local localKey = string.format("%s.nextorder(%d)", key, index)
			if hasXMLProperty(xmlFile, localKey) then
				local fillTypeName = getXMLString(xmlFile, localKey.."#fillTypeName")
				local quantity = getXMLInt(xmlFile, localKey.."#quantity")
				local fillLevel = Utils.getNoNil(getXMLInt(xmlFile, localKey.."#fillLevel"), 0)
				local payout = getXMLInt(xmlFile, localKey.."#payout")
				VIPOrderManager.nextVIPOrder[fillTypeName] = {fillTypeName=fillTypeName, quantity=quantity, fillLevel=fillLevel, payout=payout}
				index = index + 1
			else
				break
			end
		end



		delete(xmlFile);
	end;
	return VIPOrderManager.isLoaded;
end;


function VIPOrderManager:round(num, numDecimalPlaces)
	local mult = 10^(numDecimalPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
  end


-- Observe "SellingStation.addFillLevelFromTool" when products are sold at points of sale
function VIPOrderManager.sellingStation_addFillLevelFromTool(station, superFunc, farmId, deltaFillLevel, fillType, fillInfo, toolType)
	local moved = 0
	moved = superFunc(station, farmId, deltaFillLevel, fillType, fillInfo, toolType)

	-- print(string.format("  moved=%s | deltaFillLevel=%s | fillType=%s | fillInfo=%s | toolType=%s", tostring(moved),  tostring(deltaFillLevel), tostring(fillType), tostring(fillInfo), tostring(toolType)))

	if moved > 0 then
		local ft = g_fillTypeManager:getFillTypeByIndex(fillType)
        local vipOrder = VIPOrderManager.currentVIPOrder[ft.name]
        -- print(string.format("  Anzahl Order Items=%s", VIPOrderManager:getCountElements(VIPOrderManager.currentVIPOrder)))
		if vipOrder ~= nil then
			vipOrder.fillLevel = math.min(vipOrder.fillLevel + moved, vipOrder.quantity)
			VIPOrderManager.showVIPOrder = 1;
			VIPOrderManager.infoDisplayPastTime = 0
			VIPOrderManager:UpdateOutputLines()
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