-- Author: Fetty42
-- Date: 08.04.2023
-- Version: 1.3.0.0


local dbPrintfOn = false

local function dbPrintf(...)
	if dbPrintfOn then
    	print(string.format(...))
	end
end



OrderFrame = {
	CONTROLS = {
		DIALOG_TITLE = "dialogTitleElement",
        TABLE = "orderTable",
        TABLE_TEMPLATE = "orderRowTemplate",
		BUTTON_ABORT = "buttonAbort",
		BUTTON_TAG = "buttonTag"
	}
}
local OrderFrame_mt = Class(OrderFrame, MessageDialog)

function OrderFrame.new(target, custom_mt)
	local self = MessageDialog.new(target, custom_mt or OrderFrame_mt)

	self:registerControls(OrderFrame.CONTROLS)

	return self
end

function OrderFrame:onGuiSetupFinished()
	-- dbPrintf("OrderFrame:onGuiSetupFinished()")
	OrderFrame:superClass().onGuiSetupFinished(self)
	self.orderTable:setDataSource(self)
	self.orderTable:setDelegate(self)
end

function OrderFrame:onCreate()
	-- dbPrintf("OrderFrame:onCreate()")
	OrderFrame:superClass().onCreate(self)    
end


function OrderFrame:onOpen()
	-- dbPrintf("OrderFrame:onOpen()")
	OrderFrame:superClass().onOpen(self)
	FocusManager:setFocus(self.orderTable)
end


function OrderFrame:setVIPOrders(VIPOrders)   
	-- dbPrintf("OrderFrame:setVIPOrders()")

	-- fill table data (title, quantity, fillLevel, payout, targetStationTitle, isCompleted, mapHotspot)
	self.VIPOrdersData = {}

	-- hudOverlayFilename :: dataS/menu/hud/fillTypes/hud_fill_grass.png

	-- current VIPOrder
	for _, vipOrder in pairs(VIPOrders) do
		local VIPOrderData = {title = "No title", orders = {}}	
		local payoutTotal = 0
		for _, vipOrderEntry in pairs(vipOrder.entries) do
			local orderEntry = {}
			orderEntry.ft = g_fillTypeManager:getFillTypeByName(vipOrderEntry.fillTypeName)
			if vipOrderEntry.isAnimal then
				orderEntry.fillLevel = string.format("%d %s", math.ceil(vipOrderEntry.fillLevel), g_i18n:getText("VIPOrderManager_Piece"))
				orderEntry.quantity = string.format("%d %s", vipOrderEntry.quantity, g_i18n:getText("VIPOrderManager_Piece"))
			else
				orderEntry.fillLevel = g_i18n:formatVolume(math.ceil(vipOrderEntry.fillLevel), 0)
				orderEntry.quantity = g_i18n:formatVolume(vipOrderEntry.quantity, 0)
			end
			orderEntry.isCompleted =  math.ceil(vipOrderEntry.fillLevel) >= vipOrderEntry.quantity
			orderEntry.title = vipOrderEntry.title
			
			orderEntry.mapHotspot = nil
			if vipOrderEntry.targetStation ~= nil then
				orderEntry.targetStationTitle = vipOrderEntry.targetStation.owningPlaceable:getName()
				if vipOrderEntry.targetStation.owningPlaceable.spec_hotspots ~= nil  and vipOrderEntry.targetStation.owningPlaceable.spec_hotspots.mapHotspots ~= nil then

					for _, mapHotspot in ipairs(vipOrderEntry.targetStation.owningPlaceable.spec_hotspots.mapHotspots) do
						if not p and mapHotspot.worldX ~= nil and mapHotspot.worldZ ~= nil then
							orderEntry.mapHotspot = mapHotspot
						end
					end
				end
			else
				if vipOrderEntry.isAnimal then
				orderEntry.targetStationTitle = g_i18n:getText("VIPOrderManager_Automatic")
				else
					orderEntry.targetStationTitle = g_i18n:getText("VIPOrderManager_FreeChoise")
				end
			end
			
			orderEntry.payout = g_i18n:formatMoney(vipOrderEntry.payout, 0, true)	-- g_i18n:formatMoney(value, bool Währung ausgeben, bool Währung vor dem Betrag?)
			table.insert(VIPOrderData.orders, orderEntry)	
			payoutTotal = payoutTotal + vipOrderEntry.payout
		end
		if vipOrder == VIPOrders[1] then
			VIPOrderData.title = string.format(g_i18n:getText("ui_orderDlg_section_active"), vipOrder.level, g_i18n:formatMoney(payoutTotal, 0, true))
		else
			VIPOrderData.title = string.format(g_i18n:getText("ui_orderDlg_section_notactive"), vipOrder.level, g_i18n:formatMoney(payoutTotal, 0, true))
		end
		table.insert(self.VIPOrdersData, VIPOrderData)
	end
   
	self.orderTable:reloadData()    
