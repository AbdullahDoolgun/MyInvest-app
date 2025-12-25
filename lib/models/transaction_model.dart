class PortfolioTransaction {
  final int? id;
  final String userId;
  final String symbol;
  final String type; // 'BUY' or 'SELL'
  final int quantity;
  final double price;
  final DateTime date;

  PortfolioTransaction({
    this.id,
    required this.userId,
    required this.symbol,
    required this.type,
    required this.quantity,
    required this.price,
    required this.date,
  });

  factory PortfolioTransaction.fromJson(Map<String, dynamic> json) {
    return PortfolioTransaction(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      symbol: json['symbol'] as String,
      type: json['type'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      date: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'symbol': symbol,
      'type': type,
      'quantity': quantity,
      'price': price,
      'created_at': date.toIso8601String(),
    };
  }
}
