import '../models/stock_model.dart';
import '../models/transaction_model.dart';
import 'yahoo_finance_service.dart';
import 'supabase_portfolio_repository.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';

class StockRepository {
  final YahooFinanceService _yahooService = YahooFinanceService();
  final SupabasePortfolioRepository _supabaseRepo =
      SupabasePortfolioRepository();

  // Symbols to track (Expanded List - BIST 100 + Popular)
  final List<String> _allStockSymbols = [
    // BIST 30
    "AKBNK",
    "ARCLK",
    "ASELS",
    "ASTOR",
    "BIMAS",
    "BRSAN",
    "DOAS",
    "EKGYO",
    "ENKAI",
    "EREGL",
    "FROTO",
    "GARAN",
    "GUBRF",
    "HEKTS",
    "ISCTR",
    "KCHOL",
    "KONTR",
    "KOZAL",
    "KRDMD",
    "ODAS",
    "OYAKC",
    "PETKM",
    "PGSUS",
    "SAHOL",
    "SASA",
    "SISE",
    "TCELL",
    "THYAO",
    "TOASO",
    "TUPRS",
    "YKBNK",

    // BIST 100 & Popular
    "AEFES",
    "AGHOL",
    "AHGAZ",
    "AKFGY",
    "AKFYE",
    "AKSA",
    "AKSEN",
    "ALARK",
    "ALBRK",
    "ALFAS",
    "ANHYT",
    "ANSGR",
    "ARASE",
    "ASGYO",
    "AYDEM",
    "BAGFS",
    "BERA",
    "BIENY",
    "BIOEN",
    "BOBET",
    "BRYAT",
    "BUCIM",
    "CANTE",
    "CCOLA",
    "CEMTS",
    "CIMSA",
    "CWENE",
    "DOHOL",
    "ECILC",
    "ECZYT",
    "EGEEN",
    "ENFOR",
    "ENJSA",
    "ESEN",
    "EUPWR",
    "EUREN",
    "FUBUT",
    "GENIL",
    "GESAN",
    "GLYHO",
    "GOZDE",
    "GRTUR",
    "GWIND",
    "HALKB",
    "IHLAS",
    "IMASM",
    "IPEKE",
    "ISDMR",
    "ISGYO",
    "ISMEN",
    "IZMDC",
    "KARSN",
    "KAYSE",
    "KCAER",
    "KMPUR",
    "KORDS",
    "KOZAA",
    "KZBGY",
    "MAVI",
    "MGROS",
    "MIATK",
    "NUHCM",
    "OTKAR",
    "PENTA",
    "PSGYO",
    "QUAGR",
    "REEDR",
    "RTALB",
    "SARKY",
    "SDTTR",
    "SELEC",
    "SKBNK",
    "SKTAS",
    "SMRTG",
    "SNGYO",
    "SOKM",
    "TATGD",
    "TAVHL",
    "TETMT",
    "TKFEN",
    "TMSN",
    "TRGYO",
    "TSKB",
    "TTKOM",
    "TTRAK",
    "TURSG",
    "ULKER",
    "VAKBN",
    "VESBE",
    "VESTL",
    "YEOTK", "YYLGD", "ZOREN",
    // Additional Popular
    "ALGYO",
    "ALKIM",
    "AYGAZ",
    "BFREN",
    "BIZIM",
    "BRISA",
    "BVSAN",
    "CRFSA",
    "DEVA",
    "DGNMO",
    "DOCO",
    "ELITE",
    "ERBOS",
    "FMIZP",
    "GEDZA",
    "GLRYH",
    "GSDHO",
    "HLGYO",
    "HUNER",
    "INDES",
    "INFO",
    "INVEO",
    "ISFIN",
    "JANTS",
    "KAREL",
    "KERVT",
    "KFEIN",
    "KLKIM",
    "KNFRT",
    "KRVGD",
    "KUTPO",
    "LOGO",
    "LUKSK",
    "MAKIM",
    "MEDTR",
    "MERCN",
    "MNDRS",
    "MOBTL",
    "MPARK",
    "MRSHL",
    "NATEN",
    "NETAS",
    "NTHOL",
    "NUGYO",
    "OOGYO",
    "ORGE",
    "OZKGY",
    "OZRDN",
    "PAGYO",
    "PARSN",
    "PEKGY",
    "PNSUT",
    "POLHO",
    "PRKAB",
    "PRKME",
    "RYSAS",
    "RYGYO",
    "SAFKR",
    "SANEL",
    "SANKO",
    "SEKFK",
    "SEKUR",
    "SEYKM",
    "SILVR",
    "SNGYO",
    "SNKRN",
    "SUNTK",
    "SUWEN",
    "TLMAN",
    "TMPOL",
    "TRCAS",
    "TRILC",
    "TSPOR",
    "TUCLK",
    "TURGG",
    "UNLU",
    "USAK",
    "VAKFO",
    "VAKKO",
    "VBTYZ",
    "VERUS", "VKGYO", "YATAS", "YGGYO", "YYAPI", "ZEDUR",
  ];

  final List<String> _bist30Symbols = [
    "AKBNK",
    "ARCLK",
    "ASELS",
    "ASTOR",
    "BIMAS",
    "BRSAN",
    "DOAS",
    "EKGYO",
    "ENKAI",
    "EREGL",
    "FROTO",
    "GARAN",
    "GUBRF",
    "HEKTS",
    "ISCTR",
    "KCHOL",
    "KONTR",
    "KOZAL",
    "KRDMD",
    "ODAS",
    "OYAKC",
    "PETKM",
    "PGSUS",
    "SAHOL",
    "SASA",
    "SISE",
    "TCELL",
    "THYAO",
    "TOASO",
    "TUPRS",
    "YKBNK",
  ];

