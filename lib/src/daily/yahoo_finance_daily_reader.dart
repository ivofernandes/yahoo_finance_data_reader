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
  Future<YahooFinanceResponse> getDailyDTOs(String ticker,
      {DateTime? startDate}) async {
    Map<String, dynamic> dailyData = await getDailyData(ticker);

    return YahooFinanceResponse.fromJson(dailyData);
  }

  /// Python like get allDailyData, inspired on python package yfinance
  /// Get https://query2.finance.yahoo.com/v8/finance/chart/GOOG
  Future<Map<String, dynamic>> getDailyData(String ticker) async {
    ticker = ticker.toUpperCase();

    String now =
        (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();

    //TODO update period2
    String params =
        'period1=-2208994789&period2=1671412806&interval=1d&includePrePost=False&events=div,splits';
    String url =
        'https://query2.finance.yahoo.com/v8/finance/chart/$ticker?$params';

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
    return {};
  }

  /// create the isolate to process the response
  Future<Map<String, dynamic>> _computeResponse(String value) {
    return compute(_processResponse, value);
  }

  /// Process to get the daily data from the html response
  Map<String, dynamic> _processResponse(String body) {
    // Parse all json
    Map<String, dynamic> json = jsonDecode(body);

    Map<String, dynamic>? historicalPrice = json['chart']['result'].first;
    return historicalPrice ?? {};
  }
}
