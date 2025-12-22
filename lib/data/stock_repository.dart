import '../models/stock_model.dart';
import 'dart:async';

class StockRepository {
  // All Stocks Database
  final List<Stock> _allStocks = [
    Stock(
      symbol: "GARAN",
      name: "Garanti Bankası",
      price: 108.50,
      changeRate: 2.15,
    ),
    Stock(
      symbol: "THYAO",
      name: "Türk Hava Yolları",
      price: 298.75,
      changeRate: -0.85,
    ),
    Stock(
      symbol: "BIMAS",
      name: "BİM Mağazalar",
      price: 495.25,
      changeRate: 3.10,
    ),
    Stock(symbol: "TUPRS", name: "Tüpraş", price: 180.60, changeRate: -1.20),
    Stock(symbol: "ASELS", name: "Aselsan", price: 42.10, changeRate: 0.45),
    Stock(
      symbol: "EREGL",
      name: "Ereğli Demir Çelik",
      price: 41.80,
      changeRate: -7.52,
    ),
    Stock(
      symbol: "KCHOL",
      name: "Koç Holding",
      price: 140.00,
      changeRate: 1.50,
    ),
    Stock(symbol: "AKBNK", name: "Akbank", price: 30.20, changeRate: 0.90),
  ];

  List<PortfolioItem> _portfolioItems = [];
  List<Stock> _favoriteStocks = [];

  List<Stock> _bist30Stocks = [];
  List<Stock> _participationStocks = [];

  StockRepository() {
    _init();
  }

  void _init() {
    // Initial Data
    _portfolioItems = [
      PortfolioItem(
        stock: _allStocks.firstWhere((s) => s.symbol == "GARAN"),
        quantity: 1500,
        averageCost: 108.50,
        weeklyRec: "AL",
        monthlyRec: "NÖTR",
        threeMonthlyRec: "AL",
      ),
      PortfolioItem(
        stock: _allStocks.firstWhere((s) => s.symbol == "THYAO"),
        quantity: 450,
        averageCost: 298.75,
        weeklyRec: "SAT",
        monthlyRec: "NÖTR",
        threeMonthlyRec: "AL",
      ),
    ];

    _favoriteStocks = [
      _allStocks.firstWhere((s) => s.symbol == "BIMAS"),
      _allStocks.firstWhere((s) => s.symbol == "TUPRS"),
    ];
    
    // Mock BIST 30 Data (Subset of all stocks + new ones)
    _bist30Stocks = [
       _allStocks.firstWhere((s) => s.symbol == "GARAN"),
       _allStocks.firstWhere((s) => s.symbol == "THYAO"),
       _allStocks.firstWhere((s) => s.symbol == "BIMAS"),
       _allStocks.firstWhere((s) => s.symbol == "TUPRS"),
       _allStocks.firstWhere((s) => s.symbol == "ASELS"),
       _allStocks.firstWhere((s) => s.symbol == "EREGL"),
       _allStocks.firstWhere((s) => s.symbol == "KCHOL"),
       _allStocks.firstWhere((s) => s.symbol == "AKBNK"),
       Stock(symbol: "SISE", name: "Şişecam", price: 48.20, changeRate: 1.10),
       Stock(symbol: "SAHOL", name: "Sabancı Holding", price: 78.50, changeRate: -0.50),
    ];

    // Mock Participation Data
    _participationStocks = [
       _allStocks.firstWhere((s) => s.symbol == "BIMAS"),
       _allStocks.firstWhere((s) => s.symbol == "ASELS"),
       _allStocks.firstWhere((s) => s.symbol == "EREGL"),
       Stock(symbol: "FROTO", name: "Ford Otosan", price: 850.00, changeRate: 2.50),
       Stock(symbol: "TOASO", name: "Tofaş", price: 245.50, changeRate: -1.10),
    ];
  }

  // Simulate async operations
  Future<List<Stock>> getAllStocks() async {
    await Future.delayed(const Duration(milliseconds: 50)); // Simluate delay
    return _allStocks;
  }

  Future<List<PortfolioItem>> getPortfolio() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _portfolioItems;
  }

  Future<List<Stock>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _favoriteStocks;
  }
  
  Future<List<Stock>> getBist30Stocks() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _bist30Stocks;
  }

  Future<List<Stock>> getParticipationStocks() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _participationStocks;
  }

  Future<void> addFavorite() async {
    for (var stock in _allStocks) {
      if (!_favoriteStocks.contains(stock)) {
        _favoriteStocks.add(stock);
        break; // Add only one
      }
    }
  }
}
