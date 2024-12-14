import 'package:miraibo/model_deprecated/infra/fields.dart';

// Be aware that they do not call database directly.
// Rather, they are used to generate SQL strings and interpret/serialize data.
// Calling database should be implemented in data provider classes.

/// [FieldEnum] defines fields of a table by enumarating [Field] objects.
abstract class FieldEnum<T, F extends Field<T>> {
  final F val;
  const FieldEnum(this.val);
}

/// [FieldEnumEx] provides some useful methods for [FieldEnum].
extension FieldEnumEx<T, F extends Field<T>> on FieldEnum<T, F> {
  /// means field name. Because its' confusing to use `name` for field name, this property is abbreviated to [fn].
  String get fn => val.name;
  String get fieldMakeString => val.fieldString();
  T interpret(Object? value) => val.interpret(value);
  Object? serialize(T value) => val.serialize(value);
}

/// [Table] defines table name and its fields by haveing a [FieldEnum] object.
abstract class Table<T, F extends Field<T>> {
  List<FieldEnum<T, F>> get fieldEnums;
  String get tableName;

  String get createString {
    List<String> fieldStrings = [];
    List<String> foreignConstrains = [];
    for (var fieldEnum in fieldEnums) {
      switch (fieldEnum.val) {
        case ForeignIdField field:
          foreignConstrains.add(field.foreignConstrainStinrg());
          break;
        case NullableForeignIdField field:
          foreignConstrains.add(field.foreignConstrainStinrg());
          break;
        default:
      }
      fieldStrings.add(fieldEnum.fieldMakeString);
    }
    return "CREATE TABLE IF NOT EXISTS '$tableName' (${[
      ...fieldStrings,
      ...foreignConstrains
    ].join(', ')});";
  }
}

/// [Record] defines a record object.
/// Record objects should be able to be inserted into a table by serializing it.
/// They also interpret a Map object to themselves.
///
/// make `interpret` factory, like;
///
/// ```
///   factory Record.interpret(Map<String, Object?> row) {
///    return Record(...);
///  }
/// ```
abstract class Record {
  /// do not include id field when serializing
  Map<String, Object?> serialize();
}
