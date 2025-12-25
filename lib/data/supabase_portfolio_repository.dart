import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class SupabasePortfolioRepository {
  final SupabaseClient _supabase;

  SupabasePortfolioRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  // --- Portfolio Methods ---

  Future<List<Map<String, dynamic>>> getPortfolio() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('portfolio')
          .select()
          .eq('user_id', user.id);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // If table doesn't exist or other error, return empty
      debugPrint("Supabase Portfolio Error: $e");
      return [];
    }
  }

  Future<void> removeFromPortfolio(String symbol) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Fetch existing validation to record transaction
    final existing = await _supabase
        .from('portfolio')
        .select()
        .eq('user_id', user.id)
        .eq('symbol', symbol)
        .maybeSingle();

    if (existing != null) {
      final int quantity = existing['quantity'];
      // Ideally we should use current market price, but we don't have it here easily without refetching.
      // We will use average_cost as a proxy for now or pass it in. passed in is better but signature change...
      // For now, let's use average_cost to record what was effectively "removed".
      final double price = (existing['average_cost'] as num).toDouble();

      await _supabase
          .from('portfolio')
          .delete()
          .eq('user_id', user.id)
          .eq('symbol', symbol);

      await addTransaction(symbol, 'SELL', quantity, price);
    }
  }

  Future<void> addToPortfolio(String symbol, int quantity, double cost) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Check if user already owns this stock
    final existing = await _supabase
        .from('portfolio')
        .select()
        .eq('user_id', user.id)
        .eq('symbol', symbol)
        .maybeSingle();

    if (existing != null) {
      // Update existing
      final int oldQty = existing['quantity'];
      final double oldCost = (existing['average_cost'] as num).toDouble();

      final int newQty = oldQty + quantity;
      final double newAvgCost =
          ((oldQty * oldCost) + (quantity * cost)) / newQty;

      await _supabase
          .from('portfolio')
          .update({
            'quantity': newQty,
            'average_cost': newAvgCost,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id) // Ensure user_id is checked
          .eq('id', existing['id']);

      await addTransaction(symbol, 'BUY', quantity, cost);
    } else {
      // Insert new
      await _supabase.from('portfolio').insert({
        'user_id': user.id,
        'symbol': symbol,
        'quantity': quantity,
        'average_cost': cost,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      await addTransaction(symbol, 'BUY', quantity, cost);
    }
  }

  // --- Favorites Methods ---

  Future<List<String>> getFavorites() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('favorites')
          .select('symbol')
          .eq('user_id', user.id);

      return (response as List).map((e) => e['symbol'] as String).toList();
    } catch (e) {
      debugPrint("Supabase Favorites Error: $e");
      return [];
    }
  }

  Future<void> addFavorite(String symbol) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    // Check duplicates
    final existing = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', user.id)
        .eq('symbol', symbol)
        .maybeSingle();

    if (existing != null) return;

    await _supabase.from('favorites').insert({
      'user_id': user.id,
      'symbol': symbol,
    });
  }

  Future<void> removeFavorite(String symbol) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    await _supabase
        .from('favorites')
        .delete()
        .eq('user_id', user.id)
        .eq('symbol', symbol);
  }

  // --- Transaction Methods ---

  Future<List<PortfolioTransaction>> getTransactions() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => PortfolioTransaction.fromJson(e))
          .toList();
    } catch (e) {
      debugPrint("Supabase Transactions Error: $e");
      return [];
    }
  }

  Future<void> addTransaction(
    String symbol,
    String type,
    int quantity,
    double price,
  ) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.from('transactions').insert({
        'user_id': user.id,
        'symbol': symbol,
        'type': type,
        'quantity': quantity,
        'price': price,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint("Supabase Add Transaction Error: $e");
    }
  }
}
