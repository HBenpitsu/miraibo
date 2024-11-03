import 'package:flutter_test/flutter_test.dart';
import 'package:miraibo/data/database.dart';

void main() async {
  test('dbProvider works', () async {
    PersistentDatabaseProvider dbProvider = PersistentDatabaseProvider();
    await dbProvider.ensureAvailability();
    expect(dbProvider.db, isNotNull);
    InmemoryDatabaseProvider inmemoryProvider = InmemoryDatabaseProvider();
    await inmemoryProvider.ensureAvailability();
    expect(inmemoryProvider.db, isNotNull);
  });
  tearDownAll(() async {
    PersistentDatabaseProvider dbProvider = PersistentDatabaseProvider();
    await dbProvider.clear();
  });
}
