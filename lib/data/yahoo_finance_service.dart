import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';

import 'package:flutter/foundation.dart';

class YahooFinanceService {
  final String _baseUrl = "https://query2.finance.yahoo.com/v7/finance/quote";

  Future<List<Stock>> getQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return [];

    // Uniqueify symbols
    final uniqueSymbols = symbols.toSet().toList();

    // BIST hisseleri için .IS uzantısı ekliyoruz
    final symbolsParam = uniqueSymbols.map((s) => s.endsWith('.IS') ? s : '$s.IS').join(',');
    
    final url = Uri.parse("$_baseUrl?symbols=$symbolsParam");
    
    debugPrint("Fetching URL: $url");

    try {
      final response = await http.get(
        url,
        headers: {
          "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
          "Accept": "*/*",
        },
      ).timeout(const Duration(seconds: 10));

      debugPrint("Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['finance'] != null && data['finance']['error'] != null) {
          debugPrint("Yahoo Finance Internal Error: ${data['finance']['error']}");
          throw Exception("Yahoo Finance API Error: ${data['finance']['error']}");
        }

        final List<dynamic> results = data['quoteResponse']['result'] ?? [];
        debugPrint("Fetched ${results.length} stocks.");
        return results.map((json) => Stock.fromJson(json)).toList();
      } else {
        debugPrint("Failed Body: ${response.body}");
        throw Exception("Failed to load stock data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Yahoo Service Critical Error: $e");
      return []; 
    }
  }
}
