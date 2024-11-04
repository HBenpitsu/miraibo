import 'package:flutter_test/flutter_test.dart';

import 'package:miraibo/model/infra/database_provider.dart';

void main() {
  test('ensureAvailability', () async {
    RelationalDatabaseProvider dbProvider = PersistentDatabaseProvider();
    await dbProvider.ensureAvailability();
    expect(dbProvider.db.isOpen, true);
  });
}
