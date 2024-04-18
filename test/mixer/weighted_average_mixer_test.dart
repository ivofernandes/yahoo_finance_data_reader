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

    // Check if they have the same values
    for (int i = 0; i < pricesAverageMixed.length; i++) {
      final averageElement = pricesAverageMixed[i];
      final weightedAverageElement = pricesAverageWeightedMixed[i];

      expect(averageElement.date, weightedAverageElement.date);
      expect(averageElement.open, weightedAverageElement.open);
      expect(averageElement.high, weightedAverageElement.high);
      expect(averageElement.low, weightedAverageElement.low);
      expect(averageElement.close, weightedAverageElement.close);
      expect(averageElement.adjClose, weightedAverageElement.adjClose);
    }
  });
}
