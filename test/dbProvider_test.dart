import 'package:flutter_test/flutter_test.dart';

import 'package:miraibo/data/database.dart';

Future<void> resetDB() async {
  PersistentDatabaseProvider dbProvider = PersistentDatabaseProvider();
  await dbProvider.clear();
}

void main() async {
  await resetDB();
  test('no test', () {});
}
