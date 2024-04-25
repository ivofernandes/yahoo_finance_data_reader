import 'package:yahoo_finance_data_reader/src/daily/mixer/mixer_utils.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class WeightedAverageMixer {
  /// Mix a map of weights to lists of prices dataframes according to the defined weights
  static List<YahooFinanceCandleData> mix(Map<List<YahooFinanceCandleData>, double> weightedPricesList) {
    if (weightedPricesList.isEmpty) {
      return [];
    }

    // Ensure all lists are of the same size and start from the same date
    MixerUtils.preparePricesList(weightedPricesList.keys.toList());

    // Calculate proportions for each asset based on the maximum open value
    final proportions = MixerUtils.getProportionList(weightedPricesList.keys.toList());

    // Calculate the total weight for normalization
    final double totalWeight = weightedPricesList.values.fold(0, (sum, item) => sum + item);

    // Merge the prices using weights and proportions
    return mergeWeightedPrices(weightedPricesList, totalWeight, proportions);
  }

  static List<YahooFinanceCandleData> mergeWeightedPrices(
      Map<List<YahooFinanceCandleData>, double> weightedPricesList, double totalWeight, List<double> proportions) {
    // Validate that there are as many proportions as there are price lists
    if (weightedPricesList.length != proportions.length) {
      throw ArgumentError('The number of price lists must match the number of proportions.');
    }
    final int numberOfTimePoints = weightedPricesList.keys.first.length;
    final List<YahooFinanceCandleData> result = [];
    int assetIndex = 0;
    final List<List<YahooFinanceCandleData>> pricesList = weightedPricesList.keys.toList();
    final List<double> weights = weightedPricesList.values.toList();

    for (int d = 0; d < numberOfTimePoints; d++) {
      final DateTime currentDate = pricesList.first[d].date;
      double sumOpen = 0;
      double sumClose = 0;
      double sumCloseAdj = 0;
      double sumHigh = 0;
      double sumLow = 0;
      double sumVolume = 0;

      for (int i = 0; i < pricesList.length; i++) {
        final List<YahooFinanceCandleData> prices = pricesList[i];
        final double currentProportion = proportions[i];
        final double currentWeight = (weights[i] / totalWeight) / currentProportion;

        // Find the candle with the same date as 'currentDate'
        final YahooFinanceCandleData currentCandle = MixerUtils.findCandleByDate(prices, currentDate, d);

        sumOpen += currentCandle.open * currentWeight;
        sumClose += currentCandle.close * currentWeight;
        sumCloseAdj += currentCandle.adjClose * currentWeight;
        sumHigh += currentCandle.high * currentWeight;
        sumLow += currentCandle.low * currentWeight;
        sumVolume += currentCandle.volume * currentWeight;
      }

      result.add(YahooFinanceCandleData(
          open: sumOpen,
          close: sumClose,
          adjClose: sumCloseAdj,
          high: sumHigh,
          low: sumLow,
          volume: sumVolume.round(),
          date: currentDate));

      assetIndex = (assetIndex + 1) % weightedPricesList.length;
    }

    return result;
  }
}
