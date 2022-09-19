import 'dart:convert';

class YahooFinanceData {
  final DateTime date;
  final double? open;
  final double? high;
  final double? low;
  final double? close;
  final int? volume;
  final double? adjClose;

  YahooFinanceData({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.adjClose,
  });

  static YahooFinanceData fromJson(json) {
    return YahooFinanceData(
      date: DateTime.fromMillisecondsSinceEpoch(json['date'] * 1000),
      open: json['open'] == null ? null : double.parse(json['open'].toString()),
      high: json['high'] == null ? null : double.parse(json['high'].toString()),
      low: json['low'] == null ? null : double.parse(json['low'].toString()),
      close:
          json['close'] == null ? null : double.parse(json['close'].toString()),
      volume:
          json['volume'] == null ? null : int.parse(json['volume'].toString()),
      adjClose: json['adjclose'] == null
          ? null
          : double.parse(json['adjclose'].toString()),
    );
  }

  Map toJson() {
    return {
      'date': date.millisecondsSinceEpoch ~/ 1000,
      'open': open,
      'close': close,
      'adjclose': adjClose,
      'high': high,
      'low': low,
      'volume': volume,
    };
  }

  @override
  String toString() => json.encode(toJson());
}
