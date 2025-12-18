import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/stock_model.dart';
import '../../data/stock_repository.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository repository;

  StockBloc({required this.repository}) : super(StockLoading()) {
    on<LoadStocks>(_onLoadStocks);
    on<AddFavoriteStock>(_onAddFavoriteStock);
  }

  Future<void> _onLoadStocks(LoadStocks event, Emitter<StockState> emit) async {
    try {
      final stocks = await repository.getAllStocks();
      final portfolio = await repository.getPortfolio();
      final favorites = await repository.getFavorites();

      emit(
        StockLoaded(
          allStocks: stocks,
          portfolioItems: portfolio,
          favoriteStocks: favorites,
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
        await repository.addFavorite();
        // Reload data to stay in sync
        final favorites = await repository.getFavorites();

        final currentState = state as StockLoaded;
        emit(currentState.copyWith(favoriteStocks: List.from(favorites)));
      } catch (e) {
        emit(StockError("Failed to add favorite"));
      }
    }
  }
}
