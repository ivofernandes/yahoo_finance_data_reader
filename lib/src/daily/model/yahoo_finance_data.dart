class YahooFinanceCandleData {
  final DateTime date;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final int? volume;

  YahooFinanceCandleData({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  static YahooFinanceCandleData fromJson(json) {
    return YahooFinanceCandleData(
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] * 1000),
      open: json['open'] == null ? null : double.parse(json['open'].toString()),
      high: json['high'] == null ? null : double.parse(json['high'].toString()),
      low: json['low'] == null ? null : double.parse(json['low'].toString()),
      close:
          json['close'] == null ? null : double.parse(json['close'].toString()),
      volume:
          json['volume'] == null ? null : int.parse(json['volume'].toString()),
    );
  }

  Map toJson() {
    return {
      'date': date.millisecondsSinceEpoch ~/ 1000,
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
}
