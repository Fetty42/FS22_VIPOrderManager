-- Author: Fetty42
-- Date: 22.10.2023
-- Version: 1.3.1.0

VIPOrderManager.isAnimalOrdersWished= true

-- orders definition for order level 1 and own field area of 1 ha
VIPOrderManager.countOrderItemsRange = {min=2, max=4}
VIPOrderManager.quantityFactor = {min=7, max=9}
VIPOrderManager.payoutFactor = {min=3, max=5}

VIPOrderManager.isLimitedPercentage = 20 -- Max share of limited products

-- Depending on the OrderLeven, special correction factors for count, quantity and payout
VIPOrderManager.orderLevelCorrectionFactors = {}
VIPOrderManager.orderLevelCorrectionFactors[1] = {0.40, 0.60, 1.00}
VIPOrderManager.orderLevelCorrectionFactors[2] = {0.65, 0.80, 1.00}
VIPOrderManager.orderLevelCorrectionFactors[3] = {0.90, 1.00, 1.00}


-- Constants for filltype selection
-- VIPOrderManager.fillTypesNeededFruitType = {ALFALFA_WINDROW="ALFALFA", DRYALFALFA_WINDROW="ALFALFA", ALFALFA_FERMENTED="ALFALFA", CLOVER_WINDROW="CLOVER", DRYCLOVER_WINDROW="CLOVER", CLOVER_FERMENTED="CLOVER", Carrot="CARROT"} -- filltype check for maps who not support MaizePlus
VIPOrderManager.fillTypesNoPriceList = {}

-- constants
VIPOrderManager.maxVIPOrdersCount	= 4		-- Count of already calculated orders (preview)
VIPOrderManager.abortFeeInPercent = 35
VIPOrderManager.allowSumQuantitySameFT = false	-- Summarize quantity of same filetypes
VIPOrderManager.ownFieldArea = 1	-- min field area
VIPOrderManager.rangeAnimalCheckTime = {min=8, max=17}
VIPOrderManager.rangeAnimalAgeDifInMonths = {min=5, max=12}
VIPOrderManager.rangeAnimalDummyPrice = {min=500, max=800}
VIPOrderManager.minOrderLevelDecreaseIfProductionOrAnimalHusbandryExists = 2
VIPOrderManager.probabilityMultiplierIfProductionOrAnimalHusbandryExists = 2


