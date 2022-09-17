import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Class to read daily data from yahoo finance
class YahooFinanceDailyReader {
  /// Time that will way for an response from yahoo finance
  final Duration timeout;

  /// Prefix that you want in the call, for avoiding CORS errors
  final String prefix;

  /// Headers of the http request
  final Map<String, dynamic>? headers;

  const YahooFinanceDailyReader(
      {this.timeout = const Duration(seconds: 30),
      this.prefix = 'https://',
      this.headers});

  /// This abstraction lets the developer pass a dateTime
  Future<List<dynamic>> getDaily(String ticker, {DateTime? startDate}) async {
    int? timestamp;
    if (startDate != null) {
      timestamp = (startDate.millisecondsSinceEpoch / 1000).round();
      return getDailyData(ticker, startTimestamp: timestamp);
    } else {
      return getDailyData(ticker);
    }
  }

  /// Python like get allDailyData, inspired on pandas_datareader/yahoo/daily
  /// Steps:
  /// 1 - Get https://finance.yahoo.com/quote/%5EGSPC/history?period1=-1577908800&period2=1617505199&interval=1d&indicators=quote&includeTimestamps=true
  /// 2 - Find the delimiters of the begging and end of the json
  /// 3 - Get item ["context"]["dispatcher"]["stores"]["HistoricalPriceStore"]
  Future<List<dynamic>> getDailyData(String ticker,
      {int startTimestamp = -1577908800}) async {
    ticker = ticker.toUpperCase();

    String now =
        (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();

    String url = '${prefix}finance.yahoo.com/quote/$ticker/history?'
        'period1=$startTimestamp&period2=$now&interval=1d&indicators=quote&includeTimes';

    Dio dio = Dio();
    dio.options.connectTimeout = timeout.inMilliseconds;
    dio.options.receiveTimeout = timeout.inMilliseconds;

    Map<String, dynamic> currentHeaders = {
      'content-type': 'application/json',
      'charset': 'utf-8',
      'Access-Control-Allow-Origin': '*'
    };

    if (headers != null) {
      currentHeaders = headers!;
    }

    dio.options.headers = currentHeaders;

    Response response = await dio.get(url);

    if (response.statusCode == 200) {
      String body = response.toString();

      return await _computeResponse(body);
    }

    // If was not a 200 status code, return empty list
    return [];
  }

  /// create the isolate to process the response
  Future<List<dynamic>> _computeResponse(String value) {
    return compute(_processResponse, value);
  }

  /// Process to get the daily data from the html response
  List<dynamic> _processResponse(String body) {
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
}
