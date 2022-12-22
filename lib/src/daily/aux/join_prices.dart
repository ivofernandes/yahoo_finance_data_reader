import 'package:yahoo_finance_data_reader/yahoo_finance_data_reader.dart';

class JoinPrices {
  /// Join [oldPricesList] with the [recentPricesList]
  ///
  /// [oldPricesList]
  ///
  static List<YahooFinanceCandleData> joinPrices(
      List<YahooFinanceCandleData> oldPricesList,
      List<YahooFinanceCandleData> recentPricesList) {
    double proportion = _calculateProportion(oldPricesList, recentPricesList);

    if (proportion != 1) {
      print('Found porportion != 1: ${recentPricesList.last.date}');
      for (int i = 0; i < oldPricesList.length; i++) {
        oldPricesList[i] = oldPricesList[i].copyWith(
          adjClose: oldPricesList[i].adjClose * proportion,
        );
      }
    }

    return _finishJoin(oldPricesList, recentPricesList, proportion);
  }

  static double _calculateProportion(List<YahooFinanceCandleData> oldPricesList,
      List<YahooFinanceCandleData> recentPricesList) {
    //Get the index on prices that matches the last value in next prices

    int indexInOld = 0;
    int indexInRecent = recentPricesList.length;

    bool foundMatch = false;

    // Start in the last recent index of the recent dataframe
    // and goes on searching for a date in the old dataframe that matches
    while (!foundMatch && indexInRecent != 0) {
      indexInRecent--;
      indexInOld = 0;

      DateTime oldestDateInTheRecentList = recentPricesList[indexInRecent].date;

      while (indexInOld < oldPricesList.length - 1 &&
          recentPricesList[indexInRecent].date !=
              oldPricesList[indexInOld].date &&
          indexInOld < oldPricesList.length) {
        indexInOld++;
      }

      //
      foundMatch = recentPricesList[indexInRecent].date ==
          oldPricesList[indexInOld].date;
    }

    double proportion = 1;

    if (foundMatch) {
      // Check if there is a need to apply a porportion adjustment int ehe adjusted close
      proportion = recentPricesList[indexInRecent].adjClose /
          oldPricesList[indexInOld].adjClose;
    }

    return proportion;
  }

  static List<YahooFinanceCandleData> _finishJoin(
      List<YahooFinanceCandleData> oldPricesList,
      List<YahooFinanceCandleData> recentPricesList,
      double proportion) {
    // Will check if is has the same day than the old date limit,
    // because it can be incomplete as the close data is not from close
    // but rather the last price in the time of the request
    DateTime oldLimitDate = oldPricesList.first.date;
    String oldLimitDateString = oldLimitDate.toIso8601String().split('T')[0];
    bool overridedLast = false;

    // join the next prices into the prices array
    for (int i = recentPricesList.length - 1; i >= 0; i--) {
      if (recentPricesList[i].date.millisecondsSinceEpoch <
          oldPricesList.first.date.millisecondsSinceEpoch) {
        continue;
      }

      if (!overridedLast) {
        DateTime currentDate = recentPricesList[i].date;
        String currentDateString = currentDate.toIso8601String().split('T')[0];

        if (currentDateString == oldLimitDateString) {
          oldPricesList[0] = recentPricesList[i];
          overridedLast = true;
          continue;
        }
      }

      oldPricesList.insert(0, recentPricesList[i]);
    }

    return oldPricesList;
  }
}
