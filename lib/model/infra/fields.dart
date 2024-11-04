// In this file, General field objects are defined.

sealed class Field<T> {
  final String name;
  final bool isIndexed;
  const Field(this.name, {this.isIndexed = false});
  String fieldString();
  T interpret(Object? value);
  Object? serialize(T value);
}

class IdField extends Field<int> {
  const IdField() : super('id');
  @override
  String fieldString() => '$name INTEGER PRIMARY KEY';
  @override
  int interpret(Object? value) => value as int;
  @override
  int serialize(int value) => value;
}

class IntField extends Field<int> {
  const IntField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER NOT NULL';
  @override
  int interpret(Object? value) => value as int;
  @override
  int serialize(int value) => value;
}

class NullableIntField extends Field<int?> {
  const NullableIntField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER';
  @override
  int? interpret(Object? value) => value as int?;
  @override
  int? serialize(int? value) => value;
}

class TextField extends Field<String> {
  const TextField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name TEXT NOT NULL';
  @override
  String interpret(Object? value) => value as String;
  @override
  String serialize(String value) => value;
}

class NullableTextField extends Field<String?> {
  const NullableTextField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name TEXT';
  @override
  String? interpret(Object? value) => value as String?;
  @override
  String? serialize(String? value) => value;
}

class RealField extends Field<double> {
  const RealField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name REAL NOT NULL';
  @override
  double interpret(Object? value) => value as double;
  @override
  double serialize(double value) => value;
}

class NullableRealField extends Field<double?> {
  const NullableRealField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name REAL';
  @override
  double? interpret(Object? value) => value as double?;
  @override
  double? serialize(double? value) => value;
}

class BoolField extends Field<bool> {
  const BoolField(super.name);
  @override
  String fieldString() =>
      '$name INTEGER NOT NULL CHECK ($name = 0 OR $name = 1)';
  @override
  bool interpret(Object? value) => (value as int) == 1;
  @override
  int serialize(bool value) => value ? 1 : 0;
}

class EnumField<E extends Enum> extends Field<E> {
  final List<E> enumValues;
  const EnumField(super.name, this.enumValues);
  @override
  String fieldString() =>
      '$name INTEGER NOT NULL CHECK (0 <= $name AND $name < ${enumValues.length})';
  @override
  E interpret(Object? value) => enumValues[value as int];
  @override
  int serialize(E value) => enumValues.indexOf(value);
}

class DateTimeField extends Field<DateTime> {
  const DateTimeField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER NOT NULL CHECK ($name >= 0)';
  @override
  DateTime interpret(Object? value) =>
      DateTime.fromMicrosecondsSinceEpoch(value as int);
  @override
  int serialize(DateTime value) => value.microsecondsSinceEpoch;
}

class NullableDateTimeField extends Field<DateTime?> {
  const NullableDateTimeField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER CHECK ($name >= 0)';
  @override
  DateTime? interpret(Object? value) {
    if (value == null) return null;
    return DateTime.fromMicrosecondsSinceEpoch(value as int);
  }

  @override
  int? serialize(DateTime? value) => value?.microsecondsSinceEpoch;
}

const aDayInMilliseconds = 1000 * 60 * 60 * 24;

class DateField extends Field<DateTime> {
  const DateField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER NOT NULL CHECK ($name >= 0)';
  @override
  DateTime interpret(Object? value) =>
      DateTime.fromMillisecondsSinceEpoch((value as int) * aDayInMilliseconds);
  @override
  int serialize(DateTime value) =>
      value.millisecondsSinceEpoch ~/ aDayInMilliseconds;
}

class NullableDateField extends Field<DateTime?> {
  const NullableDateField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER CHECK ($name >= 0)';
  @override
  DateTime? interpret(Object? value) {
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(
        (value as int) * aDayInMilliseconds);
  }

  @override
  int? serialize(DateTime? value) {
    if (value == null) return null;
    return value.millisecondsSinceEpoch ~/ aDayInMilliseconds;
  }
}

class DurationField extends Field<Duration> {
  const DurationField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER NOT NULL CHECK ($name >= 0)';
  @override
  Duration interpret(Object? value) => Duration(microseconds: value as int);
  @override
  int serialize(Duration value) => value.inMicroseconds;
}

class NullableDurationField extends Field<Duration?> {
  const NullableDurationField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER CHECK ($name >= 0)';
  @override
  Duration? interpret(Object? value) {
    if (value == null) return null;
    return Duration(microseconds: value as int);
  }

  @override
  int? serialize(Duration? value) => value?.inMicroseconds;
}

class DaysField extends Field<Duration> {
  const DaysField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER NOT NULL CHECK ($name >= 0)';
  @override
  Duration interpret(Object? value) => Duration(days: value as int);
  @override
  int serialize(Duration value) => value.inDays;
}

class NullableDaysField extends Field<Duration?> {
  const NullableDaysField(super.name, {super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER CHECK ($name >= 0)';
  @override
  Duration? interpret(Object? value) {
    if (value == null) return null;
    return Duration(days: value as int);
  }

  @override
  int? serialize(Duration? value) => value?.inDays;
}

class ForeignIdField extends Field<int> {
  final String foreignTableName;
  final String foreignFieldName;
  const ForeignIdField(super.name, this.foreignTableName,
      {this.foreignFieldName = 'id', super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER NOT NULL';
  @override
  int interpret(Object? value) => value as int;
  @override
  int serialize(int value) => value;
  String foreignConstrainStinrg() =>
      'FOREIGN KEY ($name) REFERENCES $foreignTableName($foreignFieldName)';
}

class NullableForeignIdField extends Field<int?> {
  final String foreignTableName;
  final String foreignFieldName;
  const NullableForeignIdField(super.name, this.foreignTableName,
      {this.foreignFieldName = 'id', super.isIndexed = false});
  @override
  String fieldString() => '$name INTEGER';
  @override
  int? interpret(Object? value) => value as int?;
  @override
  int? serialize(int? value) => value;
  String foreignConstrainStinrg() =>
      'FOREIGN KEY ($name) REFERENCES $foreignTableName($foreignFieldName)';
}
