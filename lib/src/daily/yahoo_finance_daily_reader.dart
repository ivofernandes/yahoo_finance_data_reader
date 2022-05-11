import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class YahooFinanceDailyReader {
  final Duration timeout;

  const YahooFinanceDailyReader({this.timeout = const Duration(seconds: 30)});

  /// Python like get allDailyData, inspired on pandas_datareader/yahoo/daily
  /// Steps:
  /// 1 - // Get https://finance.yahoo.com/quote/%5EGSPC/history?period1=-1577908800&period2=1617505199&interval=1d&indicators=quote&includeTimestamps=true
  /// 2 - Find the delimiters of the begging and end of the json
  /// 3 - Get item ["context"]["dispatcher"]["stores"]["HistoricalPriceStore"]
  Future<List<dynamic>> getDailyData(String ticker,
      {int startTimestamp = -1577908800}) async {
    ticker = ticker.toUpperCase();
    String now = DateTime.now().millisecondsSinceEpoch.toString();

    Uri uri = Uri.https('finance.yahoo.com', 'quote/' + ticker + '/history', {
      'period1': startTimestamp.toString(),
      'period2': now,
      'interval': '1d',
      'indicators': 'quote',
      'includeTimestamps': 'true'
    });
    http.Response response =
        await http.get(uri).timeout(timeout, onTimeout: () {
      throw TimeoutException('Timeout');
    });

    if (response.statusCode == 200) {
      String body = response.body;

      // Find the json in the html
      String startDelimiter = 'root.App.main = ';
      String endDelimiter = ';\n}(this));';

      int startIndex = body.indexOf(startDelimiter) + startDelimiter.length;
      int endIndex = body.indexOf(endDelimiter, startIndex);
      String jsonString = body.substring(startIndex, endIndex);

      // Parse all json
      Map<String, dynamic> json = jsonDecode(jsonString);

      // Get item ["context"]["dispatcher"]["stores"]["HistoricalPriceStore"]
      Map<String, dynamic>? historicalPrice =
          json["context"]["dispatcher"]["stores"]["HistoricalPriceStore"];

      List<dynamic> result = [];

      if (historicalPrice != null) {
        result = historicalPrice["prices"];
      }

      return result;
    }

    // If was not a 200 status code, return empty list
    return [];
  }
}