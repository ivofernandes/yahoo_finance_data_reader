import 'package:yahoo_finance_data_reader/src/daily/model/yahoo_finance_data.dart';

class YahooFinanceResponse {
  YahooFinanceResponse({
    required this.candlesData,
  });

  List<YahooFinanceCandleData> candlesData = [];
}
