import 'package:yahoo_finance_data_reader/src/daily/model/yahoo_finance_candle_data.dart';

class JoinPricesTextAux {
  static void validateSizeAndContinuity(
      List<YahooFinanceCandleData> result, int expectedSize) {
    assert(result.length == expectedSize);

    for (int i = 0; i < expectedSize - 1; i++) {
      assert(result[i].date.isBefore(result[i + 1].date));
    }
  }
}
