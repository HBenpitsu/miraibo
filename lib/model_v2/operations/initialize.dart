import 'package:miraibo/model_v2/data/data.dart';
import 'package:miraibo/util/util.dart';

Future<void> initializeCategory() async {
  await rdb.categoryAccessor.bulkInsert([
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
  ]);
}

Future<void> initializeMetaData() async {
  await ndb.metaData.setFirstLaunch(today());
}

class InitializeOperations {
  Future<void> ensureInilialized() async {
    if (await ndb.metaData.appInitialized) {
      return;
    }
    await Future.wait([initializeCategory(), initializeMetaData()]);
    await ndb.metaData.setAppInitialized(true);
  }
}

final initialize = InitializeOperations();
