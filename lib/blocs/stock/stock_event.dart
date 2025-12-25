part of 'stock_bloc.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object> get props => [];
}

class LoadStocks extends StockEvent {}

class AddPortfolioStock extends StockEvent {
  final String symbol;
  final int quantity;
  final double cost;

  const AddPortfolioStock({
    required this.symbol,
    required this.quantity,
    required this.cost,
  });

  @override
  List<Object> get props => [symbol, quantity, cost];
}

class RemovePortfolioStock extends StockEvent {
  final String symbol;

  const RemovePortfolioStock(this.symbol);

  @override
  List<Object> get props => [symbol];
}

class AddFavoriteStock extends StockEvent {
  final String symbol;

  const AddFavoriteStock(this.symbol);

  @override
  List<Object> get props => [symbol];
}

class RemoveFavoriteStock extends StockEvent {
  final String symbol;

  const RemoveFavoriteStock(this.symbol);

  @override
  List<Object> get props => [symbol];
}

class RefreshStocks extends StockEvent {}
