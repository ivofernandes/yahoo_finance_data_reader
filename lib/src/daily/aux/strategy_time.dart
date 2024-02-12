// ignore_for_file: prefer_final_locals

import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class StrategyTime {
  /// Check if a prices data stills valid
  /// This is done in json data
  static bool isUpToDate(
      List<YahooFinanceCandleData> prices, DateTime? startDate) {
    DateTime now = DateTime.now();

    // Go to the last working day
    while (now.weekday > 5) {
      now = now.subtract(const Duration(hours: 4));
    }

    DateTime lastPrice = prices.last.date;

    Duration difference = now.difference(lastPrice);
    bool isUpToDate = difference.inHours < 12;

    return isUpToDate;
  }
}
