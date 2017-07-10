-- Money transfer menu
-- Transfer money between the player account and a NPC manager account

-- section == gJLPUniTrader_uiconfig_transferMoney
-- param == { 0, 0, entity [, suggestedAmount] }

local menu = {
	name = "jlp_MoneyTransfer",
}

local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
end

function menu.cleanup()
	menu.title = nil
	menu.entity = nil

	menu.infotable = nil
	menu.selecttable = nil
end

-- menu member functions

-- Button Scripts
function menu.buttonOK()
	local managerMoney, managerMinMoney, managerMaxMoney, isDummy = GetAccountData(menu.entity, "money", "minmoney", "maxmoney", "isdummy")
	local value1, value2, value3, value4 = GetSliderValue(menu.slider)
	-- Transfer the money here
	if value1 > 0 then
		TransferPlayerMoneyTo(value1, menu.entity)
	elseif value1 - managerMoney < 0 then
		TransferMoneyToPlayer(-value1, menu.entity)
	end
	local money = GetAccountData(menu.entity, "money")
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end

function menu.buttonCancel()
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end

function menu.onShowMenu()
	menu.title = ReadText(1001, 2000)
	
	menu.entity = menu.param[3]
	
	
	-- collect slider value parameters
	local managerMoney, managerMinMoney, managerMaxMoney, isDummy = GetAccountData(menu.entity, "money", "minmoney", "maxmoney", "isdummy")
	
	local playerMoney = GetPlayerMoney()
	
	local suggestedMoney = math.min(menu.param[4] and (menu.param[4] - managerMoney) or 0, playerMoney)
	
	local sliderinfo = {
		["background"] = "tradesellbuy_blur", 
		["captionLeft"] = ReadText(1001, 2001), 
		["captionCenter"] = ReadText(1001, 2000), 
		["captionRight"] = ReadText(1001, 2002), 
		["min"]= 0,
		["max"] = math.floor(playerMoney + managerMoney),
		["start"] = math.floor(suggestedMoney + managerMoney),
		["zero"] = math.floor(managerMoney)
	}
	local scalexinfo = { 
		["left"] = math.floor(playerMoney),
		["right"] = math.floor(managerMoney),
		["suffix"] = " " .. ReadText(1001, 101)
	}
	local sliderdesc = Helper.createSlider(sliderinfo, scalexinfo, nil, 1, Helper.sliderOffsetx, Helper.tableCharacterOffsety)
	
	-- Title line as one TableView
	local setup = Helper.createTableSetup(menu)
	
	local name, typestring, typeicon, typename, ownericon = GetComponentData(menu.entity, "name", "typestring", "typeicon", "typename", "ownericon")
	setup:addTitleRow{
		Helper.createIcon(typeicon, false, 255, 255, 255, 100, 0, 0, Helper.headerCharacterIconSize, Helper.headerCharacterIconSize),
		Helper.createFontString(typename .. " " .. name, false, "left", 255, 255, 255, 100, Helper.headerRow1Font, Helper.headerRow1FontSize),
		Helper.createIcon(ownericon, false, 255, 255, 255, 100, 0, 0, Helper.headerCharacterIconSize, Helper.headerCharacterIconSize)	-- text depends on selection
	}
	
	setup:addTitleRow({
		menu.param[4] and (ReadText(1001, 1919) .. ReadText(1001, 120) .. " " .. ConvertMoneyString(menu.param[4], false, true, 0, true) .. " " .. ReadText(1001, 101)) or Helper.getEmptyCellDescriptor()
	}, nil, {3})
	
	local infodesc = setup:createCustomWidthTable({ Helper.scaleX(Helper.headerCharacterIconSize), 0, Helper.scaleX(Helper.headerCharacterIconSize) + 37 }, false, true)
	
	-- Lower button table
	setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({ 
		Helper.getEmptyCellDescriptor(),
		Helper.createButton(Helper.createButtonText(ReadText(1001, 14), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 200, Helper.standardTextHeight),
		Helper.getEmptyCellDescriptor(),
		Helper.createButton(Helper.createButtonText(ReadText(1001, 64), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 200, Helper.standardTextHeight),
		Helper.getEmptyCellDescriptor()
	})
	local selectdesc = setup:createCustomWidthTable({200, 200, 0, 200, 200}, false, false, false, 2, 1, 0, 205)
	
	-- create tableview
	menu.infotable, menu.selecttable, menu.slider = Helper.displayTwoTableSliderView(menu, infodesc, selectdesc, sliderdesc, true)

	-- set button scripts
	Helper.setButtonScript(menu, nil, menu.selecttable, 1, 2, menu.buttonOK)
	Helper.setButtonScript(menu, nil, menu.selecttable, 1, 4, menu.buttonCancel)

	-- clear descriptors again
	Helper.releaseDescriptors()
end

--menu.updateInterval = 1.0

function menu.onUpdate()
end

function menu.onRowChanged(row, rowdata)
end

function menu.onSelectElement()
	menu.buttonOK()
end

function menu.onCloseElement(dueToClose)
	if dueToClose == "close" then
		menu.cleanup()
		--Helper.closeMenuAndCancel(menu)
		Helper.closeMenuAndReturn(menu, false, {0, 0, menu.param[3]})
	else
		--Helper.closeMenuAndReturn(menu)
	  Helper.closeMenuAndReturn(menu, false, {0, 0, menu.param[3]})
		menu.cleanup()
	end
end

init()
