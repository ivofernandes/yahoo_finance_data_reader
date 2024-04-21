import 'package:flutter_test/flutter_test.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
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

    // Check if they have the same size
    expect(pricesAverageMixed.length, pricesAverageWeightedMixed.length);

    // Check if they have the same proportion
    final double pricesAverageChange = pricesAverageMixed.last.adjClose / pricesAverageMixed.first.adjClose;
    final double pricesAverageWeightedChange =
        pricesAverageWeightedMixed.last.adjClose / pricesAverageWeightedMixed.first.adjClose;

    expect(pricesAverageChange, pricesAverageWeightedChange);
  });
}