end


function OrderFrame:getNumberOfSections()
	return #self.VIPOrdersData
end


function OrderFrame:getNumberOfItemsInSection(list, section)
	return #self.VIPOrdersData[section].orders
end


function OrderFrame:getTitleForSectionHeader(list, section)
	-- dbPrintf("OrderFrame:getTitleForSectionHeader()")
	return self.VIPOrdersData[section].title
end


function OrderFrame:populateCellForItemInSection(list, section, index, cell)
	local orderEntry = self.VIPOrdersData[section].orders[index]    
	cell:getAttribute("fillTypeIcon"):setImageFilename(orderEntry.ft.hudOverlayFilename)
	cell:getAttribute("ftTitle"):setText(orderEntry.title)
 	cell:getAttribute("quantity"):setText(orderEntry.quantity)
	cell:getAttribute("fillLevel"):setText(orderEntry.fillLevel)
	cell:getAttribute("payout"):setText(orderEntry.payout)
	cell:getAttribute("targetStationTitle"):setText(orderEntry.targetStationTitle)

	local bold = section == 1 -- only the active order
	local color = {1, 1, 1, 1}
	local colorSelected = {1, 1, 1, 1}
	
	dbPrintf("section=%s | index=%s | title=%s | quantity=%s | filllevel=%s", section, index, orderEntry.title, orderEntry.quantity, orderEntry.fillLevel)
	if orderEntry.isCompleted then
		dbPrintf("order entry completed")
		-- color completed order entrys
		color = {0.2122, 0.5271, 0.0307, 1} 
		colorSelected = {0.0781, 0.2233, 0.0478, 1}
	end

	cell:getAttribute("ftTitle").textBold = bold
	cell:getAttribute("quantity").textBold = bold
	cell:getAttribute("fillLevel").textBold = bold
	cell:getAttribute("payout").textBold = bold
	cell:getAttribute("targetStationTitle").textBold = bold

	cell:getAttribute("ftTitle"):setTextColor(unpack(color))
	cell:getAttribute("ftTitle"):setTextSelectedColor(unpack(colorSelected))
	cell:getAttribute("quantity").textColor = color
	cell:getAttribute("quantity"):setTextSelectedColor(unpack(colorSelected))
	cell:getAttribute("fillLevel").textColor = color
	cell:getAttribute("fillLevel"):setTextSelectedColor(unpack(colorSelected))
	cell:getAttribute("payout").textColor = color
	cell:getAttribute("payout"):setTextSelectedColor(unpack(colorSelected))
	cell:getAttribute("targetStationTitle").textColor = color
	cell:getAttribute("targetStationTitle"):setTextSelectedColor(unpack(colorSelected))

	-- dbPrintf("** Start DebugUtil.printTableRecursively() ************************************************************")
	-- DebugUtil.printTableRecursively(cell:getAttribute("targetStationTitle"), ".", 0, 2)
	-- dbPrintf("** End DebugUtil.printTableRecursively() **************************************************************\n")
end


function OrderFrame:onClose()
	-- dbPrintf("OrderFrame:onClose()")
	OrderFrame:superClass().onClose(self)
end


function OrderFrame:onClickBack(sender)
	-- dbPrintf("OrderFrame:onClickBack()")
	self:close()
end


function OrderFrame:onClickAbort()
	-- dbPrintf("OrderFrame:onClickAbort()")
	VIPOrderManager:AbortCurrentVIPOrder()
end


function OrderFrame:onListSelectionChanged(list, section, index)
	local orderEntry = self.VIPOrdersData[section].orders[index]

	self.mapHotspot = orderEntry.mapHotspot
    if self.mapHotspot ~= nil then
        self.buttonTag.disabled = false
        if self.mapHotspot == g_currentMission.currentMapTargetHotspot then
            self.buttonTag.text = string.upper(g_i18n:getText("ui_orderDlg_btnUntagSellPoint"))
        else
            self.buttonTag.text = string.upper(g_i18n:getText("ui_orderDlg_btnTagSellPoint"))
        end
    else
        self.buttonTag.disabled = true
    end
end


function OrderFrame:onTagLocation(m)
    if self.mapHotspot ~= nil then
        if self.mapHotspot == g_currentMission.currentMapTargetHotspot then
            self.buttonTag.text = string.upper(g_i18n:getText("ui_orderDlg_btnTagSellPoint"))
            g_currentMission:setMapTargetHotspot()
        else
            self.buttonTag.text = string.upper(g_i18n:getText("ui_orderDlg_btnUntagSellPoint"))
            g_currentMission:setMapTargetHotspot(self.mapHotspot)
        end
    end
end
