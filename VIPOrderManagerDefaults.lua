-- Author: Fetty42
-- Date: 01.11.2022
-- Version: 1.2.0.0


-- isAllowed (true, false) - whether the fill type is offered 
-- minOrderLevel (1 - n) - from which level the fill type is offered
-- quantityCorrectionFactor (> 0) - Factor for the correction of the quantity calculation
-- isLimited (true, false) - whether the fill type is limted to x prozent of the order items
-- minOrderLevelIfProductionExists	- Korrection of needed minOrderLevel if production allready exists
-- probability - The probability with which this filltype is taken when selected. Default is 100%
VIPOrderManager.ftConfigs = 
{
	-- Defaults
	DEFAULT_FRUITTYPE	= {isUnknown=true, isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- for unknown fruittypes
	DEFAULT_FILLTYPE	= {isUnknown=true, isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4, probability=50},		-- for unknown filltypes
		
	-- Not Allowed
	STONE 			= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Steine
	ROUNDBALE 		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Rundballen
	ROUNDBALE_WOOD 	= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- RundballenHolz
	SQUAREBALE 		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Quaderballen
	WATER	 		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Wasser
	LIME			= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Kalk

	-- Basic crops
	BARLEY 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Gerste
	WHEAT 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Weizen
	OAT 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Hafer
	CANOLA 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Raps
	SORGHUM 		= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Sorghumhirse
	SOYBEAN 		= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Sojabohnen
	SUNFLOWER 		= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Sonnenblumen
	MAIZE 			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.0, isLimited=false, probability=100},		-- Mais
	SUGARBEET 		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=1.0, isLimited=false, probability=90},		-- Zuckerrüben
	SUGARBEET_CUT	= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, probability=90},		-- Zuckerrübenschnitzel
	POTATO 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, probability=90},		-- Kartoffeln
	OLIVE 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Oliven
	GRAPE 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Trauben
	COTTON 			= {isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Baumwolle
	SUGARCANE 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Zuckerrohr

	-- Straw, grass and chaff
	STRAW 				= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.4, isLimited=false, probability=80},		-- Stroh
	GRASS_WINDROW 		= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.4, isLimited=false, probability=50},		-- Gras
	DRYGRASS_WINDROW 	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50},		-- Heu
	SILAGE 				= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.5, isLimited=false, probability=50},		-- Silage
	CHAFF 				= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.5, isLimited=false, probability=80},		-- Häckselgut

	-- Tree products
	WOOD 		= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Holz
	WOODCHIPS 	= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.8, isLimited=false, probability=50},		-- Hackschnitzel

	-- Animal products
	HONEY 			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.3, isLimited=false},		-- Honig
	EGG 			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.7, isLimited=false, minOrderLevelIfProductionExists=1, probability=90},		-- Eier
	WOOL 			= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.7, isLimited=false, minOrderLevelIfProductionExists=2, probability=90},		-- Wolle
	MILK 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, minOrderLevelIfProductionExists=2, probability=90},		-- Milch
	LIQUIDMANURE 	= {isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=0.1, isLimited=false, minOrderLevelIfProductionExists=3, probability=50},		-- Gülle
	MANURE 			= {isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=0.1, isLimited=false, minOrderLevelIfProductionExists=3, probability=50},		-- Mist

	-- Greenhouse products
	STRAWBERRY 	= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.8, isLimited=false, probability=80},		-- Erdbeeren
	TOMATO 		= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.8, isLimited=false, probability=80},		-- Tomaten
	LETTUCE 	= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.8, isLimited=false, probability=80},		-- Salat

	-- Factory products
	DIESEL 			= {isAllowed=false, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Diesel
	GRAPEJUICE 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Traubensaft
	OLIVE_OIL 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Olivenöl
	RAISINS 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Rosinen
	SUGAR 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Zucker
	SUNFLOWER_OIL 	= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Sonnenblumenöl
	BUTTER 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Butter
	CANOLA_OIL 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Rapsöl
	FLOUR 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Mehl
	BOARDS 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Bretter
	BREAD 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Brot
	CHEESE 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Käse
	CLOTHES 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=3, probability=50},		-- Kleidung
	FABRIC			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4, probability=50},		-- Stoff
	CAKE 			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4, probability=50},		-- Kuchen
	CEREAL 			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4, probability=50},		-- Müsli
	CHOCOLATE 		= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4, probability=50},		-- Schokolade
	FURNITURE 		= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.5, isLimited=true, minOrderLevelIfProductionExists=4, probability=50},		-- Möbel

	-- MaizePlus
	CCM						= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=100},
	CCMRAW					= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=100},
	GRAINGRIST				= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=100},

	CHOPPEDMAIZE			= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.7, isLimited=false, probability=80},
	CHOPPEDMAIZE_FERMENTED	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.7, isLimited=false, probability=100},
	DRYGRASS_WINDROW 		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=80},
	GRASS_FERMENTED			= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=80},
	POTATO_CUT				= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=100},

	-- MaizePlus - only allowed if fruittype exists
	CARROT					= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=100, neededFruittype="CARROT"},
	DRYCLOVER_WINDROW		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=80, neededFruittype="CLOVER"},
	CLOVER_FERMENTED		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=80, neededFruittype="CLOVER"},
	DRYALFALFA_WINDROW		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=80, neededFruittype="ALFALFA"},
	ALFALFA_FERMENTED		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=80, neededFruittype="ALFALFA"},
	DRYHORSEGRASS_WINDROW	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=80, neededFruittype="HORSEGRASS"},
	HORSEGRASS_FERMENTED	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=80, neededFruittype="HORSEGRASS"},

	-- MaizePlus - is allowed, as the purchased product still has to be fermented
	BREWERSGRAIN_FERMENTED	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=100},
	BEETPULP_FERMENTED		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=100},

	-- MaizePlus - not allowed because is only buyable
	CROP_WINDROW			= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	WETGRASS_WINDROW		= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	SEMIDRYGRASS_WINDROW	= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	BREWERSGRAIN			= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	BEETPULP				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	MOLASSES				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	CLEAREDWATER			= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	FEEDPELLETS				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	HAYPELLETS				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	CHICKENFOOD				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	FEEDPELLETS				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	HORSEFOOD				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	MINERALS				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	PIGFOOD2				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	POWERFOOD				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	SHEEPFOOD				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	EMPTYPALLET				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false}
}


