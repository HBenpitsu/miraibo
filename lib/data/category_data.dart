import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:miraibo/data/database.dart';

class Category extends DTO {
  final String name;

  const Category({super.id, required this.name});

  static Future<Category> make(String name) async {
    var categoryTable = await CategoryTable.use(null);
    return categoryTable.make(name, null);
  }

  Future<void> integrateWith(Category other) async {
    // mere wrapper. the actual integration is done in CategoryTable.integrate()
    var categoryTable = await CategoryTable.use(null);
    await categoryTable.integrate(this, other, null);
  }

  Future<Category> rename(String newName) async {
    var ret = Category(id: id, name: newName);
    var categoryTable = await CategoryTable.use(null);
    await categoryTable.save(ret, null);
    return ret;
  }
}

class CategoryTable extends Table<Category> {
  @override
  covariant String tableName = 'Categories';
  @override
  covariant DatabaseProvider dbProvider = PersistentDatabaseProvider();

  // <field name>
  static const String nameField = 'name';
  // </field name>

  // <constructor>
  CategoryTable._internal();
  static final CategoryTable _instance = CategoryTable._internal();
  static Future<CategoryTable> use(Transaction? txn) async {
    await _instance.ensureAvailability(txn);
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
    'Medication',
    'Amusument',
    'Furniture',
    'Necessities',
    'OtherExpense',
    'Scholarship',
    'Payment',
    'OtherIncome',
    'Ajustment',
  ];

  @override
  Future<void> prepare(Transaction? txn) async {
    if (txn == null) {
      return PersistentDatabaseProvider().db.transaction((txn) async {
        return prepare(txn);
      });
    }

    await txn.execute(makeTable([
      makeIdField(),
      makeTextField(nameField, notNull: true),
    ]));
    // check if the table is empty
    var queryResult = await txn.rawQuery('SELECT COUNT(*) FROM $tableName');
    if (queryResult.first.values.first == 0) {
      // insert initial categories at once
      await txn.execute('''
        INSERT INTO $tableName ( $nameField ) VALUES
        ${initialCategories.map((cat) => "('$cat')").join(", ")}
      ''');
    }
  }

  Future<Category> make(String name, Transaction? txn) async {
    if (txn == null) {
      return PersistentDatabaseProvider().db.transaction((txn) async {
        return make(name, txn);
      });
    }

    var id = await txn.insert(tableName, {nameField: name});
    return Category(id: id, name: name);
  }

  @override
  Future<Category> interpret(Map<String, Object?> row, Transaction? txn) async {
    return Category(
        id: row[Table.idField] as int, name: row[nameField] as String);
  }

  @override
  void validate(Category data) {} // always valid

  @override
  Map<String, Object?> serialize(Category data) {
    return {nameField: data.name};
  }

  /// although super class, [Table], provides delete method, it should not be used directly for this [CategoryTable].
  @override
  Future<int> delete(int id, Transaction? txn) {
    throw ShouldNotBeCalledException(
        'category should not be deleted directly. instead, use [CategoryTable.integrate()]');
  }

  List<HaveCategoryField> integrators = [];

  Future<int> integrate(
      Category replaced, Category replaceWith, Transaction? txn) async {
    if (txn == null) {
      return dbProvider.db.transaction((txn) async {
        return integrate(replaced, replaceWith, txn);
      });
    }

    if (replaced.id == null || replaceWith.id == null) {
      throw ArgumentError('phantom category cannot be integrated');
    }

    await Future.wait([
      for (var integrator in integrators)
        integrator.ensureAvailability(txn).then((_) {
          integrator.replaceCategory(txn, replaced, replaceWith);
        })
    ]);

    await txn.delete(tableName,
        where: '${Table.idField} = ?', whereArgs: [replaced.id]);

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
  Future<void> prepare(Transaction? txn) async {
    bindCategoryIntegrator();
    await super.prepare(txn);
  }

  @override
  Future<void> replaceCategory(
      Transaction txn, Category replaced, Category replaceWith) async {
    // duplicates will be eliminated at the point of selection by distinct option.
    await txn.execute('''
    UPDATE $tableName
    SET ${Linker.valueIdField} = ${replaceWith.id}
    WHERE ${Linker.valueIdField} = ${replaced.id};
    ''');
  }
}
