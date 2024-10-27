import 'package:flutter_test/flutter_test.dart';

import '../lib/data/database.dart';

void main() async {
  test('test of dbProvider', () async {
    var dbProvider = DatabaseProvider();
    await dbProvider.init();
    var db = dbProvider.db;
    await db.execute('''
    CREATE TABLE IF NOT EXISTS test (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      field1 INTEGER NOT NULL,
      field2 INTEGER NOT NULL
    );
    INSERT INTO test (field1, field2) VALUES (1, 2), (1, 3), (1, 3), (1, 3), (1, 2), (1, 1), (2, 5), (1, 6);
  ''');
    print(await db.rawQuery('''
    SELECT * FROM test;
  '''));
    await db.execute('''
    DELETE FROM test WHERE id IN (SELECT id FROM test GROUP BY field1, field2 HAVING COUNT(*) > 1);
  ''');
    print(await db.rawQuery('''
    SELECT * FROM test GROUP BY field1, field2 HAVING COUNT(*) > 1;
  '''));
    print(await db.rawQuery('''
    SELECT * FROM test;
  '''));
    await db.execute('''
    DROP TABLE test;
  ''');
  });
}
