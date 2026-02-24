import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApi {
  final String apiKey;
  final Duration ttl;

  CurrencyApi({
    required this.apiKey,
    this.ttl = const Duration(hours: 1),
  });

  static const String _defaultSource = 'USD';

  Map<String, double> _usdQuotes = {};
  DateTime? _lastFetch;

  Future<Map<String, double>> getUsdQuotes({
    required List<String> currencies,
  }) async {
    final now = DateTime.now();
    final stillValid =
        _lastFetch != null && now.difference(_lastFetch!) < ttl;

    if (stillValid && currencies.every((c) => _usdQuotes.containsKey(c))) {
      return _usdQuotes;
    }

    final uri = Uri.parse('https://api.exchangerate.host/live').replace(
      queryParameters: <String, String>{
        'access_key': apiKey,
        'currencies': currencies.toSet().join(','),
        'format': '1',
      },
    );

    final res = await http.get(uri);
    final body = jsonDecode(res.body) as Map<String, dynamic>;

    if (body['success'] == false) {
      final err = body['error'];
      if (err is Map) {
        final type = err['type']?.toString();
        final code = err['code'];

        // If the API says we've hit a temporary rate limit
        if (type == 'rate_limit_reached' && _usdQuotes.isNotEmpty) {
          _lastFetch = now;
          return _usdQuotes;
        }

        throw Exception('$type ($code): ${err['info']}');
      }
      throw Exception('API error');
    }

    final quotes = (body['quotes'] as Map?)?.cast<String, dynamic>();
    if (quotes == null) throw Exception('Missing quotes in response');

    final out = <String, double>{};
    for (final entry in quotes.entries) {
      final k = entry.key; // e.g. "USDINR"
      final v = entry.value;
      if (k.startsWith(_defaultSource) && v is num) {
        final ccy = k.substring(_defaultSource.length); // "INR"
        out[ccy] = v.toDouble();
      }
    }

    out[_defaultSource] = 1.0; // USD->USD is always 1

    _usdQuotes = out;
    _lastFetch = now;
    return _usdQuotes;
  }
}
