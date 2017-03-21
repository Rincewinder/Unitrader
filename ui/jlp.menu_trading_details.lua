
-- section == gJLPUniTrader_gTrade_details
-- param == { 0, 0, tradeoffer, shipid, tradeoffercontainer, entity] }

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	int GetCargoSpaceUsedAfterShoppingList(UniverseID containerid)
]]

local menu = {
	name = "jlp_TradingDetailsMenu",
	white = { r = 255, g = 255, b = 255, a = 100 },
	red = {r = 255, g = 0, b = 0, a = 100 },
	transparent = { r = 0, g = 0, b = 0, a = 0 }
}

local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end

	menu.strings = {
		buy = ReadText(1001, 2916) .. ReadText(1001, 120) .. " ",
		sell = ReadText(1001, 2917) .. ReadText(1001, 120) .. " ",
		invalid = "*INVALID*",
		cr = " " .. ReadText(1001, 101),
		baseprice = ReadText(1001, 2413),
		finalprice = ReadText(1001, 2921),
		pricecalc = ReadText(1001, 2933), 
		adjustment = ReadText(1001, 2934), 
		unitprice = ReadText(1001, 2935),
		totalprice = ReadText(1001, 2927),
		quantitydiscount = ReadText(1001, 2904),
		quantitycommission = ReadText(1001, 2905),
		quantitypremium = ReadText(1001, 2929),
		quantityabatement = ReadText(1001, 2930),
		baseprice = ReadText(1001, 2413),
		details = ReadText(1001, 2961),
		queued = ReadText(1001, 2937),
		capacity = ReadText(1001, 2958),
		trade = ReadText(1001, 2900),
		station = ReadText(1001, 3),
		location = ReadText(1001, 2943),
		distance = ReadText(1001, 2957),
		gates = ReadText(1001, 2959),
		jumps = ReadText(1001, 2960),
		na = ReadText(1001, 2672),
		noships = ReadText(1001, 2942),
		mot_encyclopedia = ReadText(1026, 2907),
		mot_details = ReadText(1026, 2908),
		mot_map = ReadText(1026, 2909)
	}
end

function menu.cleanup()
	if menu.shipid and IsComponentOperational(menu.shipid) then
		SetVirtualCargoMode(menu.shipid, false)
	end

	menu.title = nil

	menu.infotable = nil
	menu.buttontable = nil
	
	-- specific variables
	menu.trade = nil
	menu.ship = nil
	menu.playership = nil
	
	menu.tradeid = nil
	menu.tradeware = nil
	menu.shipid = nil
	menu.tradeoffercontainer = nil

	-- Reset Helper
	Helper.standardFontSize = 14
	Helper.standardTextHeight = 24
	Helper.standardButtonWidth = 36
end

-- Button Scripts

function menu.buttonShowMap()
	Helper.closeMenuForSubSection(menu, false, "gMainNav_menumap", { 0, 0, "zone", GetContextByClass(menu.trade.station, "zone"), nil, menu.trade.station })
	menu.cleanup()
end

function menu.buttonShipDetails()
	Helper.closeMenuForSubSection(menu, false, "gMain_object_closeup", { 0, 0, menu.shipid })
	menu.cleanup()
end

function menu.buttonEncyclopedia()
	Helper.closeMenuForSubSection(menu, false, "gEncyclopedia_ware", { 0, 0, "wares", menu.trade.ware })
	menu.cleanup()
end
	
-- Menu member functions

