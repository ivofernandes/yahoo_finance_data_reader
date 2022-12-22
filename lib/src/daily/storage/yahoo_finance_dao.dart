import 'package:sembast/sembast.dart';

import 'sembast_database.dart';

/// Class to manage interactions with local database
class YahooFinanceDAO with SembastDatabase {
  // Singleton
  static final YahooFinanceDAO _singleton = YahooFinanceDAO._internal();

  factory YahooFinanceDAO() {
    return _singleton;
  }

  YahooFinanceDAO._internal();

  static const String storeDaily = 'YAHOO_DAILY';

  Future<List<dynamic>?> getAllDailyData(String ticker) async {
    var store = intMapStoreFactory.store(storeDaily);

    final DatabaseClient database = await getDatabase();
    var data = await store.find(database,
        finder: Finder(filter: Filter.equals('ticker', ticker)));

    List<dynamic>? resultsList = [];

    for (var snapshot in data) {
      var map = snapshot.value;

      resultsList = map['data'] as List<dynamic>?;
    }

    return resultsList;
  }

  Future<void> saveDailyData(String? ticker, List<dynamic> data) async {
    var store = intMapStoreFactory.store(storeDaily);
    final DatabaseClient database = await getDatabase();

    await store.delete(database,
        finder: Finder(filter: Filter.equals('ticker', ticker)));

    await store.add(database, {'ticker': ticker, 'data': data});
  }

  Future<int> removeDailyData(String? ticker) async {
    var store = intMapStoreFactory.store(storeDaily);
    final DatabaseClient database = await getDatabase();

    int deletedRecords = await store.delete(database,
        finder: Finder(filter: Filter.equals('ticker', ticker)));

    return deletedRecords;
  }
}
