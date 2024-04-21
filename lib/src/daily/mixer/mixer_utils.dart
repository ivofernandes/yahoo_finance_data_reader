import 'package:yahoo_finance_data_reader/src/daily/model/yahoo_finance_candle_data.dart';

abstract class MixerUtils {
  /// Align the size of the dataframes of prices
  static void preparePricesList(List<List<YahooFinanceCandleData>> pricesList) {
    // Get the more recent start date in the list
    // before start the average processing
    DateTime mostRecentStartDate = pricesList.first.first.date;
    for (final List<YahooFinanceCandleData> prices in pricesList) {
      if (prices.first.date.isAfter(mostRecentStartDate)) {
        mostRecentStartDate = prices.first.date;
      }
    }

    // Discard the dates before start date
    for (final List<YahooFinanceCandleData> prices in pricesList) {
      while (prices.first.date.isBefore(mostRecentStartDate) && prices.isNotEmpty) {
        prices.removeAt(0);
      }
    }
  }

  /// Check by which value each dataframe needs to be multipled to start at the same value
  static List<double> getProportionList(List<List<YahooFinanceCandleData>> pricesList) {
    final maxOpenValue = _calculateMaxOpenValue(pricesList);

    //
    final List<double> result = [];
    for (var i = 0; i < pricesList.length; i++) {
      final open = pricesList[i].first.open;
      final proportion = open / maxOpenValue;

      result.add(proportion);
    }

    return result;
  }

  static double _calculateMaxOpenValue(List<List<YahooFinanceCandleData>> pricesList) {
    double maxValue = pricesList.first.first.open;

    for (var i = 1; i < pricesList.length; i++) {
      final open = pricesList[i].first.open;

      if (maxValue < open) {
        maxValue = open;
      }
    }

    return maxValue;
  }
}
