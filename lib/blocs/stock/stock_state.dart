part of 'stock_bloc.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object?> get props => [];
}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<Stock> allStocks;
  final List<PortfolioItem> portfolioItems;
  final List<Stock> favoriteStocks;
  final List<Stock> bist30Stocks;
  final List<Stock> participationStocks;
  final List<PortfolioTransaction> transactions;
  final DateTime? lastUpdated;

  const StockLoaded({
    this.allStocks = const [],
    this.portfolioItems = const [],
    this.favoriteStocks = const [],
    this.bist30Stocks = const [],
    this.participationStocks = const [],
    this.transactions = const [],
    this.lastUpdated,
  });

  double get totalCurrentValue {
    // Sum of quantity * current price for all items
    return portfolioItems.fold(0, (sum, item) {
      return sum + (item.quantity * item.stock.price);
    });
  }

  double get totalCost {
    // Sum of quantity * average cost for all items
    return portfolioItems.fold(0, (sum, item) {
      return sum + (item.quantity * item.averageCost);
    });
  }

  double get totalProfitLoss => totalCurrentValue - totalCost;

  double get totalProfitLossRate {
    if (totalCost == 0) return 0;
    return (totalProfitLoss / totalCost) * 100;
  }

  @override
  List<Object?> get props => [
    allStocks,
    portfolioItems,
    favoriteStocks,
    bist30Stocks,
    participationStocks,
    transactions,
    lastUpdated,
  ];

  StockLoaded copyWith({
    List<Stock>? allStocks,
    List<PortfolioItem>? portfolioItems,
    List<Stock>? favoriteStocks,
    List<Stock>? bist30Stocks,
    List<Stock>? participationStocks,
    List<PortfolioTransaction>? transactions,
    DateTime? lastUpdated,
  }) {
    return StockLoaded(
      allStocks: allStocks ?? this.allStocks,
      portfolioItems: portfolioItems ?? this.portfolioItems,
      favoriteStocks: favoriteStocks ?? this.favoriteStocks,
      bist30Stocks: bist30Stocks ?? this.bist30Stocks,
      participationStocks: participationStocks ?? this.participationStocks,
      transactions: transactions ?? this.transactions,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }
}

class StockError extends StockState {
  final String message;

  const StockError(this.message);

  @override
  List<Object> get props => [message];
}
