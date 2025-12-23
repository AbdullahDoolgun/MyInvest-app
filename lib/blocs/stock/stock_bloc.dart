import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/stock_model.dart';
import '../../data/stock_repository.dart';
import 'package:flutter/foundation.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository repository;

  StockBloc({required this.repository}) : super(StockLoading()) {
    on<LoadStocks>(_onLoadStocks);
    on<AddPortfolioStock>(_onAddPortfolioStock);
    on<AddFavoriteStock>(_onAddFavoriteStock);
    on<RefreshStocks>(_onRefreshStocks);
  }

  Future<void> _onLoadStocks(LoadStocks event, Emitter<StockState> emit) async {
    try {
      final stocks = await repository.getAllStocks();
      final portfolio = await repository.getPortfolio();
      final favorites = await repository.getFavorites();
      final bist30 = await repository.getBist30Stocks();
      final participation = await repository.getParticipationStocks();

      emit(
        StockLoaded(
          allStocks: stocks,
          portfolioItems: portfolio,
          favoriteStocks: favorites,
          bist30Stocks: bist30,
          participationStocks: participation,
        ),
      );
    } catch (e) {
      emit(StockError("Failed to load stocks: $e"));
    }
  }

  Future<void> _onAddFavoriteStock(
    AddFavoriteStock event,
    Emitter<StockState> emit,
  ) async {
    if (state is StockLoaded) {
      try {
        await repository.addFavorite(event.symbol);
        // Reload data to stay in sync
        final favorites = await repository.getFavorites();

        final currentState = state as StockLoaded;
        emit(currentState.copyWith(favoriteStocks: List.from(favorites)));
      } catch (e) {
        emit(StockError("Failed to add favorite"));
      }
    }
  }

  Future<void> _onAddPortfolioStock(
    AddPortfolioStock event,
    Emitter<StockState> emit,
  ) async {
    if (state is StockLoaded) {
      try {
        await repository.addToPortfolio(event.symbol, event.quantity, event.cost);
        // Reload data
        final portfolio = await repository.getPortfolio();
        final currentState = state as StockLoaded;
        emit(currentState.copyWith(portfolioItems: List.from(portfolio)));
      } catch (e) {
        emit(StockError("Failed to add to portfolio: $e"));
      }
    }
  }
  Future<void> _onRefreshStocks(RefreshStocks event, Emitter<StockState> emit) async {
    // Quietly update data without changing state to Loading
    if (state is StockLoaded) {
      try {
        final stocks = await repository.getAllStocks();
        final portfolio = await repository.getPortfolio();
        final favorites = await repository.getFavorites();
        final bist30 = await repository.getBist30Stocks();
        final participation = await repository.getParticipationStocks();

        emit(
          StockLoaded(
            allStocks: stocks,
            portfolioItems: portfolio,
            favoriteStocks: favorites,
            bist30Stocks: bist30,
            participationStocks: participation,
          ),
        );
      } catch (e) {
        // Silently fail or log, don't disrupt user
        debugPrint("Quiet Refresh Failed: $e");
      }
    }
  }
}
