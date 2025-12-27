import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../data/invest_boss_repository.dart';

part 'invest_boss_event.dart';
part 'invest_boss_state.dart';

class InvestBossBloc extends Bloc<InvestBossEvent, InvestBossState> {
  final InvestBossRepository _repository;

  InvestBossBloc({required InvestBossRepository repository})
      : _repository = repository,
        super(const InvestBossState()) {
    on<LoadGameData>(_onLoadGameData);
    on<BuyStock>(_onBuyStock);
    on<SellStock>(_onSellStock);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
    on<SyncEquity>(_onSyncEquity);
  }

  Future<void> _onLoadGameData(
    LoadGameData event,
    Emitter<InvestBossState> emit,
  ) async {
    emit(state.copyWith(status: InvestBossStatus.loading));
    try {
      final profile = await _repository.getGameProfile();
      final portfolio = await _repository.getGamePortfolio();
      
      // Also fetch leaderboard initially
      final leaderboard = await _repository.getLeaderboard();

      emit(state.copyWith(
        status: InvestBossStatus.success,
        profile: profile,
        portfolio: portfolio,
        leaderboard: leaderboard,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InvestBossStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<InvestBossState> emit,
  ) async {
      try {
          final leaderboard = await _repository.getLeaderboard();
          emit(state.copyWith(leaderboard: leaderboard));
      } catch (e) {
          debugPrint("Leaderboard refresh failed: $e");
      }
  }

  Future<void> _onBuyStock(
    BuyStock event,
    Emitter<InvestBossState> emit,
  ) async {
    try {
      await _repository.buyStock(event.symbol, event.quantity, event.price);
      add(LoadGameData()); // Reload to update UI
    } catch (e) {
      emit(state.copyWith(
        status: InvestBossStatus.failure,
        errorMessage: "Alım işlemi başarısız: $e",
      ));
      // Reset status to success or initial after error so UI can recover?
      // Better: just emit error, UI shows snackbar, then user tries again.
    }
  }

  Future<void> _onSellStock(
    SellStock event,
    Emitter<InvestBossState> emit,
  ) async {
    try {
      await _repository.sellStock(event.symbol, event.quantity, event.price);
      add(LoadGameData());
    } catch (e) {
      emit(state.copyWith(
        status: InvestBossStatus.failure,
        errorMessage: "Satış işlemi başarısız: $e",
      ));
    }
  }
  
  Future<void> _onSyncEquity(
      SyncEquity event,
      Emitter<InvestBossState> emit,
  ) async {
      await _repository.syncEquity(event.totalEquity);
  }
}
