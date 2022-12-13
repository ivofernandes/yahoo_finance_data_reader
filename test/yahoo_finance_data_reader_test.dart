import 'package:flutter_test/flutter_test.dart';
import 'package:yahoo_finance_data_reader/src/daily/model/yahoo_finance_data.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  test('Test get yahoo finance data on GOOG', () async {
    DateTime startTime = DateTime.now();
    const yahooFinance = YahooFinanceDailyReader();

    List<dynamic> data = await yahooFinance.getDailyData('GOOG');

    DateTime endTime = DateTime.now();

    logPerformance(startTime, endTime, 'getDailyData on GOOG');
    assert(data.isNotEmpty);
  });

  test('Test get yahoo finance DTO on ^GSPC', () async {
    const yahooFinance = YahooFinanceDailyReader();

    DateTime startTime = DateTime.now();

    List<YahooFinanceCandleData> data =
        await yahooFinance.getDailyDTOs('^GSPC');

    DateTime endTime = DateTime.now();

    assert(data.isNotEmpty);

    logPerformance(startTime, endTime, 'getDailyDTOs on ^GSPC');
  });

  test('Test get yahoo finance data on ^GSPC', () async {
    DateTime startTime = DateTime.now();
    const yahooFinance = YahooFinanceDailyReader();

    List<dynamic> data = await yahooFinance.getDailyData('^GSPC');

    DateTime endTime = DateTime.now();

    logPerformance(startTime, endTime, 'getDailyData on ^GSPC');
    assert(data.isNotEmpty);
  });

  test('Test get yahoo finance data from a timestamp', () async {
    const yahooFinance = YahooFinanceDailyReader();

    DateTime dateTime = DateTime.now();
    dateTime = dateTime.subtract(const Duration(days: 30));

    List<dynamic> data = await yahooFinance.getDailyData('GOOG',
        startTimestamp: dateTime.millisecondsSinceEpoch ~/ 1000);

    assert(data.isNotEmpty);
    assert(data.first.containsKey('date'));

    DateTime firstDate =
        DateTime.fromMillisecondsSinceEpoch(data[0]['date'] * 1000);

    assert(firstDate.isAfter(DateTime(2021)));
    assert(data.length > 15);
    assert(data.length < 30);
  });

  test('Test get yahoo finance data from a datetime', () async {
    const yahooFinance = YahooFinanceDailyReader();

    DateTime dateTime = DateTime.now();
    dateTime = dateTime.subtract(const Duration(days: 30));

    List<dynamic> data =
        await yahooFinance.getDaily('GOOG', startDate: dateTime);

    assert(data.isNotEmpty);
    assert(data.first.containsKey('date'));

    DateTime firstDate =
        DateTime.fromMillisecondsSinceEpoch(data[0]['date'] * 1000);

    assert(firstDate.isAfter(DateTime(2021)));
    assert(data.length > 15);
    assert(data.length < 30);
  });

  test('Test get yahoo finance DTO from a datetime', () async {
    const yahooFinance = YahooFinanceDailyReader();

    DateTime dateTime = DateTime.now();
    dateTime = dateTime.subtract(const Duration(days: 30));

    List<YahooFinanceCandleData> data =
        await yahooFinance.getDailyDTOs('GOOG', startDate: dateTime);

    assert(data.isNotEmpty);

    DateTime firstDate = data[0].date;

    assert(firstDate.isAfter(DateTime(2021)));
    assert(data.length > 15);
    assert(data.length < 30);
  });

  test('Test get yahoo finance DTO on GOOG', () async {
    const yahooFinance = YahooFinanceDailyReader();

    DateTime startTime = DateTime.now();

    List<YahooFinanceCandleData> data = await yahooFinance.getDailyDTOs('GOOG');

    DateTime endTime = DateTime.now();

    assert(data.isNotEmpty);

    logPerformance(startTime, endTime, 'getDailyDTOs on GOOG');
  });
}

void logPerformance(DateTime startTime, DateTime endTime, String message) {
  Duration duration = endTime.difference(startTime);

  print('$message: $duration');
}
