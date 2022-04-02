-- Author: Fetty42
-- Date: 02.01.2022
-- Version: 1.1.0.0

VIPOrderManager = {}; -- Class

-- isAllowed (true, false) - whether the fill type is offered 
-- minOrderLevel (1 - n) - from which level the fill type is offered
-- quantityCorrectionFactor (> 0) - Factor for the correction of the quantity calculation
-- isLimited (true, false) - whether the fill type is limted to x prozent of the order items
VIPOrderManager.ftConfigs = 
{
	-- Defaults
	DEFAULT_FRUITTYPE	= {isUnknown=true, isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.0, isLimited=false},		-- for unknown fruittypes
	DEFAULT_FILLTYPE	= {isUnknown=true, isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true},		-- for unknown filltypes
	
	-- Not Allowed
	STONE 			= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Steine
	ROUNDBALE 		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Rundballen
	ROUNDBALE_WOOD 	= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- RundballenHolz
	SQUAREBALE 		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Quaderballen

	-- Basic crops
	BARLEY 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Gerste
	WHEAT 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Weizen
	OAT 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Hafer
	CANOLA 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Raps
	SORGHUM 		= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Sorghumhirse
	SOYBEAN 		= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Sojabohnen
	SUNFLOWER 		= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.0, isLimited=false},		-- Sonnenblumen
	MAIZE 			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.0, isLimited=false},		-- Mais
	SUGARBEET 		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=1.0, isLimited=false},		-- Zuckerrüben
	SUGARBEET_CUT	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=1.0, isLimited=false},		-- Zuckerrübenschnitzel
	POTATO 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false},		-- Kartoffeln
	OLIVE 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false},		-- Oliven
	GRAPE 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false},		-- Trauben
	COTTON 			= {isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=1.0, isLimited=false},		-- Baumwolle
	SUGARCANE 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=1.0, isLimited=false},		-- Zuckerrohr

	-- Straw and grass
	STRAW 				= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.6, isLimited=false},		-- Stroh
	GRASS_WINDROW 		= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.6, isLimited=false},		-- Gras
	DRYGRASS_WINDROW 	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.6, isLimited=false},		-- Heu
	SILAGE 				= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.6, isLimited=false},		-- Silage

	-- Tree products
	WOOD 		= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false},		-- Holz
	WOODCHIPS 	= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.8, isLimited=false},		-- Hackschnitzel

	-- Animal products
	HONEY 			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.3, isLimited=false},		-- Honig
	EGG 			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.7, isLimited=false},		-- Eier
	WOOL 			= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.7, isLimited=false},		-- Wolle
	MILK 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false},		-- Milch
	LIQUIDMANURE 	= {isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=0.3, isLimited=false},		-- Gülle
	MANURE 			= {isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=0.3, isLimited=false},		-- Mist

	-- Greenhouse products
	STRAWBERRY 	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.8, isLimited=false},		-- Erdbeeren
	TOMATO 		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.8, isLimited=false},		-- Tomaten
	LETTUCE 	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.8, isLimited=false},		-- Salat

	-- Factory products
	DIESEL 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Diesel
	GRAPEJUICE 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Traubensaft
	OLIVE_OIL 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Olivenöl
	RAISINS 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Rosinen
	SUGAR 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Zucker
	SUNFLOWER_OIL 	= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Sonnenblumenöl
	BUTTER 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Butter
	CANOLA_OIL 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Rapsöl
	FLOUR 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Mehl
	BOARDS 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Bretter
	BREAD 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Brot
	CHEESE 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Käse
	CLOTHES 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Kleidung
	FABRIC			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true},		-- Stoff
	CAKE 			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true},		-- Kuchen
	CEREAL 			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true},		-- Müsli
	CHOCOLATE 		= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true},		-- Schokolade
	FURNITURE 		= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true}		-- Möbel
}

-- orders definition for order level 1 and own field area of 1 ha
VIPOrderManager.countOrderItemsRange = {min=2, max=3}
VIPOrderManager.quantityFactor = {min=8, max=10}
VIPOrderManager.payoutFactor = {min=6, max=7}
VIPOrderManager.isLimitedPercentage = 20 -- percentage from current order level round off

