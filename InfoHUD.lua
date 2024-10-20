-- Author: Fetty42
-- Date: 20.10.2024
-- Version: 1.4.0.0

InfoHUD = {}

local InfoHUD_mt = Class(InfoHUD, HUDElement)

function InfoHUD.new()
	-- print("InfoHUD.new")
	local hudAtlasPath = g_baseHUDFilename
	-- print("g_baseHUDFilename=" .. tostring(g_baseHUDFilename))
	local backgroundOverlay = InfoHUD.createBackground(hudAtlasPath)
	local self = InfoHUD:superClass().new(backgroundOverlay, nil, InfoHUD_mt)

	self:setVisible(false)

	return self
end

function InfoHUD.createBackground(hudAtlasPath)
	-- print("InfoHUD.createBackground")
	local width, height = getNormalizedScreenValues(table.unpack(InfoHUD.SIZE.BACKGROUND))
	-- local backgroundOverlay = Overlay.new('dataS/menu/blank.png', 0.5, 0.5, width, height)
	local backgroundOverlay = Overlay.new(hudAtlasPath, 0.5, 0.5, width, height)

	backgroundOverlay:setAlignment(Overlay.ALIGN_VERTICAL_TOP, Overlay.ALIGN_HORIZONTAL_LEFT)
	backgroundOverlay:setUVs(GuiUtils.getUVs(HUDElement.UV.FILL))
	backgroundOverlay:setColor(table.unpack(InfoHUD.COLOR.FRAME))

	return backgroundOverlay
end

function InfoHUD:draw()
	-- print("InfoHUD.draw")
	InfoHUD:superClass().draw(self)
end


InfoHUD.SIZE = {
	BACKGROUND = {
		300,
		80
	}
}

InfoHUD.COLOR = {
	BAR_BACKGROUND = {
		1,
		1,
		1,
		0.2
	},
	FRAME = {
		0,
		0,
		0,
		0.75
	}
}