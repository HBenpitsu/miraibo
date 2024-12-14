import 'package:miraibo/model_deprecated/infra/table_components.dart';
import 'package:miraibo/model_deprecated/infra/fields.dart';

// <prediction task queue>
enum PredictionTaskFE<T> implements FieldEnum {
  id(IdField()),
  createdAt(DateTimeField('created_at'));

  const PredictionTaskFE(this.val);
  @override
  final Field<T> val;
}

class PredictionTasks extends Table {
  @override
  get fieldEnums => PredictionTaskFE.values;
  @override
  String get tableName => 'task_queue';
}
// </prediction task queue>
