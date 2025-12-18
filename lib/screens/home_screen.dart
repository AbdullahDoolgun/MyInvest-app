import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/colors.dart';
import '../widgets/stock_card.dart';
import '../blocs/stock/stock_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, state) {
        if (state is StockLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StockError) {
          return Center(child: Text(state.message));
        }

        if (state is StockLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Expandable Past Transactions
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Theme.of(context).cardColor,
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.history,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      "Geçmiş İşlemler",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    collapsedIconColor: Theme.of(context).colorScheme.onSurface,
                    iconColor: Theme.of(context).colorScheme.primary,
                    children: const [
                      ListTile(
                        title: Text("BIMAS - Alış"),
                        subtitle: Text("12.12.2023 - 10 Adet"),
                        trailing: Text("₺4,952.50"),
                      ),
                      ListTile(
                        title: Text("THYAO - Satış"),
                        subtitle: Text("10.12.2023 - 5 Adet"),
                        trailing: Text("₺1,493.75"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Portfolio Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary, // Navy in Light, White in Dark
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PORTFÖY GÜNCEL TUTARI",
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onPrimary.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Simplified calc or hardcoded for now, or sum from portfolio
                      Text(
                        "₺158,245.50",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.show_chart,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "+₺12,540.20",
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.up,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "%8.61",
                              style: TextStyle(
                                color: Colors
                                    .white, // Keep white as 'up' color is usually solid
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Owned Stocks Header
                Text(
                  "Portföyüm",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                // Owned Stocks List
                ...state.portfolioItems.map(
                  (item) => StockCard(
                    symbol: item.stock.symbol,
                    name: item.stock.name,
                    price: item.stock.priceString,
                    change: item.stock.changeString,
                    isUp: item.stock.isUp,
                    subtitle:
                        "${item.quantity} Adet • Ort. ₺${item.averageCost}",
                  ),
                ),

                const SizedBox(height: 24),

                // 4. Favorite Stocks Header with Add Button
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
                if (state.favoriteStocks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Favori hisse yok."),
                  ),
                ...state.favoriteStocks.map(
                  (stock) => StockCard(
                    symbol: stock.symbol,
                    name: stock.name,
                    price: stock.priceString,
                    change: stock.changeString,
                    isUp: stock.isUp,
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