-- Depending on the OrderLeven, special correction factors for count, quantity and payout
VIPOrderManager.orderLevelCorrectionFactors = {}
VIPOrderManager.orderLevelCorrectionFactors[1] = {0.50, 0.50, 1.00}
VIPOrderManager.orderLevelCorrectionFactors[2] = {0.75, 0.65, 1.00}
VIPOrderManager.orderLevelCorrectionFactors[3] = {1.00, 0.75, 1.00}


-- Constants for filltype selection
-- VIPOrderManager.fillTypesNeededFruitType = {ALFALFA_WINDROW="ALFALFA", DRYALFALFA_WINDROW="ALFALFA", ALFALFA_FERMENTED="ALFALFA", CLOVER_WINDROW="CLOVER", DRYCLOVER_WINDROW="CLOVER", CLOVER_FERMENTED="CLOVER", Carrot="CARROT"} -- filltype check for maps who not support MaizePlus
VIPOrderManager.fillTypesNoPriceList = {}

-- constants
VIPOrderManager.abortFeeInPercent = 25
VIPOrderManager.allowSumQuantitySameFT = false	-- Summarize quantity of same filetypes
VIPOrderManager.ownFieldArea = 1


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

VIPOrderManager.currentVIPOrder 	= {}	-- [Name] = {fillTypeName, quantity, fillLevel, payout, targetStation}
VIPOrderManager.nextVIPOrder 		= {}	-- [Name] = {fillTypeName, quantity, fillLevel, payout, targetStation}
VIPOrderManager.outputLines 		= {}	-- Output lines for the draw() function (text, size, bold, colorId, x, y)
VIPOrderManager.currentOrderLevel 	= 0		-- will be increased by 1 with each orders generation
VIPOrderManager.infoHud 			= nil	-- VID Order Info HUD
VIPOrderManager.OrderDlg			= nil


source(Utils.getFilename("InfoHUD.lua", VIPOrderManager.dir))
source(VIPOrderManager.dir .. "gui/OrderFrame.lua")

function VIPOrderManager:loadMap(name)
--   print("call VIPOrderManager:loadMap()");

	Player.registerActionEvents = Utils.appendedFunction(Player.registerActionEvents, VIPOrderManager.registerActionEvents);
	Drivable.onRegisterActionEvents = Utils.appendedFunction(Drivable.onRegisterActionEvents, VIPOrderManager.registerActionEvents);
	VIPOrderManager.eventName = {};

	FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, VIPOrderManager.saveSettings);
	FSBaseMission.onFinishedLoading = Utils.appendedFunction(FSBaseMission.onFinishedLoading, VIPOrderManager.loadSettings);
	--VIPOrderManager:loadSettings();

	SellingStation.addFillLevelFromTool = Utils.overwrittenFunction(SellingStation.addFillLevelFromTool, VIPOrderManager.sellingStation_addFillLevelFromTool)	
end;


function VIPOrderManager:registerActionEvents()
	-- print("call VIPOrderManager:registerActionEvents()");

	local result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'ShowCurrentVIPOrder',self, VIPOrderManager.ShowCurrentVIPOrder ,false ,true ,false ,true)
	if result then
        table.insert(VIPOrderManager.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = true;
    end
	-- result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'AbortCurrentVIPOrder',self, VIPOrderManager.AbortCurrentVIPOrder ,false ,true ,false ,true)
	-- if result then
    --     table.insert(VIPOrderManager.eventName, eventName);
	-- 	g_inputBinding.events[eventName].displayIsVisible = true;
    -- end
	result, eventName = InputBinding.registerActionEvent(g_inputBinding, 'ShowVIPOrderDlg',self, VIPOrderManager.ShowVIPOrderDlg ,false ,true ,false ,true)
	if result then
        table.insert(VIPOrderManager.eventName, eventName);
		g_inputBinding.events[eventName].displayIsVisible = true;
    end

	if infoHud == nil then
		infoHud = InfoHUD.new()
		infoHud:setVisible(true)
	end
	-- hud:delete()
end;


