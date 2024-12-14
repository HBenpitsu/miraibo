import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/util/date_time.dart';

class DefaultCategoryProvider {
  static view_obj.Category category =
      view_obj.Category(name: 'invalid category');
}

abstract final class DefaultTicketProvider {
  static view_obj.Display get displayTicket => view_obj.Display(
        displayPeriod: DisplayPeriod.week,
        termMode: DisplayTermMode.untilToday,
        contentType: DisplayContentType.summation,
        targetingAllCategories: true,
        targetCategories: [],
      );
  static view_obj.Estimation get estimation => view_obj.Estimation(
        contentType: EstimationContentType.perDay,
        targetingAllCategories: false,
        targetCategories: [],
      );
  static view_obj.Schedule get schedule => view_obj.Schedule(
        category: DefaultCategoryProvider.category,
        supplement: '',
        amount: 0,
        originDate: today(),
        repeatType: ScheduleRepeatType.no,
        repeatInterval: const Duration(days: 0),
        weeklyRepeatOn: [],
      );
  static view_obj.Log get log => view_obj.Log(
      date: today(),
      category: DefaultCategoryProvider.category,
      amount: 0,
      supplement: '',
      confirmed: false);
}
