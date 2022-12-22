import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class StrategyTime {
  /// Check if a prices data stills valid
  /// This is done in json data
  static bool isUpToDate(List<YahooFinanceCandleData> prices) {
    DateTime now = DateTime.now();

    // Go to the last working day
    while (now.weekday > 5) {
      now = now.subtract(const Duration(hours: 4));
    }

    DateTime lastPrice = prices.first.date;

    Duration difference = now.difference(lastPrice);
    bool isUpToDate = difference.inHours < 12;

    return isUpToDate;
  }
}