--  
function VIPOrderManager:ShowVIPOrderDlg(actionName, keyStatus, arg3, arg4, arg5)
	-- print("call VIPOrderManager:ShowVIPOrderDlg()");

	VIPOrderManager.OrderDlg = nil
	g_gui:loadProfiles(VIPOrderManager.dir .. "gui/guiProfiles.xml")
	local orderFrame = OrderFrame.new(g_i18n) 
	g_gui:loadGui(VIPOrderManager.dir .. "gui/OrderFrame.xml", "OrderFrame", orderFrame)
	VIPOrderManager.OrderDlg = g_gui:showDialog("OrderFrame")

	if VIPOrderManager.OrderDlg ~= nil then
        VIPOrderManager.OrderDlg.target:setVIPOrders(VIPOrderManager.currentOrderLevel, VIPOrderManager.currentVIPOrder, VIPOrderManager.nextVIPOrder)
    end
end


-- Payout complete orders less a abort fee for incomplete orders. 
--function VIPOrderManager:AbortCurrentVIPOrder(actionName, keyStatus, arg3, arg4, arg5)
function VIPOrderManager:AbortCurrentVIPOrder()
	print("call VIPOrderManager:AbortCurrentVIPOrder()");

	local sumAbortFee, sumPayout = VIPOrderManager:GetSumAbortFeeAndSumPayout()

	-- g_gui:showYesNoDialog({text=g_i18n:getText("tour_text_start"), title="", callback=self.reactToDialog, target=self})
	local msgText = string.format(g_i18n:getText("VIPOrderManager_DlgMsg_AbortCurrentVIPOrder"), g_i18n:formatMoney(sumAbortFee, 0, true), g_i18n:formatMoney(sumPayout, 0, true))
	g_gui:showYesNoDialog({text=msgText, title=g_i18n:getText("VIPOrderManager_DlgTitel_AbortCurrentVIPOrder"), callback=VIPOrderManager.reactToDialog_AbortCurrentVIPOrder, target=self})
end


function VIPOrderManager:reactToDialog_AbortCurrentVIPOrder(yes)
	-- print("call VIPOrderManager:reactToDialog_AbortCurrentVIPOrder()");
    if yes then
		local sumAbortFee, sumPayout = VIPOrderManager:GetSumAbortFeeAndSumPayout()
	
		-- show message and payout
		-- print(string.format("  sumAbortFee=%s | sumPayout=%s", g_i18n:formatMoney(sumAbortFee, 0, true), g_i18n:formatMoney(sumPayout, 0, true)))
		g_currentMission:addMoney(sumPayout, g_currentMission.player.farmId, MoneyType.MISSIONS, true, true);
		g_currentMission:addMoney(sumAbortFee, g_currentMission.player.farmId, MoneyType.MISSIONS, true, true);

		VIPOrderManager.currentVIPOrder = {}
		VIPOrderManager:RestockVIPOrders()
		if VIPOrderManager.OrderDlg ~= nil then
			VIPOrderManager.OrderDlg.target:setVIPOrders(VIPOrderManager.currentOrderLevel, VIPOrderManager.currentVIPOrder, VIPOrderManager.nextVIPOrder)
		end
    end
end


function VIPOrderManager:GetSumAbortFeeAndSumPayout()
	-- print("call VIPOrderManager:GetSumAbortFeeAndSumPayout()");
	local sumPayout = 0
	local sumAbortFee = 0

	for _, vipOrderEntry in pairs(VIPOrderManager.currentVIPOrder) do
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
	-- print("call VIPOrderManager:RestockVIPOrders()");

	VIPOrderManager.ownFieldArea = VIPOrderManager:CalculateOwnFieldArea()

	if self.currentVIPOrder == nil or VIPOrderManager:getCountElements(self.currentVIPOrder) == 0 then
		VIPOrderManager.currentOrderLevel  = VIPOrderManager.currentOrderLevel + 1
		if self.nextVIPOrder ~= nil and VIPOrderManager:getCountElements(self.nextVIPOrder) > 0 then
			self.currentVIPOrder = self.nextVIPOrder
			self.nextVIPOrder = {}
		else
			VIPOrderManager:calculateAndFillOrder(self.currentVIPOrder, VIPOrderManager.currentOrderLevel)
		end
		self.showVIPOrder = 1
		self.infoDisplayPastTime = 0
		VIPOrderManager:UpdateOutputLines()
	end

	if self.nextVIPOrder == nil or VIPOrderManager:getCountElements(self.nextVIPOrder) == 0 then
		VIPOrderManager:calculateAndFillOrder(self.nextVIPOrder, VIPOrderManager.currentOrderLevel + 1)
	end
