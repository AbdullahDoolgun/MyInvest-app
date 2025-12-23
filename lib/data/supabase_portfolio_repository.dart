import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      final double newAvgCost = ((oldQty * oldCost) + (quantity * cost)) / newQty;

      await _supabase.from('portfolio').update({
        'quantity': newQty,
        'average_cost': newAvgCost,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', existing['id']);
    } else {
      // Insert new
      await _supabase.from('portfolio').insert({
        'user_id': user.id,
        'symbol': symbol,
        'quantity': quantity,
        'average_cost': cost,
        // 'weekly_rec': 'NÖTR', // Optional fields if your DB expects them
      });
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
}
