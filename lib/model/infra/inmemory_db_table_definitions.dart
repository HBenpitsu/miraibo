import 'package:miraibo/model/infra/fields.dart';
import 'package:miraibo/model/infra/table_components.dart';

enum TaskQueueFE<T> implements FieldEnum {
  id(IdField()),
  createdAt(DateTimeField());

  const TaskQueueFE(Field<T> val);
  @override
  final Field<T> val;
}
