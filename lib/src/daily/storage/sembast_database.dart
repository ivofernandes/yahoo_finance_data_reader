import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

mixin SembastDatabase {
  static const String dbName = 'sembast';

  Database? _db;

  Future<void> _initWebDatabase() async {
    final factory = databaseFactoryWeb;

    // Open the database
    _db = await factory.openDatabase(dbName);
  }

  Future<void> _initNativeDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    final String dbPath = join(dir.path, dbName);

    _db = await databaseFactoryIo.openDatabase(dbPath);
  }

  Future<void> initDatabase() async {
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
