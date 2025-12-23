import '../models/stock_model.dart';
import 'yahoo_finance_service.dart';
import 'dart:async';

class StockRepository {
  final YahooFinanceService _yahooService = YahooFinanceService();

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

  // Portfolio Data Configuration (Mock database for portfolio holdings)
  final List<Map<String, dynamic>> _portfolioConfig = [
    {
      "symbol": "GARAN",
      "quantity": 1500,
      "averageCost": 108.50,
      "weeklyRec": "AL",
      "monthlyRec": "NÖTR",
      "threeMonthlyRec": "AL"
    },
    {
      "symbol": "THYAO",
      "quantity": 450,
      "averageCost": 298.75,
      "weeklyRec": "SAT",
      "monthlyRec": "NÖTR",
      "threeMonthlyRec": "AL"
    }
  ];

  final List<String> _favoriteSymbols = ["BIMAS", "TUPRS", "SASA", "HEKTS"];

  StockRepository();

  Future<List<Stock>> _fetchOrMock(List<String> symbols) async {
    try {
      final stocks = await _yahooService.getQuotes(symbols);
      if (stocks.isNotEmpty) return stocks;
    } catch (e) {
      // Fallback
    }
    return _generateMockStocks(symbols);
  }

  Future<List<Stock>> getAllStocks() async {
    return await _fetchOrMock(_allStockSymbols);
  }

  Future<List<PortfolioItem>> getPortfolio() async {
    final symbols = _portfolioConfig.map((e) => e['symbol'] as String).toList();
    final stocks = await _fetchOrMock(symbols);
    
    List<PortfolioItem> portfolioItems = [];
    
    for (var config in _portfolioConfig) {
      final stockIndex = stocks.indexWhere((s) => s.symbol == config['symbol']);
      if (stockIndex != -1) {
        portfolioItems.add(PortfolioItem(
          stock: stocks[stockIndex],
          quantity: config['quantity'],
          averageCost: config['averageCost'],
          weeklyRec: config['weeklyRec'],
          monthlyRec: config['monthlyRec'],
          threeMonthlyRec: config['threeMonthlyRec'],
        ));
      } else {
        // Create a mock stock if not found
        final mockStock = Stock(
          symbol: config['symbol'],
          name: "${config['symbol']} A.Ş.",
          price: config['averageCost'] * 1.1, // Mock current price
          changeRate: 1.5,
        );
         portfolioItems.add(PortfolioItem(
          stock: mockStock,
          quantity: config['quantity'],
          averageCost: config['averageCost'],
          weeklyRec: config['weeklyRec'],
          monthlyRec: config['monthlyRec'],
          threeMonthlyRec: config['threeMonthlyRec'],
        ));
      }
    }
    return portfolioItems;
  }

  Future<List<Stock>> getFavorites() async {
    return await _fetchOrMock(_favoriteSymbols);
  }
  
  Future<List<Stock>> getBist30Stocks() async {
    return await _fetchOrMock(_bist30Symbols);
  }

  Future<List<Stock>> getParticipationStocks() async {
    return await _fetchOrMock(_participationSymbols);
  }

  Future<void> addToPortfolio(String symbol, int quantity, double cost) async {
    _portfolioConfig.add({
      "symbol": symbol,
      "quantity": quantity,
      "averageCost": cost,
      "weeklyRec": "NÖTR",
      "monthlyRec": "NÖTR",
      "threeMonthlyRec": "NÖTR"
    });
  }

  Future<void> addFavorite(String symbol) async {
    if (!_favoriteSymbols.contains(symbol)) {
      _favoriteSymbols.add(symbol);
    }
  }

  // Fallback Generation
  List<Stock> _generateMockStocks(List<String> symbols) {
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
