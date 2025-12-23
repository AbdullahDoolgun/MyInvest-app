import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/stock_model.dart';
import 'package:flutter/foundation.dart';

class YahooFinanceService {
  final String _baseUrl = "https://query2.finance.yahoo.com/v7/finance/quote";

  // Auth state
  String? _cookie;
  String? _crumb;
  DateTime? _lastAuthTime;

  // Headers to mimic a real desktop browser
  final Map<String, String> _headers = {
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept":
        "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9",
    "Connection": "keep-alive",
    "Upgrade-Insecure-Requests": "1",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
  };

  Future<void> _authenticate() async {
    // Re-auth if needed (e.g., every 45 minutes)
    if (_cookie != null && _crumb != null && _lastAuthTime != null) {
      if (DateTime.now().difference(_lastAuthTime!).inMinutes < 45) {
        return;
      }
    }

    try {
      debugPrint("YahooFinanceService: Starting Authentication Flow...");

      // 1. Get Cookie from fc.yahoo.com
      // This often redirects, so valid http client handles it.
      // We explicitly hit a page that sets the cookie.
      final cookieUri = Uri.parse('https://fc.yahoo.com');

      final cookieResponse = await http
          .get(cookieUri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      final setCookie = cookieResponse.headers['set-cookie'];

      if (setCookie != null) {
        // Extract the first part of the cookie (usually A3=...)
        // It might be multiple cookies separated by commas or semicolons
        final a3Match = RegExp(r'(A3=[^;]+)').firstMatch(setCookie);
        if (a3Match != null) {
          _cookie = a3Match.group(1);
          debugPrint(
            "YahooFinanceService: Got Cookie: ${_cookie?.substring(0, 10)}...",
          );
        } else {
          // Sometimes cookie is just set directly without A3 prefix in rare cases or we just take the first chunk
          _cookie = setCookie.split(';').first;
        }
      }

      if (_cookie == null) {
        debugPrint(
          "YahooFinanceService: WARNING - Failed to get Cookie. Header: $setCookie",
        );
        // Continue anyway, sometimes crumb works without it or we existing cached headers
      }

      // 2. Get Crumb
      // We must pass the cookie here
      final crumbUri = Uri.parse(
        'https://query1.finance.yahoo.com/v1/test/getcrumb',
      );

      final crumbHeaders = Map<String, String>.from(_headers);
      if (_cookie != null) {
        crumbHeaders['Cookie'] = _cookie!;
      }

      final crumbResponse = await http
          .get(crumbUri, headers: crumbHeaders)
          .timeout(const Duration(seconds: 10));

      if (crumbResponse.statusCode == 200) {
        _crumb = crumbResponse.body;
        _lastAuthTime = DateTime.now();
        debugPrint("YahooFinanceService: Got Crumb: $_crumb");
      } else {
        debugPrint(
          "YahooFinanceService: Failed to get Crumb. Code: ${crumbResponse.statusCode} Body: ${crumbResponse.body}",
        );
        // If 429, we are rate limited.
      }
    } catch (e) {
      debugPrint("YahooFinanceService: Auth Failed: $e");
    }
  }

  Future<List<Stock>> getQuotes(List<String> symbols) async {
    if (symbols.isEmpty) return [];

    // Ensure we are authenticated (have crumb)
    await _authenticate();

    // Uniqueify symbols & Add .IS for BIST
    final uniqueSymbols = symbols.toSet().toList();
    final symbolsParam = uniqueSymbols
        .map((s) => s.endsWith('.IS') ? s : '$s.IS')
        .join(',');

    // Construct URL with symbols and crumb
    String urlString = "$_baseUrl?symbols=$symbolsParam";
    if (_crumb != null && _crumb!.isNotEmpty) {
      urlString += "&crumb=$_crumb";
    }

    final url = Uri.parse(urlString);
    debugPrint("Fetching URL: $url");

    try {
      final requestHeaders = Map<String, String>.from(_headers);
      if (_cookie != null) {
        requestHeaders['Cookie'] = _cookie!;
      }

      final response = await http
          .get(url, headers: requestHeaders)
          .timeout(const Duration(seconds: 15));

      debugPrint("Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['finance'] != null && data['finance']['error'] != null) {
          final error = data['finance']['error'];
          debugPrint("Yahoo Finance Internal Error: $error");
          // If code is "Unauthorized", clear auth to retry next time
          if (error['code'] == 'Unauthorized') {
            _clearAuth();
          }
          throw Exception("Yahoo Finance API Error: $error");
        }

        final List<dynamic> results = data['quoteResponse']['result'] ?? [];
        if (results.isEmpty) {
          debugPrint("API 200 OK but NO RESULTS used body: ${response.body}");
        }
        debugPrint("Fetched ${results.length} stocks successfully with Auth.");
        return results.map((json) => Stock.fromJson(json)).toList();
      } else {
        debugPrint("Failed Body: ${response.body}");

        if (response.statusCode == 401 || response.statusCode == 403) {
          _clearAuth();
        }
        throw Exception("Failed to load stock data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Yahoo Service Critical Error: $e");
      throw Exception("Yahoo Service Error: $e");
    }
  }

  void _clearAuth() {
    _cookie = null;
    _crumb = null;
    _lastAuthTime = null;
  }
}
