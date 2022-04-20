-- Author: Fetty42
-- Date: 16.04.2022
-- Version: 1.0.0.0


OrderFrame = {
	CONTROLS = {
		DIALOG_TITLE = "dialogTitleElement",
        TABLE = "orderTable",
        TABLE_TEMPLATE = "orderRowTemplate",
		BUTTON_ABORT = "buttonAbort"
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
	self.buttonAbort.inputActionName = InputAction.MENU_EXTRA_1
end


function OrderFrame:onOpen()
	-- dbPrintf("OrderFrame:onOpen()")
	OrderFrame:superClass().onOpen(self)
	FocusManager:setFocus(self.orderTable)
end


function OrderFrame:setVIPOrders(VIPOrders)   
	-- dbPrintf("OrderFrame:setVIPOrders()")

	-- fill table data (fillTypeName, quantity, fillLevel, payout, targetStation, isCompleted)
	self.VIPOrdersData = {}

	-- hudOverlayFilename :: dataS/menu/hud/fillTypes/hud_fill_grass.png

	-- current VIPOrder
	for _, vipOrder in pairs(VIPOrders) do
		local VIPOrderData = {title = "No title", orders = {}}	
		local payoutTotal = 0
		for _, vipOrderEntry in pairs(vipOrder.entries) do
			local orderEntry = {}
			orderEntry.ftTitle = g_fillTypeManager:getFillTypeByName(vipOrderEntry.fillTypeName).title
			-- orderEntry.requiredQuantity = g_i18n:formatNumber(vipOrderEntry.quantity - math.ceil(vipOrderEntry.fillLevel), 1, false)
			orderEntry.fillLevel = g_i18n:formatVolume(math.ceil(vipOrderEntry.fillLevel), 0)
			orderEntry.quantity = g_i18n:formatVolume(vipOrderEntry.quantity, 0)
			orderEntry.isCompleted =  math.ceil(vipOrderEntry.fillLevel) >= vipOrderEntry.quantity
			
			if vipOrderEntry.targetStation ~= nil then
				orderEntry.targetStation = vipOrderEntry.targetStation.owningPlaceable:getName()
			else
				orderEntry.targetStation = "Free choice"
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
	cell:getAttribute("ftTitle"):setText(orderEntry.ftTitle)
 	cell:getAttribute("quantity"):setText(orderEntry.quantity)
	cell:getAttribute("fillLevel"):setText(orderEntry.fillLevel)
	cell:getAttribute("payout"):setText(orderEntry.payout)
	cell:getAttribute("targetStation"):setText(orderEntry.targetStation)

	local bold = section == 1 -- only the active order
	local color = {1, 1, 1, 1}
	local colorSelected = {1, 1, 1, 1}
	
	dbPrintf("section=%s | index=%s | ftTitle=%s | quantity=%s | filllevel=%s", section, index, orderEntry.ftTitle, orderEntry.quantity, orderEntry.fillLevel)
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
	cell:getAttribute("targetStation").textBold = bold

	cell:getAttribute("ftTitle"):setTextColor(unpack(color))
	cell:getAttribute("ftTitle"):setTextSelectedColor(unpack(colorSelected))
	cell:getAttribute("quantity").textColor = color
	cell:getAttribute("quantity"):setTextSelectedColor(unpack(colorSelected))
	cell:getAttribute("fillLevel").textColor = color
	cell:getAttribute("fillLevel"):setTextSelectedColor(unpack(colorSelected))
	cell:getAttribute("payout").textColor = color
	cell:getAttribute("payout"):setTextSelectedColor(unpack(colorSelected))
	cell:getAttribute("targetStation").textColor = color
	cell:getAttribute("targetStation"):setTextSelectedColor(unpack(colorSelected))

	-- dbPrintf("** Start DebugUtil.printTableRecursively() ************************************************************")
	-- DebugUtil.printTableRecursively(cell:getAttribute("targetStation"), ".", 0, 2)
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

