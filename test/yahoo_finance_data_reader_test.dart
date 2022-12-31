import 'package:flutter_test/flutter_test.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  test('Test get yahoo finance data on GOOG', () async {
    DateTime startTime = DateTime.now();
    const yahooFinance = YahooFinanceDailyReader();

    Map<String, dynamic> data = await yahooFinance.getDailyData('GOOG');

    DateTime endTime = DateTime.now();

    logPerformance(startTime, endTime, 'getDailyData on GOOG');
    assert(data.isNotEmpty);
  });

  test('Test get yahoo finance DTO on GOOG', () async {
    const yahooFinance = YahooFinanceDailyReader();

    DateTime startTime = DateTime.now();

    YahooFinanceResponse data = await yahooFinance.getDailyDTOs('GOOG');

    DateTime endTime = DateTime.now();

    assert(data.candlesData.isNotEmpty);

    logPerformance(startTime, endTime, 'getDailyDTOs on GOOG');
  });

  test('Test get yahoo finance DTO on ^GSPC', () async {
    const yahooFinance = YahooFinanceDailyReader();

    DateTime startTime = DateTime.now();

    YahooFinanceResponse data = await yahooFinance.getDailyDTOs('^GSPC');

    DateTime endTime = DateTime.now();

    assert(data.candlesData.isNotEmpty);

    logPerformance(startTime, endTime, 'getDailyDTOs on ^GSPC');
  });

  test('Test get yahoo finance data on ^GSPC', () async {
    DateTime startTime = DateTime.now();
    const yahooFinance = YahooFinanceDailyReader();

    Map<String, dynamic> data = await yahooFinance.getDailyData('^GSPC');

    DateTime endTime = DateTime.now();

    logPerformance(startTime, endTime, 'getDailyData on ^GSPC');
    assert(data.isNotEmpty);
  });

  test('Test get yahoo finance DTO on GOOG', () async {
    const yahooFinance = YahooFinanceDailyReader();

    DateTime startTime = DateTime.now();

    YahooFinanceResponse data = await yahooFinance.getDailyDTOs(
      'GOOG',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
    );

    DateTime endTime = DateTime.now();

    assert(data.candlesData.isNotEmpty);

    logPerformance(startTime, endTime, 'getDailyDTOs on GOOG last month');
  });

  test('Test mix', () async {
    final yahooFinance = YahooFinanceService();

    List<YahooFinanceCandleData> prices =
        await yahooFinance.getTickerData('ES=F, GC=F');

    assert(prices.isNotEmpty);
  });
}

void logPerformance(DateTime startTime, DateTime endTime, String message) {
  Duration duration = endTime.difference(startTime);

  print('$message: $duration');
}
