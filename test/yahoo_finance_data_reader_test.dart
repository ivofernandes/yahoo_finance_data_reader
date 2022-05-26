import 'package:flutter_test/flutter_test.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  test('Test get yahoo finance data', () async {
    const yahooFinance = YahooFinanceDailyReader();

    List<dynamic> data = await yahooFinance.getDailyData('GOOG');

    assert(data.isNotEmpty);
  });

  test('Test get yahoo finance data from a timestamp', () async {
    const yahooFinance = YahooFinanceDailyReader();

    DateTime dateTime = DateTime.now();
    dateTime = dateTime.subtract(Duration(days: 30));

    List<dynamic> data = await yahooFinance.getDailyData('GOOG',
        startTimestamp: (dateTime.millisecondsSinceEpoch / 1000).toInt());

    assert(data.isNotEmpty);
    assert(data.first.containsKey('date'));

    DateTime firstDate =
        DateTime.fromMillisecondsSinceEpoch(data[0]['date'] * 1000);

    assert(firstDate.isAfter(DateTime(1917)));
  });
}
