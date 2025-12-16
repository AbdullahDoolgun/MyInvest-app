import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'home_view_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPortfolioSummary(state, currencyFormat),
              const SizedBox(height: 20),
              _buildPastTransactions(state, currencyFormat),
              const SizedBox(height: 20),
              _buildSectionTitle('Held Stocks'),
              _buildStockList(state.heldStocks, currencyFormat),
              const SizedBox(height: 20),
              _buildSectionTitle('Favorite Stocks'),
              _buildStockList(state.favoriteStocks, currencyFormat),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPortfolioSummary(HomeState state, NumberFormat currencyFormat) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Total Portfolio Value',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              currencyFormat.format(state.totalPortfolioValue),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.totalGainLossAmount >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                  color: state.totalGainLossAmount >= 0 ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.totalGainLossPercent}% (${currencyFormat.format(state.totalGainLossAmount)})',
                  style: TextStyle(
                    fontSize: 16,
                    color: state.totalGainLossAmount >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastTransactions(HomeState state, NumberFormat currencyFormat) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: const Text('Past Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        children: state.pastTransactions.map((transaction) {
          return ListTile(
            leading: Icon(
              transaction.type == 'Buy' ? Icons.shopping_cart : Icons.sell,
              color: transaction.type == 'Buy' ? Colors.green : Colors.red,
            ),
            title: Text('${transaction.type} ${transaction.symbol}'),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(transaction.date)),
            trailing: Text(
              '${transaction.amount} @ ${currencyFormat.format(transaction.price)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStockList(List<Stock> stocks, NumberFormat currencyFormat) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(stock.symbol, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(stock.name),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  currencyFormat.format(stock.price),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${stock.changePercent}%',
                  style: TextStyle(
                    color: stock.changePercent >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