end


function VIPOrderManager:calculateAndFillOrder(VIPOrder, orderLevel)
	print("\ncall VIPOrderManager:calculateAndFillOrder()");

	local usableFillTypes = {};
	VIPOrderManager:GetUsableFillTypes(usableFillTypes, orderLevel)

	-- set the special corrections faktors depending on the current order level and the own field area
	-- for level=1, 20, 1 do
	-- 	local factorCount =     ((1 + level*0.04)-0.04)
	-- 	local factorQuantity =  ((1 + level*level*0.005) - 0.005)
	-- 	local factorPayout =   1/ ((1 + level*0.05) - 0.05)
	-- 	print(string.format("Level %2i: factorCount=%f | factorQuantity=%f | factorPayout=%f",
	-- 		level, factorCount, factorQuantity, factorPayout))
	-- end

	
	local specCorFactorCount = ((1 + orderLevel * 0.04) - 0.04)
	local specCorFactorQuantity = ((1 + orderLevel*orderLevel*0.005) - 0.005)
	local specCorFactorPayout = 1.0 / ((1 + orderLevel*0.05) - 0.05)
	print(string.format("\nCreate new VIP Order: Level %s", orderLevel))
	print(string.format("  Initial basic correction factors:"))
	print(string.format("    - Count factor    = %.2f", specCorFactorCount))
	print(string.format("    - Quantity factor = %.2f", specCorFactorQuantity))
	print(string.format("    - Payout factor   = %.2f", specCorFactorPayout))

	local ownFieldSizeFactor = ((1 + VIPOrderManager.ownFieldArea*0.3)-0.3)
	print("  Basic correction factors adjusted by the size of the own fields:")
	print("    - own field size        = " .. VIPOrderManager.ownFieldArea)
	print("    - own field size factor = " .. ownFieldSizeFactor)
	print(string.format("    - adjusted quantity factor from %.2f to %.2f", specCorFactorQuantity, specCorFactorQuantity * ownFieldSizeFactor))
	print(string.format("    - adjusted payout factor from   %.2f to %.2f", specCorFactorPayout, specCorFactorPayout / ownFieldSizeFactor))
	local specCorFactorQuantity = specCorFactorQuantity * ownFieldSizeFactor
	local specCorFactorPayout = specCorFactorPayout / ownFieldSizeFactor

	-- if necessary overright by Correction factors for easier beginning
	if VIPOrderManager.orderLevelCorrectionFactors[orderLevel] ~= nil then
		specCorFactorCount = VIPOrderManager.orderLevelCorrectionFactors[orderLevel][1]
		specCorFactorQuantity = VIPOrderManager.orderLevelCorrectionFactors[orderLevel][2]
		specCorFactorPayout = VIPOrderManager.orderLevelCorrectionFactors[orderLevel][3]
		print(string.format("  If necessary overright by Correction factors for easier beginning:"))
		print(string.format("    - Count factor    = %.2f", specCorFactorCount))
		print(string.format("    - Quantity factor = %.2f", specCorFactorQuantity))
		print(string.format("    - Payout factor   = %.2f", specCorFactorPayout))
	end

	-- create random order items
	local countFillTypes = #usableFillTypes
	local countOrderItems = math.floor(math.random(VIPOrderManager.countOrderItemsRange.min, VIPOrderManager.countOrderItemsRange.max) * specCorFactorCount + 0.5)
	print("  Calculate order item count:")
	print("    - min count      = " .. VIPOrderManager.countOrderItemsRange.min)
	print("    - max count      = " .. VIPOrderManager.countOrderItemsRange.max)
	print("    - Count factor   = " .. specCorFactorCount)
	print("    ==> Count order items = " .. countOrderItems)

	local maxLimitedOrderItems = math.floor(orderLevel / 100 * VIPOrderManager.isLimitedPercentage)
	print(string.format("  Max allowed limited order items: %s percent from %s = %s", VIPOrderManager.isLimitedPercentage, orderLevel, maxLimitedOrderItems))
	
	local i = 0
	while (i < countOrderItems) do
		i = i + 1
		print(string.format("\n  %s. Order Item:", i))
		
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
			print("  --> choose limited filltype")
		end

		local quantityCorrectionFactor = 1
		if ftConfig.quantityCorrectionFactor ~= nil then
			quantityCorrectionFactor = ftConfig.quantityCorrectionFactor
		end
		print(string.format("    - FillType: %s (%s) | filltype quantity factor = %.2f", fillType.name, fillType.title, quantityCorrectionFactor))

		local randomQuantityFaktor = math.random(VIPOrderManager.quantityFactor.min, VIPOrderManager.quantityFactor.max) * specCorFactorQuantity
		local randomPayoutFactor = math.random(VIPOrderManager.payoutFactor.min, VIPOrderManager.payoutFactor.max) * specCorFactorPayout
		local orderItemQuantity = math.floor(randomQuantityFaktor * 1000 / fillType.pricePerLiter * quantityCorrectionFactor)
		print(string.format("    - final quantity factor = %.2f", randomQuantityFaktor))
		print(string.format("    - final payout factor   = %.2f", randomPayoutFactor))
		

		if orderItemQuantity > 1000 then
			orderItemQuantity = math.floor(orderItemQuantity / 1000) * 1000
		elseif orderItemQuantity > 100 then
			orderItemQuantity = math.floor(orderItemQuantity / 100) * 100
		elseif orderItemQuantity > 10 then
			orderItemQuantity = math.floor(orderItemQuantity / 10) * 10
		end 
		print(string.format("    ==> Quantity = %.2f * 1000 / %.2f * %.2f = %s", randomQuantityFaktor, fillType.pricePerLiter, quantityCorrectionFactor, orderItemQuantity))
		
		local orderItemPayout = math.floor(orderItemQuantity * fillType.pricePerLiter * randomPayoutFactor/100)*100
		print(string.format("    ==> Payout   = %.2f * %.2f * %.2f = %s", orderItemQuantity, fillType.pricePerLiter, randomPayoutFactor, orderItemPayout))

		-- target station
		local targetStation = fillType.acceptingStations[math.random(1, #fillType.acceptingStations)]
		print(string.format("    ==> target station = %s", targetStation.owningPlaceable:getName()))

		if VIPOrder[fillType.name] ~= nil then
			if allowSumQuantitySameFT then
				-- Summ double entries
				VIPOrder[fillType.name].quantity = VIPOrder[fillType.name].quantity + orderItemQuantity/2
				VIPOrder[fillType.name].payout = VIPOrder[fillType.name].payout + orderItemPayout/2
				print("  Double --> Sum order items")
			else
				i = i - 1 	-- try again
				print("  Double --> discard current order item and try again")
			end
		else
			VIPOrder[fillType.name] = {fillTypeName=fillType.name, quantity=orderItemQuantity, fillLevel=0, payout=orderItemPayout, targetStation=targetStation}
		end
	end
end


function VIPOrderManager:CalculateOwnFieldArea()
	print("\ncall VIPOrderManager:CalculateOwnFieldArea()");

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

		print(string.format("  --> %s. Owned Farmland: id=%s | FieldCount=%s | FieldAreaSum=%s", i, farmland.id, fieldCount, g_i18n:formatArea(fieldAreaSum, 2)))
	end
	print(string.format("  ==> Field Area Overall: %s\n", g_i18n:formatArea(fieldAreaOverall, 2)))

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
	-- print(string.format("GetFillTypeConfig: ftName=%s --> ftConfig=%s (isUnknown=%s)", ftName, tostring(ftConfig), tostring(ftConfig.isUnknown)))
	
	return ftConfig
end


function VIPOrderManager:GetUsableFillTypes(usableFillTypes, orderLevel)
	print("\ncall VIPOrderManager:GetUsableFillTypes()");
	
	local sellableFillTypes = VIPOrderManager:getAllSellableFillTypes()

	-- Validate FillTypes	
	print("\nNot usable filltypes:")
	for index, sft in pairs(sellableFillTypes) do    
        print("  Validate FillTypes: " .. index .. " --> " .. sft.name .. " (" .. sft.title .. ")")
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
		if notUsableWarning == nil and ftConfig.minOrderLevel > orderLevel then
			if ftConfig.isUnknown ~= nil and ftConfig.isUnknown then
				--  unknown filltype
				notUsableWarning = string.format("Not usable, because current VIP-Order level (%s) is for new fill types not high enough (needs %s)", orderLevel, ftConfig.minOrderLevel)
			else
				notUsableWarning = string.format("Not usable, because current VIP-Order level (%s) is not high enough (needs %s)", orderLevel, ftConfig.minOrderLevel)
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
            print(defaultWarningText .. notUsableWarning)
        end
	end
	
	print("\nUsable filltypes:")
	for _, v in pairs(usableFillTypes) do    
		local tempNameOutput = string.format("%s (%s)", v.name, v.title)
		
		local stationList = ""
		for i=1, #v.acceptingStations do
			if stationList ~= "" then
				stationList = stationList .. ", "
			end
			stationList = stationList .. v.acceptingStations[i].owningPlaceable:getName()
		end
		
		print(string.format("  - %-40s | price=%f | Stations=%s", tempNameOutput, v.pricePerLiter, stationList));
	end
end


function VIPOrderManager:getAllSellableFillTypes()
	print("\ncall VIPOrderManager:getAllSellableFillTypes()");
	local sellableFillTypes = {}

	for _, station in pairs(g_currentMission.storageSystem.unloadingStations) do
		print(string.format("Station: getName=%s | typeName=%s | categoryName=%s | isSellingPoint=%s | currentSavegameId=%s", 
			station.owningPlaceable:getName(), tostring(station.owningPlaceable.typeName), tostring(station.owningPlaceable.storeItem.categoryName), tostring(station.isSellingPoint), station.owningPlaceable.currentSavegameId))
		-- PRODUCTIONPOINTS, SILOS, ANIMALPENS

		-- if station.uiName ~= nil and string.find(station.uiName, "Bäckerei") and 1==0 then
		-- 	print("** Start DebugUtil.printTableRecursively() ************************************************************")
		-- 	DebugUtil.printTableRecursively(station.owningPlaceable, ".", 0, 1)
		-- 	print("** End DebugUtil.printTableRecursively() **************************************************************\n")
		-- end

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
					
					-- print(string.format("  - filltype: %s (%s)%s", fillType.name, fillType.title, extraMsg))
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
	-- print("\ncall VIPOrderManager:ShowCurrentVIPOrder()");

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
	local posX = VIPOrderManager.outputStartPoint.x
	local posY = VIPOrderManager.outputStartPoint.y
	local fontSize = VIPOrderManager.outputFontSize
	local isOrderCompleted = true
	local payoutTotal = 0
	VIPOrderManager.outputLines = {}	-- Output lines for the draw() function (text, size, bold, colorId, x, y)

	local title = g_i18n:getText("VIPOrderManager_CurrentVIPOrder")
	local VIPOrder = VIPOrderManager.currentVIPOrder
	local level = VIPOrderManager.currentOrderLevel
	
	if VIPOrderManager.showVIPOrder == 2 then
		VIPOrder = VIPOrderManager.nextVIPOrder
		title = g_i18n:getText("VIPOrderManager_NextVIPOrder")
		level = VIPOrderManager.currentOrderLevel + 1
	end

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

	table.insert(VIPOrderManager.outputLines, {text = string.format("%s (Level: %s):", title, level), size = fontSize, bold = true, align=RenderText.ALIGN_LEFT, colorId = 7, x = posX, y = posY})
	posY = posY - fontSize
	
	local maxTextWidth = 0
	local posXIncrease = getTextWidth(fontSize, "  999.999  ")

	for _, vipOrderEntry in pairs(VIPOrder) do
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
		if (textWidth > maxTextWidth) then
			maxTextWidth = textWidth
		end

		isOrderCompleted = isOrderCompleted and requiredQuantity <= 0
		payoutTotal = payoutTotal + vipOrderEntry.payout
	end
	
	local line = string.format(g_i18n:getText("VIPOrderManager_Payout"), g_i18n:formatMoney(payoutTotal, 0, true)) --, false))	-- g_i18n:formatMoney(value, bool Währung ausgeben, bool Währung vor dem Betrag?)
	table.insert(VIPOrderManager.outputLines, {text = line, size = fontSize, bold = true, align=RenderText.ALIGN_LEFT, colorId = 7, x = posX, y = posY})
	posY = posY - fontSize

	if infoHud ~= nil then
		infoHud:setPosition(VIPOrderManager.outputStartPoint.x - 0.005, VIPOrderManager.outputStartPoint.y + 0.005 + fontSize)
		infoHud:setDimension(posXIncrease + maxTextWidth + 0.01, VIPOrderManager.outputStartPoint.y - posY + fontSize)
	end

	return isOrderCompleted and VIPOrderManager:getCountElements(VIPOrder) > 0
