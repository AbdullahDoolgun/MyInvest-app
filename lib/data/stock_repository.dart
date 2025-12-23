import '../models/stock_model.dart';
import 'yahoo_finance_service.dart';
import 'supabase_portfolio_repository.dart';
import 'dart:async';

class StockRepository {
  final YahooFinanceService _yahooService = YahooFinanceService();
  final SupabasePortfolioRepository _supabaseRepo = SupabasePortfolioRepository();

  // Symbols to track (Expanded List)
  final List<String> _allStockSymbols = [
    "GARAN", "THYAO", "BIMAS", "TUPRS", "ASELS", "EREGL", "KCHOL", "AKBNK", "SISE", "SAHOL",
    "FROTO", "TOASO", "SASA", "HEKTS", "YKBNK", "ISCTR", "DOAS", "KONTR", "SMRTG", "EUPWR",
    "ASTOR", "ODAS", "PETKM", "TCELL", "TTKOM", "ENKAI", "BIST30", "XU100"
  ];

  final List<String> _bist30Symbols = [
    "GARAN", "THYAO", "BIMAS", "TUPRS", "ASELS", "EREGL", "KCHOL", "AKBNK", "SISE", "SAHOL",
    "FROTO", "TOASO", "SASA", "HEKTS", "YKBNK", "ISCTR", "DOAS", "PETKM", "TCELL", "TTKOM"
  ];

  final List<String> _participationSymbols = [
    "BIMAS", "ASELS", "EREGL", "FROTO", "TOASO", "KONTR", "SMRTG", "EUPWR", "ASTOR"
  ];

  StockRepository();

  Future<List<Stock>> _fetchOrMock(List<String> symbols) async {
    if (symbols.isEmpty) return []; // Don't fetch if no symbols

    try {
      final stocks = await _yahooService.getQuotes(symbols);
      // Filter out any stocks that might not have been returned or error
       if (stocks.isNotEmpty) {
        // Ensure order matches if possible, or just return result
        return stocks;
       }
    } catch (e) {
      // Fallback
    }
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
      
      portfolioItems.add(PortfolioItem(
        stock: stockData,
        quantity: quantity,
        averageCost: avgCost,
        weeklyRec: "NÖTR", // Default or fetch logic
        monthlyRec: "NÖTR",
        threeMonthlyRec: "NÖTR",
      ));
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
  
  Future<List<Stock>> getBist30Stocks() async {
    return await _fetchOrMock(_bist30Symbols);
  }

  Future<List<Stock>> getParticipationStocks() async {
    return await _fetchOrMock(_participationSymbols);
  }

  Future<void> addToPortfolio(String symbol, int quantity, double cost) async {
    await _supabaseRepo.addToPortfolio(symbol, quantity, cost);
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
      "GARAN": 105.4, "THYAO": 270.5, "BIMAS": 480.0, "TUPRS": 160.2, "ASELS": 60.5,
      "EREGL": 45.3, "KCHOL": 200.1, "AKBNK": 55.4, "SISE": 48.7, "SAHOL": 85.0,
      "FROTO": 1020.0, "TOASO": 250.5, "SASA": 42.1, "HEKTS": 15.3, "YKBNK": 28.9,
      "ISCTR": 12.5, "DOAS": 280.0, "KONTR": 230.5, "SMRTG": 55.0, "EUPWR": 140.0,
      "ASTOR": 95.5, "ODAS": 9.8, "PETKM": 22.4, "TCELL": 75.0, "TTKOM": 35.0,
      "ENKAI": 38.5, "BIST30": 10250.0, "XU100": 9150.0
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
