import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:yahoo_finance_data_reader/src/daily/model/yahoo_finance_response.dart';

/// Class to read daily data from yahoo finance
class YahooFinanceDailyReader {
  /// Time that will way for an response from yahoo finance
  final Duration timeout;

  /// Headers of the http request
  final Map<String, dynamic>? headers;

  const YahooFinanceDailyReader({
    this.timeout = const Duration(seconds: 30),
    this.headers,
  });

  /// getDailyData but transform the data into a YahooFinanceData list
  Future<YahooFinanceResponse> getDailyDTOs(
    String ticker, {
    DateTime? startDate,
    bool adjust = false,
  }) async {
    int? startTimestamp;
    if (startDate != null) {
      startTimestamp = (startDate.millisecondsSinceEpoch / 1000).floor();
    }

    final Map<String, dynamic> dailyData = await getDailyData(
      ticker,
      startTimestamp: startTimestamp,
    );

    return YahooFinanceResponse.fromJson(
      dailyData,
      adjust: adjust,
    );
  }

  /// Python like get allDailyData, inspired on python package yfinance
  /// Get https://query2.finance.yahoo.com/v8/finance/chart/GOOG
  Future<Map<String, dynamic>> getDailyData(
    String ticker, {
    int? startTimestamp = -2208994789,
  }) async {
    final int startTimestampReady = startTimestamp ?? -2208994789;
    final String tickerUpperCase = ticker.toUpperCase();

    final String now = (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();

    final String params =
        'period1=$startTimestampReady&period2=$now&interval=1d&includePrePost=False&events=div,splits';
    final String url = 'https://query2.finance.yahoo.com/v8/finance/chart/$tickerUpperCase?$params';

    final Dio dio = Dio();
    dio.options.connectTimeout = Duration(milliseconds: timeout.inMilliseconds);
    dio.options.receiveTimeout = Duration(milliseconds: timeout.inMilliseconds);

    Map<String, dynamic> currentHeaders = {
      'content-type': 'application/json',
      'charset': 'utf-8',
      'Access-Control-Allow-Origin': '*'
    };

    if (headers != null) {
      currentHeaders = headers!;
    }

    dio.options.headers = currentHeaders;

    final Response<dynamic> response = await dio.get(url);

    if (response.statusCode == 200) {
      final String body = response.toString();

      return _computeResponse(body);
    }

    // If was not a 200 status code, return empty list
    return {};
  }

  /// create the isolate to process the response
  Future<Map<String, dynamic>> _computeResponse(String value) => compute(_processResponse, value);

  /// Process to get the daily data from the html response
  Map<String, dynamic> _processResponse(String body) {
    // Parse all json
    final Map<String, dynamic> json = jsonDecode(body) as Map<String, dynamic>;

    final chart = json['chart'] as Map<String, dynamic>;
    final result = chart['result'] as List<dynamic>;
    final Map<String, dynamic>? historicalPrice = result.first as Map<String, dynamic>?;
    return historicalPrice ?? {};
  }
}