end


function VIPOrderManager:MakePayout()
	-- print("\ncall VIPOrderManager:MakePayout()");

	-- show message
	g_currentMission:addIngameNotification(FSBaseMission.INGAME_NOTIFICATION_OK, g_i18n:getText("VIPOrderManager_OrderCompleted"))

	-- Pay out profit
	local payoutTotal = VIPOrderManager:GetPayoutTotal()
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
				VIPOrderManager:MakePayout()
				VIPOrderManager.currentVIPOrder = {}
			end
			if VIPOrderManager:getCountElements(VIPOrderManager.currentVIPOrder) == 0 or VIPOrderManager:getCountElements(VIPOrderManager.nextVIPOrder) == 0 then
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
	-- print("call VIPOrderManager:saveSettings()");
	
	local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory.."/";
	if savegameFolderPath == nil then
		savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex.."/");
	end;
	local key = "VIPOrderManager";
	local storePlace = g_currentMission.storeSpawnPlaces[1];
	local xmlFile = createXMLFile(key, savegameFolderPath.."VIPOrderManager.xml", key);
	setXMLString(xmlFile, key.."#XMLFileVersion", "1.0");
	setXMLInt(xmlFile, key.."#orderLevel", VIPOrderManager.currentOrderLevel);
	setXMLInt(xmlFile, key..".countOrderItemsRange#Min", VIPOrderManager.countOrderItemsRange.min)
	setXMLInt(xmlFile, key..".countOrderItemsRange#Max", VIPOrderManager.countOrderItemsRange.max)
	setXMLInt(xmlFile, key..".quantityFactor#Min", VIPOrderManager.quantityFactor.min)
	setXMLInt(xmlFile, key..".quantityFactor#Max", VIPOrderManager.quantityFactor.max)
	setXMLInt(xmlFile, key..".payoutFactor#Min", VIPOrderManager.payoutFactor.min)
	setXMLInt(xmlFile, key..".payoutFactor#Max", VIPOrderManager.payoutFactor.max)

	-- current VIP order
	local i = 0
	for _, vipOrder in pairs(VIPOrderManager.currentVIPOrder) do
		local localKey = string.format("%s.currentorder(%d)", key, i)
		setXMLString(xmlFile, localKey.."#fillTypeName", vipOrder.fillTypeName)
		setXMLInt(xmlFile, localKey.."#quantity", vipOrder.quantity)
		setXMLInt(xmlFile, localKey.."#fillLevel", math.ceil(vipOrder.fillLevel))
		setXMLInt(xmlFile, localKey.."#payout", vipOrder.payout)
		setXMLString(xmlFile, localKey.."#fillTypeTitle_OnlyAsInfo", g_fillTypeManager:getFillTypeByName(vipOrder.fillTypeName).title)
		if vipOrder.targetStation ~= nil then
			setXMLInt(xmlFile, localKey.."#targetStationSavegameId", vipOrder.targetStation.owningPlaceable.currentSavegameId)
			setXMLString(xmlFile, localKey.."#targetStationName_OnlyAsInfo", vipOrder.targetStation.owningPlaceable:getName())
		end
		i = i + 1
	end

	-- next VIP order
	i = 0
	for _, vipOrder in pairs(VIPOrderManager.nextVIPOrder) do
		local localKey = string.format("%s.nextorder(%d)", key, i)
		setXMLString(xmlFile, localKey.."#fillTypeName", vipOrder.fillTypeName)
		setXMLInt(xmlFile, localKey.."#quantity", vipOrder.quantity)
		setXMLInt(xmlFile, localKey.."#fillLevel", vipOrder.fillLevel)
		setXMLInt(xmlFile, localKey.."#payout", vipOrder.payout)
		setXMLString(xmlFile, localKey.."#fillTypeTitle_OnlyAsInfo", g_fillTypeManager:getFillTypeByName(vipOrder.fillTypeName).title)
		if vipOrder.targetStation ~= nil then
			setXMLInt(xmlFile, localKey.."#targetStationSavegameId", vipOrder.targetStation.owningPlaceable.currentSavegameId)
			setXMLString(xmlFile, localKey.."#targetStationName_OnlyAsInfo", vipOrder.targetStation.owningPlaceable:getName())
		end
		i = i + 1
	end

	-- Write unknown filltypes as info
	-- isUnknown=true, isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.0, isLimited=false}
	i = 0
	for ftName, config in pairs(VIPOrderManager.ftConfigs) do
		if config.isUnknown ~= nil and config.isUnknown then
			local localKey = string.format("%s.UnknownFilltypesInfo(%d)", key, i)
			setXMLString(xmlFile, localKey.."#ftName", ftName)
			setXMLBool(xmlFile, localKey.."#isAllowed", config.isAllowed)
			setXMLInt(xmlFile, localKey.."#minOrderLevel", config.minOrderLevel)
			setXMLFloat(xmlFile, localKey.."#quantityCorrectionFactor", config.quantityCorrectionFactor)
			setXMLBool(xmlFile, localKey.."#isLimited", config.isLimited)
			i = i + 1
		end
	end
	
	saveXMLFile(xmlFile);
	delete(xmlFile);
