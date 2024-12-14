import 'package:miraibo/model_v2/operations/delete.dart';
import 'package:miraibo/model_v2/operations/write.dart';
import 'package:miraibo/model_v2/operations/fetch.dart';
import 'package:miraibo/model_v2/operations/summarize.dart';
import 'package:miraibo/model_v2/operations/cache.dart';
import 'package:miraibo/model_v2/operations/initialize.dart';

abstract final class Operations {
  static FetchOperations fetch = fetch;
  static WriteOperations write = write;
  static DeleteOperations delete = delete;
  static SummarizingOperations summ = summ;
  static CachingOperations cache = cache;
  static InitializeOperations initialize = initialize;
}
