import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'database.dart';

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
      await Table.dbProvider.db.execute('''
        INSERT INTO $tableName (name) VALUES
        ${initialCategories.map((cat) => "('$cat')").join(", ")}
      ''');
    }
  }

  @override
  Future<Category> interpret(Map<String, Object?> row, Transaction? txn) async {
    return Category(id: row['id'] as int, name: row['name'] as String);
  }

  @override
  void validate(Category data) {} // always valid

  @override
  Map<String, Object?> serialize(Category data) {
    return {'name': data.name};
  }

  @override
  Future<int> delete(Category data, Transaction? txn) {
    throw ShouldNotBeCalledException(
        'category should not be deleted directly. instead, use [CategoryTable.integrate()]');
  }

  List<HaveCategoryField> integrators = [];

  Future<int> integrate(Category replaced, Category replaceWith) async {
    if (replaced.id == null || replaceWith.id == null) {
      throw ArgumentError('phantom category cannot be integrated');
    }
    await useTables(integrators, (db) async {
      await db.transaction((txn) async {
        await Future.wait([
          for (var integrator in integrators)
            integrator.replaceCategory(txn, replaced, replaceWith)
        ]);
        await txn.delete(tableName, where: 'id = ?', whereArgs: [replaced.id]);
      });
    });
    return replaceWith.id!;
  }
}

/// implement [replaceCategory] and call [bindCategoryIntegrator] in [prepare] method
mixin HaveCategoryField<T extends DTO> on Table<T> {
  Future<void> replaceCategory(
      Transaction txn, Category replaced, Category replaceWith);

  /// call this method in [prepare] method of the table
  void bindCategoryIntegrator() {
    var categoryTable = CategoryTable.ref();
    categoryTable.integrators.add(this);
  }
}

/// implement [replaceCategory]
mixin CategoryLinker<Kv extends DTO, Vv extends DTO>
    on Linker<Kv, Vv>, HaveCategoryField<Link> {
  @override
  Future<void> prepare() async {
    bindCategoryIntegrator();
    await super.prepare();
  }

  @override
  Future<void> replaceCategory(
      Transaction txn, Category replaced, Category replaceWith) async {
    // TODO: eliminate duplicated valueId
    await txn.execute('''
    UPDATE $tableName
    SET valueId = ${replaceWith.id}
    WHERE valueId = ${replaced.id};
    SELECT * FROM $tableName GROUP BY keyId, valueId HAVING COUNT(*) > 1;
    ''');
  }
}
