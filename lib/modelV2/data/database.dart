import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:miraibo/type/enumarations.dart';

import 'package:miraibo/modelV2/data/tables.dart';
import 'package:miraibo/modelV2/data/basic_accessors.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Categories,
  Logs,
  Displays,
  DisplayCategoryLinks,
  Schedules,
  Estimations,
  EstimationCategoryLinks,
  EstimationCaches,
  RepeatCaches
], daos: [
  CategoryAccessor
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
