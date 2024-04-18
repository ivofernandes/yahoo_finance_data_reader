import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  test('Test get yahoo finance data on GOOG', () async {
    final DateTime startTime = DateTime.now();
    const yahooFinance = YahooFinanceDailyReader();

    final Map<String, dynamic> data = await yahooFinance.getDailyData('GOOG');

    final DateTime endTime = DateTime.now();

    logPerformance(startTime, endTime, 'getDailyData on GOOG');
    assert(data.isNotEmpty);
  });

  test('Test get yahoo finance DTO on GOOG', () async {
    const yahooFinance = YahooFinanceDailyReader();

    final DateTime startTime = DateTime.now();

    final YahooFinanceResponse data = await yahooFinance.getDailyDTOs('GOOG');

    final DateTime endTime = DateTime.now();

    assert(data.candlesData.isNotEmpty);

    logPerformance(startTime, endTime, 'getDailyDTOs on GOOG');
  });

  test('Test get yahoo finance DTO on ^GSPC', () async {
    const yahooFinance = YahooFinanceDailyReader();

    final DateTime startTime = DateTime.now();

    final YahooFinanceResponse data = await yahooFinance.getDailyDTOs('^GSPC');

    final DateTime endTime = DateTime.now();

    assert(data.candlesData.isNotEmpty);

    logPerformance(startTime, endTime, 'getDailyDTOs on ^GSPC');
  });

  test('Test get yahoo finance data on ^GSPC', () async {
    final DateTime startTime = DateTime.now();
    const yahooFinance = YahooFinanceDailyReader();

    final Map<String, dynamic> data = await yahooFinance.getDailyData('^GSPC');

    final DateTime endTime = DateTime.now();

    logPerformance(startTime, endTime, 'getDailyData on ^GSPC');
    assert(data.isNotEmpty);
  });

  test('Test get yahoo finance DTO on GOOG', () async {
    const yahooFinance = YahooFinanceDailyReader();

    final DateTime startTime = DateTime.now();

    final YahooFinanceResponse data = await yahooFinance.getDailyDTOs(
      'GOOG',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
    );

    final DateTime endTime = DateTime.now();

    assert(data.candlesData.isNotEmpty);

    logPerformance(startTime, endTime, 'getDailyDTOs on GOOG last month');
  });

  test('Test mix', () async {
    final yahooFinance = YahooFinanceService();

    final List<YahooFinanceCandleData> prices = await yahooFinance.getTickerData(
      'ES=F, GC=F',
      useCache: false,
    );

    assert(prices.isNotEmpty);
  });

  test('Test weighted mix', () async {
    final yahooFinance = YahooFinanceService();

    final List<YahooFinanceCandleData> pricesAverageWeightedMixed = await yahooFinance.getTickerData(
      'ES=F-0.5, GC=F-0.5',
      useCache: false,
    );

    final List<YahooFinanceCandleData> pricesAverageMixed = await yahooFinance.getTickerData(
      'ES=F, GC=F',
      useCache: false,
    );

    assert(pricesAverageMixed.isNotEmpty);
    assert(pricesAverageWeightedMixed.isNotEmpty);
  });
}

void logPerformance(DateTime startTime, DateTime endTime, String message) {
  final Duration duration = endTime.difference(startTime);

  debugPrint('$message: $duration');
}
