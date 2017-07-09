
-- section == gJLPUniTrader_uiconfig
-- param ==  { 0, 0, object }
-- param2 == Ship

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t UniverseID;
	typedef uint64_t TradeID;
	typedef struct {
		const char* wareid;
		uint32_t amount;
	} UIWareAmount;
	bool HasCustomConversation(UniverseID entityid);
	int GetCargoSpaceUsedAfterShoppingList(UniverseID containerid);
	const char* GetComponentName(UniverseID componentid);
	const char* GetMapShortName(UniverseID componentid);	
	
	typedef struct {
		const char* wareid;
		bool isSellOffer;
		UITradeOfferStatData* data;
		uint32_t numdata;
	} UITradeOfferStat;
	typedef struct {
		double time;
		int64_t price;
		int amount;
		int limit;
	} UITradeOfferStatData;
	
	uint32_t GetNumTradeOfferStatistics(UniverseID containerorspaceid, double starttime, double endtime, size_t numdatapoints);
	uint32_t GetTradeOfferStatistics(UITradeOfferStat* result, uint32_t resultlen, size_t numdatapoints);
]]

local utf8 = require("utf8")

local menu = {
	name = "jlp_unitrader_ConfigMenu",
	white = { r = 255, g = 255, b = 255, a = 100 },
	red = { r = 255, g = 0, b = 0, a = 100 },
	transparent = { r = 0, g = 0, b = 0, a = 0 },
	extendedcategories = {}
}

local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
end

-- Start or Updated to show the Menu
function menu.onShowMenu()
	menu.title = ReadText(8570, 1000)

	
	menu.strings = {
		ware = ReadText(1001, 45),
		distance = ReadText(1001, 2957),
		amount = ReadText(1001, 1202),
		cr = " " .. ReadText(1001, 101),
		price = ReadText(1001, 2926),
		totalprice = ReadText(1001, 2927),
		selloffers = ReadText(1001, 2931),
		buyoffers = ReadText(1001, 2932),
		toselloffers = ReadText(1001, 2964),
		tobuyoffers = ReadText(1001, 2965),
		adjustment = ReadText(1001, 2956),
		all = ReadText(1001, 2963),
		bulk = ReadText(20205, 200),
		container = ReadText(20205, 100),
		energy = ReadText(20205, 700),
		liquid = ReadText(20205, 300),
		queued = ReadText(1001, 2937),
		capacity = ReadText(1001, 2958),
		noships = ReadText(1001, 2942),
		gates = ReadText(1001, 2959),
		jumps = ReadText(1001, 2960),
		na = ReadText(1001, 2672),
		back = ReadText(1001, 2669),
		details = ReadText(1001, 2961),
		next = ReadText(1001, 2962),
		nomoney = ReadText(1001, 2966),
		nospace = ReadText(1001, 2987),
		nocargo = ReadText(1001, 2988),
		nobay = ReadText(1001, 2989),
		isenemy = ReadText(1001, 2971),
		toomanytrips = ReadText(1001, 2990),
		categories = ReadText(1001, 2970),
		notrades = ReadText(1001, 2973),
		nodrones = ReadText(1001, 2978),
		transferfrom = ReadText(1001, 2981),
		transferto = ReadText(1001, 2982),
		totransferfrom = ReadText(1001, 2983),
		totransferto = ReadText(1001, 2984),
		tradesummary = ReadText(1001, 2974),
		transferfromsummary = ReadText(1001, 2985),
		transfertosummary = ReadText(1001, 2986),
		unknownproblem = ReadText(1001, 2991),
		cannotsell = ReadText(1001, 6202),
		tradedeals = ReadText(1001, 6204),
		range = ReadText(1001, 1302),
		galaxy = ReadText(20001, 901),
		cluster = ReadText(20001, 101),
		sector = ReadText(20001, 201),
		investment = ReadText(1001, 6210),
		profit = ReadText(1001, 6208),
		buytradesummary = ReadText(1001, 6206),
		selltradesummary = ReadText(1001, 6207),
		mot_tobuyoffers = ReadText(1026, 2900),
		mot_toselloffers = ReadText(1026, 2906),
		mot_details = ReadText(1026, 2901),
		mot_next = ReadText(1026, 2902),
		mot_noship = ReadText(1026, 2903),
		mot_noships = ReadText(1026, 2905),
		mot_toomanytrips = ReadText(1001, 2972)
	}
	
  -- read params
  menu.entity = menu.param[3]
	menu.container = GetContextByClass(menu.entity, "container", false)
  menu.ship = GetContextByClass(menu.entity, "ship", false)
	
  if menu.ship ~= nil then
    menu.ship = GetTradeShipData(menu.ship)
 end

	menu.displayMenu(true)
end

function menu.cleanup()

menu.entity = nil
	menu.container = nil
	menu.title = nil
	menu.lastupdate = nil
	menu.strings = nil

	cleanupConfigData ()

	menu.infotable = nil
	menu.selecttable = nil
	--menu.buttontable = nil --TODO: why i cannot delete this?

	-- Reset Helper
	Helper.standardFontSize = 14
	Helper.standardTextHeight = 24
	Helper.standardButtonWidth = 36
end

---------------------------------------------------------------------------------------------
-- Menu member functions
---------------------------------------------------------------------------------------------

-- Buttons functions
function menu.buttonTransferMoney ()
	if IsValidComponent(menu.entity) then
		Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_transferMoney", {0, 0, menu.entity, menu.jlp_unitrader_budgetmax / 2 }, menu.ship)
		menu.cleanup()
	end
end

function menu.buttonChangeMaxBudget ()
	if IsValidComponent(menu.entity) then
		Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_setBudget", {0, 0, menu.entity, "setmax" , menu.jlp_unitrader_budgetmin, menu.jlp_unitrader_budgetmax }, menu.ship)
		menu.cleanup()
	end
end

function menu.buttonChangeMinBudget ()
	if IsValidComponent(menu.entity) then
		Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_setBudget", {0, 0, menu.entity, "setmin" , menu.jlp_unitrader_budgetmin, menu.jlp_unitrader_budgetmax }, menu.ship)
		menu.cleanup()
	end
end

function menu.buttonSetRangeJumpMin()
	if IsValidComponent(menu.entity) then
		if menu.rowDataMap[Helper.currentDefaultTableRow] then
			local rowdata = menu.rowDataMap[Helper.currentDefaultTableRow]
			if rowdata == "setRangeJumpSell" then
				Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_setJump", {0, 0, menu.entity, "sell", "setmin" ,0, 24 }, menu.ship)
				menu.cleanup()
			elseif rowdata == "setRangeJumpBuy" then
				Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_setJump", {0, 0, menu.entity, "buy", "setmin" ,0, 24 }, menu.ship)
				menu.cleanup()
			end
		end
	end
end

function menu.buttonSetRangeJumpMax()
	if IsValidComponent(menu.entity) then
		if menu.rowDataMap[Helper.currentDefaultTableRow] then
			local rowdata = menu.rowDataMap[Helper.currentDefaultTableRow]
			if rowdata == "setRangeJumpSell" then
				Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_setJump", {0, 0, menu.entity, "sell", "setmax" ,0, 24 }, menu.ship)
				SetNPCBlackboard(menu.entity, "$nextbuyoffercheck", nil)
				SetNPCBlackboard(menu.entity, "$traderangeBuy_nexttime", nil)
				SetNPCBlackboard(menu.entity, "$traderangeSell_nexttime", nil)
				menu.cleanup()
			elseif rowdata == "setRangeJumpBuy" then
				Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_setJump", {0, 0, menu.entity, "buy", "setmax" ,0, 24 }, menu.ship)
				SetNPCBlackboard(menu.entity, "$nextbuyoffercheck", nil)
				SetNPCBlackboard(menu.entity, "$traderangeBuy_nexttime", nil)
				SetNPCBlackboard(menu.entity, "$traderangeSell_nexttime", nil)
				menu.cleanup()
			end
		end
	end
end

function menu.buttonDetailsBuy()
	if menu.jlp_unitrader_currentselloffer ~= nil and IsValidComponent(menu.jlp_unitrader_currentselloffer.station) then
		Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_gTrade_details", {0, 0, menu.jlp_unitrader_currentselloffer, menu.ship and menu.ship.shipid or nil, menu.jlp_unitrader_currentsellofferentity, menu.entity }, menu.ship)
		menu.cleanup()
	end
end