-- orders definition for order level 1 and own field area of 1 ha
VIPOrderManager.countOrderItemsRange = {min=3, max=5}
VIPOrderManager.quantityFactor = {min=7, max=9}
VIPOrderManager.payoutFactor = {min=4, max=6}

VIPOrderManager.isLimitedPercentage = 20 -- Max share of limited products

-- Depending on the OrderLeven, special correction factors for count, quantity and payout
VIPOrderManager.orderLevelCorrectionFactors = {}
VIPOrderManager.orderLevelCorrectionFactors[1] = {0.80, 0.70, 1.00}
VIPOrderManager.orderLevelCorrectionFactors[2] = {0.90, 0.85, 1.00}


-- Constants for filltype selection
-- VIPOrderManager.fillTypesNeededFruitType = {ALFALFA_WINDROW="ALFALFA", DRYALFALFA_WINDROW="ALFALFA", ALFALFA_FERMENTED="ALFALFA", CLOVER_WINDROW="CLOVER", DRYCLOVER_WINDROW="CLOVER", CLOVER_FERMENTED="CLOVER", Carrot="CARROT"} -- filltype check for maps who not support MaizePlus
VIPOrderManager.fillTypesNoPriceList = {}

-- constants
VIPOrderManager.maxVIPOrdersCount	= 4		-- Count of already calculated orders (preview)
VIPOrderManager.abortFeeInPercent = 25
VIPOrderManager.allowSumQuantitySameFT = false	-- Summarize quantity of same filetypes
VIPOrderManager.ownFieldArea = 1	-- min field area


