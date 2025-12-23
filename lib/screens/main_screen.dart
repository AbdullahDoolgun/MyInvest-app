import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_cubit.dart';
import '../blocs/stock/stock_bloc.dart'; // Add
import '../constants/colors.dart';
import '../widgets/stock_selection_sheet.dart';
import 'home_screen.dart';
import 'live_tracking_screen.dart';
import 'portfolio_screen.dart';
import 'settings_screen.dart';

import 'dart:async'; // Add this

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isSettingsOpen = false;
  Timer? _refreshTimer;

  final List<Widget> _pages = const [
    HomeScreen(),
    LiveTrackingScreen(),
    PortfolioScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    final duration = (_selectedIndex == 1) ? 5 : 30;

    _refreshTimer = Timer.periodic(Duration(seconds: duration), (timer) {
      if (mounted) {
        debugPrint("Timer Tick: Requesting Refresh (Interval: $duration s)");
        context.read<StockBloc>().add(RefreshStocks());
      }
    });
  }

  void _openSettings() {
    setState(() {
      _isSettingsOpen = true;
    });
  }

  void _closeSettingsAndNavigate(int index) {
    setState(() {
      _selectedIndex = index;
      _isSettingsOpen = false;
    });
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    bool showFab =
        !_isSettingsOpen && (_selectedIndex == 1 || _selectedIndex == 2);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? colorScheme.surface : AppColors.primary,
        elevation: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Hoş Geldiniz, ",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: isDark ? Colors.white70 : Colors.white70,
              ),
            ),
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                String displayName = "Kullanıcı";
                if (state is Authenticated) {
                  final metadata = state.user.userMetadata ?? {};
                  final firstName = metadata['first_name'] as String? ?? '';
                  final gender = metadata['gender'] as String? ?? '';

                  if (firstName.isNotEmpty) {
                    displayName = firstName;
                    if (gender == 'Erkek') {
                      displayName += " Bey";
                    } else if (gender == 'Kadın') {
                      displayName += " Hanım";
                    }
                  }
                }
                return Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDark ? Colors.white : Colors.white,
            ),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _isSettingsOpen ? const SettingsScreen() : _pages[_selectedIndex],
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () {
                if (_selectedIndex == 2) {
                  _showAddStockSheet(context);
                }
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        selectedItemColor: _isSettingsOpen
            ? colorScheme.onSurface.withValues(alpha: 0.5)
            : (isDark ? AppColors.accent : AppColors.primary),
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.5),
        currentIndex: _selectedIndex,
        onTap: _closeSettingsAndNavigate,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Anasayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Canlı Takip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Portföy',
          ),
        ],
      ),
    );
  }

  void _showAddStockSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<StockBloc, StockState>(
        builder: (context, state) {
          if (state is StockLoaded) {
            return StockSelectionSheet(
              allStocks: state.allStocks,
              title: "Portföye Ekle",
              onStockSelected: (stock) {
                Navigator.pop(context);
                _showStockDetailsDialog(context, stock.symbol);
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  void _showStockDetailsDialog(BuildContext context, String symbol) {
    final quantityController = TextEditingController();
    final costController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("$symbol Ekle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Adet"),
            ),
            TextField(
              controller: costController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: "Ortalama Maliyet"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = int.tryParse(quantityController.text) ?? 0;
              final cost = double.tryParse(costController.text) ?? 0.0;
              if (quantity > 0 && cost > 0) {
                context.read<StockBloc>().add(
                  AddPortfolioStock(
                    symbol: symbol,
                    quantity: quantity,
                    cost: cost,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }
}