function menu.buttonDetailsSell()
	if menu.jlp_unitrader_currentbuyoffer ~= nil and IsValidComponent(menu.jlp_unitrader_currentbuyoffer.station) then
		Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_gTrade_details", {0, 0, menu.jlp_unitrader_currentbuyoffer, menu.ship and menu.ship.shipid or nil, menu.jlp_unitrader_currentbuyofferentity, menu.entity }, menu.ship)
		menu.cleanup()
	end
end

function menu.buttonChooseZone ()
	if menu.rowDataMap[Helper.currentDefaultTableRow] then
		local rowdata = menu.rowDataMap[Helper.currentDefaultTableRow]
		if rowdata == "setRangeSell" then
			Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_chooseZone", {0, 0, 'sector', GetComponentData(menu.jlp_unitrader_home_sell, "sectorid"), null, null, "selectzone", {"gJLPUniTrader_uiconfig_range_sell_home"}}, menu.ship)
			SetNPCBlackboard(menu.entity, "$nextbuyoffercheck", nil) -- miner
			SetNPCBlackboard(menu.entity, "$traderangeBuy_nexttime", nil) -- trader
			SetNPCBlackboard(menu.entity, "$traderangeSell_nexttime", nil)
			SetNPCBlackboard(menu.entity, "$traderange_buyclusters", nil)
			SetNPCBlackboard(menu.entity, "$traderange_sellclusters", nil)

			menu.cleanup()
		elseif rowdata == "setRangeBuy" then
			Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_chooseZone", {0, 0, 'sector', GetComponentData(menu.jlp_unitrader_home_buy, "sectorid"), null, null, "selectzone", {"gJLPUniTrader_uiconfig_range_buy_home"}}, menu.ship)
			SetNPCBlackboard(menu.entity, "$nextbuyoffercheck", nil) -- miner
			SetNPCBlackboard(menu.entity, "$traderangeBuy_nexttime", nil) -- trader
			SetNPCBlackboard(menu.entity, "$traderangeSell_nexttime", nil)
			SetNPCBlackboard(menu.entity, "$traderange_buyclusters", nil)
			SetNPCBlackboard(menu.entity, "$traderange_sellclusters", nil)
			menu.cleanup()
		end
	end
end

function menu.buttonStart()
	if IsValidComponent(menu.entity) then
		if menu.jlp_unitrader_mode == "trader" then
			menu.jlp_unitrader_istraderrun = 1
			menu.jlp_unitrader_isminerrun = 0
			menu.saveConfigDatas()
			Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_trader_start", {0, 0, menu.entity}, menu.ship)
      menu.cleanup()
      --menu.displayMenu(true)
  	elseif menu.jlp_unitrader_mode == "miner" then
			menu.jlp_unitrader_istraderrun = 0
			menu.jlp_unitrader_isminerrun = 1
			menu.saveConfigDatas()
			Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_miner_start", {0, 0, menu.entity}, menu.ship)
      menu.cleanup()
     --menu.displayMenu(true)
		end
	end
end

function menu.buttonStop()
	if IsValidComponent(menu.entity) then
		if menu.jlp_unitrader_mode == "trader" then
			menu.jlp_unitrader_istraderrun = 0
			menu.jlp_unitrader_isminerrun = 0
			menu.saveConfigDatas()
			Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_trader_stop", {0, 0, menu.entity}, menu.ship)
      menu.cleanup()
      --menu.displayMenu(true)
    elseif menu.jlp_unitrader_mode == "miner" then
			menu.jlp_unitrader_istraderrun = 0
			menu.jlp_unitrader_isminerrun = 0
			menu.saveConfigDatas()
			Helper.closeMenuForSubSection(menu, false, "gJLPUniTrader_uiconfig_miner_stop", {0, 0, menu.entity}, menu.ship)
			menu.cleanup()
      --menu.displayMenu(true)
		end
	end
end


function  menu.buttonSetRangeModus ()
	if menu.rowDataMap[Helper.currentDefaultTableRow] then
		local rowdata = menu.rowDataMap[Helper.currentDefaultTableRow]
		if rowdata == "setRangeModusBuy" then
			SetNPCBlackboard(menu.entity, "$nextbuyoffercheck", nil) -- miner
			SetNPCBlackboard(menu.entity, "$traderangeBuy_nexttime", nil) -- trader
			SetNPCBlackboard(menu.entity, "$traderangeSell_nexttime", nil)
			SetNPCBlackboard(menu.entity, "$traderange_buyclusters", nil)
			SetNPCBlackboard(menu.entity, "$traderange_sellclusters", nil)
			
			if menu.jlp_unitrader_range_buy == nil or  menu.jlp_unitrader_range_buy == "ranged" then
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_buy", "zone")
				Helper.updateCellText(menu.selecttable, Helper.currentDefaultTableRow, 3, ReadText(20001, 301))
				menu.jlp_unitrader_range_buy = "zone"
			elseif menu.jlp_unitrader_range_buy == "zone" then
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_buy", "sector")
				Helper.updateCellText(menu.selecttable, Helper.currentDefaultTableRow, 3, ReadText(20001, 201))
				menu.jlp_unitrader_range_buy = "sector"
			elseif menu.jlp_unitrader_range_buy == "sector" then
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_buy", "cluster")
				menu.jlp_unitrader_range_buy = "cluster"
				Helper.updateCellText(menu.selecttable, Helper.currentDefaultTableRow, 3, ReadText(20001, 101))
			elseif menu.jlp_unitrader_range_buy == "cluster" then
				if menu.jlp_unitrader_mode == "trader" then
					SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_buy", "ranged")
					menu.jlp_unitrader_range_buy = "ranged"
					Helper.updateCellText(menu.selecttable, Helper.currentDefaultTableRow, 3, ReadText(20001, 901))
				else
					SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_buy", "zone")
					Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(20001, 901))
					menu.jlp_unitrader_range_buy = "zone"
				end

			end
		elseif rowdata == "setRangeModusSell" then
			SetNPCBlackboard(menu.entity, "$nextbuyoffercheck", nil) -- miner
			SetNPCBlackboard(menu.entity, "$traderangeBuy_nexttime", nil) -- trader
			SetNPCBlackboard(menu.entity, "$traderangeSell_nexttime", nil)
			SetNPCBlackboard(menu.entity, "$traderange_buyclusters", nil)
			SetNPCBlackboard(menu.entity, "$traderange_sellclusters", nil)
			if menu.jlp_unitrader_range_sell == nil or  menu.jlp_unitrader_range_sell == "ranged" then
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_sell", "zone")
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(20001, 301))
				menu.jlp_unitrader_range_sell = "zone"
			elseif menu.jlp_unitrader_range_sell == "zone" then
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_sell", "sector")
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(20001, 201))
				menu.jlp_unitrader_range_sell = "sector"
			elseif menu.jlp_unitrader_range_sell == "sector" then
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_sell", "cluster")
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(20001, 101))
				menu.jlp_unitrader_range_sell = "cluster"
			elseif menu.jlp_unitrader_range_sell == "cluster" then
				if menu.jlp_unitrader_mode == "trader" then
					SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_sell", "ranged")
					Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(20001, 901))
					menu.jlp_unitrader_range_sell = "ranged"
				else
					SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_sell", "zone")
					Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(20001, 901))
					menu.jlp_unitrader_range_sell = "zone"
				end
			end
		end
	end
	--menu.cleanup()
	menu.displayMenu(false)
end

function  menu.buttonChangeMode ()
	if menu.jlp_unitrader_mode == "trader" then
		menu.jlp_unitrader_mode = "miner"
		SetNPCBlackboard(menu.entity, "$jlpUniTraderMode","miner")
		SetNPCBlackboard(menu.entity, "$nextbuyoffercheck", nil) -- miner
		SetNPCBlackboard(menu.entity, "$traderangeBuy_nexttime", nil) -- trader
		SetNPCBlackboard(menu.entity, "$traderangeSell_nexttime", nil)
		SetNPCBlackboard(menu.entity, "$traderange_buyclusters", nil)
		SetNPCBlackboard(menu.entity, "$traderange_sellclusters", nil)
	else
		menu.jlp_unitrader_mode = "trader"
		SetNPCBlackboard(menu.entity, "$jlpUniTraderMode","trader")
		SetNPCBlackboard(menu.entity, "$nextbuyoffercheck", nil) -- miner
		SetNPCBlackboard(menu.entity, "$traderangeBuy_nexttime", nil) -- trader
		SetNPCBlackboard(menu.entity, "$traderangeSell_nexttime", nil)
		SetNPCBlackboard(menu.entity, "$traderange_buyclusters", nil)
		SetNPCBlackboard(menu.entity, "$traderange_sellclusters", nil)
	end
	--menu.cleanup()
	menu.displayMenu(false)