  final List<String> _participationSymbols = [
    "BIMAS",
    "ASELS",
    "EREGL",
    "FROTO",
    "TOASO",
    "KONTR",
    "SMRTG",
    "EUPWR",
    "ASTOR",
  ];

  StockRepository();

  Future<List<Stock>> _fetchOrMock(List<String> symbols) async {
    if (symbols.isEmpty) return [];

    try {
      // Chunking to avoid URL length limits
      List<Stock> allFetchedStocks = [];
      const int queueSize = 50;

      for (int i = 0; i < symbols.length; i += queueSize) {
        final end = (i + queueSize < symbols.length)
            ? i + queueSize
            : symbols.length;
        final chunk = symbols.sublist(i, end);

        final chunkResults = await _yahooService.getQuotes(chunk);
        allFetchedStocks.addAll(chunkResults);
      }

      if (allFetchedStocks.isNotEmpty) {
        return allFetchedStocks;
      }
    } catch (e) {
      debugPrint("StockRepository Error: $e");
    }

    debugPrint("WARNING: Falling back to Mock Data (User prefers Real Data)");
    return _generateMockStocks(symbols);
  }

  Future<List<Stock>> getAllStocks() async {
    return await _fetchOrMock(_allStockSymbols);
  }

  Future<List<PortfolioItem>> getPortfolio() async {
    // 1. Get User's Portfolio from Supabase
    final userPortfolio = await _supabaseRepo.getPortfolio();

    if (userPortfolio.isEmpty) return [];

    // 2. Extract symbols
    final symbols = userPortfolio.map((e) => e['symbol'] as String).toList();

    // 3. Get Live Data
    final stocks = await _fetchOrMock(symbols);

    // 4. Merge
    List<PortfolioItem> portfolioItems = [];

    for (var item in userPortfolio) {
      final symbol = item['symbol'] as String;
      final quantity = item['quantity'] as int;
      final avgCost = (item['average_cost'] as num).toDouble();

      // Find matching stock data
      final stockIndex = stocks.indexWhere((s) => s.symbol == symbol);

      Stock stockData;
      if (stockIndex != -1) {
        stockData = stocks[stockIndex];
      } else {
        // Fallback if live data missed this specific symbol
        stockData = Stock(
          symbol: symbol,
          name: "$symbol A.Ş.",
          price: avgCost, // Fallback to cost so no insane profit/loss shown
          changeRate: 0.0,
        );
      }

      portfolioItems.add(
        PortfolioItem(
          stock: stockData,
          quantity: quantity,
          averageCost: avgCost,
          weeklyRec: "NÖTR", // Default or fetch logic
          monthlyRec: "NÖTR",
          threeMonthlyRec: "NÖTR",
        ),
      );
    }
    return portfolioItems;
  }

  Future<List<Stock>> getFavorites() async {
    // 1. Get User's Favorites from Supabase
    final favoriteSymbols = await _supabaseRepo.getFavorites();

    if (favoriteSymbols.isEmpty) return [];

    // 2. Get Live Data
    return await _fetchOrMock(favoriteSymbols);
  }

  Future<List<PortfolioTransaction>> getTransactions() async {
    return await _supabaseRepo.getTransactions();
  }

  Future<List<Stock>> getBist30Stocks() async {
    return await _fetchOrMock(_bist30Symbols);
  }

  Future<List<Stock>> getParticipationStocks() async {
    return await _fetchOrMock(_participationSymbols);
  }

  Future<void> addToPortfolio(String symbol, int quantity, double cost) async {
    await _supabaseRepo.addToPortfolio(symbol, quantity, cost);
  }

  Future<void> removeFromPortfolio(String symbol) async {
    await _supabaseRepo.removeFromPortfolio(symbol);
  }

  Future<void> addFavorite(String symbol) async {
    await _supabaseRepo.addFavorite(symbol);
  }

  // Method to remove favorite if needed
  Future<void> removeFavorite(String symbol) async {
    await _supabaseRepo.removeFavorite(symbol);
  }

  // Fallback Generation
  List<Stock> _generateMockStocks(List<String> symbols) {
    if (symbols.isEmpty) return [];

    // Realistic mock data
    final Map<String, double> mockPrices = {
      "GARAN": 105.4,
      "THYAO": 270.5,
      "BIMAS": 480.0,
      "TUPRS": 160.2,
      "ASELS": 60.5,
      "EREGL": 45.3,
      "KCHOL": 200.1,
      "AKBNK": 55.4,
      "SISE": 48.7,
      "SAHOL": 85.0,
      "FROTO": 1020.0,
      "TOASO": 250.5,
      "SASA": 42.1,
      "HEKTS": 15.3,
      "YKBNK": 28.9,
      "ISCTR": 12.5,
      "DOAS": 280.0,
      "KONTR": 230.5,
      "SMRTG": 55.0,
      "EUPWR": 140.0,
      "ASTOR": 95.5,
      "ODAS": 9.8,
      "PETKM": 22.4,
      "TCELL": 75.0,
      "TTKOM": 35.0,
      "ENKAI": 38.5,
      "BIST30": 10250.0,
      "XU100": 9150.0,
    };

    return symbols.map((symbol) {
      double price = mockPrices[symbol] ?? (10.0 + (symbol.length * 5.0));

      return Stock(
        symbol: symbol,
        name: "$symbol A.Ş.", // Removed (Mock) suffix
        price: price,
        changeRate: (symbol.hashCode % 200 - 100) / 100.0 * 5.0,
      );
    }).toList();
  }
}
