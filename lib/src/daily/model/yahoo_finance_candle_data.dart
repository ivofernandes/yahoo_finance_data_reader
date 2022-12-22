class YahooFinanceCandleData {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;
  final double adjClose;

  Map<String, double> indicators = {};

  YahooFinanceCandleData({
    required this.date,
    this.open = -1,
    this.high = -1,
    this.low = -1,
    this.close = -1,
    this.adjClose = -1,
    this.volume = 0,
  });

  static YahooFinanceCandleData fromJson(json) {
    return YahooFinanceCandleData(
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] * 1000),
      open: double.parse(json['open'].toString()),
      high: double.parse(json['high'].toString()),
      low: double.parse(json['low'].toString()),
      close: double.parse(json['close'].toString()),
      adjClose: double.parse(json['adjClose'].toString()),
      volume: int.parse(json['volume'].toString()),
    );
  }

  Map toJson() {
    return {
      'date': date.millisecondsSinceEpoch ~/ 1000,
      'adjClose': adjClose,
      'open': open,
      'close': close,
      'high': high,
      'low': low,
      'volume': volume,
    };
  }

  @override
  String toString() => 'YahooFinanceCandleData{date: $date, open: $open, '
      'close: $close, high: $high, low: $low, volume: $volume}';

  YahooFinanceCandleData copyWith({
    DateTime? date,
    double? open,
    double? close,
    double? adjClose,
    double? high,
    double? low,
    int? volume,
  }) {
    return YahooFinanceCandleData(
      date: date ?? this.date,
      open: open ?? this.open,
      close: close ?? this.close,
      adjClose: adjClose ?? this.adjClose,
      high: high ?? this.high,
      low: low ?? this.low,
      volume: volume ?? this.volume,
    );
  }
}
