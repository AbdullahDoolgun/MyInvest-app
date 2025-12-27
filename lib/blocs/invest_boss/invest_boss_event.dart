part of 'invest_boss_bloc.dart';

@immutable
sealed class InvestBossEvent {}

class LoadGameData extends InvestBossEvent {}

class BuyStock extends InvestBossEvent {
  final String symbol;
  final int quantity;
  final double price;

  BuyStock({required this.symbol, required this.quantity, required this.price});
}

class SellStock extends InvestBossEvent {
  final String symbol;
  final int quantity;
  final double price;

  SellStock({required this.symbol, required this.quantity, required this.price});
}

class RefreshLeaderboard extends InvestBossEvent {}

class SyncEquity extends InvestBossEvent {
    final double totalEquity;
    SyncEquity(this.totalEquity);
}
