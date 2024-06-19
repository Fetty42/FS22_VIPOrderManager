-- Author: Fetty42
-- Date: 12.02.2023
-- Version: 1.1.0.0


local dbPrintfOn = false

local function dbPrintf(...)
	if dbPrintfOn then
    	print(string.format(...))
	end
end



-- AvailableTypesDlgFrame = {
-- 	CONTROLS = {
-- 		DIALOG_TITLE = "dialogTitleElement",
--         TABLE = "overviewTable",
--         TABLE_TEMPLATE = "orderRowTemplate",
-- 	}
-- }

AvailableTypesDlgFrame = {
	CONTROLS = {
		"dialogTitleElement",
        "typesTable",
        "orderRowTemplate",
	}
}

local AvailableTypesDlgFrame_mt = Class(AvailableTypesDlgFrame, MessageDialog)

function AvailableTypesDlgFrame.new(target, custom_mt)
	dbPrintf("AvailableTypesDlgFrame:new()")
	local self = MessageDialog.new(target, custom_mt or AvailableTypesDlgFrame_mt)

	self:registerControls(AvailableTypesDlgFrame.CONTROLS)

	return self
end

function AvailableTypesDlgFrame:onGuiSetupFinished()
	dbPrintf("AvailableTypesDlgFrame:onGuiSetupFinished()")
	AvailableTypesDlgFrame:superClass().onGuiSetupFinished(self)
	self.typesTable:setDataSource(self)
	self.typesTable:setDelegate(self)
end

function AvailableTypesDlgFrame:onCreate()
	dbPrintf("AvailableTypesDlgFrame:onCreate()")
	AvailableTypesDlgFrame:superClass().onCreate(self)
end


function AvailableTypesDlgFrame:onOpen()
	dbPrintf("AvailableTypesDlgFrame:onOpen()")
	AvailableTypesDlgFrame:superClass().onOpen(self)
end


function AvailableTypesDlgFrame:InitData(data)
	dbPrintf("AvailableTypesDlgFrame:InitData()")

	-- Fill data structure
	self.tableData = data

	-- finilaze dialog
	self.typesTable:reloadData()

	self:setSoundSuppressed(true)
    FocusManager:setFocus(self.typesTable)
    self:setSoundSuppressed(false)

end


function AvailableTypesDlgFrame:getNumberOfSections(list)
	dbPrintf("AvailableTypesDlgFrame:getNumberOfSections()")
	return #self.tableData
end


function AvailableTypesDlgFrame:getNumberOfItemsInSection(list, section)
	dbPrintf("AvailableTypesDlgFrame:getNumberOfItemsInSection()")
	return #self.tableData[section].items
end


function AvailableTypesDlgFrame:getTitleForSectionHeader(list, section)
	dbPrintf("AvailableTypesDlgFrame:getTitleForSectionHeader()")
	return self.tableData[section].sectionTitle
end


function AvailableTypesDlgFrame:populateCellForItemInSection(list, section, index, cell)
	dbPrintf("AvailableTypesDlgFrame:populateCellForItemInSection()")
	local item = self.tableData[section].items[index]
	cell:getAttribute("ftIcon"):setImageFilename(item.hudOverlayFilename)
	cell:getAttribute("ftTitle"):setText(item.title)
	cell:getAttribute("minOrderLevel"):setText(item.minOrderLevel)
	cell:getAttribute("probability"):setText(string.format("%s %%", item.probability))
	cell:getAttribute("quantityCorrectionFactor"):setText(string.format("%.1f", item.quantityCorrectionFactor))
	cell:getAttribute("msg"):setText(item.msg)
end


function AvailableTypesDlgFrame:onClose()
	dbPrintf("AvailableTypesDlgFrame:onClose()")
	AvailableTypesDlgFrame:superClass().onClose(self)
end


function AvailableTypesDlgFrame:onClickClose(sender)
	dbPrintf("AvailableTypesDlgFrame:onClickClose()")
	self:close()
end

