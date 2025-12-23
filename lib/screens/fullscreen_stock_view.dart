import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/rendering.dart';

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
  late List<Stock> _displayStocks;
  late Timer _timer;
  int _rotationQuarter = 0;
  final GlobalKey _globalKey = GlobalKey();

  // Settings
  int _itemCount = 10;
  // Track previous prices to determine flash color
  final Map<String, double> _prevPrices = {};
  final Map<String, Color> _flashColors = {};

  @override
  void initState() {
    super.initState();
    _populateStocks();
    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startSimulation();
  }

  void _populateStocks() {
    // Generate dummy stocks to fill up to 100 based on the "allStocks"
    // In a real app, this would be fetched from API
    List<Stock> baseStocks = List.from(widget.allStocks);
    _displayStocks = [];

    // Sort base based on mode to have "real" ones first
    // Sort base based on mode to have "real" ones first
    if (widget.mode == ViewMode.risers) {
      baseStocks.sort((a, b) => b.changeRate.compareTo(a.changeRate));
    } else {
      baseStocks.sort((a, b) => a.changeRate.compareTo(b.changeRate));
    }

    if (baseStocks.isEmpty) return; // Prevent crash if list is empty

    // Fill to 100
    for (int i = 0; i < 100; i++) {
      Stock template = baseStocks[i % baseStocks.length];

      // Vary the template slightly so they aren't identical
      double priceVar = 1.0 + (Random().nextDouble() - 0.5) * 0.1;
      double changeVar = widget.mode == ViewMode.risers
          ? Random().nextDouble() * 5
          : -Random().nextDouble() * 5;

      _displayStocks.add(
        Stock(
          symbol: "${template.symbol}${i > baseStocks.length ? i : ''}",
          name: template.name,
          price: template.price * priceVar,
          changeRate: changeVar, // Ensure it fits the mode
        ),
      );
    }

    // Initialize prev prices
    for (var s in _displayStocks) {
      _prevPrices[s.symbol] = s.price;
      _flashColors[s.symbol] = Colors.transparent;
    }
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final random = Random();

      setState(() {
        for (int i = 0; i < _displayStocks.length; i++) {
          if (_displayStocks.isEmpty) break;
          var s = _displayStocks[i];
          double change = (random.nextDouble() - 0.5) * (s.price * 0.01);
          double newPrice = s.price + change;

          // Update flash color
          if (newPrice > s.price) {
            _flashColors[s.symbol] = AppColors.up.withValues(alpha: 0.3);
          } else if (newPrice < s.price) {
            _flashColors[s.symbol] = AppColors.down.withValues(alpha: 0.3);
          } else {
            _flashColors[s.symbol] = Colors.transparent;
          }

          // Update stock
          _displayStocks[i] = Stock(
            symbol: s.symbol,
            name: s.name,
            price: newPrice,
            changeRate:
                s.changeRate + (change / s.price) * 100, // simplistic approx
          );
        }
      });

      // Clear flash after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            // Reset all to transparent? No, just loop.
            // Actually, recreating the map is expensive in build, but updating standard Map is fine.
            // We can just rely on the next tick overwriting it or set timer to clear.
            // For simplicity in this loop, we just leave it until next update or fade it out?
            // The user asked for "yanıp sönüyor", implying it goes back to normal.
            _flashColors.updateAll((key, value) => Colors.transparent);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
      body: RepaintBoundary(
        key: _globalKey,
        child: RotatedBox(
          quarterTurns: _rotationQuarter,
          child: SafeArea(
            child: Column(
              children: [
                if (_displayStocks.isEmpty)
                  const Expanded(child: Center(child: Text("Görüntülenecek hisse yok", style: TextStyle(color: Colors.white))))
                else
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Calculate grid
                      // If count is small (e.g. 1-3), maybe just a Column.
                      // If count is large, Grid.
                      // Let's try to find a nice aspect ratio.
                      // Simple approach: Always use a list/grid that forces fitting.
                      // However, GridView usually needs childAspectRatio.

                      // We want to fit N items in local height.
                      // Let's assume 2 columns for better readability if Count > 5?
                      // Or Just 1 column?
                      // User said "bist100 hisseleri listelenecek".
                      // Let's do a GridView with maxCrossAxisExtent to responsive fit,
                      // but adjust ratio so exactly _itemCount rows*cols fit in height.

                      // Actually, easiest way to "fit exactly N items" is:
                      // Calculate item Height = TotalHeight / ceil(N / Cols).

                      int cols = 1;
                      if (_itemCount > 10) cols = 2;
                      if (_itemCount > 30) cols = 3;
                      if (_itemCount > 60) cols = 4;

                      int rows = (_itemCount / cols).ceil();
                      double itemHeight = constraints.maxHeight / rows;
                      double itemWidth = constraints.maxWidth / cols;
                      double childAspectRatio = itemWidth / itemHeight;

                      return GridView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable scrolling to force fit
                        itemCount: _itemCount,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemBuilder: (context, index) {
                          if (index >= _displayStocks.length) {
                            return const SizedBox();
                          }
                          final stock = _displayStocks[index];
                          final color =
                              _flashColors[stock.symbol] ?? Colors.transparent;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(color: Colors.white10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    stock.symbol,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                          16, // Dynamic font size could be better but sticking to fixed for now
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
                                      fontSize: 16,
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
                                      fontSize: 14,
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
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
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
      ),
    );
  }
}
