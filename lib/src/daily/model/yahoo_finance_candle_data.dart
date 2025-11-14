/// Representation of a single candle
class YahooFinanceCandleData {
  /// Date of the candle
  final DateTime date;

  /// Open price
  final double open;

  /// High price
  final double high;

  /// Low price
  final double low;

  /// Close price
  final double close;

  /// Volume
  final int volume;

  /// Adjusted close price, by splits and dividends
  final double adjClose;

  /// Map to receive indicators associated with this candle
  Map<String, double> indicators = {};

  /// Constructor
  YahooFinanceCandleData({
    required this.date,
    this.open = -1,
    this.high = -1,
    this.low = -1,
    this.close = -1,
    this.adjClose = -1,
    this.volume = 0,
  });

  factory YahooFinanceCandleData.fromJson(
    Map<String, dynamic> json, {
    bool adjust = false,
  }) {
    final double adjClose = double.parse(json['adjClose'].toString());
    double close = double.parse(json['close'].toString());
    double open = double.parse(json['open'].toString());
    double low = double.parse(json['low'].toString());
    double high = double.parse(json['high'].toString());

    if (adjust) {
      final double proportion = adjClose / close;
      close = close * proportion;
      open = open * proportion;
      low = low * proportion;
      high = high * proportion;
    }

    return YahooFinanceCandleData(
      date: DateTime.fromMillisecondsSinceEpoch((json['date'] as int) * 1000),
      open: open,
      high: high,
      low: low,
      close: close,
      adjClose: adjClose,
      volume: int.parse(json['volume'].toString()),
    );
  }

  /// Create a list of YahooFinanceCandleData based in a json array
  static List<YahooFinanceCandleData> fromJsonList(
      List<Map<String, dynamic>> jsonList) {
    final List<YahooFinanceCandleData> result = [];

    for (final Map<String, dynamic> jsonObject in jsonList) {
      result.add(YahooFinanceCandleData.fromJson(jsonObject));
    }

    return result;
  }

  Map<String, dynamic> toJson() => {
        'date': date.millisecondsSinceEpoch ~/ 1000,
        'adjClose': adjClose,
        'open': open,
        'close': close,
        'high': high,
        'low': low,
        'volume': volume,
      };

  @override
  String toString() =>
      'YahooFinanceCandleData{date: $date, adjClose: $adjClose, open: $open, '
      'close: $close, high: $high, low: $low, volume: $volume}';

  YahooFinanceCandleData copyWith({
    DateTime? date,
    double? open,
    double? close,
    double? adjClose,
    double? high,
    double? low,
    int? volume,
  }) =>
      YahooFinanceCandleData(
        date: date ?? this.date,
        open: open ?? this.open,
        close: close ?? this.close,
        adjClose: adjClose ?? this.adjClose,
        high: high ?? this.high,
        low: low ?? this.low,
        volume: volume ?? this.volume,
      );
}
