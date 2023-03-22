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
  test('Join prices test', () async {
    final List<YahooFinanceCandleData> oldPricesList = [
      YahooFinanceCandleData(
        date: DateTime.parse('2021-09-29'),
        adjClose: 53.470001220703125,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2021-10-01'),
        adjClose: 54.310001373291016,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2021-10-04'),
        adjClose: 53.13999938964844,
      ),
    ];

    final List<YahooFinanceCandleData> recentPricesList = [
      YahooFinanceCandleData(
        date: DateTime.parse('2021-10-01'),
        adjClose: 54.310001373291016,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2021-10-04'),
        adjClose: 53.13999938964844,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2021-10-05'),
        adjClose: 53.91999816894531,
      ),
    ];

    final List<YahooFinanceCandleData> result =
        JoinPrices.joinPrices(oldPricesList, recentPricesList);

    JoinPricesTextAux.validateSizeAndContinuity(result, 4);
  });

  test('Join prices test split 1/2', () async {
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
        date: DateTime.parse('2021-10-01'),
        adjClose: 1.5,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2021-10-04'),
        adjClose: 2,
      ),
      YahooFinanceCandleData(
        date: DateTime.parse('2021-10-05'),
        adjClose: 3,
      ),
    ];

    final List<YahooFinanceCandleData> result =
        JoinPrices.joinPrices(oldPricesList, recentPricesList);

    JoinPricesTextAux.validateSizeAndContinuity(result, 4);

    // Validate the join after the split
    assert(result[0].adjClose == 0.5);
    assert(result[1].adjClose == 1.5);
    assert(result[2].adjClose == 2);
    assert(result[3].adjClose == 3);
  });
}