end

function VIPOrderManager:loadSettings()
	-- print("call VIPOrderManager:loadSettings()")

	local savegameFolderPath = g_currentMission.missionInfo.savegameDirectory
	if savegameFolderPath == nil then
		savegameFolderPath = ('%ssavegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex)
	end;
	savegameFolderPath = savegameFolderPath.."/"
	local key = "VIPOrderManager"

	if fileExists(savegameFolderPath.."VIPOrderManager.xml") then
		local xmlFile = loadXMLFile(key, savegameFolderPath.."VIPOrderManager.xml")

		local XMLFileVersion = getXMLString(xmlFile, key.."#XMLFileVersion")
		VIPOrderManager.currentOrderLevel = Utils.getNoNil(getXMLInt(xmlFile, key.."#orderLevel"), 1)
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
				local targetStationSavegameId = getXMLInt(xmlFile, localKey.."#targetStationSavegameId")
				local targetStationName = getXMLString(xmlFile, localKey.."#targetStationName_OnlyAsInfo")
				-- print(string.format("loadSettings: %s | %s", targetStationSavegameId, targetStationName))
				local targetStation = VIPOrderManager:getStationBySavegameId(targetStationSavegameId)
				if targetStation ~= nil then
					-- print(string.format("  --> %s | %s", targetStation, targetStation.owningPlaceable:getName()))
				end

				VIPOrderManager.currentVIPOrder[fillTypeName] = {fillTypeName=fillTypeName, quantity=quantity, fillLevel=fillLevel, payout=payout, targetStation=targetStation}
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
				local targetStationSavegameId = getXMLInt(xmlFile, localKey.."#targetStationSavegameId")
				local targetStationName = getXMLString(xmlFile, localKey.."#targetStationName_OnlyAsInfo")
				-- print(string.format("loadSettings: %s | %s", targetStationSavegameId, targetStationName))
				local targetStation = VIPOrderManager:getStationBySavegameId(targetStationSavegameId)
				if targetStation ~= nil then
					-- print(string.format("  --> %s | %s", targetStation, targetStation.owningPlaceable:getName()))
				end

				VIPOrderManager.nextVIPOrder[fillTypeName] = {fillTypeName=fillTypeName, quantity=quantity, fillLevel=fillLevel, payout=payout, targetStation=targetStation}
				index = index + 1
			else
				break
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
	-- print(string.format("  stationCategoryName=%s | moved=%s | deltaFillLevel=%s | ftName=%s (%s) | ftIndex=%s | toolType=%s", tostring(stationCategoryName), tostring(moved), tostring(deltaFillLevel), ft.name, ft.title, tostring(fillType), tostring(toolType)))

	if moved > 0 then
        local vipOrder = VIPOrderManager.currentVIPOrder[ft.name]
        -- print(string.format("  Anzahl Order Items=%s", VIPOrderManager:getCountElements(VIPOrderManager.currentVIPOrder)))
		if vipOrder ~= nil then
			if vipOrder.targetStation == nil or vipOrder.targetStation == station then
				vipOrder.fillLevel = math.min(vipOrder.fillLevel + moved, vipOrder.quantity)
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