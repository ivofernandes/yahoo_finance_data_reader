import 'package:yahoo_finance_data_reader/src/daily/model/yahoo_finance_candle_data.dart';

class YahooFinanceResponse {
  YahooFinanceResponse({
    this.candlesData = const [],
  });

  /// List with all the candles
  List<YahooFinanceCandleData> candlesData = [];

  factory YahooFinanceResponse.fromJson(Map<String, dynamic> json) {
    List<YahooFinanceCandleData> data = [];

    List timestamps = json['timestamp'];

    Map<String, dynamic> indicators = json['indicators']['quote'].first;

    List opens = indicators['open'];
    List closes = indicators['close'];
    List lows = indicators['low'];
    List highs = indicators['high'];
    List volumes = indicators['volume'];

    List adjCloses = json['indicators']['adjclose'].first['adjclose'];

    for (int i = 0; i < timestamps.length; i++) {
      int timestamp = timestamps[i] as int;
      DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

      // Ignore null values
      if (closes[i] == null ||
          opens[i] == null ||
          lows[i] == null ||
          highs[i] == null ||
          volumes[i] == null ||
          adjCloses[i] == null) {
        continue;
      }

      // Add candle to the list
      YahooFinanceCandleData candle = YahooFinanceCandleData(
          date: date,
          close: closes[i],
          open: opens[i],
          low: lows[i],
          high: highs[i],
          volume: volumes[i],
          adjClose: adjCloses[i]);
      data.add(candle);
    }

    return YahooFinanceResponse(
      candlesData: data,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'candlesData': toCandlesJson(),
    };
  }

  List toCandlesJson() {
    return candlesData.map((e) => e.toJson()).toList();
  }
}
