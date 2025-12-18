import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'home_screen.dart';
import 'live_tracking_screen.dart';
import 'portfolio_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isSettingsOpen = false;

  final List<Widget> _pages = const [
    HomeScreen(),
    LiveTrackingScreen(),
    PortfolioScreen(),
  ];

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
  }

  @override
  Widget build(BuildContext context) {
    bool showFab =
        !_isSettingsOpen && (_selectedIndex == 1 || _selectedIndex == 2);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Hoş Geldiniz",
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            Text(
              "Ahmet Bey",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _isSettingsOpen ? const SettingsScreen() : _pages[_selectedIndex],
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () {
                // Add stock action placeholder
                // Add stock action placeholder
                // debugPrint("Add Stock Clicked");
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: _isSettingsOpen
            ? AppColors.textSecondary
            : AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
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
}
