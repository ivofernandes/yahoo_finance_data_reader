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
      while (prices.first.date.isBefore(mostRecentStartDate) &&
          prices.isNotEmpty) {
        prices.removeAt(0);
      }
    }
  }

  /// Check by which value each dataframe needs to be multipled to start at the same value
  static List<double> getProportionList(
      List<List<YahooFinanceCandleData>> pricesList) {
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

  static double _calculateMaxOpenValue(
      List<List<YahooFinanceCandleData>> pricesList) {
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
      List<YahooFinanceCandleData> prices,
      DateTime targetDate,
      int hintIndexParam) {
    // Bound the hint index to min and max index in prices list
    final hintIndex = hintIndexParam.clamp(0, prices.length - 1);

    if (prices[hintIndex].date == targetDate) {
      return prices[hintIndex];
    }
    // If the current date is before the target, search forward
    else if (prices[hintIndex].date.compareTo(targetDate) < 0) {
      for (int j = hintIndex; j < prices.length; j++) {
        // If the current date is equals or after the target, return the candle
        if (prices[j].date.compareTo(targetDate) >= 0) {
          return prices[j];
        }
      }
    } else {
      // If the current date is after the target, search backward
      for (int j = hintIndex; j >= 0; j--) {
        // If the current date is equals or before the target, return the candle
        if (prices[j].date.compareTo(targetDate) <= 0) {
          return prices[j];
        }
      }
    }
    // Search for the closest candle to the target date
    YahooFinanceCandleData closestCandle = prices.first;
    for (final YahooFinanceCandleData candle in prices) {
      if ((candle.date
              .difference(targetDate)
              .abs()
              .compareTo(closestCandle.date.difference(targetDate).abs())) <
          0) {
        closestCandle = candle;
      }
    }

    return closestCandle;
  }
}
