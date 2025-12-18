part of 'stock_bloc.dart';

abstract class StockEvent extends Equatable {
  const StockEvent();

  @override
  List<Object> get props => [];
}

class LoadStocks extends StockEvent {}

class AddFavoriteStock extends StockEvent {}
