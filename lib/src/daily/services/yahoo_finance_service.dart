import 'dart:async';

import 'package:yahoo_finance_data_reader/src/daily/aux/join_prices.dart';
import 'package:yahoo_finance_data_reader/src/daily/aux/strategy_time.dart';
import 'package:yahoo_finance_data_reader/src/daily/mixer/average_mixer.dart';
import 'package:yahoo_finance_data_reader/src/daily/storage/yahoo_finance_dao.dart';
import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

/// This class abstracts for the state machine how the API vs cache works
class YahooFinanceService {
  // Singleton
  static final YahooFinanceService _singleton = YahooFinanceService._internal();
  factory YahooFinanceService() {
    return _singleton;
  }
  YahooFinanceService._internal();

  Future<List<YahooFinanceCandleData>> getTickerDataList(
      List<String> symbols) async {
    List<List<YahooFinanceCandleData>> pricesList = [];

    for (String symbol in symbols) {
      List<YahooFinanceCandleData> prices = await getTickerData(symbol);
      pricesList.add(prices);
    }

    return AverageMixer.mix(pricesList);
  }

  /// Gets the candles for a ticker
  Future<List<YahooFinanceCandleData>> getTickerData(String symbol) async {
    if (symbol.contains(',')) {
      List<String> symbols = symbol.split(', ');
      return getTickerDataList(symbols);
    }

    // Try to get data from cache
    List<dynamic>? pricesRaw = await YahooFinanceDAO().getAllDailyData(symbol);
    List<YahooFinanceCandleData> prices = [];

    for (final priceRaw in pricesRaw ?? []) {
      prices.add(YahooFinanceCandleData.fromJson(priceRaw));
    }

    // If have no cached historical data
    if (prices.isEmpty) {
      prices = await getAllDataFromYahooFinance(symbol);
    }

    // If there is offline data but is not up to date
    // try to get the remaining part
    else if (!StrategyTime.isUpToDate(prices)) {
      prices = await refreshData(prices, symbol);
    }

    return prices;
  }

  Future<List<YahooFinanceCandleData>> refreshData(
      List<YahooFinanceCandleData> prices, String symbol) async {
    if (prices.length > 1) {
      // Get one of the lasts dates in the cache, this is not the most recent,
      // because the most recent often is in the middle of the day,
      // and the yahoo finance returns us the current price in the close price column,
      // and for joining dates, we need real instead of the real close prices
      DateTime lastDate = prices[2].date;

      YahooFinanceResponse response =
          await const YahooFinanceDailyReader().getDailyDTOs(
        symbol,
        startDate: lastDate,
      );
      List<YahooFinanceCandleData> nextPrices = response.candlesData;

      if (nextPrices != []) {
        prices = JoinPrices.joinPrices(prices, nextPrices);

        List jsonList =
            YahooFinanceResponse(candlesData: prices).toCandlesJson();
        // Cache data after join locally
        YahooFinanceDAO().saveDailyData(symbol, jsonList);
        return prices;
      }
    }

    // If was not possible to refresh, get all data from yahoo finance
    return getAllDataFromYahooFinance(symbol);
  }

  Future<List<YahooFinanceCandleData>> getAllDataFromYahooFinance(
      String symbol) async {
    YahooFinanceResponse response = YahooFinanceResponse();

    // Get data from yahoo finance
    try {
      response = await const YahooFinanceDailyReader().getDailyDTOs(symbol);
    } catch (e) {
      return [];
    }

    if (response.candlesData.isNotEmpty) {
      // Cache data locally

      List jsonList = response.toCandlesJson();
      YahooFinanceDAO().saveDailyData(symbol, jsonList);
      return response.candlesData;
    }

    return [];
  }
}
