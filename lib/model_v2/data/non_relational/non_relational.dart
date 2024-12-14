import 'package:miraibo/model_v2/data/non_relational/caching_status.dart';
import 'package:miraibo/model_v2/data/non_relational/meta_data.dart';
import 'package:miraibo/model_v2/data/non_relational/user_preferences.dart';

class NonRelationalDatabase {
  final CachingStatusAccessObject cachingStatus = CachingStatusAccessObject();
  final MetaDataAccessObject metaData = MetaDataAccessObject();
  final UserPreferencesAccessObject userPreferences =
      UserPreferencesAccessObject();
}

final ndb = NonRelationalDatabase();
