class Stock {
  final String symbol;
  final String name;
  final double price;
  final double changeRate; // e.g. 2.15 for +2.15%

  Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changeRate,
  });

  bool get isUp => changeRate >= 0;
  String get changeString =>
      "${changeRate >= 0 ? '+' : ''}${changeRate.toStringAsFixed(2)}%";
  String get priceString => "₺${price.toStringAsFixed(2)}";
}

class PortfolioItem {
  final Stock stock;
  final int quantity;
  final double averageCost;
  final String weeklyRec;
  final String monthlyRec;
  final String threeMonthlyRec;

  PortfolioItem({
    required this.stock,
    required this.quantity,
    required this.averageCost,
    this.weeklyRec = "NÖTR",
    this.monthlyRec = "NÖTR",
    this.threeMonthlyRec = "NÖTR",
  });
}
