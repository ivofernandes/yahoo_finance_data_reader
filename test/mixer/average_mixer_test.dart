import 'package:flutter_test/flutter_test.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  test('Test mix', () async {
    final yahooFinance = YahooFinanceService();

    final List<YahooFinanceCandleData> prices = await yahooFinance.getTickerData(
      'ES=F, GC=F',
      useCache: false,
    );

    assert(prices.isNotEmpty);
  });
}
