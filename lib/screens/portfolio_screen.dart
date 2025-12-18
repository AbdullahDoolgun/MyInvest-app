import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/colors.dart';
import '../widgets/portfolio_stock_card.dart';
import '../blocs/stock/stock_bloc.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, state) {
        if (state is StockLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StockLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Value Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Portföy Toplam Değer",
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Mock Value
                            Text(
                              "₺128,450.75",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.upLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.arrow_upward,
                                    size: 14,
                                    color: AppColors.up,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "+₺1,240.10 (+1.87%)",
                                    style: TextStyle(
                                      color: AppColors.up,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Portfolio List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Portföyüm",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      "${state.portfolioItems.length} Hisse",
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Portfolio Items
                ...state.portfolioItems.map(
                  (item) => PortfolioStockCard(
                    symbol: item.stock.symbol,
                    name: "${item.quantity} Adet • ₺${item.averageCost}",
                    price:
                        "₺${(item.quantity * item.stock.price).toStringAsFixed(0)}",
                    change: item.stock.changeString,
                    isUp: item.stock.isUp,
                    weekly: item.weeklyRec,
                    monthly: item.monthlyRec,
                    threeMonthly: item.threeMonthlyRec,
                  ),
                ),

                const SizedBox(height: 24),

                // Favorites
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Favori Hisseler",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: AppColors.accent,
                      ),
                      onPressed: () {
                        context.read<StockBloc>().add(AddFavoriteStock());
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Favorites Items
                ...state.favoriteStocks.map(
                  (stock) => PortfolioStockCard(
                    symbol: stock.symbol,
                    name: stock.name,
                    price: stock.priceString,
                    change: stock.changeString,
                    isUp: stock.isUp,
                    weekly: "AL",
                    monthly: "NÖTR",
                    threeMonthly: "SAT", // Mock data
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
