import 'package:yahoo_finance_data_reader/src/daily/mixer/average_mixer.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class WeightedAverageMixer {
  /// Mix a map of weights to lists of prices dataframes according to the defined weights
  static List<YahooFinanceCandleData> mix(Map<List<YahooFinanceCandleData>, double> weightedPricesList) {
    if (weightedPricesList.isEmpty) {
      return [];
    }

    // Ensure all lists are of the same size and start from the same date
    AverageMixer.preparePricesList(weightedPricesList.keys.toList());

    // Calculate the total weight for normalization
    final double totalWeight = weightedPricesList.values.fold(0, (sum, item) => sum + item);

    // Merge the prices using weights
    return mergeWeightedPrices(weightedPricesList, totalWeight);
  }

  static List<YahooFinanceCandleData> mergeWeightedPrices(
      Map<List<YahooFinanceCandleData>, double> weightedPricesList, double totalWeight) {
    final int numberOfTimePoints = weightedPricesList.keys.first.length;
    final List<YahooFinanceCandleData> result = [];

    for (int d = 0; d < numberOfTimePoints; d++) {
      final DateTime currentDate = weightedPricesList.keys.first[d].date;
      double sumOpen = 0;
      double sumClose = 0;
      double sumCloseAdj = 0;
      double sumHigh = 0;
      double sumLow = 0;
      double sumVolume = 0;

      weightedPricesList.forEach((prices, weight) {
        // Adjust index if necessary, similar to the logic in mergeAveragePrices
        final int currentAssetIndex = d < prices.length ? d : prices.length - 1;
        final YahooFinanceCandleData candle = prices[currentAssetIndex];

        // Adjust the sums using the weight of each asset
        final double adjustedWeight = weight / totalWeight;
        sumOpen += candle.open * adjustedWeight;
        sumClose += candle.close * adjustedWeight;
        sumCloseAdj += candle.adjClose * adjustedWeight;
        sumLow += candle.low * adjustedWeight;
        sumHigh += candle.high * adjustedWeight;
        sumVolume += candle.volume * adjustedWeight;
      });

      result.add(YahooFinanceCandleData(
          open: sumOpen,
          close: sumClose,
          adjClose: sumCloseAdj,
          high: sumHigh,
          low: sumLow,
          volume: sumVolume.round(),
          date: currentDate));
    }

    return result;
  }
}
