import 'package:flutter/material.dart';
import '../models/stock_model.dart';
import '../constants/colors.dart';

class StockSelectionSheet extends StatefulWidget {
  final List<Stock> allStocks;
  final Function(Stock) onStockSelected;
  final String title;

  const StockSelectionSheet({
    super.key,
    required this.allStocks,
    required this.onStockSelected,
    this.title = "Hisse Seç",
  });

  @override
  State<StockSelectionSheet> createState() => _StockSelectionSheetState();
}

class _StockSelectionSheetState extends State<StockSelectionSheet> {
  late List<Stock> _filteredStocks;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStocks = List.from(widget.allStocks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterStocks(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredStocks = List.from(widget.allStocks);
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredStocks = widget.allStocks.where((stock) {
        return stock.symbol.toLowerCase().contains(lowerQuery) ||
            stock.name.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterStocks,
              decoration: InputDecoration(
                hintText: "Hisse Ara...",
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.3)),
                ),
                filled: true,
                fillColor: theme.cardColor,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stock List
          Expanded(
            child: _filteredStocks.isEmpty
                ? Center(
                    child: Text(
                      "Hisse bulunamadı.",
                      style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredStocks.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final stock = _filteredStocks[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          stock.symbol,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          stock.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              stock.priceString,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              stock.changeString,
                              style: TextStyle(
                                fontSize: 12,
                                color: stock.isUp ? AppColors.up : AppColors.down,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                           widget.onStockSelected(stock);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