end

function  menu.buttonChangeLogbookMode ()
	if menu.jlp_unitrader_extendedlogbook == 1 then
		menu.jlp_unitrader_extendedlogbook = 0
		SetNPCBlackboard(menu.entity, "$jlp_unitrader_show_extendedlogbook",0)
		Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4013))
	else
		menu.jlp_unitrader_extendedlogbook = 1
		SetNPCBlackboard(menu.entity, "$jlp_unitrader_show_extendedlogbook",1)
		Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4012) )
	end
	--menu.cleanup()
	menu.displayMenu(false)
end

function  menu.buttonSetSubscription ()
	if menu.rowDataMap[Helper.currentDefaultTableRow] then
		local rowdata = menu.rowDataMap[Helper.currentDefaultTableRow]
		if rowdata == "setSubscriptionSell" then
			if menu.jlp_unitrader_trade_stations_sell == "onlyTraderSell" then
				menu.jlp_unitrader_trade_stations_sell = "onlyKnownSell" 
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_trade_stations_sell", menu.jlp_unitrader_trade_stations_sell)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4122))
			elseif menu.jlp_unitrader_trade_stations_sell == "onlyKnownSell" then
				menu.jlp_unitrader_trade_stations_sell = "allSell"
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_trade_stations_sell", menu.jlp_unitrader_trade_stations_sell)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4123))
			elseif menu.jlp_unitrader_trade_stations_sell == "allSell"  then
				menu.jlp_unitrader_trade_stations_sell = "onlyTraderSell"
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_trade_stations_sell", menu.jlp_unitrader_trade_stations_sell)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4121))
			end
		elseif rowdata == "setSubscriptionBuy" then
			if menu.jlp_unitrader_trade_stations_buy == "onlyTraderBuy" then
				menu.jlp_unitrader_trade_stations_buy = "onlyKnownBuy" 
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_trade_stations_buy", menu.jlp_unitrader_trade_stations_buy)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4122))
			elseif menu.jlp_unitrader_trade_stations_buy == "onlyKnownBuy" then
				menu.jlp_unitrader_trade_stations_buy = "allBuy"
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_trade_stations_buy", menu.jlp_unitrader_trade_stations_buy)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4123))
			elseif menu.jlp_unitrader_trade_stations_buy == "allBuy"  then
				menu.jlp_unitrader_trade_stations_buy = "onlyTraderBuy"
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_trade_stations_buy", menu.jlp_unitrader_trade_stations_buy)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4121))
			end
		end
	end

	--menu.cleanup()
	menu.displayMenu(false)
end


 function  menu.setButtonStationMode ()
	if menu.rowDataMap[Helper.currentDefaultTableRow] then
		local rowdata = menu.rowDataMap[Helper.currentDefaultTableRow]
		if rowdata == "setSellStationMode" then
			if menu.jlp_unitrader_home_sell_find == "onlyForeignTrader" then
				menu.jlp_unitrader_home_sell_find = "onlySelfTrader" 
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_home_sell_find", menu.jlp_unitrader_home_sell_find)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4122))
			elseif menu.jlp_unitrader_home_sell_find == "onlySelfTrader" then
				menu.jlp_unitrader_home_sell_find = "allTrader"
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_home_sell_find", menu.jlp_unitrader_home_sell_find)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4123))
			elseif menu.jlp_unitrader_home_sell_find == "allTrader"  then
				menu.jlp_unitrader_home_sell_find = "onlyForeignTrader"
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_home_sell_find", menu.jlp_unitrader_home_sell_find)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4121))
			end
		elseif rowdata == "setBuyStationMode" then
			if menu.jlp_unitrader_home_buy_find == "onlyForeignTrader" then
				menu.jlp_unitrader_home_buy_find = "onlySelfTrader" 
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_home_buy_find", menu.jlp_unitrader_home_buy_find)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4122))
			elseif menu.jlp_unitrader_home_buy_find == "onlySelfTrader" then
				menu.jlp_unitrader_home_buy_find = "allTrader"
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_home_buy_find", menu.jlp_unitrader_home_buy_find)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4123))
			elseif menu.jlp_unitrader_home_buy_find == "allTrader"  then
				menu.jlp_unitrader_home_buy_find = "onlyForeignTrader"
				SetNPCBlackboard(menu.entity, "$jlp_unitrader_home_buy_find", menu.jlp_unitrader_home_buy_find)
				Helper.updateCellText(menu.selecttable,  Helper.currentDefaultTableRow, 3, ReadText(8570, 4121))
			end
		end
	end

	--menu.cleanup()
	menu.displayMenu(false)
end

