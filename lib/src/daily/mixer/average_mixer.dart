import 'dart:math';

import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class AverageMixer {
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

    preparePricesList(pricesList);

    return mergeAveragePrices(numberOfAssets, pricesList);
  }

  static void preparePricesList(List<List<YahooFinanceCandleData>> pricesList) {
    // Get the date for start the average processing
    DateTime startDate = pricesList.first.first.date;
    for (List<YahooFinanceCandleData> prices in pricesList) {
      if (prices.first.date.isAfter(startDate)) {
        startDate = prices.first.date;
      }
    }

    // Discard the dates before start date
    for (List<YahooFinanceCandleData> prices in pricesList) {
      while (prices.first.date.isBefore(startDate) && prices.isNotEmpty) {
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
    // Merge the assets in one single dataframe
    int numberOfTimePoints = pricesList[0].length;
    List<YahooFinanceCandleData> result = [];

    for (int d = 0; d < numberOfTimePoints; d++) {
      DateTime currentDate = pricesList[0][d].date;
      double sumOpen = 0;
      double sumClose = 0;
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

        sumOpen += candle.open;
        sumClose += candle.close;

        sumLow += candle.low;
        sumHigh += candle.high;
        sumVolume += candle.volume;
      }

      result.add(YahooFinanceCandleData(
          open: sumOpen / numberOfAssets,
          close: sumClose / numberOfAssets,
          high: sumHigh / numberOfAssets,
          low: sumLow / numberOfAssets,
          volume: (sumVolume / numberOfAssets).round(),
          date: currentDate));
    }

    return result;
  }
}
