import 'package:flutter_riverpod/flutter_riverpod.dart';

class Stock {
  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final double changeAmount;

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.changeAmount,
  });
}

class Transaction {
  final String symbol;
  final String type; // 'Buy' or 'Sell'
  final double amount;
  final double price;
  final DateTime date;

  Transaction({
    required this.symbol,
    required this.type,
    required this.amount,
    required this.price,
    required this.date,
  });
}

class HomeState {
  final double totalPortfolioValue;
  final double totalGainLossAmount;
  final double totalGainLossPercent;
  final List<Stock> heldStocks;
  final List<Stock> favoriteStocks;
  final List<Transaction> pastTransactions;
  final String userName;

  HomeState({
    required this.totalPortfolioValue,
    required this.totalGainLossAmount,
    required this.totalGainLossPercent,
    required this.heldStocks,
    required this.favoriteStocks,
    required this.pastTransactions,
    required this.userName,
  });

  factory HomeState.initial() {
    return HomeState(
      totalPortfolioValue: 125000.0,
      totalGainLossAmount: 5000.0,
      totalGainLossPercent: 4.2,
      userName: 'Ahmet',
      heldStocks: [
        Stock(symbol: 'THYAO', name: 'Türk Hava Yolları', price: 250.5, changePercent: 2.5, changeAmount: 6.1),
        Stock(symbol: 'ASELS', name: 'Aselsan', price: 45.2, changePercent: -1.2, changeAmount: -0.5),
      ],
      favoriteStocks: [
        Stock(symbol: 'GARAN', name: 'Garanti BBVA', price: 60.0, changePercent: 1.5, changeAmount: 0.9),
        Stock(symbol: 'AKBNK', name: 'Akbank', price: 32.8, changePercent: 0.8, changeAmount: 0.25),
      ],
      pastTransactions: [
        Transaction(symbol: 'THYAO', type: 'Buy', amount: 10, price: 240.0, date: DateTime.now().subtract(const Duration(days: 5))),
        Transaction(symbol: 'ASELS', type: 'Buy', amount: 100, price: 46.0, date: DateTime.now().subtract(const Duration(days: 10))),
      ],
    );
  }
}

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel() : super(HomeState.initial());
}

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel();
});
