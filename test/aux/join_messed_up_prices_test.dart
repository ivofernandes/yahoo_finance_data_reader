// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:yahoo_finance_data_reader/src/daily/aux/join_prices.dart';
import 'package:yahoo_finance_data_reader/src/daily/model/yahoo_finance_candle_data.dart';

import 'join_prices_text_aux.dart';

void main() {
  test('Join prices with old prices messed up', () async {
    // This dataset to join has multiple problems,
    // the date 2022-05-12 18:57:32.000 in the old prices has no match with the
    // last date in the recentPricesList that is 2022-05-12 05:00:00.000
    // and also has null in some element of the old list so to join the algorithm
    // will need to pick a nice date to use as reference
    final List<YahooFinanceCandleData> oldPricesList = [
      YahooFinanceCandleData(
        date: DateTime.parse('2022-05-08'),
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2022-05-09'),
        open: 12605,
        high: 12637.25,
        low: 12135.25,
        close: 12193.75,
        volume: 816033,
        adjClose: 12193.75,
      ),
      YahooFinanceCandleData(
          date: DateTime.parse('2022-05-10'),
          open: 12206,
          high: 12547,
          low: 12102.25,
          close: 12349,
          volume: 816033,
          adjClose: 12349),
      YahooFinanceCandleData(
          date: DateTime.parse('2022-05-11'),
          open: 12004.5,
          high: 12005.75,
          low: 11950.25,
          close: 11986.75,
          volume: 5943,
          adjClose: 11986.75),
      YahooFinanceCandleData(
          date: DateTime.parse('2022-05-12T18:57:32'),
          open: 12004.5,
          high: 12132.75,
          low: 11693.25,
          close: 11752.25,
          volume: 679220,
          adjClose: 11752.25),
      YahooFinanceCandleData(
        date: DateTime.parse('2022-05-13'),
        open: 11891.5,
        high: 12432,
        low: 11891.5,
        close: 12382.75,
        volume: 878238,
        adjClose: 12382.75,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2022-05-16'),
        open: 12409,
        high: 12498.75,
        low: 12190.25,
        close: 12353.25,
        volume: 527525,
        adjClose: 12353.25,
      ),
    ];

    final List<YahooFinanceCandleData> recentPricesList = [
      YahooFinanceCandleData(
        date: DateTime.parse('2022-05-12'),
        open: 12004.5,
        high: 12132.75,
        low: 11689,
        close: 11947.25,
        volume: 878238,
        adjClose: 11947.25,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2022-05-13'),
        open: 11891.5,
        high: 12432,
        low: 11891.5,
        close: 12382.75,
        volume: 663517,
        adjClose: 12382.75,
      ),
      YahooFinanceCandleData(
          date: DateTime.parse('2022-05-16'),
          open: 12409,
          high: 12498.75,
          low: 12190.25,
          close: 12244.75,
          volume: 623715,
          adjClose: 12244.75),
      YahooFinanceCandleData(
        date: DateTime.parse('2022-05-17'),
        open: 12235.5,
        high: 12578,
        low: 12234,
        close: 12560.25,
        volume: 653222,
        adjClose: 12560.25,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2022-05-18'),
        open: 12572,
        high: 12594,
        low: 11862.75,
        close: 11935.5,
        volume: 735386,
        adjClose: 11935.5,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2022-05-19'),
        open: 11907,
        high: 12076.75,
        low: 11704,
        close: 11878.25,
        volume: 735386,
        adjClose: 11878.25,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2022-05-20'),
        open: 11898,
        high: 12096.75,
        low: 11895,
        close: 12094.25,
        volume: 70366,
        adjClose: 12094.25,
      ),
    ];

    final List<YahooFinanceCandleData> result =
        JoinPrices.joinPrices(oldPricesList, recentPricesList);

    JoinPricesTextAux.validateSizeAndContinuity(result, 11);
  });

  test('Join prices test without match', () async {
    final List<YahooFinanceCandleData> oldPricesList = [
      YahooFinanceCandleData(
        date: DateTime.parse('2021-09-29'),
        adjClose: 1,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2021-10-01'),
        adjClose: 3,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2021-10-04'),
        adjClose: 4,
      ),
    ];

    final List<YahooFinanceCandleData> recentPricesList = [
      YahooFinanceCandleData(
        date: DateTime.parse('2021-10-05'),
        adjClose: 3,
      ),
    ];

    final List<YahooFinanceCandleData> result =
        JoinPrices.joinPrices(oldPricesList, recentPricesList);

    JoinPricesTextAux.validateSizeAndContinuity(result, 4);

    // Validate the join after the split
    assert(result[0].adjClose == 1);
    assert(result[1].adjClose == 3);
    assert(result[2].adjClose == 4);
    assert(result[3].adjClose == 3);
  });
}

void addTimestampForTesting(List<Map<String, dynamic>> list) {
  for (int i = 0; i < list.length; i++) {
    final int dateNum = list[i]['date'] as int;
    list[i]['datetime'] = DateTime.fromMillisecondsSinceEpoch(dateNum * 1000);
  }
}
