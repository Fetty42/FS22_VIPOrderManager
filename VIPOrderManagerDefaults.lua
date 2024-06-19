-- Author: Fetty42
-- Date: 29.03.2024
-- Version: 1.3.3.0

VIPOrderManager.isAnimalOrdersWished= true

-- orders definition for order level 1 and own field area of 1 ha
VIPOrderManager.countOrderItemsRange = {min=3, max=5}
VIPOrderManager.quantityFactor = {min=5, max=7}
VIPOrderManager.payoutFactor = {min=4, max=6}

-- Depending on the OrderLeven, special correction factors for count, quantity and payout
VIPOrderManager.orderLevelCorrectionFactors = {}
VIPOrderManager.orderLevelCorrectionFactors[1] = {0.40, 0.60, 1.00}
VIPOrderManager.orderLevelCorrectionFactors[2] = {0.65, 0.80, 1.00}
VIPOrderManager.orderLevelCorrectionFactors[3] = {0.90, 1.00, 1.00}


-- Constants for filltype selection
VIPOrderManager.fillTypesNoPriceList = {}
VIPOrderManager.acceptOwnPlaceableProductionPointsAsSellingStation = true	-- accept own placeable production points if fill types is not also loadable at the same time


-- constants
VIPOrderManager.maxVIPOrdersCount = 4		-- Count of already calculated orders (preview)
VIPOrderManager.abortFeeInPercent = 35
VIPOrderManager.allowSumQuantitySameFT = false	-- Summarize quantity of same filetypes
VIPOrderManager.ownFieldArea = 1	-- min field area
VIPOrderManager.rangeAnimalAgeDifInMonths = {min=6, max=12}
VIPOrderManager.rangeAnimalDummyPrice = {min=500, max=800}

VIPOrderManager.limitedGroupsPercent = {} -- Max share of limited groups
-- VIPOrderManager.limitedGroupsPercent["animal"] = 50
-- VIPOrderManager.limitedGroupsPercent["production"] = 30

VIPOrderManager.numPrioTrysForGroup = 100

VIPOrderManager.groupNameSettings = {}
table.insert(VIPOrderManager.groupNameSettings, {groupName="basic crop", 					sectionOrder=1, probability=60})
table.insert(VIPOrderManager.groupNameSettings, {groupName="windrowed, silaged, chopped", 	sectionOrder=2, probability=30})
table.insert(VIPOrderManager.groupNameSettings, {groupName="animal", 						sectionOrder=3, probability=60})
table.insert(VIPOrderManager.groupNameSettings, {groupName="production easy", 				sectionOrder=4, probability=40})
table.insert(VIPOrderManager.groupNameSettings, {groupName="production", 					sectionOrder=5, probability=20})


-- overwrite group name which comes from the ftConfig defaults
VIPOrderManager.defaultGroupNameOverwriting = {}
VIPOrderManager.defaultGroupNameOverwriting["GOATMILK"] = "production easy"
VIPOrderManager.defaultGroupNameOverwriting["FORAGE"] = "production easy"


-- Base values per animaltyp to correct num of animals for orders
-- VIPOrderManager.animalFoodConsumptionPerMonthBase["CHICKEN"]= 5		-- 4
-- VIPOrderManager.animalFoodConsumptionPerMonthBase["SHEEP"]= 15		-- 72
-- VIPOrderManager.animalFoodConsumptionPerMonthBase["PIG"]= 20		-- 150
-- VIPOrderManager.animalFoodConsumptionPerMonthBase["HORSE"]= 400		-- 400
-- VIPOrderManager.animalFoodConsumptionPerMonthBase["COW"]= 450		-- 650

-- -- for farm "Hof Bergmann"
-- VIPOrderManager.animalFoodConsumptionPerMonthBase["CAT"]= 2
-- VIPOrderManager.animalFoodConsumptionPerMonthBase["PULLET"]= 5
-- VIPOrderManager.animalFoodConsumptionPerMonthBase["RABBIT"]= 8		-- 10
-- VIPOrderManager.animalFoodConsumptionPerMonthBase["BULL"]= 450


