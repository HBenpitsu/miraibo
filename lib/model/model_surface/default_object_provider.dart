import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/util/date_time.dart';

class DefaultCategoryProvider {
  static view_obj.Category category =
      view_obj.Category(name: 'invalid category');
}

abstract final class DefaultTicketProvider {
  static view_obj.DisplayTicket get displayTicket => view_obj.DisplayTicket(
        displayPeriod: DTPeriod.week,
        termMode: DTTermMode.untilToday,
        contentType: DTContentType.summation,
        targetingAllCategories: true,
        targetCategories: [],
      );
  static view_obj.Estimation get estimation => view_obj.Estimation(
        contentType: ETContentType.perDay,
        targetingAllCategories: false,
        targetCategories: [],
      );
  static view_obj.Schedule get schedule => view_obj.Schedule(
        category: DefaultCategoryProvider.category,
        supplement: '',
        amount: 0,
        originDate: today(),
        repeatType: SCRepeatType.no,
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
