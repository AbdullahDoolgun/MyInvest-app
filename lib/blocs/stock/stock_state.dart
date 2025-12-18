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

  const StockLoaded({
    this.allStocks = const [],
    this.portfolioItems = const [],
    this.favoriteStocks = const [],
  });

  @override
  List<Object> get props => [allStocks, portfolioItems, favoriteStocks];

  StockLoaded copyWith({
    List<Stock>? allStocks,
    List<PortfolioItem>? portfolioItems,
    List<Stock>? favoriteStocks,
  }) {
    return StockLoaded(
      allStocks: allStocks ?? this.allStocks,
      portfolioItems: portfolioItems ?? this.portfolioItems,
      favoriteStocks: favoriteStocks ?? this.favoriteStocks,
    );
  }
}

class StockError extends StockState {
  final String message;

  const StockError(this.message);

  @override
  List<Object> get props => [message];
}