-- groupName="<group name>"
-- isAllowed (true, false) - whether the fill type is offered 
-- minOrderLevel {(1-n)(, (1-n), (1-n))} - from which level the fill type is offered (1:default, 2:existing, 3:self owned)
-- quantityCorrectionFactor (> 0) - Factor for the correction of the quantity calculation
-- isLimited (true, false) - whether the fill type is limted to x prozent of the order items --> depricated
-- minOrderLevelIfProductionOrAnimalHusbandryExists	- Korrection of needed minOrderLevel if production allready exists
-- probability {(1-n)(, (1-n), (1-n))} - The probability with which this filltype is taken when selected. (1:default, 2:existing, 3:sef owned)
VIPOrderManager.ftConfigs = 
{
	-- Not Allowed
	STONE 			= {isAllowed=false, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={0}},		-- Steine
	ROUNDBALE 		= {isAllowed=false, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={0}},		-- Rundballen
	ROUNDBALE_WOOD 	= {isAllowed=false, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={0}},		-- RundballenHolz
	SQUAREBALE 		= {isAllowed=false, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={0}},		-- Quaderballen
	WATER	 		= {isAllowed=false, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={0}},		-- Wasser
	LIME			= {isAllowed=false, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={0}},		-- Kalk
	SOYBEANSTRAW	= {isAllowed=false, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={0}},		-- Sojabohnen Stroh
	EMPTYPALLET		= {isAllowed=false, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={0}},		-- leere Paletten

	-- defaults
	DEFAULT_FRUITTYPE			= {groupName="basic crop", isUnknown=true, isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.5, probability={30}},						-- for unknown fruittypes
	DEFAULT_FILLTYPE			= {groupName="production", isUnknown=true, isAllowed=true, minOrderLevel={5,4,2}, quantityCorrectionFactor=1.0, probability={2, 5, 15}},			-- for unknown filltypes (booster possible)
	DEFAULT_ANIMALTYPE			= {groupName="animal", isUnknown=true, isAllowed=true, minOrderLevel={4,3,2}, quantityCorrectionFactor=0.5, probability={40, 60, 70}, animalFoodConsumptionBase=10},	-- for unknown animals (booster possible)

	-- standard animals (booster possible)
	ANIMALTYPE_CHICKEN	= {groupName="animal", isAllowed=true, minOrderLevel={2,1,1}, quantityCorrectionFactor=2.5, probability={30, 40, 50}, animalFoodConsumptionBase=5},		-- max consumption: 5 (Maize+: 4)
	ANIMALTYPE_SHEEP	= {groupName="animal", isAllowed=true, minOrderLevel={3,2,1}, quantityCorrectionFactor=4.0, probability={30, 35, 50}, animalFoodConsumptionBase=30},		-- max consumption: 15 (Maize+: 72)
	ANIMALTYPE_COW		= {groupName="animal", isAllowed=true, minOrderLevel={4,3,2}, quantityCorrectionFactor=1.5, probability={20, 30, 50}, animalFoodConsumptionBase=400},	-- max consumption: 450 (Maize+: 650)
	ANIMALTYPE_PIG		= {groupName="animal", isAllowed=true, minOrderLevel={4,3,2}, quantityCorrectionFactor=7.0, probability={20, 30, 50}, animalFoodConsumptionBase=20},		-- max consumption: 20 (Maize+: 150)
	ANIMALTYPE_HORSE	= {groupName="animal", isAllowed=true, minOrderLevel={4,3,2}, quantityCorrectionFactor=0.5, probability={20, 30, 50}, animalFoodConsumptionBase=200},	-- max consumption: 400 (Maize+: 400)

	-- other animals (booster possible)
	ANIMALTYPE_BULL		= {groupName="animal", isAllowed=true, minOrderLevel={4,3,2}, quantityCorrectionFactor=0.4, probability={5, 7, 20}, animalFoodConsumptionBase=400},	-- Hof Bergmann, max consumption: 450
	ANIMALTYPE_CAT		= {groupName="animal", isAllowed=true, minOrderLevel={4,3,2}, quantityCorrectionFactor=0.2, probability={5, 7, 10}, animalFoodConsumptionBase=2},		-- Hof Bergmann, max consumption: 2
	ANIMALTYPE_RABBIT	= {groupName="animal", isAllowed=true, minOrderLevel={4,3,2}, quantityCorrectionFactor=1.0, probability={10, 15, 30}, animalFoodConsumptionBase=8},		-- Hof Bergmann, max consumption: 8
	ANIMALTYPE_PULLET	= {groupName="animal", isAllowed=true, minOrderLevel={4,3,2}, quantityCorrectionFactor=2.0, probability={20, 30, 50}, animalFoodConsumptionBase=5},		-- Hof Bergmann, max consumption: 5

	-- Animal products (booster possible)
	HONEY 				= {groupName="production easy", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=0.3, probability={25}},				-- Honig
	EGG 				= {groupName="production easy", isAllowed=true, minOrderLevel={2,1,1}, quantityCorrectionFactor=0.7, probability={15, 20, 25}},	-- Eier
	WOOL 				= {groupName="production easy", isAllowed=true, minOrderLevel={3,2,1}, quantityCorrectionFactor=0.7, probability={15, 17, 25}},	-- Wolle
	MILK 				= {groupName="production easy", isAllowed=true, minOrderLevel={4,3,2}, quantityCorrectionFactor=1.0, probability={10, 15, 25}},	-- Milch
	LIQUIDMANURE 		= {groupName="production easy", isAllowed=true, minOrderLevel={4,3,2}, quantityCorrectionFactor=0.1, probability={10, 15, 25}},	-- Gülle
	MANURE 				= {groupName="production easy", isAllowed=true, minOrderLevel={4,3,2}, quantityCorrectionFactor=0.1, probability={10, 15, 25}},	-- Mist

	-- Basic crops (incl. Premium Expansion)
	BARLEY 			= {groupName="basic crop", isAllowed=true, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={30}},		-- Gerste
	WHEAT 			= {groupName="basic crop", isAllowed=true, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={30}},		-- Weizen
	OAT 			= {groupName="basic crop", isAllowed=true, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={30}},		-- Hafer
	CANOLA 			= {groupName="basic crop", isAllowed=true, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={30}},		-- Raps
	SORGHUM 		= {groupName="basic crop", isAllowed=true, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={30}},		-- Sorghumhirse
	SOYBEAN 		= {groupName="basic crop", isAllowed=true, minOrderLevel={1}, quantityCorrectionFactor=1.0, probability={30}},		-- Sojabohnen
	SUNFLOWER 		= {groupName="basic crop", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=1.0, probability={30}},		-- Sonnenblumen
	MAIZE 			= {groupName="basic crop", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=1.0, probability={30}},		-- Mais
	SUGARBEET 		= {groupName="basic crop", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=1.0, probability={30}},		-- Zuckerrüben
	POTATO 			= {groupName="basic crop", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=1.0, probability={30}},		-- Kartoffeln
	OLIVE 			= {groupName="basic crop", isAllowed=true, minOrderLevel={4}, quantityCorrectionFactor=1.0, probability={30}},		-- Oliven
	GRAPE 			= {groupName="basic crop", isAllowed=true, minOrderLevel={4}, quantityCorrectionFactor=1.0, probability={30}},		-- Trauben
	COTTON 			= {groupName="basic crop", isAllowed=true, minOrderLevel={5}, quantityCorrectionFactor=1.0, probability={30}},		-- Baumwolle
	SUGARCANE 		= {groupName="basic crop", isAllowed=true, minOrderLevel={5}, quantityCorrectionFactor=1.0, probability={30}},		-- Zuckerrohr
	PARSNIP			= {groupName="basic crop", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.6, probability={30}, neededFruittype="PARSNIP"},	-- Premium Expansion
	BEETROOT		= {groupName="basic crop", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.6, probability={30}, neededFruittype="BEETROOT"},	-- Premium Expansion
	CARROT			= {groupName="basic crop", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.6, probability={30}, neededFruittype="CARROT"},	-- Premium Expansion

	-- Tree products
	WOOD 			= {groupName="production easy", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=2.0, probability={30}},		-- Holz
	WOODCHIPS 		= {groupName="production easy", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=0.8, probability={30}},		-- Hackschnitzel

	-- Greenhouse products (booster possible)
	STRAWBERRY 		= {groupName="production easy", isAllowed=true, minOrderLevel={3,2,1}, quantityCorrectionFactor=0.8, probability={15, 20, 30}},		-- Erdbeeren
	TOMATO 			= {groupName="production easy", isAllowed=true, minOrderLevel={3,2,1}, quantityCorrectionFactor=0.8, probability={15, 20, 30}},		-- Tomaten
	LETTUCE 		= {groupName="production easy", isAllowed=true, minOrderLevel={3,2,1}, quantityCorrectionFactor=0.8, probability={15, 20, 30}},		-- Salat

	-- Factory products
	SEEDS			= {groupName="production easy", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=1.0, probability={0, 20, 20}},		-- Samen
	DIESEL 			= {groupName="production easy", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=1.0, probability={0, 20, 20}},		-- Diesel
	FORAGE 			= {groupName="production easy", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=1.0, probability={20}},
	SUGARBEET_CUT	= {groupName="production easy", isAllowed=true, minOrderLevel={4}, quantityCorrectionFactor=0.4, probability={20}},		-- Zuckerrübenschnitzel
	POTATO_CUT		= {groupName="production easy", isAllowed=true, minOrderLevel={4}, quantityCorrectionFactor=0.4, probability={20}},

	-- Straw, grass and chaff
	STRAW 					= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=0.4, probability={20}},		-- Stroh
	GRASS_WINDROW 			= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=0.4, probability={20}},		-- Gras
	DRYGRASS_WINDROW 		= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=0.4, probability={20}},		-- Heu
	SILAGE 					= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=0.5, probability={30}, probabilityMaizePlus=20, quantityCorrectionFactorMaizePlus=0.3},		-- Silage
	CHAFF 					= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=0.4, probability={30}, probabilityMaizePlus=20, quantityCorrectionFactorMaizePlus=0.3},		-- Häckselgut

	-- MaizePlus
	GRASS_FERMENTED			= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={20}},
	CHOPPEDMAIZE			= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.7, probability={30}},
	CHOPPEDMAIZE_FERMENTED	= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.7, probability={30}},
	CCM						= {groupName="production easy", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={20}},
	CCMRAW					= {groupName="production easy", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={20}},
	GRAINGRIST				= {groupName="production easy", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={20}},

	-- MaizePlus - only allowed if fruittype exists
	-- CARROT					= {isAllowed=true, minOrderLevel=3, quantityCorrectionFactor=0.4, probability=70, neededFruittype="CARROT"},
	CLOVER_WINDROW			= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=0.4, probability={20}, neededFruittype="CLOVER"},
	DRYCLOVER_WINDROW		= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={20}, neededFruittype="CLOVER"},
	CLOVER_FERMENTED		= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={20}, neededFruittype="CLOVER"},
	ALFALFA_WINDROW			= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=0.4, probability={20}, neededFruittype="ALFALFA"},
	DRYALFALFA_WINDROW		= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={20}, neededFruittype="ALFALFA"},
	ALFALFA_FERMENTED		= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={20}, neededFruittype="ALFALFA"},
	DRYHORSEGRASS_WINDROW	= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={20}, neededFruittype="HORSEGRASS"},
	HORSEGRASS_FERMENTED	= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={20}, neededFruittype="HORSEGRASS"},

	-- other new Filltypes
	LUCERNE_WINDROW			= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={2}, quantityCorrectionFactor=0.4, probability={20}, neededFruittype="LUCERNE"},
	DRYLUCERNE_WINDROW		= {groupName="windrowed, silaged, chopped", isAllowed=true, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={20}, neededFruittype="LUCERNE"},

	-- MaizePlus - not allowed because is only buyable
	CROP_WINDROW			= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	WETGRASS_WINDROW		= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	SEMIDRYGRASS_WINDROW	= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	BREWERSGRAIN			= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	BREWERSGRAIN_FERMENTED	= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	BEETPULP				= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	BEETPULP_FERMENTED		= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	MOLASSES				= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	CLEAREDWATER			= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	HAYPELLETS				= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	CHICKENFOOD				= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	FEEDPELLETS				= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	HORSEFOOD				= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	MINERALS				= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	PIGFOOD2				= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	POWERFOOD				= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}},
	SHEEPFOOD				= {isAllowed=false, minOrderLevel={3}, quantityCorrectionFactor=0.4, probability={0}}
}