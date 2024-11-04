import 'package:miraibo/model/infra/table_components.dart';
import 'package:miraibo/model/infra/fields.dart';

// <prediction task queue>
enum PredictionTaskFE<T> implements FieldEnum {
  id(IdField()),
  createdAt(DateTimeField('created_at'));

  const PredictionTaskFE(this.val);
  @override
  final Field<T> val;
}

class Task extends Record {
  int? id;
  DateTime createdAt;

  Task({this.id, required this.createdAt});

  factory Task.interpret(Map<String, Object?> row) {
    return Task(
      id: PredictionTaskFE.id.interpret(row[PredictionTaskFE.id.fn]),
      createdAt: PredictionTaskFE.createdAt
          .interpret(row[PredictionTaskFE.createdAt.fn]),
    );
  }

  @override
  Map<String, Object?> serialize() {
    return {
      PredictionTaskFE.id.fn: PredictionTaskFE.id.serialize(id),
      PredictionTaskFE.createdAt.fn:
          PredictionTaskFE.createdAt.serialize(createdAt),
    };
  }
}

class PredictionTasks extends Table {
  @override
  get fieldEnums => PredictionTaskFE.values;
  @override
  String get tableName => 'task_queue';
}
// </prediction task queue>
