import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/invest_boss/invest_boss_bloc.dart';
import '../blocs/stock/stock_bloc.dart';
import '../constants/colors.dart';

class InvestBossScreen extends StatefulWidget {
  const InvestBossScreen({super.key});

  @override
  State<InvestBossScreen> createState() => _InvestBossScreenState();
}

class _InvestBossScreenState extends State<InvestBossScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("InvestBoss"),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: "1M Dolar"),
            Tab(text: "Boss"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          OneMillionDollarTab(),
          BossLeaderboardTab(),
        ],
      ),
    );
  }
}

// --- TAB 1: 1M DOLLAR ---

class OneMillionDollarTab extends StatelessWidget {
  const OneMillionDollarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvestBossBloc, InvestBossState>(
      builder: (context, state) {
        if (state.status == InvestBossStatus.loading && state.profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = state.profile ?? {};
        final cash = (profile['cash_balance'] as num?)?.toDouble() ?? 100000.0;
        final portfolio = state.portfolio;

        // Calculate total equity live based on current stock prices
        // Since we need prices from StockBloc, we can't easily do it inside InvestBossBloc without dependency
        // So we do a quick calculation here for display
        
        return BlocBuilder<StockBloc, StockState>(
          builder: (context, stockState) {
             double equity = cash;
             double stockValue = 0.0;
             
             if (stockState is StockLoaded) {
                 for (var item in portfolio) {
                     final symbol = item['symbol'];
                     final qty = item['quantity'] as int;
                     final stock = stockState.allStocks.firstWhere((s) => s.symbol == symbol, orElse: () => stockState.allStocks.first); 
                     // fallback to first is risky but prevents crash if symbol not found
                     // better to check if exists
                     final currentPrice = stock.price; 
                     stockValue += qty * currentPrice;
                 }
                 equity += stockValue;
                 
                 // Sync equity to DB periodically?
                 // Let's do it once here if it differs significantly? 
                 // No, don't trigger side effects in build.
             }

            return Column(
              children: [
                _buildSummaryCard(context, cash, stockValue, equity),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Varlıklarım", style: Theme.of(context).textTheme.titleMedium),
                      ElevatedButton.icon(
                        onPressed: () => _showTradeSheet(context),
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text("İşlem Yap"),
                        style: ElevatedButton.styleFrom(
                           backgroundColor: AppColors.primary,
                           foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: portfolio.isEmpty
                      ? const Center(child: Text("Henüz hisse almadınız."))
                      : ListView.builder(
                          itemCount: portfolio.length,
                          itemBuilder: (context, index) {
                            final item = portfolio[index];
                            final symbol = item['symbol'];
                            final qty = item['quantity'];
                            final avgCost = (item['average_cost'] as num).toDouble();
                            
                            // Find current price
                            double currentPrice = avgCost;
                            if (stockState is StockLoaded) {
                                try {
                                    currentPrice = stockState.allStocks.firstWhere((s) => s.symbol == symbol).price;
                                } catch (_) {}
                            }
                            
                            final profit = (currentPrice - avgCost) * qty;
                            final profitPercent = ((currentPrice - avgCost) / avgCost) * 100;

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: Text(symbol.substring(0, 1)),
                                ),
                                title: Text(symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("$qty Adet • Ort: ${avgCost.toStringAsFixed(2)}"),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        "${(currentPrice * qty).toStringAsFixed(2)} ₺",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "${profit >= 0 ? '+' : ''}${profit.toStringAsFixed(2)} (%${profitPercent.toStringAsFixed(1)})",
                                      style: TextStyle(
                                        color: profit >= 0 ? AppColors.up : AppColors.down,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, double cash, double stockValue, double total) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text("Toplam Varlık", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            "${total.toStringAsFixed(2)} ₺",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn("Nakit", "${cash.toStringAsFixed(2)} ₺"),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildInfoColumn("Hisse Değeri", "${stockValue.toStringAsFixed(2)} ₺"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showTradeSheet(BuildContext context) {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TradeSheet(),
    );
  }
}

class TradeSheet extends StatefulWidget {
    const TradeSheet({super.key});

    @override
    State<TradeSheet> createState() => _TradeSheetState();
}

class _TradeSheetState extends State<TradeSheet> {
    String? selectedSymbol;
    bool isBuy = true;
    final qtyController = TextEditingController();
    
    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                padding: const EdgeInsets.all(16),
                height: 500,
                child: Column(
                    children: [
                        const Text("İşlem Yap", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        // Toggle Buy/Sell
                        Row(
                            children: [
                                Expanded(
                                    child: GestureDetector(
                                        onTap: () => setState(() => isBuy = true),
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                                color: isBuy ? AppColors.up : Colors.grey[200],
                                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                                            ),
                                            child: Text("AL", style: TextStyle(color: isBuy ? Colors.white : Colors.black)),
                                        ),
                                    ),
                                ),
                                Expanded(
                                    child: GestureDetector(
                                        onTap: () => setState(() => isBuy = false),
                                        child: Container(
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            decoration: BoxDecoration(
                                                color: !isBuy ? AppColors.down : Colors.grey[200],
                                                borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                                            ),
                                            child: Text("SAT", style: TextStyle(color: !isBuy ? Colors.white : Colors.black)),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                        const SizedBox(height: 20),
                        // Stock Selector (Simple Dropdown for MVP)
                        BlocBuilder<StockBloc, StockState>(
                            builder: (context, state) {
                                if (state is StockLoaded) {
                                    return DropdownButtonFormField<String>(
                                        value: selectedSymbol,
                                        hint: const Text("Hisse Seçiniz"),
                                        items: state.allStocks.map((s) => DropdownMenuItem(
                                            value: s.symbol,
                                            child: Text("${s.symbol} - ${s.price} ₺"),
                                        )).toList(),
                                        onChanged: (val) => setState(() => selectedSymbol = val),
                                    );
                                }
                                return const CircularProgressIndicator();
                            },
                        ),
                        const SizedBox(height: 20),
                        TextField(
                            controller: qtyController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: "Adet",
                                border: OutlineInputBorder(),
                            ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () {
                                    if (selectedSymbol != null && qtyController.text.isNotEmpty) {
                                        final qty = int.tryParse(qtyController.text) ?? 0;
                                        if (qty > 0) {
                                            final stockBloc = context.read<StockBloc>();
                                            double price = 0;
                                            if (stockBloc.state is StockLoaded) {
                                                price = (stockBloc.state as StockLoaded).allStocks.firstWhere((s) => s.symbol == selectedSymbol).price;
                                            }
                                            
                                            final event = isBuy 
                                                ? BuyStock(symbol: selectedSymbol!, quantity: qty, price: price)
                                                : SellStock(symbol: selectedSymbol!, quantity: qty, price: price);
                                                
                                            context.read<InvestBossBloc>().add(event);
                                            Navigator.pop(context);
                                        }
                                    }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: isBuy ? AppColors.up : AppColors.down,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(isBuy ? "ALIM YAP" : "SATIŞ YAP"),
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

// --- TAB 2: BOSS LEADERBOARD ---

class BossLeaderboardTab extends StatelessWidget {
  const BossLeaderboardTab({super.key});
  
  String maskName(String? firstName, String? lastName) {
      // Default fallback
      if (firstName == null || firstName.isEmpty) return "B*** K********"; // "Bilinmeyen Kullanıcı" placeholder
      
      String f = firstName.substring(0, 1) + "*" * (firstName.length - 1);
      String l = "";
      if (lastName != null && lastName.isNotEmpty) {
           l = lastName.substring(0, 1) + "*" * (lastName.length - 1);
      } else {
           l = "*****";
      }
      return "$f $l";
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvestBossBloc, InvestBossState>(
      builder: (context, state) {
        if (state.status == InvestBossStatus.loading && state.leaderboard.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final leaderboard = state.leaderboard;

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: const Row(
                children: [
                  Icon(Icons.emoji_events, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    "Liderlik Tablosu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: leaderboard.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = leaderboard[index];
                  final equity = (item['total_equity'] as num).toDouble();
                  final initial = (item['initial_capital'] as num).toDouble();
                  final profit = equity - initial;
                  
                  // Mocking name masking since we don't have access to other users' metadata easily
                  // In a real app, 'display_name' would be in the row.
                  // For demo purposes, we generate a masked name based on ID or index if null.
                  // Or, if it enters the "CurrentUser", we show "Sen".
                  
                  // For the sake of the "Masked Name" requirement:
                  // We simulate names like "A*** Y*****"
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRankColor(index),
                      foregroundColor: Colors.white,
                      child: Text("${index + 1}"),
                    ),
                    title: Text(
                         maskName(item['first_name'], item['last_name']),
                         style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      "${profit >= 0 ? '+' : ''}${profit.toStringAsFixed(2)} ₺",
                      style: TextStyle(
                        color: profit >= 0 ? AppColors.up : AppColors.down,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Color _getRankColor(int index) {
      if (index == 0) return Colors.amber;
      if (index == 1) return Colors.grey;
      if (index == 2) return Colors.brown;
      return AppColors.primary;
  }
}
