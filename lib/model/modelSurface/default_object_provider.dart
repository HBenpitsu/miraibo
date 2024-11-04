import 'package:miraibo/model/modelSurface/view_obj.dart';
import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/util/date_time.dart';

class DefaultCategoryProvider {
  static Category category = Category(name: 'test');
  Future<void> update() async {
    // TODO: implement
  }
}

abstract final class DefaultTicketProvider {
  static DisplayTicket get displayTicket => DisplayTicket(
        displayPeriod: DTPeriod.week,
        termMode: DTTermMode.untilToday,
        contentType: DTContentType.summation,
        targetingAllCategories: true,
        targetCategories: [],
      );
  static Estimation get estimation => Estimation(
        contentType: ETContentType.perDay,
        targetingAllCategories: false,
        targetCategories: [],
      );
  static Schedule get schedule => Schedule(
        category: DefaultCategoryProvider.category,
        supplement: '',
        amount: 0,
        originDate: today(),
        repeatType: SCRepeatType.no,
        repeatInterval: const Duration(days: 0),
        weeklyRepeatOn: [],
      );
  static Log get log => Log(
      date: today(),
      category: DefaultCategoryProvider.category,
      amount: 0,
      supplement: '',
      confirmed: false);
}
