import 'dart:math';

import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class AverageMixer {
  /// Mix a list of prices dataframes in the average
  static List<YahooFinanceCandleData> mix(
      List<List<YahooFinanceCandleData>> pricesList) {
    int numberOfAssets = pricesList.length;

    // Validate if the assets are possible to merge
    if (numberOfAssets < 1) {
      return [];
    }

    if (numberOfAssets < 2) {
      return pricesList.first;
    }

    // Reduce all lists to the same size
    preparePricesList(pricesList);

    // Merge the prices
    return mergeAveragePrices(numberOfAssets, pricesList);
  }

  /// Align the size of the dataframes of prices
  static void preparePricesList(List<List<YahooFinanceCandleData>> pricesList) {
    // Get the more recent start date in the list
    // before start the average processing
    DateTime mostRecentStartDate = pricesList.first.first.date;
    for (List<YahooFinanceCandleData> prices in pricesList) {
      if (prices.first.date.isAfter(mostRecentStartDate)) {
        mostRecentStartDate = prices.first.date;
      }
    }

    // Discard the dates before start date
    for (List<YahooFinanceCandleData> prices in pricesList) {
      while (prices.first.date.isBefore(mostRecentStartDate) &&
          prices.isNotEmpty) {
        prices.removeAt(0);
      }
    }
  }

  /// For this merge average process imagine like
  /// you have 50% of your portfolio with an asset
  /// and the other 50% of your portfolio in another asset,
  /// and every movement in your portfolio will be the average of these two assets
  static List<YahooFinanceCandleData> mergeAveragePrices(
      int numberOfAssets, List<List<YahooFinanceCandleData>> pricesList) {
    List<double> proportion = getProportionList(pricesList);

    // Merge the assets in one single dataframe
    int numberOfTimePoints = pricesList[0].length;
    List<YahooFinanceCandleData> result = [];

    for (int d = 0; d < numberOfTimePoints; d++) {
      DateTime currentDate = pricesList[0][d].date;
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

  /// Check by which value each dataframe needs to be multipled to start at the same value
  static List<double> getProportionList(
      List<List<YahooFinanceCandleData>> pricesList) {
    final maxOpenValue = calculateMaxOpenValue(pricesList);

    //
    List<double> result = [];
    for (var i = 0; i < pricesList.length; i++) {
      final open = pricesList[i].first.open;
      final proportion = open / maxOpenValue;

      result.add(proportion);
    }

    return result;
  }

  static calculateMaxOpenValue(List<List<YahooFinanceCandleData>> pricesList) {
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
