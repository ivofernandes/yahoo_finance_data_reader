import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

class SembastDatabase {
  static const String dbName = 'sembast';

  Database? _db;

  _initWebDatabase() async {
    var factory = databaseFactoryWeb;

    // Open the database
    _db = await factory.openDatabase(dbName);
  }

  _initNativeDatabase() async {
    var dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    String dbPath = join(dir.path, dbName);

    _db = await databaseFactoryIo.openDatabase(dbPath);
  }

  initDatabase() async {
    if (kIsWeb) {
      await _initWebDatabase();
    } else {
      await _initNativeDatabase();
    }
  }

  Future<DatabaseClient> getDatabase() async {
    if (_db == null) {
      await initDatabase();
    }

    return _db!;
  }
}