function menu.displayMenu(firsttime)

  -- Remove possible button scripts from previous view
  Helper.removeAllButtonScripts(menu)
  Helper.currentTableRow = {}
  Helper.currentTableRowData = nil
  menu.rowDataMap = {}
	
	menu.lastupdate = GetCurTime()
	-- read personal configuration data from menu.entity
	menu.readConfigDatas()
	-- Remove possible button scripts from previous view
	menu.rowDataMap = {}
	Helper.currentTableRow = {}
	Helper.currentTableRowData = nil
	Helper.removeAllButtonScripts(menu)
	
	-- Override some Helper settings
	Helper.standardFontSize = 11
	Helper.standardTextHeight = 20
	Helper.standardButtonWidth = 30
	--------------------------------------------------------------------
	-- create  Infoline as one TableView
	--------------------------------------------------------------------
	local setup = Helper.createTableSetup(menu)

	--	local name, typestring, typeicon, typename, ownericon, skills, skillsvisible, experienceprogress, neededexperience, isplayerowned
	--	= GetComponentData(menu.entity, "name", "typestring", "typeicon", "typename", "ownericon", "skills", "skillsvisible", "experienceprogress", "neededexperience", "isplayerowned")
	--	setup:addTitleRow({
	--		Helper.createFontString( menu.title or Helper.getEmptyCellDescriptor(), false, "left", 255, 255, 255, 100, Helper.headerRow1Font, Helper.headerRow1FontSize)
	--	}, nil, {3})
	--	setup:addTitleRow{
	--		Helper.createIcon(typeicon, false, 255, 255, 255, 100, 0, 0, Helper.headerCharacterIconSize, Helper.headerCharacterIconSize),
	--		Helper.createFontString(typename .. " " .. name, false, "left", 255, 255, 255, 100, Helper.headerRow2FontSize, Helper.headerRow2FontSize),
	--		Helper.createIcon(ownericon, false, 255, 255, 255, 100, 0, 0, Helper.headerCharacterIconSize, Helper.headerCharacterIconSize)	-- text depends on selection
	--	}
	-- create info table
	--	local infodesc = setup:createCustomWidthTable({ Helper.scaleX(Helper.headerCharacterIconSize), 0, Helper.scaleX(Helper.headerCharacterIconSize) + 37 }, false, true)
	setup:addTitleRow({
		Helper.createFontString( menu.title or Helper.getEmptyCellDescriptor(), false, "left", 255, 255, 255, 100, Helper.headerRow1Font, Helper.headerRow1FontSize)
	}, nil, {6})
	local emptyFontStringSmall = Helper.createFontString("", false, Helper.standardHalignment, Helper.standardColor.r, Helper.standardColor.g, Helper.standardColor.b, Helper.standardColor.a, Helper.standardFont, 6, false, Helper.headerRow1Offsetx, Helper.headerRow1Offsety, 6)
	local shipimage = GetComponentData(menu.ship.shipid, "image")


	setup:addHeaderRow({ emptyFontStringSmall }, nil, {6})
	setup:addSimpleRow({
		Helper.createIcon(shipimage ~= "" and shipimage or "transferSlider", false, 255, 255, 255, 100, 0, 0, 114, 214),
		Helper.createFontString( menu.buildInfoString() , false, "left", 255, 255, 255, 100, Helper.standardFont, Helper.standardFontSize, true, Helper.standardTextOffsetx, Helper.standardTextOffsety, 114),
		Helper.createFontString( menu.buildSkillString() , false, "left", 255, 255, 255, 100, Helper.standardFont, Helper.standardFontSize, true, Helper.standardTextOffsetx, Helper.standardTextOffsety, 114),
	}, nil, {2, 3, 1})

	--setup:addHeaderRow({ emptyFontStringSmall }, nil, {6})
	--setup:addHeaderRow({ emptyFontStringSmall }, nil, {6})
	--local padding = math.max(1, 32 - Helper.scaleX(Helper.standardButtonWidth))
	--local infodesc = setup:createCustomWidthTable({Helper.scaleX(Helper.standardButtonWidth), Helper.scaleX(250), 0, Helper.scaleX(450), padding, Helper.scaleX(Helper.standardButtonWidth)}, false, true, true, 3, 4, 0, 0, 0, false)
	local infodesc = setup:createCustomWidthTable({  Helper.standardButtonWidth, 230 - Helper.standardButtonWidth - 5, 0, 125, 125, 275 - Helper.standardButtonWidth - 5}, false, false, true, 3, 3, 0, 0, 550)

	--------------------------------------------------------------------
	-- create select table
	--------------------------------------------------------------------
	setup = Helper.createTableSetup(menu)
	-- setup mode _(trader miner)
	local text
	if menu.jlp_unitrader_mode == "trader" then
		text = ReadText(8570, 1010)
	elseif menu.jlp_unitrader_mode == "miner" then
		text = ReadText(8570, 2010)
	else
		text = ReadText(10002, 200)
	end
	setup:addSimpleRow({
		Helper.createFontString(text , false, "center", 255, 255, 255, 100, Helper.headerRow1Font, Helper.headerRow1FontSize)
	}, "changeMode", {6})

	-- Helper.createButton(Helper.createButtonText(menu.extendedcategories.tradequeue and "-" or "+", "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 0, Helper.standardTextHeight),
	-- show  current trades
	setup:addTitleRow({
		Helper.createFontString(ReadText(1001, 2427)) or Helper.getEmptyCellDescriptor()
	}, nil, {6})
	local shipzone = GetContextByClass(menu.ship.shipid, "zone", false)
	local zoneName, sectorName, clusterName
	= GetComponentData(shipzone, "uiname", "sector", "cluster")
  if menu.jlp_unitrader_mode == "trader" then
	 if menu.jlp_unitrader_currentselloffer ~= nil and IsValidComponent(menu.jlp_unitrader_currentselloffer.station) then
		  local name, zoneid, sectorid, clusterid, tradesubscription
		  = GetComponentData(menu.jlp_unitrader_currentselloffer.station, "uiname", "zoneid" , "sectorid", "clusterid", "tradesubscription")

		  setup:addSimpleRow({
			 Helper.createFontString(ReadText(1001, 2931) .. ": ", false, "left", 255, 255, 255, 100, Helper.standardFont),
			 Helper.createFontString(GetComponentData(clusterid, "mapshortname") .. " // " .. GetComponentData(sectorid, "mapshortname") .. " // " .. GetComponentData(zoneid, "mapshortname") .. " // " .. name, false, "left", 255, 255, 255, 100, Helper.standardFont),
			 tradesubscription and Helper.createIcon("menu_eye", false, 255, 255, 255, 100, 0, 0, Helper.standardTextHeight, Helper.standardButtonWidth) or Helper.getEmptyCellDescriptor()
		  }, "showTradedetailsBuy", {2,3,1})
	 else
		  setup:addSimpleRow({
			 Helper.createFontString(ReadText(1001, 2931) .. ": ", false, "left", 255, 255, 255, 100, Helper.standardFont),
			 Helper.createFontString(ReadText(1001, 2973), false, "left", 255, 255, 255, 100, Helper.standardFont)
		  }, "showTradedetailsBuy", {2,4})
	 end
	end
	if menu.jlp_unitrader_currentbuyoffer ~= nil  and IsValidComponent(menu.jlp_unitrader_currentbuyoffer.station) then
		local name, zoneid, sectorid, clusterid, tradesubscription
		= GetComponentData(menu.jlp_unitrader_currentbuyoffer.station, "uiname", "zoneid" , "sectorid", "clusterid", "tradesubscription")

		setup:addSimpleRow({
			Helper.createFontString(ReadText(1001, 2932) .. ": ", false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(GetComponentData(clusterid, "mapshortname") .. " // " .. GetComponentData(sectorid, "mapshortname") .. " // " .. GetComponentData(zoneid, "mapshortname") .. " // " .. name, false, "left", 255, 255, 255, 100, Helper.standardFont),
			tradesubscription and Helper.createIcon("menu_eye", false, 255, 255, 255, 100, 0, 0, Helper.standardTextHeight, Helper.standardButtonWidth) or Helper.getEmptyCellDescriptor()
		}, "showTradedetailsSell", {2,3,1})
	else
		setup:addSimpleRow({
			Helper.createFontString(ReadText(1001, 2932) .. ": ", false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(ReadText(1001, 2973), false, "left", 255, 255, 255, 100, Helper.standardFont)
		}, "showTradedetailsSell", {2,4})
	end
	
	
	-- setup Account
	local managerMoney, managerMinMoney, managerMaxMoney = GetAccountData(menu.entity, "money", "minmoney", "maxmoney")
	setup:addTitleRow({
		menu.zoneowner and string.format(ReadText(8570, 5100), menu.zoneownername) or Helper.getEmptyCellDescriptor()
	}, nil, {6})

	setup:addSimpleRow({Helper.getEmptyCellDescriptor(),
		Helper.createFontString(ReadText(1001, 2003) .. ": ", false, "left", 255, 255, 255, 100, Helper.standardFont),
		Helper.createFontString(ConvertMoneyString(managerMoney , false, true, 0, true) .. menu.strings.cr .. " (min: " .. ConvertMoneyString(menu.jlp_unitrader_budgetmin , false, true, 2, false) .. menu.strings.cr ..  " max: " .. ConvertMoneyString(menu.jlp_unitrader_budgetmax , false, true, 2, false) .. menu.strings.cr .. ")", false, "left", 255, 255, 255, 100, Helper.standardFont)
	}, "setBudget", {1,1,4})

	-- setup Range
	setup:addTitleRow({
		Helper.createFontString(ReadText(1001, 4212)) or Helper.getEmptyCellDescriptor()
	}, nil, {6})
	-- Buy
	if menu.jlp_unitrader_mode == "trader" then
		text = ReadText(8570, 4111)
	elseif menu.jlp_unitrader_mode == "miner" then
		text = ReadText(8570, 4113)
	else
		text = ReadText(8570, 100)
	end
	local rangeSetup
	local zoneName, sectorName, clusterName
	if menu.jlp_unitrader_home_buy then
		zoneName, sectorName, clusterName = GetComponentData(menu.jlp_unitrader_home_buy, "name", "sector", "cluster")
		rangeSetup = false
		setup:addSimpleRow({
			Helper.createFontString(text .. ": ", false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(clusterName .. " // " .. sectorName .. " // " .. zoneName, false, "left", 255, 255, 255, 100, Helper.standardFont)
		}, "setRangeBuy", {2,4})
	else
		setup:addSimpleRow({
			Helper.createFontString(text, false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(ReadText(8570, 100), false, "left", 255, 255, 255, 100, Helper.standardFont)
		}, "setRangeBuy", {2,4})
	end
	
	if  menu.jlp_unitrader_mode ~= "miner" then
		text =  ReadText(8570, 100)
		if menu.jlp_unitrader_home_buy_find == "onlyForeignTrader"  then
			text = ReadText(8570, 4131)
		elseif menu.jlp_unitrader_home_buy_find == "onlySelfTrader"  then
			text = ReadText(8570, 4132)
		elseif menu.jlp_unitrader_home_buy_find == "allTrader"  then 
			text = ReadText(8570, 4133)
		end
		setup:addSimpleRow({Helper.getEmptyCellDescriptor(),
			Helper.createFontString(ReadText(8570, 4130), false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(text, false, "left", 255, 255, 255, 100, Helper.standardFont)
		}, "setBuyStationMode", {1,1,4})
	end
	if menu.jlp_unitrader_home_buy_find ~= "onlySelfTrader"  and  menu.jlp_unitrader_mode ~= "miner" then
		text =  ReadText(8570, 100)
		if menu.jlp_unitrader_trade_stations_buy == "onlyTraderBuy" then
			text = ReadText(8570, 4121)
		elseif menu.jlp_unitrader_trade_stations_buy == "onlyKnownBuy"  then
			text = ReadText(8570, 4122)
		elseif menu.jlp_unitrader_trade_stations_buy == "allBuy"  then
			text = ReadText(8570, 4123)
		end
		setup:addSimpleRow({Helper.getEmptyCellDescriptor(),
			Helper.createFontString(ReadText(8570, 4120), false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(text, false, "left", 255, 255, 255, 100, Helper.standardFont)
		}, "setSubscriptionBuy", {1,1,4})
	end

	if menu.jlp_unitrader_range_buy == "zone" then
		text = ReadText(20001, 301)
	elseif menu.jlp_unitrader_range_buy == "sector" then
		text = ReadText(20001, 201)
	elseif menu.jlp_unitrader_range_buy == "cluster" then
		text = ReadText(20001, 101)
	elseif menu.jlp_unitrader_range_buy == "ranged" then
		text = ReadText(20001, 901)
		rangeSetup = true
	end
	setup:addSimpleRow({Helper.getEmptyCellDescriptor(),
		Helper.createFontString(ReadText(1001, 1302), false, "left", 255, 255, 255, 100, Helper.standardFont),
		Helper.createFontString(text, false, "left", 255, 255, 255, 100, Helper.standardFont)
	}, "setRangeModusBuy", {1,1,4})
	
	if menu.jlp_unitrader_mode == "trader" and menu.jlp_unitrader_range_buy == "ranged" then
		setup:addSimpleRow({
			Helper.getEmptyCellDescriptor(),
			Helper.createFontString(ReadText(8570, 5212), false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(menu.jlp_unitrader_jump_buy_min .. " " .. ReadText(20001, 702) , false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(ReadText(8570, 5211), false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(menu.jlp_unitrader_jump_buy_max .. " " .. ReadText(20001, 702), false, "left", 255, 255, 255, 100, Helper.standardFont)
		}, "setRangeJumpBuy", {1,1,1,2,1})
	end
	-- Sell
	
	if menu.jlp_unitrader_home_sell then
		
		zoneName, sectorName, clusterName
		= GetComponentData(menu.jlp_unitrader_home_sell, "uiname", "sector", "cluster")
		--zoneName = ffi.string(C.GetComponentName(menu.jlp_unitrader_home_sell)
	
		setup:addSimpleRow({
			Helper.createFontString(ReadText(8570, 4112) .. ": ", false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(clusterName .. " // " .. sectorName .. " // " .. zoneName, false, "left", 255, 255, 255, 100, Helper.standardFont)
		}, "setRangeSell", {2,4})
	else
		setup:addSimpleRow({
			Helper.createFontString(ReadText(8570, 4112) .. ": ", false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(ReadText(8570, 100), false, "left", 255, 255, 255, 100, Helper.standardFont)
		}, "setRangeSell", {2,4})
	end
	
	text =  ReadText(8570, 100)
	if menu.jlp_unitrader_home_sell_find == "onlyForeignTrader"  then
		text = ReadText(8570, 4131)
	elseif menu.jlp_unitrader_home_sell_find == "onlySelfTrader"  then
		text = ReadText(8570, 4132)
	elseif menu.jlp_unitrader_home_sell_find == "allTrader"  then 
		text = ReadText(8570, 4133)
	end
	setup:addSimpleRow({Helper.getEmptyCellDescriptor(),
		Helper.createFontString(ReadText(8570, 4130), false, "left", 255, 255, 255, 100, Helper.standardFont),
		Helper.createFontString(text, false, "left", 255, 255, 255, 100, Helper.standardFont)
	}, "setSellStationMode", {1,1,4})


	if menu.jlp_unitrader_home_sell_find ~= "onlySelfTrader"  then
		text =  ReadText(8570, 100)
		if menu.jlp_unitrader_trade_stations_sell == "onlyTraderSell"  then
			text = ReadText(8570, 4121)
		elseif menu.jlp_unitrader_trade_stations_sell == "onlyKnownSell"  then
			text = ReadText(8570, 4122)
		elseif menu.jlp_unitrader_trade_stations_sell == "allSell"  then 
			text = ReadText(8570, 4123)
		end
		setup:addSimpleRow({Helper.getEmptyCellDescriptor(),
			Helper.createFontString(ReadText(8570, 4120), false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(text, false, "left", 255, 255, 255, 100, Helper.standardFont)
		}, "setSubscriptionSell", {1,1,4})
	end
	if menu.jlp_unitrader_range_sell == "zone" then
		text = ReadText(20001, 301)
	elseif menu.jlp_unitrader_range_sell == "sector" then
		text = ReadText(20001, 201)
	elseif menu.jlp_unitrader_range_sell == "cluster" then
		text = ReadText(20001, 101)
	elseif menu.jlp_unitrader_range_sell == "ranged" then
		text = ReadText(20001, 901)
	end
	setup:addSimpleRow({Helper.getEmptyCellDescriptor(),
		Helper.createFontString(ReadText(1001, 1302), false, "left", 255, 255, 255, 100, Helper.standardFont),
		Helper.createFontString(text, false, "left", 255, 255, 255, 100, Helper.standardFont)
	}, "setRangeModusSell", {1,1,4})
	
	if menu.jlp_unitrader_range_sell == "ranged" then
		setup:addSimpleRow({
			Helper.getEmptyCellDescriptor(),
			Helper.createFontString(ReadText(8570, 5214), false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(menu.jlp_unitrader_jump_sell_min .. " " .. ReadText(20001, 702) , false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(ReadText(8570, 5213), false, "left", 255, 255, 255, 100, Helper.standardFont),
			Helper.createFontString(menu.jlp_unitrader_jump_sell_max .. " " .. ReadText(20001, 702), false, "left", 255, 255, 255, 100, Helper.standardFont)
		}, "setRangeJumpSell", {1,1,1,2,1})
	end

	-- setup Config
	setup:addTitleRow({
		Helper.createFontString(ReadText(8570, 5000)) or Helper.getEmptyCellDescriptor()
	}, nil, {6})
	-- Logbook enable
	setup:addSimpleRow({
		Helper.createFontString(ReadText(8570, 4010) .. ": ", false, "left", 255, 255, 255, 100, Helper.standardFont),
		Helper.createFontString((menu.jlp_unitrader_extendedlogbook == 1 and ReadText(8570, 4012) or ReadText(8570, 4013)) , false, "left", 255, 255, 255, 100, Helper.standardFont)
	}, "showExtendedLogbook", {2,4})
	
	-- create select table
	local selectdesc = setup:createCustomWidthTable({ Helper.standardButtonWidth, 0, 150, 100, 150, 150 }, false, false, true, 1, 0, 0, 165, 400, false, menu.toprow, menu.selectrow)

	--------------------------------------------------------------------
	-- create button table
	--------------------------------------------------------------------
	setup = Helper.createTableSetup(menu)
	if menu.jlp_unitrader_isminerrun == 1 or menu.jlp_unitrader_istraderrun == 1 then
		text = ReadText(8570, 4021)
	else
		text = ReadText(8570, 4020)
	end
	setup:addSimpleRow({
		Helper.getEmptyCellDescriptor(),
		Helper.createButton(Helper.createButtonText(ReadText(1002, 1202), "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, true, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_B", true)),
		Helper.getEmptyCellDescriptor(),
		Helper.createButton(Helper.createButtonText(text, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, menu.stopAllowed, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_A", true)),
		Helper.getEmptyCellDescriptor(),
		Helper.getEmptyCellDescriptor(),
		Helper.getEmptyCellDescriptor(),
		Helper.getEmptyCellDescriptor(),
		Helper.getEmptyCellDescriptor()
	}, nil, nil, false, menu.transparent)

	-- create button table
	local buttondesc = setup:createCustomWidthTable({48, 150, 48, 150, 0, 150, 48, 150, 48}, false, false, true, 2, 1, 0, 560, 0, false)

	-- join  tables
	menu.infotable, menu.selecttable, menu.buttontable = Helper.displayThreeTableView(menu, infodesc, selectdesc, buttondesc, false, "", "", 0, 0, 0, 0, "both", firsttime)


	-- set button scripts
	Helper.setButtonScript(menu, nil, menu.buttontable, 1, 2, function () return menu.onCloseElement("close") end)
	if menu.jlp_unitrader_isminerrun == 1 or menu.jlp_unitrader_istraderrun == 1 then
		Helper.setButtonScript(menu, nil, menu.buttontable, 1, 4, menu.buttonSop)
	else
		Helper.setButtonScript(menu, nil, menu.buttontable, 1, 4, menu.buttonStart)
	end


	-- clear descriptors
	Helper.releaseDescriptors()
end

menu.updateInterval = 2.0



----------------------------------------------------------
-- commons
----------------------------------------------------------
function menu.onCloseElement(dueToClose)
	if dueToClose == "close" then
		Helper.closeMenuForSubConversation(menu, false, "default", "gMainInfo_property",{0, 0, "player"})
		--Helper.closeMenuAndReturn(menu)
		menu.cleanup()
	else
		Helper.closeMenuAndCancel(menu)
		--Helper.closeMenuAndReturn(menu, false, menu.param)
		menu.cleanup()
	end
end

function menu.onUpdate()
  menu.toprow = GetTopRow(menu.selecttable)
  menu.selectrow = Helper.currentDefaultTableRow
  if menu.selectrow < 1  then 
    menu.selectrow = 1
  end
  if menu.selectrow > #menu.rowDataMap then
    menu.selectrow = #menu.rowDataMap -1
  end
	if menu.lastupdate and menu.lastupdate + 20 < GetCurTime() then
		menu.stopAllowed = true
		if GetComponentData(menu.entity, "isdocked")  and GetComponentData(menu.entity, "isdocking")  then
			menu.stopAllowed = false
		end
    menu.displayMenu(false)
	end
  Helper.updateCellText(menu.infotable,3,3, menu.buildInfoString())
  
end

function menu.onRowChanged(row, rowdata)
	if menu.rowDataMap[Helper.currentDefaultTableRow] then

	 
		rowdata = menu.rowDataMap[Helper.currentDefaultTableRow]
		Helper.removeButtonScripts(menu, menu.buttontable, 1, 8)
		local name, mot_details
		local active = false
		if rowdata ~= nil then
			if  (menu.owner == "player") then
				if GetComponentData(menu.entity, "isdocked") == true and GetComponentData(menu.entity, "isdocking") == true then
					menu.stopAllowed = false
				end
			end
		end

		-- Start button
		if menu.jlp_unitrader_isminerrun == 1 or menu.jlp_unitrader_istraderrun == 1 then
			Helper.removeButtonScripts(menu, menu.buttontable, 1, 4)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(ReadText(8570, 4021), "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, menu.stopAllowed, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_A", true)), 1, 4)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 4, menu.buttonStop)
		else
			Helper.removeButtonScripts(menu, menu.buttontable, 1, 4)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(ReadText(8570, 4020), "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, menu.stopAllowed, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_A", true)), 1, 4)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 4, menu.buttonStart)
		end
		Helper.removeButtonScripts(menu, menu.buttontable, 1, 6)
		SetCellContent(menu.buttontable, Helper.getEmptyCellDescriptor(), 1, 6)

		if rowdata == "setBuyStationMode"  or rowdata == "setSellStationMode" then
	
			-- TODO: to check
			if true  then
				active = true
			end

			name = ReadText(1001, 3105)
			mot_details = ReadText(8570, 55006)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_X", true), nil, active and mot_details or nil), 1, 8)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 8, menu.setButtonStationMode)

		elseif rowdata == "changeMode" then
			
			if  menu.jlp_unitrader_istraderrun ~= 1 and menu.jlp_unitrader_isminerrun ~= 1 then
				active = true
			end

			name = ReadText(8570, 1001)
			mot_details = ReadText(8570, 55002)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_X", true), nil, active and mot_details or nil), 1, 8)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 8, menu.buttonChangeMode)

		elseif rowdata == "setRangeJumpBuy" or  rowdata == "setRangeJumpSell"  then

			-- TODO: to check
			if true  then
				active = true
			end
			name = ReadText(8570, 5112)
			mot_details = ReadText(8570, 55002)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_X", true), nil, active and mot_details or nil), 1, 6)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 6, menu.buttonSetRangeJumpMin)
			name = ReadText(8570, 5111)
			mot_details = ReadText(8570, 55002)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_Y", true), nil, active and mot_details or nil), 1, 8)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 8, menu.buttonSetRangeJumpMax)

		elseif rowdata == "setRangeBuy" or  rowdata == "setRangeSell" then

			-- TODO: to check
			if true  then
				active = true
			end

			-- Choose sell/buy zone
			name = ReadText(1001, 3105)
			mot_details = ReadText(8570, 55000)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_X", true), nil, active and mot_details or nil), 1, 8)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 8, menu.buttonChooseZone)

		elseif rowdata == "setRangeModusSell" or  rowdata == "setRangeModusBuy" then

			-- TODO: to check
			if true  then
				active = true
			end
			name = ReadText(1001, 3105)
			mot_details = ReadText(8570, 55001)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_X", true), nil, active and mot_details or nil), 1, 8)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 8, menu.buttonSetRangeModus)

		elseif rowdata == "setSubscriptionBuy" or rowdata == "setSubscriptionSell" then

			-- TODO: to check
			if true  then
				active = true
			end

			name = ReadText(1001, 3105)
			mot_details = ReadText(8570, 55005)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_X", true), nil, active and mot_details or nil), 1, 8)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 8, menu.buttonSetSubscription)

		elseif rowdata == "showExtendedLogbook" then
			-- TODO: to check
			if true  then
				active = true
			end

			name = ReadText(1001, 3105)
			mot_details = ReadText(8570, 55004)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_X", true), nil, active and mot_details or nil), 1, 8)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 8, menu.buttonChangeLogbookMode)

		elseif rowdata == "showTradedetailsBuy" or  rowdata == "showTradedetailsSell" then

			local chooseMenu
			name = ReadText(1001, 2961)
			mot_details = ReadText(1026, 2901)
			--local tradeid, tradeoffercontainer, sellbuyswitch
			if rowdata == "showTradedetailsBuy" then
				chooseMenu = menu.buttonDetailsBuy
				menu.jlp_unitrader_currentselloffer = GetTradeData(menu.jlp_unitrader_selloffer[1]) or nil
				if  menu.jlp_unitrader_currentselloffer ~= nil then
					active = true
				end
			elseif rowdata == "showTradedetailsSell" then
				chooseMenu = menu.buttonDetailsSell
				menu.jlp_unitrader_currentbuyoffer = GetTradeData(menu.jlp_unitrader_buyoffer[1]) or nil
				if  menu.jlp_unitrader_currentbuyoffer ~= nil  then
					active = true
				end

			end

			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_X", true), nil, true and mot_details or nil), 1, 8)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 8, chooseMenu)

		elseif rowdata == "setBudget" then
			-- TODO: to check
			if true  then
				active = true
			end

			-- minimal Budget
			name = ReadText(1001, 1909)
			mot_details = ReadText(1001, 2101)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_Y", true), nil, active and mot_details or nil), 1, 6)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 6, menu.buttonChangeMinBudget)
			-- maximal Budget
			name = ReadText(1001, 1910)
			mot_details = ReadText(1001, 2102)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_B", true), nil, active and mot_details or nil), 1, 8)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 8, menu.buttonChangeMaxBudget)
			-- money transfer
			name = ReadText(1002, 2022)
			mot_details = ReadText(1004, 1072)
			local npcname = GetComponentData(menu.entity, "name")
			mot_details  = string.format(string.gsub(mot_details,'$NPC$','%s'),  npcname)

			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(name, "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_A", true), nil, active and mot_details or nil), 1, 4)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 4, menu.buttonTransferMoney)

		elseif rowdata == "tradewares" then
			mot_details = ReadText(1026, 4212)
		elseif rowdata == "chooseModus" then
			-- TODO: to check
			if true  then
				active = true
			end

			-- choose Modus
			Helper.removeButtonScripts(menu, menu.buttontable, 1, 6)
			SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(ReadText(1002, 1001), "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, active, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_Y", true), nil, active and ReadText(8570, 55001) or nil), 1, 6)
			Helper.setButtonScript(menu, nil, menu.buttontable, 1, 6, menu.buttonchooseModus)

		else
			SetCellContent(menu.buttontable,Helper.getEmptyCellDescriptor(), 1, 8)
			Helper.removeButtonScripts(menu, menu.buttontable, 1, 8)
		end
	else
		Helper.removeButtonScripts(menu, menu.buttontable, 1, 8)
		SetCellContent(menu.buttontable, Helper.createButton(Helper.createButtonText(ReadText(1001, 3105), "center", Helper.standardFont, 11, 255, 255, 255, 100), nil, false, false, 0, 0, 150, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_A", true)), 1, 8)
	end
    
  menu.onUpdate()
end

--function menu.onSelectElement()
--end

--function menu.onButtonDown()
--end

--function menu.onButtonSelect()
--end

--function menu.onButtonMouseOver()
--end

--function menu.onClick()
--end

----------------------------------------------------------
-- Internal
----------------------------------------------------------

function menu.readConfigDatas()

	local zone
	if menu.entity then
		menu.owner = GetComponentData(menu.ship.shipid, "owner")
		zone = GetComponentData(menu.ship.shipid, "zoneid")
	else
		menu.owner = "player"
		zone = GetComponentData(GetPlayerPrimaryShipID(), "zoneid")
	end
	menu.zoneowner = GetComponentData(zone, "owner")
	menu.zoneownername = GetComponentData(zone, "ownername")

	-- read from Blackboard
	menu.jlp_unitrader_mode = GetNPCBlackboard(menu.entity, "$jlpUniTraderMode") or "trader"
	menu.jlp_unitrader_istraderrun = GetNPCBlackboard(menu.entity, "$jlpUniTraderRun") or 0
	menu.jlp_unitrader_isminerrun = GetNPCBlackboard(menu.entity, "$jlpUniMiningRun") or 0
	menu.jlp_unitrader_budgetmin = GetNPCBlackboard(menu.entity, "$jlp_unitrader_budgetmin") or 100000
	menu.jlp_unitrader_budgetmax = GetNPCBlackboard(menu.entity, "$jlp_unitrader_budgetmax")  or 10000000
	menu.jlp_unitrader_range_buy = GetNPCBlackboard(menu.entity, "$jlp_unitrader_range_buy") or "ranged"
	menu.jlp_unitrader_range_sell = GetNPCBlackboard(menu.entity, "$jlp_unitrader_range_sell") or "ranged"
	menu.jlp_unitrader_home_buy = IsValidComponent(GetNPCBlackboard(menu.entity, "$jlp_unitrader_home_buy")) and GetNPCBlackboard(menu.entity, "$jlp_unitrader_home_buy") or zone
	menu.jlp_unitrader_home_sell = IsValidComponent(GetNPCBlackboard(menu.entity, "$jlp_unitrader_home_sell")) and GetNPCBlackboard(menu.entity, "$jlp_unitrader_home_sell") or zone
	menu.jlp_unitrader_home_buy_find = GetNPCBlackboard(menu.entity, "$jlp_unitrader_home_buy_find") or "allTrader"
	menu.jlp_unitrader_home_sell_find = GetNPCBlackboard(menu.entity, "$jlp_unitrader_home_sell_find") or "allTrader"
	menu.jlp_unitrader_extendedlogbook = GetNPCBlackboard(menu.entity, "$jlp_unitrader_show_extendedlogbook") or 1
	menu.jlp_unitrader_trade_stations_buy = GetNPCBlackboard(menu.entity, "$jlp_unitrader_trade_stations_buy") or "allBuy"
	menu.jlp_unitrader_trade_stations_sell = GetNPCBlackboard(menu.entity, "$jlp_unitrader_trade_stations_sell") or "allSell"
	menu.jlp_unitrader_buyoffer = GetNPCBlackboard(menu.entity, "$jlp_unitrader_currentbuyoffer") or nil
	menu.jlp_unitrader_selloffer = GetNPCBlackboard(menu.entity, "$jlp_unitrader_currentselloffer") or nil
	menu.jlp_unitrader_jump_sell_min = GetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_sell_min") or 0
	menu.jlp_unitrader_jump_sell_max = GetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_sell_max") or 24
	menu.jlp_unitrader_jump_buy_min = GetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_buy_min") or 0
	menu.jlp_unitrader_jump_buy_max = GetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_buy_max") or 24

	-- TODO check if stop allowed
	menu.stopAllowed = true

	-- transform id from saved vars to lua structures
	if  menu.jlp_unitrader_buyoffer ~= nil  and menu.jlp_unitrader_buyoffer[1] ~= nil then
		menu.jlp_unitrader_currentbuyoffer = GetTradeData(menu.jlp_unitrader_buyoffer[1]) or nil
		if not menu.jlp_unitrader_currentbuyoffer.isbuyoffer then
			menu.jlp_unitrader_currentbuyoffer = nil 
		end 
	end
	if menu.jlp_unitrader_buyoffer ~= nil and menu.jlp_unitrader_buyoffer[2] ~= nil then
		menu.jlp_unitrader_currentbuyofferentity = menu.jlp_unitrader_buyoffer[2]
		if IsValidComponent(menu.jlp_unitrader_currentbuyofferentity) then
			menu.jlp_unitrader_currentbuyofferentity = nil
		end
	end
	if menu.jlp_unitrader_selloffer ~= nil and menu.jlp_unitrader_selloffer[1] ~= nil then
		menu.jlp_unitrader_currentselloffer = GetTradeData(menu.jlp_unitrader_selloffer[1]) or nil
		if not menu.jlp_unitrader_currentselloffer.isselloffer then
			menu.jlp_unitrader_currentselloffer = nil
		end
	end
	if menu.jlp_unitrader_selloffer ~= nil and menu.jlp_unitrader_selloffer[2] ~= nil then
		menu.jlp_unitrader_currentsellofferentity = menu.jlp_unitrader_selloffer[2] 
		if IsValidComponent(menu.jlp_unitrader_currentsellofferentity) then
			menu.jlp_unitrader_currentsellofferentity = nil
		end
	end

end

function menu.saveConfigDatas()

	-- save to Blackboard
	SetNPCBlackboard(menu.entity, "$jlpUniTraderMode", menu.jlp_unitrader_mode)
	SetNPCBlackboard(menu.entity, "$jlpUniTraderRun", menu.jlp_unitrader_istraderrun)
	SetNPCBlackboard(menu.entity, "$jlpUniMiningRun", menu.jlp_unitrader_isminerrun )
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_budgetmin", menu.jlp_unitrader_budgetmin )
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_budgetmax", menu.jlp_unitrader_budgetmax )
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_buy", menu.jlp_unitrader_range_buy)
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_range_sell", menu.jlp_unitrader_range_sell)
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_home_buy", menu.jlp_unitrader_home_buy)
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_home_sell", menu.jlp_unitrader_home_sell)
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_home_buy_find", menu.jlp_unitrader_home_buy_find) 
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_home_sell_find", menu.jlp_unitrader_home_sell_find) 
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_show_extendedlogbook", menu.jlp_unitrader_extendedlogbook)
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_trade_stations_buy", menu.jlp_unitrader_trade_stations_buy)
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_trade_stations_sell", menu.jlp_unitrader_trade_stations_sell)
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_sell_min", menu.jlp_unitrader_jump_sell_min )
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_sell_max", 	menu.jlp_unitrader_jump_sell_max )
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_buy_max", menu.jlp_unitrader_jump_buy_max)
	SetNPCBlackboard(menu.entity, "$jlp_unitrader_jump_buy_min", menu.jlp_unitrader_jump_buy_min)
	--reset trade / mining tempdatas
	SetNPCBlackboard(menu.entity, "$nextbuyoffercheck", nil) -- miner
	SetNPCBlackboard(menu.entity, "$traderangeBuy_nexttime", nil) -- trader
	SetNPCBlackboard(menu.entity, "$traderangeSell_nexttime", nil)
	SetNPCBlackboard(menu.entity, "$traderange_buyclusters", nil)
	SetNPCBlackboard(menu.entity, "$traderange_sellclusters", nil)
	

	SetMaxBudget(menu.entity, menu.jlp_unitrader_budgetmax*10)
	SetMinBudget(menu.entity,  0)

end

function cleanupConfigData ()

	menu.owner = nil
	menu.zoneowner =nil
	menu.zoneownername = nil
	menu.ship =nil
	menu.stopAllowed = false

  menu.jlp_unitrader_mode = nil
	menu.jlp_unitrader_istraderrun = nil
	menu.jlp_unitrader_isminerrun = nil
	menu.jlp_unitrader_budgetmin = nil
	menu.jlp_unitrader_budgetmax = nil
	menu.jlp_unitrader_range_buy = nil
	menu.jlp_unitrader_range_sell = nil
	menu.jlp_unitrader_home_buy = nil
	menu.jlp_unitrader_home_sell = nil
	menu.jlp_unitrader_home_buy_find = nil
	menu.jlp_unitrader_home_sell_find = nil
	menu.jlp_unitrader_extendedlogbook = nil
	menu.jlp_unitrader_stationsbuy = nil
	menu.jlp_unitrader_stationssell = nil
	menu.jlp_unitrader_buyoffer =  nil
	menu.jlp_unitrader_selloffer =  nil
	menu.jlp_unitrader_jump_sell_min = nil
	menu.jlp_unitrader_jump_sell_max = nil
	menu.jlp_unitrader_jump_buy_max = nil
	menu.jlp_unitrader_jump_buy_min = nil
	menu.jlp_unitrader_trade_stations_buy = nil
	menu.jlp_unitrader_trade_stations_sell = nil
	menu.jlp_unitrader_currentbuyoffer = nil
	menu.jlp_unitrader_currentselloffer = nil

end

-- ###############################################################################################################
-- ############################################## Helpers ########################################################
-- ###############################################################################################################
function menu.buildInfoString()
  if menu.ship and IsComponentOperational(menu.ship.shipid) then
    SetVirtualCargoMode(menu.ship.shipid, true)
  end

	local aicommand = GetComponentData(menu.entity, "aicommand") or ""
	local aicommandParam1 = GetComponentData(menu.entity, "aicommandparam") or ""	
--	local aicommandParam2 = GetComponentData(menu.entity, "aicommandparam2") or ""
	local aicommandAction = GetComponentData(menu.entity, "aicommandaction") or ""
	local aicommandActionParam1 = GetComponentData(menu.entity, "aicommandactionparam") or ""

	--	local ware = " "
	--	if menu.jlp_unitrader_currentbuyoffer then
	--		if menu.jlp_unitrader_currentbuyoffer.ware and menu.jlp_unitrader_currentbuyoffer.ware.name then
	--			ware = GetWareData(menu.jlp_unitrader_currentbuyoffer.ware).name
	--		end
	--	end

  if aicommand ~= nil and aicommand ~= "" and IsComponentClass(aicommand, "component") and IsValidComponent(aicommand) then
    aicommand =  ffi.string(C.GetComponentName(ConvertIDTo64Bit(aicommand)))
    --GetComponentData(aicommand,"uiname")
  end
	if aicommandParam1 ~= nil and aicommandParam1 ~= "" and IsComponentClass(aicommandParam1, "component") and IsValidComponent(aicommandParam1) then
		aicommandParam1 = ffi.string(C.GetComponentName(ConvertIDTo64Bit(aicommandParam1)))
		--GetComponentData(aicommandParam1,"uiname")
	end
--  if aicommandParam2 ~= nil and IsValidComponent(aicommandParam2) then
--    aicommandParam2 = GetComponentData(aicommandParam2,"uiname")
--  end
  if aicommandAction ~= nil and aicommandAction ~= "" and IsComponentClass(aicommandAction, "component") and IsValidComponent(aicommandAction) then
    aicommandAction = ffi.string(C.GetComponentName(ConvertIDTo64Bit(aicommandAction)))
    --GetComponentData(aicommandAction,"uiname")
  end
	if aicommandActionParam1 ~= nil  and aicommandActionParam1 ~= "" and IsComponentClass(aicommandActionParam1, "component") and IsValidComponent(aicommandActionParam1) then
		aicommandActionParam1 =  ffi.string(C.GetComponentName(ConvertIDTo64Bit(aicommandActionParam1)))
		--GetComponentData(aicommandActionParam1,"uiname")
	end
	
	local clusterid, sectorid, zone, zoneid = GetComponentData(menu.ship.shipid, "clusterid", "sectorid", "zone", "zoneid")
	local cargo = GetCargoAfterShoppingList(menu.ship.shipid)
	local line1, line2, line3 = "", "", ""
	if  next(cargo) then
		local tempcargo = {}
		for ware, amount in pairs(cargo) do
			if ware ~= "fuelcells" then
				table.insert(tempcargo, {ware = ware, amount = amount})
			end
		end
		table.sort(tempcargo, menu.sortCargo)
		if cargo["fuelcells"] then
			table.insert(tempcargo, {ware = "fuelcells", amount = cargo["fuelcells"]})
		end
		local lines = 3
		local count = #tempcargo
		local step = math.floor(count / lines)
		local rest = count % lines
		local step1 = step + (rest > 0 and 1 or 0)
		local step2 = step1 + step + (rest > 1 and 1 or 0)
		for i, entry in ipairs(tempcargo) do
			local temp = ""
			if i <= step1 then
				temp = line1
			elseif i <= step2 then
				temp = line2
			else
				temp = line3
			end
			
			local newwarestring = "   " .. GetWareData(entry.ware, "name") .. ReadText(1001, 120) .. " " .. ConvertIntegerString(entry.amount, true, 0, true)
			if i ~= count then
				newwarestring = newwarestring .. ", "
			end
			temp = temp .. newwarestring
			if GetTextNumLines(temp .. ((i > step2 and i ~= count) and "   ..." or ""), Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), Helper.scaleX(Helper.standardSizeX - 2 * Helper.standardButtonWidth - 214 - Helper.standardTextOffsety) - 15) > 1 then
				if i <= step1 then
					line2 = line2 .. newwarestring
					step1 = i - 1
				elseif i <= step2 then
					line3 = line3 .. newwarestring
					step2 = i - 1
				else
					line3 = line3 .. "   ..."
					break
				end
			else
				if i <= step1 then
					line1 = temp
				elseif i <= step2 then
					line2 = temp
				else
					line3 = temp
				end
			end
		end
	else
		line1 = line1 .. "-"
	end
	local cargolist = line1 .. "\n" .. line2 .. "\n" .. line3
	
	local commandText = string.format(aicommand, aicommandParam1) .. "\n" .. string.format(aicommandAction, aicommandActionParam1)
  if menu.ship and IsComponentOperational(menu.ship.shipid) then
    SetVirtualCargoMode(menu.ship.shipid, false)
  end
 
	return  menu.ship.name ..  " - " .. GetComponentData(clusterid, "mapshortname") .. (sectorid and ("." .. GetComponentData(sectorid, "mapshortname") .. "." .. GetComponentData(zoneid, "mapshortname")) or "") .. ReadText(1001, 120) .. " " .. zone .. "\n" ..  menu.strings.capacity .. ReadText(1001, 120) .. " " .. ConvertIntegerString(menu.ship.cargocurrent , true, 3, true) .. " / " .. ConvertIntegerString( menu.ship.cargomax, true, 3, true) .. "\n" .. ReadText(1001, 78) .. ": " .. commandText .. "\n" .. cargolist
end

function menu.buildSkillString()

	
	local uiname = GetComponentData(menu.entity, "uiname")
	local jlp_unitrader_waittime = GetNPCBlackboard(menu.entity, "$jlp_unitrader_waittime") or ""
	local jlp_unitrader_searchtime = GetNPCBlackboard(menu.entity, "$jlp_unitrader_searchtime") or ""
	local jlp_unitrader_extrafaction = GetNPCBlackboard(menu.entity, "$jlp_unitrader_extrafaction") or ""
	local jlp_unitrader_courage = GetNPCBlackboard(menu.entity, "$jlp_unitrader_courage") or ""
	local jlp_unitrader_efficiency = GetNPCBlackboard(menu.entity, "$jlp_unitrader_efficiency") or ""
	
	local detail = ReadText(8570, 50210)
--	detail = string.gsub(detail, '$WAITTIME$',"%s")
--	detail = string.gsub(detail, '$SEARCHTIME$',"%s")
--	detail = string.gsub(detail, '$EXTRAFACTION$',"%s")
--	detail = string.gsub(detail, '$COURAGE$',"%s")
--	detail = string.gsub(detail, '$EFFICIENCY$',"%s")
	detail = string.format (detail, jlp_unitrader_waittime, jlp_unitrader_searchtime,	jlp_unitrader_extrafaction,	jlp_unitrader_courage, jlp_unitrader_efficiency)
 	return  uiname ..  "\n" .. detail 

end


function menu.sortCargo(a, b)
	if a.amount == b.amount then
		return Helper.sortWareName(a.ware, b.ware)
	end
	return a.amount > b.amount
end

init()
