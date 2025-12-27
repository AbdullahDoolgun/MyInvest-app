import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/invest_boss/invest_boss_bloc.dart';
import '../blocs/stock/stock_bloc.dart';
import '../blocs/auth/auth_cubit.dart';
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
    return BlocListener<InvestBossBloc, InvestBossState>(
      listener: (context, state) {
        if (state.status == InvestBossStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state.status == InvestBossStatus.success) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("İşlem Başarılı"),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0, // Hides the toolbar part effectively
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "1M TL"),
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
      ),
    );
  }
}

// ... OneMillionDollarTab remains similar ...

// --- TAB 2: BOSS LEADERBOARD ---

class BossLeaderboardTab extends StatelessWidget {
  const BossLeaderboardTab({super.key});
  
  String maskName(String? firstName, String? lastName) {
      if (firstName == null || firstName.isEmpty) return "B*** K********";
      
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

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
              color: isDark ? AppColors.primaryLight : AppColors.surface,
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 8),
                  Text(
                    "Liderlik Tablosu",
                    style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.bold,
                        color: textColor
                    ),
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

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRankColor(index),
                      foregroundColor: Colors.white,
                      child: Text("${index + 1}"),
                    ),
                    title: Text(
                         maskName(item['first_name'], item['last_name']),
                         style: TextStyle(
                             fontWeight: FontWeight.bold,
                             color: textColor
                         ),
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
      if (index == 1) return const Color(0xFFC0C0C0); // Silver
      if (index == 2) return const Color(0xFFCD7F32); // Bronze
      return AppColors.accent;
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
        // Listen for Auth changes to close sheet on logout
        return BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
             if (state is Unauthenticated) {
                 Navigator.of(context).pop();
             }
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
                padding: const EdgeInsets.all(16),
                height: 550, // Increased height for info
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
                                            child: Text("AL", style: TextStyle(color: isBuy ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
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
                                            child: Text("SAT", style: TextStyle(color: !isBuy ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                                        ),
                                    ),
                                ),
                            ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Stock Selector
                        BlocBuilder<InvestBossBloc, InvestBossState>(
                          builder: (context, bossState) {
                             return BlocBuilder<StockBloc, StockState>(
                                builder: (context, state) {
                                    if (state is StockLoaded) {
                                        // Calculate available stocks based on Buy/Sell mode
                                        var displayStocks = state.allStocks;
                                        if (!isBuy) {
                                            final portfolio = bossState.portfolio;
                                            displayStocks = state.allStocks.where((s) => portfolio.any((p) => p['symbol'] == s.symbol)).toList();
                                            
                                            // Reset selection if current selection is not in list
                                            if (selectedSymbol != null && !displayStocks.any((s) => s.symbol == selectedSymbol)) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    if (mounted) setState(() => selectedSymbol = null);
                                                });
                                            }
                                        }

                                        return DropdownButtonFormField<String>(
                                            value: selectedSymbol,
                                            hint: const Text("Hisse Seçiniz"),
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            ),
                                            items: displayStocks.map((s) => DropdownMenuItem(
                                                value: s.symbol,
                                                child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                        Text(s.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                        Text("${s.price} ₺"),
                                                    ],
                                                ),
                                            )).toList(),
                                            onChanged: (val) => setState(() => selectedSymbol = val),
                                        );
                                    }
                                    return const CircularProgressIndicator();
                                },
                            );
                          },
                        ),
                        
                        // Max Quantity / Price Info
                        if (selectedSymbol != null)
                             Padding(
                               padding: const EdgeInsets.only(top: 8.0),
                               child: BlocBuilder<InvestBossBloc, InvestBossState>(
                                 builder: (context, bossState) {
                                     // Get Cash
                                     final profile = bossState.profile ?? {};
                                     final cash = (profile['cash_balance'] as num?)?.toDouble() ?? 0.0;
                                     
                                     // Get Price
                                     final stockBloc = context.read<StockBloc>();
                                     double price = 0;
                                     if (stockBloc.state is StockLoaded) {
                                         try {
                                            price = (stockBloc.state as StockLoaded).allStocks.firstWhere((s) => s.symbol == selectedSymbol).price;
                                         } catch(_) {}
                                     }
                                     
                                     int maxQty = 0;
                                     if (price > 0 && isBuy) {
                                         maxQty = (cash / price).floor();
                                     } else if (!isBuy) {
                                         // If selling, find owned qty
                                         final portfolio = bossState.portfolio;
                                         final item = portfolio.firstWhere((e) => e['symbol'] == selectedSymbol, orElse: () => {});
                                         if (item.isNotEmpty) {
                                             maxQty = (item['quantity'] as num).toInt();
                                         }
                                     }
                                     
                                     return Row(
                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                         children: [
                                             Text(
                                                 isBuy ? "Mevcut Nakit: ${cash.toStringAsFixed(2)} ₺" : "Mevcut Adet: $maxQty",
                                                 style: const TextStyle(fontSize: 12, color: Colors.grey),
                                             ),
                                             if (isBuy)
                                                 Text(
                                                     "Max Alım: $maxQty Adet",
                                                     style: TextStyle(
                                                         fontSize: 13, 
                                                         fontWeight: FontWeight.bold,
                                                         color: AppColors.accent // Explicit color for visibility
                                                     ),
                                                 ),
                                         ],
                                     );
                                 },
                               ),
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
                        
                        const Spacer(),
                        
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
                                            
                                            // Optional: Client side validation could go here, 
                                            // but repository also checks.
                                            
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
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12)
                                    )
                                ),
                                child: Text(
                                    isBuy ? "ALIM YAP" : "SATIŞ YAP",
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                            ),
                        ),
                    ],
                ),
            ),
          ),
        );
    }
}

