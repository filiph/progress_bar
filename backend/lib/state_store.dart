import 'package:sqlite3/sqlite3.dart';

class StateStore {
  final Database _db;

  StateStore(String path) : _db = sqlite3.open(path) {
    _init();
  }

  StateStore.inMemory() : _db = sqlite3.openInMemory() {
    _init();
  }

  void _init() {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS state (
        key TEXT PRIMARY KEY,
        percentage INTEGER NOT NULL
      );
    ''');
  }

  int? getLastPercentage(String key) {
    final results = _db.select('SELECT percentage FROM state WHERE key = ?', [
      key,
    ]);
    if (results.isEmpty) return null;
    return results.first['percentage'] as int;
  }

  void setLastPercentage(String key, int percentage) {
    _db.execute(
      '''
      INSERT INTO state (key, percentage) VALUES (?, ?)
      ON CONFLICT(key) DO UPDATE SET percentage = excluded.percentage
    ''',
      [key, percentage],
    );
  }

  void close() {
    _db.dispose();
  }
}
