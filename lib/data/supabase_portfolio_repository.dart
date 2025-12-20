import 'package:supabase_flutter/supabase_flutter.dart';

class SupabasePortfolioRepository {
  // final SupabaseClient _supabase;

  SupabasePortfolioRepository({SupabaseClient? supabase})
      // : _supabase = supabase ?? Supabase.instance.client;
      ;

  Future<List<Map<String, dynamic>>> getPortfolio() async {
    // Placeholder implementation
    // final response = await _supabase.from('portfolio').select();
    // return response;
    return [];
  }

  Future<void> addToPortfolio(String symbol, double quantity, double price) async {
    // Placeholder implementation
    // await _supabase.from('portfolio').insert({
    //   'symbol': symbol,
    //   'quantity': quantity,
    //   'price': price,
    //   'user_id': _supabase.auth.currentUser?.id,
    // });
  }
}
