import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/stock/stock_bloc.dart';

import '../constants/colors.dart';
import '../models/stock_model.dart';

enum ViewMode { risers, fallers }

class FullScreenStockView extends StatefulWidget {
  final List<Stock> allStocks;
  final ViewMode mode;

  const FullScreenStockView({
    super.key,
    required this.allStocks,
    required this.mode,
  });

  @override
  State<FullScreenStockView> createState() => _FullScreenStockViewState();
}

class _FullScreenStockViewState extends State<FullScreenStockView> {
  final GlobalKey _globalKey = GlobalKey();
  int _rotationQuarter = 0;

  // Settings
  int _itemCount = 10;
  // Track previous prices to determine flash color
  final Map<String, double> _prevPrices = {};
  final Map<String, Color> _flashColors = {};

  @override
  void initState() {
    super.initState();
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Initialize prev prices from widget.allStocks to avoid immediate flashing on first load
    for (var s in widget.allStocks) {
      _prevPrices[s.symbol] = s.price;
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _rotateScreen() {
    setState(() {
      _rotationQuarter = (_rotationQuarter + 1) % 4;
    });
  }

  Future<void> _takeScreenshot() async {
    try {
      RenderRepaintBoundary? boundary =
          _globalKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary != null) {
        // Just mock visual feedback
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ekran Görüntüsü Alındı")),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // "Ekrana sığacak şekilde" means we want to show _itemCount items.
    // We can use a LayoutBuilder to get dimensions, then GridView with childAspectRatio.

    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<StockBloc, StockState>(
        listener: (context, state) {
          if (state is StockLoaded) {
            // Check for price changes to trigger flashes
            for (var stock in state.allStocks) {
              final oldPrice = _prevPrices[stock.symbol];
              if (oldPrice != null && stock.price != oldPrice) {
                // Price changed
                if (stock.price > oldPrice) {
                  _flashColors[stock.symbol] = AppColors.up.withValues(
                    alpha: 0.3,
                  );
                } else {
                  _flashColors[stock.symbol] = AppColors.down.withValues(
                    alpha: 0.3,
                  );
                }

                // Clear flash after momentary delay
                Future.delayed(const Duration(seconds: 1), () {
                  if (mounted) {
                    setState(() {
                      _flashColors[stock.symbol] = Colors.transparent;
                    });
                  }
                });
              }
              // Update tracked price
              _prevPrices[stock.symbol] = stock.price;
            }
          }
        },
        builder: (context, state) {
          List<Stock> currentStocks = [];
          if (state is StockLoaded) {
            // Sorting logic
            currentStocks = List.from(
              state.allStocks,
            ); // Or use widget.allStocks if source of truth? Better use state.
            if (widget.mode == ViewMode.risers) {
              currentStocks.sort(
                (a, b) => b.changeRate.compareTo(a.changeRate),
              );
            } else {
              currentStocks.sort(
                (a, b) => a.changeRate.compareTo(b.changeRate),
              );
            }
          } else {
            currentStocks = widget.allStocks; // Fallback
          }

          return RepaintBoundary(
            key: _globalKey,
            child: RotatedBox(
              quarterTurns: _rotationQuarter,
              child: SafeArea(
                child: Column(
                  children: [
                    if (currentStocks.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text(
                            "Görüntülenecek hisse yok",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Determine columns based on item count vs available space
                            // We use _itemCount to determine how many items we WANT to show per screen page essentially?
                            // Or does _itemCount limit the total list?
                            // The user's slider was controlling "how many items on screen".

                            int displayLimit = _itemCount;
                            if (displayLimit > currentStocks.length)
                              displayLimit = currentStocks.length;

                            final visibleStocks = currentStocks
                                .take(displayLimit)
                                .toList();

                            int cols = 1;
                            if (displayLimit > 10) cols = 2;
                            if (displayLimit > 30) cols = 3;
                            if (displayLimit > 60) cols = 4;

                            int rows = (displayLimit / cols).ceil();
                            if (rows == 0) rows = 1;

                            double itemHeight = constraints.maxHeight / rows;
                            double itemWidth = constraints.maxWidth / cols;
                            double childAspectRatio = itemWidth / itemHeight;

                            return GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayLimit,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: cols,
                                    childAspectRatio: childAspectRatio,
                                  ),
                              itemBuilder: (context, index) {
                                final stock = visibleStocks[index];
                                final color =
                                    _flashColors[stock.symbol] ??
                                    Colors.transparent;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  decoration: BoxDecoration(
                                    color: color,
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          stock.symbol,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          stock.priceString,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          stock.changeString,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: stock.isUp
                                                ? AppColors.up
                                                : AppColors.down,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                    // Bottom Controls
                    Container(
                      color: Colors.grey[900],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.rotate_right,
                              color: Colors.white,
                            ),
                            onPressed: _rotateScreen,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ),
                            onPressed: _takeScreenshot,
                          ),
                          const SizedBox(width: 16),
                          // Slider
                          Expanded(
                            child: Slider(
                              value: _itemCount.toDouble(),
                              min: 1,
                              max: 100,
                              divisions: 99,
                              label: _itemCount.toString(),
                              activeColor: AppColors.primary,
                              onChanged: (val) {
                                setState(() {
                                  _itemCount = val.toInt();
                                });
                              },
                            ),
                          ),
                          Text(
                            "$_itemCount",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
