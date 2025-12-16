import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AnalysisStatus { buy, sell, neutral }

class Analysis {
  final AnalysisStatus weekly;
  final AnalysisStatus monthly;
  final AnalysisStatus threeMonthly;

  Analysis({
    required this.weekly,
    required this.monthly,
    required this.threeMonthly,
  });
}

class PortfolioStock {
  final String symbol;
  final String name;
  final double price;
  final int quantity;
  final Analysis analysis;

  PortfolioStock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.quantity,
    required this.analysis,
  });
}

class PortfolioState {
  final List<PortfolioStock> heldStocks;
  final List<PortfolioStock> favoriteStocks;

  PortfolioState({
    required this.heldStocks,
    required this.favoriteStocks,
  });

  factory PortfolioState.initial() {
    return PortfolioState(
      heldStocks: [
        PortfolioStock(
          symbol: 'THYAO',
          name: 'Türk Hava Yolları',
          price: 250.5,
          quantity: 10,
          analysis: Analysis(weekly: AnalysisStatus.buy, monthly: AnalysisStatus.buy, threeMonthly: AnalysisStatus.neutral),
        ),
        PortfolioStock(
          symbol: 'ASELS',
          name: 'Aselsan',
          price: 45.2,
          quantity: 100,
          analysis: Analysis(weekly: AnalysisStatus.sell, monthly: AnalysisStatus.neutral, threeMonthly: AnalysisStatus.buy),
        ),
      ],
      favoriteStocks: [
        PortfolioStock(
          symbol: 'GARAN',
          name: 'Garanti BBVA',
          price: 60.0,
          quantity: 0,
          analysis: Analysis(weekly: AnalysisStatus.buy, monthly: AnalysisStatus.buy, threeMonthly: AnalysisStatus.buy),
        ),
      ],
    );
  }
}

class PortfolioViewModel extends StateNotifier<PortfolioState> {
  PortfolioViewModel() : super(PortfolioState.initial());
}

final portfolioViewModelProvider = StateNotifierProvider<PortfolioViewModel, PortfolioState>((ref) {
  return PortfolioViewModel();
});