-- isAllowed (true, false) - whether the fill type is offered 
-- minOrderLevel (1 - n) - from which level the fill type is offered
-- quantityCorrectionFactor (> 0) - Factor for the correction of the quantity calculation
-- isLimited (true, false) - whether the fill type is limted to x prozent of the order items
-- minOrderLevelIfProductionOrAnimalHusbandryExists	- Korrection of needed minOrderLevel if production allready exists
-- probability - The probability with which this filltype is taken when selected. Default is 100%
VIPOrderManager.ftConfigs = 
{
	-- Defaults
	DEFAULT_FILLTYPE	= {isUnknown=true, isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.6, isLimited=true, probability=30},		-- for unknown filltypes
	DEFAULT_FRUITTYPE	= {isUnknown=true, isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.5, isLimited=false, probability=40},		-- for unknown fruittypes
	DEFAULT_ANIMALTYPE_COW		= {isUnknown=true, isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.5, isLimited=false, probability=30},		-- for unknown animals
	DEFAULT_ANIMALTYPE_SHEEP	= {isUnknown=true, isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.6, isLimited=false, probability=30},		-- for unknown animals
	DEFAULT_ANIMALTYPE_PIG		= {isUnknown=true, isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.5, isLimited=false, probability=30},		-- for unknown animals
	DEFAULT_ANIMALTYPE_HORSE	= {isUnknown=true, isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.3, isLimited=false, probability=30},		-- for unknown animals
	DEFAULT_ANIMALTYPE_CHICKEN	= {isUnknown=true, isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.5, isLimited=false, probability=30},		-- for unknown animals
	DEFAULT_ANIMALTYPE			= {isUnknown=true, isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=0.6, isLimited=false, probability=30},		-- for unknown animals

		
	-- Not Allowed
	STONE 			= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Steine
	ROUNDBALE 		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Rundballen
	ROUNDBALE_WOOD 	= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- RundballenHolz
	SQUAREBALE 		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Quaderballen
	WATER	 		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Wasser
	LIME			= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},		-- Kalk
	SOYBEANSTRAW	= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},
	EMPTYPALLET		= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},
	SEEDS			= {isAllowed=false, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false},

	-- Basic crops
	BARLEY 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Gerste
	WHEAT 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Weizen
	OAT 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Hafer
	CANOLA 			= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Raps
	SORGHUM 		= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Sorghumhirse
	SOYBEAN 		= {isAllowed=true, minOrderLevel=1, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Sojabohnen
	SUNFLOWER 		= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Sonnenblumen
	MAIZE 			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.0, isLimited=false, probability=80, probabilityMaizePlus=50},		-- Mais
	SUGARBEET 		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Zuckerrüben
	SUGARBEET_CUT	= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, probability=40},		-- Zuckerrübenschnitzel
	POTATO 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, probability=70},		-- Kartoffeln
	OLIVE 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Oliven
	GRAPE 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Trauben
	COTTON 			= {isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Baumwolle
	SUGARCANE 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Zuckerrohr

	-- Straw, grass and chaff
	STRAW 				= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.4, isLimited=false, probability=70},		-- Stroh
	GRASS_WINDROW 		= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.4, isLimited=false, probability=50},		-- Gras
	DRYGRASS_WINDROW 	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50},		-- Heu
	SILAGE 				= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.5, isLimited=false, probability=70, quantityCorrectionFactorMaizePlus=0.1, probabilityMaizePlus=50},		-- Silage
	CHAFF 				= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=70, probabilityMaizePlus=0},		-- Häckselgut

	-- Tree products
	WOOD 		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=1.0, isLimited=false, probability=50},		-- Holz
	WOODCHIPS 	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.8, isLimited=false, probability=50},		-- Hackschnitzel

	-- Animal products
	HONEY 			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.3, isLimited=false, probability=60},		-- Honig
	EGG 			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.7, isLimited=false, probability=30},		-- Eier
	WOOL 			= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.7, isLimited=false, probability=30},		-- Wolle
	MILK 			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=1.0, isLimited=false, probability=30},		-- Milch
	LIQUIDMANURE 	= {isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=0.1, isLimited=false, probability=15},		-- Gülle
	MANURE 			= {isAllowed=true, minOrderLevel=5, quantityCorrectionFactor=0.1, isLimited=false, probability=15},		-- Mist

	-- Greenhouse products
	STRAWBERRY 	= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.8, isLimited=false, probability=40},		-- Erdbeeren
	TOMATO 		= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.8, isLimited=false, probability=40},		-- Tomaten
	LETTUCE 	= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.8, isLimited=false, probability=40},		-- Salat

	-- Factory products
	DIESEL 			= {isAllowed=false, minOrderLevel=6, quantityCorrectionFactor=0.5, isLimited=true},		-- Diesel
	GRAPEJUICE 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Traubensaft
	OLIVE_OIL 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Olivenöl
	RAISINS 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Rosinen
	SUGAR 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Zucker
	SUNFLOWER_OIL 	= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Sonnenblumenöl
	BUTTER 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Butter
	CANOLA_OIL 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Rapsöl
	FLOUR 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Mehl
	BOARDS 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Bretter
	BREAD 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Brot
	CHEESE 			= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Käse
	CLOTHES 		= {isAllowed=true, minOrderLevel=6, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Kleidung
	FABRIC			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Stoff
	CAKE 			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Kuchen
	CEREAL 			= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Müsli
	CHOCOLATE 		= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Schokolade
	FURNITURE 		= {isAllowed=true, minOrderLevel=7, quantityCorrectionFactor=0.7, isLimited=true, probability=20},		-- Möbel

	-- MaizePlus
	CHOPPEDMAIZE			= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.7, isLimited=false, probability=50},
	CHOPPEDMAIZE_FERMENTED	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.7, isLimited=false, probability=50},
	CCM						= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50},
	CCMRAW					= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50},
	GRAINGRIST				= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=80},
	GRASS_FERMENTED			= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50},
	POTATO_CUT				= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=60},

	-- MaizePlus - only allowed if fruittype exists
	CARROT					= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=70, neededFruittype="CARROT"},
	CLOVER_WINDROW			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.4, isLimited=false, probability=50, neededFruittype="CLOVER"},
	DRYCLOVER_WINDROW		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50, neededFruittype="CLOVER"},
	CLOVER_FERMENTED		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50, neededFruittype="CLOVER"},
	ALFALFA_WINDROW			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.4, isLimited=false, probability=50, neededFruittype="ALFALFA"},
	DRYALFALFA_WINDROW		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50, neededFruittype="ALFALFA"},
	ALFALFA_FERMENTED		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50, neededFruittype="ALFALFA"},
	DRYHORSEGRASS_WINDROW	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50, neededFruittype="HORSEGRASS"},
	HORSEGRASS_FERMENTED	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50, neededFruittype="HORSEGRASS"},

	-- other new Filltypes
	LUCERNE_WINDROW			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=0.4, isLimited=false, probability=50, neededFruittype="LUCERNE"},
	DRYLUCERNE_WINDROW		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false, probability=50, neededFruittype="LUCERNE"},
	
	

	-- MaizePlus - not allowed because is only buyable
	CROP_WINDROW			= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	WETGRASS_WINDROW		= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	SEMIDRYGRASS_WINDROW	= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	BREWERSGRAIN			= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	BREWERSGRAIN_FERMENTED	= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	BEETPULP				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
	BEETPULP_FERMENTED		= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},
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
	EMPTYPALLET				= {isAllowed=false, minOrderLevel=3, quantityCorrectionFactor=0.4, isLimited=false},

	-- standard Animals
	CHICKEN					= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.5, isLimited=false, probability=50},
	CHICKEN_ROOSTER			= {isAllowed=true, minOrderLevel=2, quantityCorrectionFactor=1.5, isLimited=false, probability=40},
	SHEEP_BLACK_WELSH		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.6, isLimited=false, probability=30},
	SHEEP_SWISS_MOUNTAIN	= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.6, isLimited=false, probability=30},
	SHEEP_LANDRACE			= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.6, isLimited=false, probability=30},
	SHEEP_STEINSCHAF		= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.6, isLimited=false, probability=30},
	COW_HOLSTEIN			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.5, isLimited=false, probability=20},
	COW_LIMOUSIN			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.5, isLimited=false, probability=20},
	COW_SWISS_BROWN			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.5, isLimited=false, probability=20},
	COW_ANGUS				= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.5, isLimited=false, probability=20},
	PIG_BLACK_PIED			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.5, isLimited=false, probability=25},
	PIG_LANDRACE			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.5, isLimited=false, probability=25},
	PIG_BERKSHIRE			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.5, isLimited=false, probability=25},
	HORSE_BAY				= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.3, isLimited=false, probability=20},
	HORSE_PALOMINO			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.3, isLimited=false, probability=20},
	HORSE_CHESTNUT			= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.3, isLimited=false, probability=20},
	HORSE_DUN				= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.3, isLimited=false, probability=20},
	HORSE_PINTO				= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.3, isLimited=false, probability=20},
	HORSE_BLACK				= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.3, isLimited=false, probability=20},
	HORSE_GRAY				= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.3, isLimited=false, probability=20},
	HORSE_SEAL_BROWN		= {isAllowed=true, minOrderLevel=4, quantityCorrectionFactor=0.3, isLimited=false, probability=20}
}