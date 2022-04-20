-- Author: Fetty42
-- Date: 16.04.2022
-- Version: 1.0.0.0


-- isAllowed (true, false) - whether the fill type is offered 
-- minOrderLevel (1 - n) - from which level the fill type is offered
-- quantityCorrectionFactor (> 0) - Factor for the correction of the quantity calculation
-- isLimited (true, false) - whether the fill type is limted to x prozent of the order items
-- minOrderLevelIfProductionExists	- Korrection of needed minOrderLevel if production allready exists
VIPOrderManager.ftConfigs = 
{
	-- Defaults
	DEFAULT_FRUITTYPE	= {isUnknown=true, isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.0, isLimited=false},		-- for unknown fruittypes
	DEFAULT_FILLTYPE	= {isUnknown=true, isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4},		-- for unknown filltypes
	
	-- Not Allowed
	STONE 			= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Steine
	ROUNDBALE 		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Rundballen
	ROUNDBALE_WOOD 	= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- RundballenHolz
	SQUAREBALE 		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Quaderballen
	WATER	 		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Wasser

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

	-- Straw, grass and chaff
	STRAW 				= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.4, isLimited=false},		-- Stroh
	GRASS_WINDROW 		= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.4, isLimited=false},		-- Gras
	DRYGRASS_WINDROW 	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},		-- Heu
	SILAGE 				= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.5, isLimited=false},		-- Silage
	CHAFF 				= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.5, isLimited=false},		-- Häckselgut

	-- Tree products
	WOOD 		= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false},		-- Holz
	WOODCHIPS 	= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.8, isLimited=false},		-- Hackschnitzel

	-- Animal products
	HONEY 			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.3, isLimited=false},		-- Honig
	EGG 			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.7, isLimited=false, minOrderLevelIfProductionExists=1},		-- Eier
	WOOL 			= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.7, isLimited=false, minOrderLevelIfProductionExists=2},		-- Wolle
	MILK 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, minOrderLevelIfProductionExists=2},		-- Milch
	LIQUIDMANURE 	= {isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=0.3, isLimited=false, minOrderLevelIfProductionExists=3},		-- Gülle
	MANURE 			= {isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=0.3, isLimited=false, minOrderLevelIfProductionExists=3},		-- Mist

	-- Greenhouse products
	STRAWBERRY 	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.8, isLimited=false},		-- Erdbeeren
	TOMATO 		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.8, isLimited=false},		-- Tomaten
	LETTUCE 	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.8, isLimited=false},		-- Salat

	-- Factory products
	DIESEL 			= {isAllowed=false, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Diesel
	GRAPEJUICE 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Traubensaft
	OLIVE_OIL 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Olivenöl
	RAISINS 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Rosinen
	SUGAR 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Zucker
	SUNFLOWER_OIL 	= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Sonnenblumenöl
	BUTTER 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Butter
	CANOLA_OIL 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Rapsöl
	FLOUR 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Mehl
	BOARDS 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Bretter
	BREAD 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Brot
	CHEESE 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Käse
	CLOTHES 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3},		-- Kleidung
	FABRIC			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4},		-- Stoff
	CAKE 			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4},		-- Kuchen
	CEREAL 			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4},		-- Müsli
	CHOCOLATE 		= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4},		-- Schokolade
	FURNITURE 		= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4}		-- Möbel
}

-- orders definition for order level 1 and own field area of 1 ha
VIPOrderManager.countOrderItemsRange = {min=2, max=4}
VIPOrderManager.quantityFactor = {min=8, max=10}
VIPOrderManager.payoutFactor = {min=3, max=5}

VIPOrderManager.isLimitedPercentage = 20 -- Max share of limited products

-- Depending on the OrderLeven, special correction factors for count, quantity and payout
VIPOrderManager.orderLevelCorrectionFactors = {}
VIPOrderManager.orderLevelCorrectionFactors[1] = {0.50, 0.50, 1.00}
-- VIPOrderManager.orderLevelCorrectionFactors[2] = {0.75, 0.65, 1.00}
-- VIPOrderManager.orderLevelCorrectionFactors[3] = {1.00, 0.75, 1.00}


-- Constants for filltype selection
-- VIPOrderManager.fillTypesNeededFruitType = {ALFALFA_WINDROW="ALFALFA", DRYALFALFA_WINDROW="ALFALFA", ALFALFA_FERMENTED="ALFALFA", CLOVER_WINDROW="CLOVER", DRYCLOVER_WINDROW="CLOVER", CLOVER_FERMENTED="CLOVER", Carrot="CARROT"} -- filltype check for maps who not support MaizePlus
VIPOrderManager.fillTypesNoPriceList = {}

-- constants
VIPOrderManager.maxVIPOrdersCount	= 4		-- Count of already calculated orders (preview)
VIPOrderManager.abortFeeInPercent = 25
VIPOrderManager.allowSumQuantitySameFT = false	-- Summarize quantity of same filetypes
VIPOrderManager.ownFieldArea = 1	-- min field area


