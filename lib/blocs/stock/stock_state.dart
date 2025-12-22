part of 'stock_bloc.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object> get props => [];
}

class StockLoading extends StockState {}

class StockLoaded extends StockState {
  final List<Stock> allStocks;
  final List<PortfolioItem> portfolioItems;
  final List<Stock> favoriteStocks;
  final List<Stock> bist30Stocks;
  final List<Stock> participationStocks;

  const StockLoaded({
    this.allStocks = const [],
    this.portfolioItems = const [],
    this.favoriteStocks = const [],
    this.bist30Stocks = const [],
    this.participationStocks = const [],
  });

  @override
  List<Object> get props => [
        allStocks,
        portfolioItems,
        favoriteStocks,
        bist30Stocks,
        participationStocks,
      ];

  StockLoaded copyWith({
    List<Stock>? allStocks,
    List<PortfolioItem>? portfolioItems,
    List<Stock>? favoriteStocks,
    List<Stock>? bist30Stocks,
    List<Stock>? participationStocks,
  }) {
    return StockLoaded(
      allStocks: allStocks ?? this.allStocks,
      portfolioItems: portfolioItems ?? this.portfolioItems,
      favoriteStocks: favoriteStocks ?? this.favoriteStocks,
      bist30Stocks: bist30Stocks ?? this.bist30Stocks,
      participationStocks: participationStocks ?? this.participationStocks,
    );
  }
}

class StockError extends StockState {
  final String message;

  const StockError(this.message);

  @override
  List<Object> get props => [message];
}
