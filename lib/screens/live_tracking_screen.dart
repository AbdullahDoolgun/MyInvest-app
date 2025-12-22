import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/colors.dart';

import '../blocs/stock/stock_bloc.dart';
import 'fullscreen_stock_view.dart';
import '../models/stock_model.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StockLoaded) {
            return Column(
              children: [
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor:
                        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    indicatorColor: AppColors.primary,
                    tabs: const [
                      Tab(text: "BIST 30"),
                      Tab(text: "BIST Katılım"),
                      Tab(text: "Takip Listesi"),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _StockListSection(
                        title: "BIST 30 Endeksi",
                        indexValue: "9.150,25", // Mock Index Value
                        indexChange: "+%2.10",
                        stocks: state.bist30Stocks,
                      ),
                      _StockListSection(
                        title: "BIST Katılım Endeksi",
                        indexValue: "10.420,15", // Mock Index Value
                        indexChange: "+%0.85",
                        stocks: state.participationStocks,
                      ),
                      _StockListSection(
                        title: "Takip Listem",
                        indexValue: "", // No total for watchlist ideally, or sum
                        indexChange: "",
                        stocks: state.favoriteStocks,
                         isWatchlist: true,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _StockListSection extends StatelessWidget {
  final String title;
  final String indexValue;
  final String indexChange;
  final List<Stock> stocks;
  final bool isWatchlist;

  const _StockListSection({
    required this.title,
    required this.indexValue,
    required this.indexChange,
    required this.stocks,
    this.isWatchlist = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar (Common)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: "Hisse Kodu veya Şirket Adı Ara...",
                hintStyle: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Market Summary Card (Only if not generic watchlist, or customized)
          if (!isWatchlist)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.upLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    indexChange,
                    style: const TextStyle(
                      color: AppColors.up,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      indexValue,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if(!isWatchlist)
          const SizedBox(height: 24),

          // Top Risers Link
          _buildCategoryHeader(
             context, 
             "En Çok Yükselenler", 
             Icons.trending_up, 
             AppColors.up,
             ViewMode.Risers
          ),
          
          const SizedBox(height: 16),

          // Top Fallers Link
          _buildCategoryHeader(
             context, 
             "En Çok Düşenler", 
             Icons.trending_down, 
             AppColors.down,
             ViewMode.Fallers
          ),

          const SizedBox(height: 24),

          // List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "HİSSELER",
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.sort,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 20,
                  ),
                   const SizedBox(width: 16),
                  Icon(
                    Icons.filter_list,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stocks Grid
          if (stocks.isEmpty)
             const Center(child: Text("Liste boş")),
          
          if (stocks.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return _GridStockCard(
                symbol: stock.symbol,
                name: stock.name,
                price: stock.priceString,
                change: stock.changeString,
                isUp: stock.isUp,
              );
            },
          ),
           const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String title, IconData icon, Color color, ViewMode mode) {
      return InkWell(
        onTap: () {
           // Filter and sort based on mode for *this specific list* generally, 
           // but for now we pass the whole list or the specific subsection to the detailed view.
           // The user requirement implies clicking this opens a "full screen" view of these specific items sorted.
           
           // We will pass 'stocks' (current tab's stocks) to the FullScreenView
           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullScreenStockView(
                allStocks: stocks, // Pass only the stocks in this tab!
                mode: mode,
              ),
            ),
          );
        },
        child: Row(
          children: [
             Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                 color: color.withValues(alpha: 0.1),
                 shape: BoxShape.circle,
               ),
               child: Icon(icon, color: color, size: 20),
             ),
             const SizedBox(width: 12),
             Text(
               title,
               style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.bold,
                 color: Theme.of(context).colorScheme.onSurface,
               ),
             ),
             const Spacer(),
             Icon(
               Icons.arrow_forward_ios, 
               size: 14, 
               color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
             ),
          ],
        ),
      );
  }
}

class _GridStockCard extends StatelessWidget {
  final String symbol;
  final String name;
  final String price;
  final String change;
  final bool isUp;

  const _GridStockCard({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surface, // Adjust if needed for contrast
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: Text(
                  symbol.substring(0, symbol.length > 2 ? 2 : symbol.length),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isUp ? AppColors.upLight : AppColors.downLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 10,
                      color: isUp ? AppColors.up : AppColors.down,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isUp ? AppColors.up : AppColors.down,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            symbol,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
