import 'package:miraibo/type/enumarations.dart';

class DateButtonHandler {
  Future<DateButtonStyle> fetchStyleFor(DateTime date) async {
    return DateButtonStyle.hasTrivialEvent;
  }
}
