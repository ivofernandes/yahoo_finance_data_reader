import 'dart:math';

import 'package:yahoo_finance_data_reader/src/daily/mixer/mixer_utils.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

/// Mix a list of prices dataframes
class AverageMixer {
  /// Mix a list of prices dataframes in the average
  static List<YahooFinanceCandleData> mix(
      List<List<YahooFinanceCandleData>> pricesList) {
    final int numberOfAssets = pricesList.length;

    // Validate if the assets are possible to merge
    if (numberOfAssets < 1) {
      return [];
    }

    if (numberOfAssets < 2) {
      return pricesList.first;
    }

    // Reduce all lists to the same size
    MixerUtils.preparePricesList(pricesList);

    // Merge the prices
    return mergeAveragePrices(numberOfAssets, pricesList);
  }

  /// For this merge average process imagine like
  /// you have 50% of your portfolio with an asset
  /// and the other 50% of your portfolio in another asset,
  /// and every movement in your portfolio will be the average of these two assets
  static List<YahooFinanceCandleData> mergeAveragePrices(
      int numberOfAssets, List<List<YahooFinanceCandleData>> pricesList) {
    final List<double> proportion = MixerUtils.getProportionList(pricesList);

    // Merge the assets in one single dataframe
    final int numberOfTimePoints = pricesList[0].length;
    final List<YahooFinanceCandleData> result = [];

    for (int d = 0; d < numberOfTimePoints; d++) {
      final DateTime currentDate = pricesList[0][d].date;
      double sumOpen = 0;
      double sumClose = 0;
      double sumCloseAdj = 0;
      double sumHigh = 0;
      double sumLow = 0;
      double sumVolume = 0;

      for (int a = 0; a < numberOfAssets; a++) {
        // Goes back until find the right date
        int currentAssetIndex = min(d, pricesList[a].length - 1);
        YahooFinanceCandleData candle = pricesList[a][currentAssetIndex];
        if (candle.date.isAfter(currentDate)) {
          while (candle.date.isAfter(currentDate) && currentAssetIndex > 0) {
            candle = pricesList[a][currentAssetIndex];
            currentAssetIndex--;
          }
        }

        // Sum while adjusting for inital proportion
        sumOpen += candle.open / proportion[a];
        sumClose += candle.close / proportion[a];
        sumCloseAdj += candle.adjClose / proportion[a];

        sumLow += candle.low / proportion[a];
        sumHigh += candle.high / proportion[a];
        sumVolume += candle.volume / proportion[a];
      }

      result.add(YahooFinanceCandleData(
          open: sumOpen / numberOfAssets,
          close: sumClose / numberOfAssets,
          adjClose: sumCloseAdj / numberOfAssets,
          high: sumHigh / numberOfAssets,
          low: sumLow / numberOfAssets,
          volume: (sumVolume / numberOfAssets).round(),
          date: currentDate));
    }

    return result;
  }
}
