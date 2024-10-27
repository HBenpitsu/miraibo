import 'package:flutter_test/flutter_test.dart';

import '../lib/data/database.dart';

Future<void> resetDB() async {
  DatabaseProvider dbProvider = DatabaseProvider();
  await dbProvider.clear();
}

void main() async {
  await resetDB();
  test('no test', () {});
}
