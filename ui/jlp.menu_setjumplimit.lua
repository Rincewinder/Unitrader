-- section == gJLPUniTrader_uiconfig_setJump
-- param == { 0, 0, entity, "buy" | "sell" , "setmin" | "setmax" [, suggestedminAmount, suggestedmaxAmount] }

local menu = {
	name = "jlp_setJump",
}
-- Set jump Limits for (Buying/Selling)
-- Use parameter to select Min or Max value

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
	menu.task = nil

	menu.infotable = nil
	menu.selecttable = nil
end

-- Menu member functions

-- Button Scripts
function menu.buttonOK()
	value1, value2, value3, value4 = GetSliderValue(menu.slider)
	-- print("Slidervalue = "..(value1 or "NIL")..(value2 or "NIL")..(value3 or "NIL")..(value4 or "NIL"))
	if menu.task == "setmin" then
		if menu.modus == "buy" then
			SetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_buy_min", value1)  
		elseif menu.modus == "sell" then
			SetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_sell_min", value1)  
		end
	else
		if menu.modus == "buy" then
			SetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_buy_max", value1)  
		elseif menu.modus == "sell" then
			SetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_sell_max", value1)  
		end
	end
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end

function menu.buttonCancel()
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end

function menu.onShowMenu()
	menu.title = ReadText(1001, 2100)
	menu.entity = menu.param[3]
	menu.modus = menu.param[4]
	menu.task = menu.param[5]
	local min = menu.param[6] or 0
	local max = menu.param[7] or 24
	
	
	local sliderMin
	local sliderMax
	local slidercurrent
	
	if menu.task == "setmin" then
		slidermin =  0
		slidermax =  math.max(0, max) 
		slidercurrent =   math.max(min, 0)
	else
		slidermin = math.max(min, 0)
		slidermax = math.max(0, max)
		slidercurrent =  math.max(0, max)
	end
	
	local sliderinfo = {
		["background"] = "tradesellbuy_blur", 
		["captionLeft"] = tostring(slidermin) .. " " .. ReadText(20001, 702), 
		["captionCenter"] = ReadText(1001, 7107), 
		["captionRight"] = tostring(slidermax) .. " " .. ReadText(20001, 702), 
		["min"]= 0, 
		["max"] = slidermax,
		["zero"] = 0, 
		["start"] = slidercurrent
	}
	local scale1info = { 
	}
	local sliderdesc = Helper.createSlider(sliderinfo, scale1info, nil, 1, Helper.sliderOffsetx, Helper.tableCharacterOffsety)
	
	-- Title line as one TableView
	local setup = Helper.createTableSetup(menu)
	
	local name, typestring, typeicon, typename, ownericon = GetComponentData(menu.entity, "name", "typestring", "typeicon", "typename", "ownericon")
	setup:addTitleRow{
		Helper.createIcon(typeicon, false, 255, 255, 255, 100, 0, 0, Helper.headerCharacterIconSize, Helper.headerCharacterIconSize),
		Helper.createFontString(typename .. " " .. name, false, "left", 255, 255, 255, 100, Helper.headerRow1Font, Helper.headerRow1FontSize),
		Helper.createIcon(ownericon, false, 255, 255, 255, 100, 0, 0, Helper.headerCharacterIconSize, Helper.headerCharacterIconSize)	-- text depends on selection
	}
	
	setup:addTitleRow({
		Helper.getEmptyCellDescriptor()
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
	-- print("onUpdate: CurTime="..GetCurTime())
end

function menu.onRowChanged(row, rowdata)
	-- print("onRowChanged: " .. row .. ", row name: " .. (rowdata or "(nil)"))
end

function menu.onSelectElement()
	menu.buttonOK()
end

function menu.onCloseElement(dueToClose)
	if dueToClose == "close" then
		Helper.closeMenuAndCancel(menu)
		menu.cleanup()
	else
		Helper.closeMenuAndReturn(menu)
		menu.cleanup()
	end
end

init()