function menu.onShowMenu()
	menu.trade = GetTradeData( menu.param[3].id)
	menu.tradeid = menu.trade.id
	menu.tradeware = menu.trade.ware
	
	menu.shipid = menu.param[4]
	menu.tradeoffercontainer = menu.param[5]

	if menu.shipid and IsComponentOperational(menu.shipid) then
		SetVirtualCargoMode(menu.shipid, true)
	end
	
	-- print("tradetransactmenu onshowmenu, menu.tradeid "..menu.tradeid.. " menu.shipid "..menu.shipid.." menu.amount "..menu.amount)

	-- Override some Helper settings
	Helper.standardFontSize = 11
	Helper.standardTextHeight = 20
	Helper.standardButtonWidth = 30
	
	menu.playership = GetPlayerPrimaryShipID()
	
	menu.ship = GetTradeShipData(menu.shipid )
	menu.title = menu.strings.details
	local emptyFontStringSmall = Helper.createFontString("", false, Helper.standardHalignment, Helper.standardColor.r, Helper.standardColor.g, Helper.standardColor.b, Helper.standardColor.a, Helper.standardFont, 6, false, Helper.headerRow1Offsetx, Helper.headerRow1Offsety, 6)

	

	-- Upper trade offer info table
	local setup = Helper.createTableSetup(menu)
	
	-- Menu Title
	setup:addTitleRow({
		Helper.createFontString(menu.title, false, "left", 255, 255, 255, 100, Helper.headerRow1Font, Helper.headerRow1FontSize, false, Helper.headerRow1Offsetx, Helper.headerRow1Offsety, Helper.headerRow1Height, Helper.headerRow1Width)
	}, nil, {7})
	setup:addHeaderRow({ emptyFontStringSmall }, nil, {7})

	local cluster, sector, zone, shipimage = GetComponentData(menu.shipid, "cluster", "sector", "zone", "image")
	local cargoplanned = C.GetCargoSpaceUsedAfterShoppingList(ConvertIDTo64Bit(menu.shipid))
	setup:addTitleRow({
		Helper.createIcon(shipimage ~= "" and shipimage or "transferSlider", false, 255, 255, 255, 100, 0, 0, 114, 214),
		Helper.createFontString(menu.ship.name .. "\n" .. cluster .. " / " .. sector .. " / " .. zone .. "\n" .. menu.strings.capacity .. ReadText(1001, 120) .. " " .. ConvertIntegerString(cargoplanned, true, 3, true) .. " / " .. ConvertIntegerString(menu.ship.cargomax, true, 3, true), false, "left", 255, 255, 255, 100, Helper.standardFont, Helper.standardFontSize, true, Helper.standardTextOffsetx, Helper.standardTextOffsety, 114),
	}, nil, {2, 5})
	setup:addHeaderRow({ emptyFontStringSmall }, nil, {7})

	if menu.trade then
		menu.displayTrade(setup, menu.trade)

	else
		setup:addTitleRow({
			ReadText(1001, 2979)
		}, nil, {7})
	end

	local infodesc = setup:createCustomWidthTable({ Helper.standardButtonWidth, 214 - Helper.standardButtonWidth - 5, 0, 125, 200, 200 - Helper.standardButtonWidth - 5, Helper.standardButtonWidth}, false, false, true, 1, 4, 0, 0, 550)

	-- summary table
	setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({ 
		"",
		Helper.createButton(Helper.createButtonText(ReadText(1001, 2669), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_B", true)),
		"",
		Helper.createButton(Helper.createButtonText(ReadText(1001, 2400), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_BACK", true), nil, menu.strings.mot_encyclopedia),
		"",
		Helper.createButton(Helper.createButtonText(ReadText(1002, 1051), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, menu.ship ~= nil, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_Y", true), nil, menu.strings.mot_details),
		"",
		Helper.createButton(Helper.createButtonText(ReadText(1001, 3203), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_X", true), nil, menu.strings.mot_map),
		""
	}, nil, nil, false, menu.transparent)
	local buttondesc = setup:createCustomWidthTable({48, 150, 48, 150, 0, 150, 48, 150, 48}, false, false, true, 2, 1, 0, 556, 0, false)

	-- create tableview
	menu.infotable, menu.buttontable = Helper.displayTwoTableView(menu, infodesc, buttondesc, false)

	-- set button script
	Helper.setButtonScript(menu, nil, menu.buttontable, 1, 2, function () return menu.onCloseElement("back") end)
	Helper.setButtonScript(menu, nil, menu.buttontable, 1, 4, menu.buttonEncyclopedia)
	Helper.setButtonScript(menu, nil, menu.buttontable, 1, 6, menu.buttonShipDetails)
	Helper.setButtonScript(menu, nil, menu.buttontable, 1, 8, menu.buttonShowMap)

	-- clear descriptors again
	Helper.releaseDescriptors()

end

function menu.sumModifier(modifiers)
	local sum = 0
	if modifiers and #modifiers ~= 0 then
		for i, p in ipairs(modifiers) do
			sum = sum + p.amount
		end
	end
	return sum
end

function menu.getShipSector()
	if menu.ship then
		local ship = menu.ship
		if #ship.queue > 1 then
			return ship.queue[#ship.queue].stationsectorid
		else
			local sector = GetComponentData(ship.shipid, "sectorid")
			if sector then
				return sector
			else
				return GetComponentData(GetComponentData(ship.shipid, "zoneid"), "exitsector")
			end
		end
	else
		local sector = GetContextByClass(menu.playership, "sector")
		if sector then
			return sector
		else
			return GetComponentData(GetContextByClass(menu.playership, "zone"), "exitsector")
		end
	end
end

function menu.displayTrade(setup, trade)
	local amount =  trade.amount
	setup:addSimpleRow({
		menu.strings.trade,
		Helper.createFontString((trade.isbuyoffer and ReadText(1001, 2917) or ReadText(1001, 2916)) .. ReadText(1001, 120) .. " " .. amount .. " x " .. trade.name, false, "left")
	}, nil, {2, 5})
	setup:addSimpleRow({
		menu.strings.station,
		Helper.createFontString(trade.stationname, false, "left")
	}, nil, {2, 5})
	local cluster, sector, zone = GetComponentData(trade.station, "cluster", "sector", "zone")
	setup:addSimpleRow({
		menu.strings.location,
		Helper.createFontString(cluster .. " / " .. sector .. " / " .. zone, false, "left")
	}, nil, {2, 5})
	local sector = menu.getShipSector()
	local gates, jumps = FindJumpRoute(sector, trade.stationsectorid)
	setup:addSimpleRow({
		menu.strings.distance,
		Helper.createFontString((gates and jumps) and gates .. menu.strings.gates .. " - " .. jumps .. menu.strings.jumps or menu.strings.na, false, "left")
	}, nil, {2, 5})
	
	local strquantitybonustype = menu.strings.invalid
	if trade.quantityfactor > 1 then
		strquantitybonustype = trade.isselloffer and menu.strings.quantitypremium or menu.strings.quantitycommission
	else
		strquantitybonustype = trade.isselloffer and menu.strings.quantitydiscount or menu.strings.quantityabatement
	end
	local quantitydiff = trade.quantityfactor - 1
	-- calculate total price diff
	trade.averageunitprice, trade.pricerange = GetWareData(trade.ware, "avgprice", "pricerange")
	local unitpricediff = Helper.round(trade.price, 2) - trade.averageunitprice
	local pricediffpercent = unitpricediff / trade.averageunitprice * 100

		setup:addHeaderRow({
			menu.strings.pricecalc, 
			menu.strings.adjustment, 
			menu.strings.unitprice, 
			menu.strings.totalprice
		}, nil, {2, 2, 1, 1, 2})
		setup:addSimpleRow({
			menu.strings.baseprice, 
			"",
			Helper.createFontString(ConvertMoneyString(Helper.round(trade.averageunitprice, 2), true, true, 3) .. menu.strings.cr, false, "right"), 
			Helper.createFontString(ConvertMoneyString(RoundTotalTradePrice(amount * trade.averageunitprice), false, true, 4) .. menu.strings.cr, false, "right", Helper.standardColor.r, Helper.standardColor.g, Helper.standardColor.b, Helper.standardColor.a, Helper.standardFontBold)
		}, nil, {2, 2, 1, 2})
		setup:addSimpleRow({
			strquantitybonustype, 
			ReadText(1001, 2851 + math.min(math.max(math.abs(quantitydiff) * 100 / trade.pricerange * trade.averageunitprice / 3, 0), 6)),
			Helper.createFontString(Helper.diffpercent((quantitydiff * 100) or 0, trade.isbuyoffer) .. " %", false, "right"), 
			Helper.createFontString(ConvertMoneyString(Helper.round(trade.marketprice - trade.averageunitprice, 2), true, true, 3) .. menu.strings.cr, false, "right"), 
			""
		}, nil, {2, 1, 1, 1, 2})

		local sum = 0
		local line = 5
		if trade.pricemodifiers and #trade.pricemodifiers ~= 0 then
			local modifiersum = 0
			for i, p in ipairs(trade.pricemodifiers) do
				if trade.isselloffer then
					modifiersum = modifiersum - p.amount
				else
					modifiersum = modifiersum + p.amount
				end
			end

			for i, p in ipairs(trade.pricemodifiers) do
				local amount = p.amount
				if trade.isselloffer then
					amount = -amount
				end
				amount = amount * math.floor(modifiersum + 0.5) / modifiersum
				-- Info Line: (factionname), ModifierName, ModifierPercent, ModifierPerUnit, Timeout
				setup:addSimpleRow({
					p.name .. (p.expire >= 0 and " (" .. Helper.timeDuration(p.expire) .. ")" or ""), 
					ReadText(1001, 2851 + math.min(math.max(p.level / 3, 0), 6)),
					Helper.createFontString(Helper.diffpercent(Helper.round(amount), trade.isbuyoffer) .. " %", false, "right"), 
					Helper.createFontString(ConvertMoneyString(Helper.round(trade.averageunitprice * amount / 100, 2), true, true, 3) .. menu.strings.cr, false, "right"), 
					""
				}, nil, {2, 1, 1, 1, 2})
				sum = sum + amount
				line = line + 1
			end
		end

		setup:addSimpleRow({
			menu.strings.finalprice, 
			ReadText(1001, 2851 + math.min(math.max(math.abs(pricediffpercent) / trade.pricerange * trade.averageunitprice / 3, 0), 6)),
			Helper.createFontString(Helper.diffpercent(pricediffpercent, trade.isbuyoffer).." %", false, "right"), 
			Helper.createFontString(ConvertMoneyString(Helper.round(trade.price, 2), true, true, 3) .. menu.strings.cr, false, "right"), 
			Helper.createFontString(ConvertMoneyString(RoundTotalTradePrice(amount * trade.price), false, true, 4) .. menu.strings.cr, false, "right", Helper.standardColor.r, Helper.standardColor.g, Helper.standardColor.b, Helper.standardColor.a, Helper.standardFontBold)
		}, nil, {2, 1, 1, 1, 2})
end


-- menu.updateInterval = 2.0

function menu.onUpdate()
end

function menu.onRowChanged(row, rowdata)
end

function menu.onSelectElement()
end

function menu.onCloseElement(dueToClose)
	if dueToClose == "close" then
		--menu.cleanup()
		Helper.closeMenuAndCancel(menu)
	else
		--menu.cleanup()
		Helper.closeMenuAndReturn(menu, false, {0, 0, menu.param[6], {menu.tradeid, menu.tradeware}, menu.tradeoffercontainer})
	end
end

init()
