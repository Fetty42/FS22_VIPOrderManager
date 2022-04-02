
OrderFrame = {
	CONTROLS = {
		DIALOG_TITLE = "dialogTitleElement",
		-- CLOSE_BUTTON = "closeButton",
        TABLE = "fieldCalculatorOrderTable",
        TABLE_TEMPLATE = "fieldCalculatorOrderRowTemplate",
		-- BUTTON_CLOSE = "buttonClose",
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
	print("OrderFrame:onGuiSetupFinished()")
	OrderFrame:superClass().onGuiSetupFinished(self)
	self.fieldCalculatorOrderTable:setDataSource(self)
	self.fieldCalculatorOrderTable:setDelegate(self)
end

function OrderFrame:onCreate()
	print("OrderFrame:onCreate()")
	OrderFrame:superClass().onCreate(self)    
	self.buttonAbort.inputActionName = InputAction.MENU_EXTRA_1
end


function OrderFrame:onOpen()
	print("OrderFrame:onOpen()")
	OrderFrame:superClass().onOpen(self)
	FocusManager:setFocus(self.fieldCalculatorOrderTable)

	-- self.dialogTitleElement:setText("VIP Orders")

	-- if self.dialogTitleElement ~= nil then
    --     local headerText = g_i18n:getText("ui_orderFrame_header")
	-- 	self.dialogTitleElement:setText(Utils.getNoNil(headerText, "No title"))
	-- end

	-- print()
	-- print("** Start DebugUtil.printTableRecursively() ************************************************************")
	-- DebugUtil.printTableRecursively(self.buttonAbort, ".", 0, 1)
	-- print("** End DebugUtil.printTableRecursively() **************************************************************")
	-- print()
end

function OrderFrame:setVIPOrders(currentOrderLevel, currentVIPOrder, nextVIPOrder)   
	print("OrderFrame:setVIPOrders()")

	-- fill table data (fillTypeName, quantity, fillLevel, payout, targetStation)
	self.VIPOrdersData = {}

	-- hudOverlayFilename :: dataS/menu/hud/fillTypes/hud_fill_grass.png

	-- current VIPOrder
	local VIPOrder = {title = "No title", orders = {}}	
	local payoutTotal = 0
	for _, vipOrderEntry in pairs(currentVIPOrder) do
		local orderEntry = {}
		orderEntry.ftTitle = g_fillTypeManager:getFillTypeByName(vipOrderEntry.fillTypeName).title
		-- orderEntry.requiredQuantity = g_i18n:formatNumber(vipOrderEntry.quantity - math.ceil(vipOrderEntry.fillLevel), 1, false)
		orderEntry.fillLevel = g_i18n:formatVolume(math.ceil(vipOrderEntry.fillLevel), 0)
		orderEntry.quantity = g_i18n:formatVolume(vipOrderEntry.quantity, 0)
		orderEntry.targetStation = vipOrderEntry.targetStation.owningPlaceable:getName()
		orderEntry.payout = g_i18n:formatMoney(vipOrderEntry.payout, 0, true)	-- g_i18n:formatMoney(value, bool Währung ausgeben, bool Währung vor dem Betrag?)
		table.insert(VIPOrder.orders, orderEntry)	
		payoutTotal = payoutTotal + vipOrderEntry.payout
	end
	VIPOrder.title = string.format(g_i18n:getText("ui_orderDlg_section_active"), currentOrderLevel, g_i18n:formatMoney(payoutTotal, 0, true))
	table.insert(self.VIPOrdersData, VIPOrder)
    
	-- next VIPOrder
	local VIPOrder = {title = "No title", orders = {}}	
	local payoutTotal = 0
	for _, vipOrderEntry in pairs(nextVIPOrder) do
		local orderEntry = {}
		orderEntry.ftTitle = g_fillTypeManager:getFillTypeByName(vipOrderEntry.fillTypeName).title
		-- orderEntry.requiredQuantity = g_i18n:formatNumber(vipOrderEntry.quantity - math.ceil(vipOrderEntry.fillLevel), 1, false)
		orderEntry.fillLevel = g_i18n:formatVolume(math.ceil(vipOrderEntry.fillLevel), 1)
		orderEntry.quantity = g_i18n:formatVolume(vipOrderEntry.quantity, 1)
		orderEntry.targetStation = vipOrderEntry.targetStation.owningPlaceable:getName()
		orderEntry.payout = g_i18n:formatMoney(vipOrderEntry.payout, 0, true)	-- g_i18n:formatMoney(value, bool Währung ausgeben, bool Währung vor dem Betrag?)
		table.insert(VIPOrder.orders, orderEntry)	
		payoutTotal = payoutTotal + vipOrderEntry.payout
	end
	VIPOrder.title = string.format(g_i18n:getText("ui_orderDlg_section_notactive"), currentOrderLevel+1, g_i18n:formatMoney(payoutTotal, 0, true))
	table.insert(self.VIPOrdersData, VIPOrder)

	self.fieldCalculatorOrderTable:reloadData()    
end

function OrderFrame:getNumberOfSections()
	return #self.VIPOrdersData
end

function OrderFrame:getNumberOfItemsInSection(list, section)
	return #self.VIPOrdersData[section].orders
end

function OrderFrame:getTitleForSectionHeader(list, section)
	print("OrderFrame:getTitleForSectionHeader()")
	return self.VIPOrdersData[section].title
end


function OrderFrame:populateCellForItemInSection(list, section, index, cell)
	local orderEntry = self.VIPOrdersData[section].orders[index]    
	cell:getAttribute("ftTitle"):setText(orderEntry.ftTitle)
 	cell:getAttribute("quantity"):setText(orderEntry.quantity)
	cell:getAttribute("fillLevel"):setText(orderEntry.fillLevel)
	cell:getAttribute("payout"):setText(orderEntry.payout)
	cell:getAttribute("targetStation"):setText(orderEntry.targetStation)
end

function OrderFrame:onClose()
	print("OrderFrame:onClose()")
	OrderFrame:superClass().onClose(self)
end

function OrderFrame:onClickBack(sender)
	print("OrderFrame:onClickBack()")
	self:close()
end

function OrderFrame:onClickAbort()
	print("OrderFrame:onClickAbort()")
	VIPOrderManager:AbortCurrentVIPOrder()
end

