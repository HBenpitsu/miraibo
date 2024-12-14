import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'package:miraibo/type/enumarations.dart';

import 'package:miraibo/model_v2/data/relational/tables.dart';
import 'package:miraibo/model_v2/data/relational/basic_accessors.dart';
import 'package:miraibo/model_v2/data/relational/cacher.dart';
import 'package:miraibo/model_v2/data/relational/summarizer.dart';

part 'relational.g.dart';

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
  CategoryAccessor,
  EstimationAccessor,
  ScheduleAccessor,
  DisplayAccessor,
  LogAccessor,
  EstimationCacher,
  RepeatCacher,
  EstimationContent,
  RecordCollector
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

final rdb = AppDatabase();

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
