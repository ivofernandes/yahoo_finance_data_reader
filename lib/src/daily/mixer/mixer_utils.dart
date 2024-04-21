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

  // Utility method to find a candle by date with optimization
  static YahooFinanceCandleData findCandleByDate(
      List<YahooFinanceCandleData> prices, DateTime targetDate, int hintIndex) {
    if (hintIndex >= 0 && hintIndex < prices.length) {
      if (prices[hintIndex].date == targetDate) {
        return prices[hintIndex];
      } else if (prices[hintIndex].date.compareTo(targetDate) < 0) {
        // If the current date is before the target, search forward
        for (int j = hintIndex; j < prices.length; j++) {
          if (prices[j].date == targetDate) {
            return prices[j];
          }
        }
      } else {
        // If the current date is after the target, search backward
        for (int j = hintIndex; j >= 0; j--) {
          if (prices[j].date == targetDate) {
            return prices[j];
          }
        }
      }
    }

    // Default to a zero-data candle if not found
    return YahooFinanceCandleData(open: 0, close: 0, adjClose: 0, high: 0, low: 0, volume: 0, date: targetDate);
  }
}
