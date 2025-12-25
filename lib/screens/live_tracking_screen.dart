import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/colors.dart';

import '../blocs/stock/stock_bloc.dart';

import '../models/stock_model.dart';

class LiveTrackingScreen extends StatelessWidget {
  const LiveTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, state) {
        if (state is StockLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is StockLoaded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              children: [
                _StockListSection(
                  title: "BIST 100 Endeksi",
                  indexValue: "9.150,25", // Mock Index Value
                  indexChange: "+%2.10",
                  stocks: state.allStocks, // Assuming allStocks is BIST 100
                ),
                _StockListSection(
                  title: "BIST 30 Endeksi",
                  indexValue: "9.850,40", // Mock Index Value
                  indexChange: "+%2.45",
                  stocks: state.bist30Stocks,
                ),
                _StockListSection(
                  title: "BIST Katılım Endeksi",
                  indexValue: "10.420,15", // Mock Index Value
                  indexChange: "+%0.85",
                  stocks: state.participationStocks,
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

enum SortType { none, risers, fallers }

class _StockListSection extends StatefulWidget {
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
  State<_StockListSection> createState() => _StockListSectionState();
}

class _StockListSectionState extends State<_StockListSection> {
  SortType _sortType = SortType.none;

  List<Stock> get sortedStocks {
    List<Stock> list = List.from(widget.stocks);
    if (_sortType == SortType.risers) {
      list.sort((a, b) => b.changeRate.compareTo(a.changeRate));
    } else if (_sortType == SortType.fallers) {
      list.sort((a, b) => a.changeRate.compareTo(b.changeRate));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    // If watchlist is empty and it's the watchlist section, handle gracefully
    if (widget.isWatchlist && widget.stocks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            "Takip listeniz boş",
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          if (!widget.isWatchlist)
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
                  // Change Box (Left)
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
                      widget.indexChange,
                      style: const TextStyle(
                        color: AppColors.up,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title & Value (Middle-Left)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.indexValue,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Sorting Buttons (Right)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildSortButton(
                        "En Çok Yükselen",
                        SortType.risers,
                        AppColors.up,
                      ),
                      const SizedBox(height: 8),
                      _buildSortButton(
                        "En Çok Düşen",
                        SortType.fallers,
                        AppColors.down,
                      ),
                    ],
                  ),
                ],
              ),
            )
          else
            // Watchlist Header
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // List Header (Optional, but good for clarity)
          if (!widget.isWatchlist)
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
                // Reset Sort Button (Optional)
                if (_sortType != SortType.none)
                  GestureDetector(
                    onTap: () => setState(() => _sortType = SortType.none),
                    child: Text(
                      "Sıfırla",
                      style: TextStyle(color: AppColors.primary, fontSize: 12),
                    ),
                  ),
              ],
            ),

          if (!widget.isWatchlist) const SizedBox(height: 12),

          // Grid of Stocks
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              childAspectRatio: 1.3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: sortedStocks.length,
            itemBuilder: (context, index) {
              final stock = sortedStocks[index];
              return _GridStockCard(
                symbol: stock.symbol,
                name: stock.name,
                price: stock.priceString,
                change: stock.changeString,
                isUp: stock.isUp,
              );
            },
          ),
          const SizedBox(height: 24),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildSortButton(String text, SortType type, Color color) {
    final isSelected = _sortType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortType = (isSelected) ? SortType.none : type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : color,
          ),
        ),
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
      padding: const EdgeInsets.all(10), // Reduced from 12
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.1),
                  ),
                ),
                child: FittedBox(
                  child: Text(
                    symbol.substring(0, symbol.length > 2 ? 2 : symbol.length),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: colorScheme.onSurface,
                    ),
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
          const Spacer(), // Keeps using spacer but with more room due to less padding
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
