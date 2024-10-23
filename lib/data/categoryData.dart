import 'package:miraibo/data/ticketData.dart';
import 'database.dart';

import 'dart:developer' as developer;

class Category extends DTO {
  final String name;

  const Category({super.id, required this.name});

  static Future<Category> make(String name) async {
    var ret = Category(name: name);
    await ret.save();
    return ret;
  }

  static Category saveInFuture(String name) {
    var ret = Category(name: name);
    ret.save();
    return ret;
  }

  @override
  Future<void> save() async {
    var categoryTable = await CategoryTable.use();
    await categoryTable.save(this);
  }

  @override
  Future<void> delete() async {
    throw ShouldNotBeCalledException(
        'category should not be deleted directly. instead, use [Category.integrateWith()]');
  }

  Future<void> integrateWith(Category other) async {
    var categoryTable = await CategoryTable.use();
    await categoryTable.integrate(this, other);
  }

  Future<Category> rename(String newName) async {
    var ret = Category(id: id, name: newName);
    await ret.save();
    return ret;
  }
}

class CategoryTable extends Table<Category> {
  @override
  covariant String tableName = 'Categories';

  // <constructor>
  CategoryTable._internal();
  static final CategoryTable _instance = CategoryTable._internal();
  static Future<CategoryTable> use() async {
    await _instance.ensureAvailability();
    return _instance;
  }

  factory CategoryTable.ref() => _instance;
  // </constructor>

  static final List<String> initialCategories = [
    'Food',
    'Gas',
    'Water',
    'Electricity',
    'Transportation',
    'EducationFee',
    'EducationMaterials',
    'Amusument',
    'Furniture',
    'Necessities',
    'OtherExpense',
    'Scholarship',
    'Payment',
    'Ajustment',
  ];

  @override
  Future<void> prepare() async {
    await Table.dbProvider.db.execute(makeTable([
      makeIdField(),
      makeTextField('name', notNull: true),
    ]));
    // check if the table is empty
    var queryResult =
        await Table.dbProvider.db.rawQuery('SELECT COUNT(*) FROM $tableName');
    if (queryResult.first.values.first == 0) {
      // insert initial categories at once
      await Table.dbProvider.db.rawInsert('''
        INSERT INTO $tableName (name) VALUES
        ${initialCategories.map((cat) => "('$cat')").join(", ")}
      ''');
    }
  }

  @override
  Future<Category> interpret(Map<String, Object?> row) async {
    return Category(id: row['id'] as int, name: row['name'] as String);
  }

  @override
  void validate(Category data) {} // always valid

  @override
  Map<String, Object?> serialize(Category data) {
    return {'id': data.id, 'name': data.name};
  }

  @override
  Future<int> delete(Category data) {
    throw ShouldNotBeCalledException(
        'category should not be deleted directly. instead, use [CategoryTable.integrate()]');
  }

  Future<int> integrate(Category replaced, Category replaceWith) async {
    if (replaced.id == null || replaceWith.id == null) {
      throw ArgumentError('phantom category cannot be integrated');
    }
    var logRecs = await LogRecordTable.use();
    var scheduleRecs = await ScheduleTable.use();
    var displayLinker = await DisplayTicketTargetCategoryLinker.use();
    var estimationLinker = await EstimationTargetCategoryLinker.use();
    throw UnimplementedError();
    return replaceWith.id!;
  }
}
