import 'package:flutter_test/flutter_test.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

void main() {
  test('Test weighted mix', () async {
    final yahooFinance = YahooFinanceService();

    final List<YahooFinanceCandleData> pricesAverageWeightedMixed =
        await yahooFinance.getTickerData(
      'ES=F-0.5, GC=F-0.5',
      useCache: false,
    );

    final List<YahooFinanceCandleData> pricesAverageMixed =
        await yahooFinance.getTickerData(
      'ES=F, GC=F',
      useCache: false,
    );

    final List<YahooFinanceCandleData> pricesES =
        await yahooFinance.getTickerData(
      'ES=F',
      useCache: false,
    );

    final List<YahooFinanceCandleData> pricesGC =
        await yahooFinance.getTickerData(
      'GC=F',
      useCache: false,
    );

    assert(pricesAverageMixed.isNotEmpty);
    assert(pricesAverageWeightedMixed.isNotEmpty);

    // Check if they have the same size
    expect(pricesAverageMixed.length, pricesAverageWeightedMixed.length);

    // Check if they have the same proportion
    final double pricesAverageMixedLast = pricesAverageMixed.last.adjClose;
    final double pricesAverageMixedFirst = pricesAverageMixed.first.adjClose;

    final double pricesAverageWeightedMixedLast =
        pricesAverageWeightedMixed.last.adjClose;
    final double pricesAverageWeightedMixedFirst =
        pricesAverageWeightedMixed.first.adjClose;

    final double pricesAverageChange =
        pricesAverageMixedLast / pricesAverageMixedFirst;
    final double pricesAverageWeightedChange =
        pricesAverageWeightedMixedLast / pricesAverageWeightedMixedFirst;

    final double pricesESChange =
        pricesES.last.adjClose / pricesES.first.adjClose;
    final double pricesGCChange =
        pricesGC.last.adjClose / pricesGC.first.adjClose;
    print(
        'prices ES changed by $pricesESChange from ${pricesES.first.date} to ${pricesES.last.date}');
    print(
        'prices GC changed by $pricesGCChange from ${pricesGC.first.date} to ${pricesGC.last.date}');

    print(
        'Prices average changed by $pricesAverageChange from ${pricesAverageMixed.first.date} to ${pricesAverageMixed.last.date}');
    print(
        'Prices average weighted changed by $pricesAverageWeightedChange from ${pricesAverageWeightedMixed.first.date} to ${pricesAverageWeightedMixed.last.date}');

    // Check if the weighted average is close enough being doubles
    expect(pricesAverageChange, closeTo(pricesAverageWeightedChange, 0.01));
  });
}
