import 'package:yahoo_finance_data_reader/src/daily/model/yahoo_finance_candle_data.dart';

class YahooFinanceResponse {
  YahooFinanceResponse({
    this.candlesData = const [],
  });

  /// List with all the candles
  List<YahooFinanceCandleData> candlesData = [];

  factory YahooFinanceResponse.fromJson(
    Map<String, dynamic> json, {
    bool adjust = false,
  }) {
    final List<YahooFinanceCandleData> data = [];

    final List<dynamic> timestamps = json['timestamp'] as List;

    final Map<String, dynamic> indicators =
        json['indicators'] as Map<String, dynamic>;
    final List<dynamic> quotes = indicators['quote'] as List<dynamic>;
    final Map<String, dynamic> firstQuote =
        quotes.first as Map<String, dynamic>;

    final List<dynamic> opens = firstQuote['open'] as List;
    final List<dynamic> closes = firstQuote['close'] as List;
    final List<dynamic> lows = firstQuote['low'] as List;
    final List<dynamic> highs = firstQuote['high'] as List;
    final List<dynamic> volumes = firstQuote['volume'] as List;

    final List<dynamic> adjClosesList = indicators['adjclose'] as List<dynamic>;
    final Map<String, dynamic> adjClosesList2 =
        adjClosesList.first as Map<String, dynamic>;

    final List<dynamic> adjCloses = adjClosesList2['adjclose'] as List<dynamic>;

    for (int i = 0; i < timestamps.length; i++) {
      final int timestamp = timestamps[i] as int;
      final DateTime date =
          DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

      // Ignore null values
      if (closes[i] == null ||
          opens[i] == null ||
          lows[i] == null ||
          highs[i] == null ||
          volumes[i] == null ||
          adjCloses[i] == null) {
        continue;
      }

      double close = closes[i] as double;
      double open = opens[i] as double;
      double low = lows[i] as double;
      double high = highs[i] as double;
      final int volume = volumes[i] as int;
      final double adjClose = adjCloses[i] as double;

      if (adjust) {
        final double proportion = adjClose / close;
        close = close * proportion;
        open = open * proportion;
        low = low * proportion;
        high = high * proportion;
      }

      // Add candle to the list
      final YahooFinanceCandleData candle = YahooFinanceCandleData(
        date: date,
        close: close,
        open: open,
        low: low,
        high: high,
        volume: volume,
        adjClose: adjClose,
      );
      data.add(candle);
    }

    return YahooFinanceResponse(
      candlesData: data,
    );
  }

  Map<String, dynamic> toJson() => {
        'candlesData': toCandlesJson(),
      };

  List<dynamic> toCandlesJson() => candlesData.map((e) => e.toJson()).toList();
}
