import 'package:miraibo/model_deprecated/transaction/prediction.dart';

class PredictionHandler {
  Future<void> onDateRendered(DateTime date) async {
    await RequirePrediction(date).execute();
  }
}
