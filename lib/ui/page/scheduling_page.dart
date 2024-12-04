import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:miraibo/ui/component/display_ticket_configurator.dart';
import 'package:miraibo/ui/component/estimation_ticket_configurator.dart';
import 'package:miraibo/ui/component/schedule_ticket_configurator.dart';
import 'package:miraibo/ui/component/log_ticket_configurator.dart';
import 'package:miraibo/ui/component/applied_ticket_configurator.dart';
import 'package:miraibo/ui/component/ticket_configurator_shared_traits.dart';
import 'package:miraibo/ui/component/motion.dart';
import 'package:miraibo/ui/component/ticket.dart';

import 'package:miraibo/model/model_surface/date_button_handler.dart';
import 'package:miraibo/model/model_surface/display_handler.dart';
import 'package:miraibo/model/model_surface/estimation_handler.dart';
import 'package:miraibo/model/model_surface/log_handler.dart';
import 'package:miraibo/model/model_surface/schedule_handler.dart';
import 'package:miraibo/model/model_surface/prediction_handler.dart';

import 'package:miraibo/type/view_obj.dart' as data;

import 'package:miraibo/util/date_time.dart';
import 'package:miraibo/type/enumarations.dart';

/* 
SchedulingPage has two screens: MonthlyScreen and DailyScreen
The main function of SchedulingPage is to switch between these two screens
*/

class SchedulingPageController {
  late final PredictionController predictionController;
  late final MonthlyScreenController monthlyScreenController;
  late final DailyScreenController dailyScreenController;

  SchedulingPageController() {
    predictionController = PredictionController(this);
    monthlyScreenController = MonthlyScreenController(this);
    dailyScreenController = DailyScreenController(this);
  }

  late void Function() onMonthlyScreenRequird;
  late void Function() onDailyScreenRequird;

  void switchToMonthlyScreen() {
    onMonthlyScreenRequird();
  }

  void switchToDailyScreen() {
    dailyScreenController.pivotDate = focusedDate;
    onDailyScreenRequird();
  }

  DateTime _focusedDate = today();
  DateTime get focusedDate => _focusedDate;
  set focusedDate(DateTime date) {
    _focusedDate = date;
    dailyScreenController.updateLabel();
  }
}

/* 
PredictionController is a controller to observe the range of shown dates.
It is invoked by scrolling the CalendarList/TicketContainerList.
*/

class PredictionController {
  final SchedulingPageController superController;
  PredictionController(this.superController);
  final handler = PredictionHandler();
  void rendered(DateTime date) {
    handler.onDateRendered(date);
  }
}

enum Screen { monthly, daily }

class SchedulingPage extends StatefulWidget {
  static const Duration screenSwitchingDuration = Duration(milliseconds: 300);
  final SchedulingPageController ctl;
  const SchedulingPage({super.key, required this.ctl});

  @override
  State<SchedulingPage> createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  Screen _currentScreen = Screen.monthly;

  @override
  void initState() {
    super.initState();
    widget.ctl.onMonthlyScreenRequird = () {
      if (!mounted) return;
      setState(() {
        _currentScreen = Screen.monthly;
      });
    };
    widget.ctl.onDailyScreenRequird = () {
      if (!mounted) return;
      setState(() {
        _currentScreen = Screen.daily;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: SchedulingPage.screenSwitchingDuration,
        child: _currentScreen == Screen.monthly
            ? MonthlyScreen(
                ctl: widget.ctl.monthlyScreenController,
              )
            : DailyScreen(
                ctl: widget.ctl.dailyScreenController,
              ));
  }
}

/* 
MonthlyScreen has infinite list of MonthlyCalendar widgets
Main function of MonthlyScreen is to show a list of MonthlyCalendar widgets

And MonthlyScreen should notify Monthlycalendars to start making buttons when its scrolling is setteled.
*/
class MonthlyScreenController {
  final SchedulingPageController superCtl;
  MonthlyScreenController(this.superCtl);

  MonthlyCalenderController newCalenderController(DateTime targetDate) {
    int renderingDelay;
    if (_isScrolling) {
      renderingDelay = 0;
    } else {
      // inject fluctuation on first appearance of the screen to mitigate performance impact
      renderingDelay = 30 * (10 * Random().nextDouble()).floor();
    }
    return MonthlyCalenderController(this,
        targetDate: targetDate,
        renderingDelay: Duration(milliseconds: renderingDelay));
  }

  // <observing scroll speed>
  bool _isScrolling = false;
  bool _greenLight = true; // to allow button making
  bool get greenLight => _greenLight;
  void init() {
    _isScrolling = false;
    _greenLight = false;
    onSettled();
  }

  void onScrolling() {
    _isScrolling = true;
    _greenLight = false;
  }

  void onSettled() {
    Future(() async {
      // inject delay to avoid flickering
      _isScrolling = false;
      await Future.delayed(MonthlyScreen.settleDelay);
      if (_isScrolling) return;
      _greenLight = true;
    });
  }
  // </observing scroll speed>
}

class MonthlyScreen extends StatelessWidget {
  static const Duration settleDelay = Duration(milliseconds: 300);
  final MonthlyScreenController ctl;

  const MonthlyScreen({super.key, required this.ctl});

  // to observe scroll speed
  bool onNotification(Notification notification) {
    switch (notification) {
      case ScrollUpdateNotification _:
      case ScrollStartNotification _:
        ctl.onScrolling();
        return false;
      case ScrollEndNotification _:
        ctl.onSettled();
        return false;
      default:
        return false;
    }
  }

  MonthlyCalendar calender(DateTime forThisDate) {
    // shownRangeController is called to observe the range of shown dates.
    // This is necessary to update the range of caluculation of `Predictions`.
    ctl.superCtl.predictionController.rendered(forThisDate);
    var calendar = MonthlyCalendar(ctl: ctl.newCalenderController(forThisDate));
    return calendar;
  }

  Scrollable calendarList() {
    // dual-directional infinite vertically scrollable list
    Key center = UniqueKey(); // this key is to center the list
    SliverList forwardList = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        var date = DateTime(ctl.superCtl.focusedDate.year,
            ctl.superCtl.focusedDate.month + index, 1);
        return calender(date);
      }),
      key: center,
    );

    SliverList reverseList = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        var date = DateTime(ctl.superCtl.focusedDate.year,
            ctl.superCtl.focusedDate.month - index - 1, 1);
        return calender(date);
      }),
    );

    return Scrollable(
      viewportBuilder: (context, offset) {
        return Viewport(
          offset: offset,
          center: center,
          slivers: [
            reverseList,
            forwardList,
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ctl.init();
    // notify based on scroll speed
    return NotificationListener(
      onNotification: onNotification,
      child: calendarList(),
    );
  }
}

/* The MonthlyCalendar widget displays a grid of DateButton widgets.
Its main function is to arrange DateButton widgets in a calendar format.
It also includes a header to show the its month and year.

DataButtons vary in style based on data existance.
So, it should handle Future-Object to consult a data provider.
Monthlycalendar should also handle Future-Object to show a loading indicator.

DateButtons are so many that it influences the performance; it supresses ButtonBuilding until it is needed.
*/

class MonthlyCalenderController {
  final MonthlyScreenController superCtl;
  final DateTime targetDate;
  final Duration renderingDelay;
  MonthlyCalenderController(this.superCtl,
      {required this.targetDate,
      this.renderingDelay = const Duration(milliseconds: 0)});

  DateButtonController newButtonController(DateTime date) {
    return DateButtonController(this, date: date);
  }

  // <values> value caluculations
  int? _numberOfRows;
  int get numberOfRows {
    const int daysInWeek = 7;
    _numberOfRows ??= ((daysInMonth + indexDateMapOffset) / daysInWeek).ceil();
    return _numberOfRows!;
  }

  int get indexDateMapOffset => targetDate.weekday - 1;

  int? _daysInMonth;
  int get daysInMonth {
    _daysInMonth ??= DateTime(targetDate.year, targetDate.month + 1, 0).day;
    return _daysInMonth!;
  }

  int? dateOn(int index) {
    if (index < indexDateMapOffset) {
      return null;
    }
    if (index - indexDateMapOffset >= daysInMonth) {
      return null;
    }
    return index - indexDateMapOffset + 1;
  }
  // </values>
}

class MonthlyCalendar extends StatelessWidget {
  final MonthlyCalenderController ctl;
  static const Duration signCheckInterval = Duration(milliseconds: 600);

  const MonthlyCalendar({super.key, required this.ctl});

  double calendarWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double maxWidth = 350;
    return min(maxWidth, screenWidth);
  }

  Widget frame(BuildContext context, Widget child) {
    return Container(
      height: calendarWidth(context) * ctl.numberOfRows / 7,
      width: calendarWidth(context),
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  SizedBox label(BuildContext context) {
    return SizedBox(
      width: calendarWidth(context),
      child: Text(
        '${ctl.targetDate.year} - ${ctl.targetDate.month}',
        style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 38), //Theme.of(context).textTheme.headlineLarge
      ),
    );
  }

  Future<void> waitForGreenLight() async {
    // to allow blocking, await for a while regardless of the state of greenLight
    await Future.delayed(Duration(milliseconds: 100));
    while (!ctl.superCtl.greenLight) {
      await Future.delayed(signCheckInterval);
    }
  }

  Future<List<DateButton>> arrayOfButtons(BuildContext context) async {
    // inject rendering delay to vary the time of button making
    await Future.delayed(ctl.renderingDelay);
    // to mitigate performance impact, buttons are made in batches
    const batchNum = 3; // number of batches
    List<DateButton> ret = [];
    int batchSize = (ctl.daysInMonth / batchNum).floor();

    // make `batchSize` of buttons at once
    for (int i = 0; i < batchNum - 1; i += 1) {
      await waitForGreenLight(); // to avoid flickering
      for (int j = i * batchSize; j < (i + 1) * batchSize; j += 1) {
        ret.add(DateButton(
            ctl: ctl.newButtonController(
                DateTime(ctl.targetDate.year, ctl.targetDate.month, j + 1))));
      }
    }

    // make the rest of buttons (this is separated to deal with rounding error)
    await waitForGreenLight();
    for (int j = (batchNum - 1) * batchSize; j < ctl.daysInMonth; j += 1) {
      ret.add(DateButton(
          ctl: ctl.newButtonController(
              DateTime(ctl.targetDate.year, ctl.targetDate.month, j + 1))));
    }

    return ret;
  }

  Future<Widget> buttonsInGrid(BuildContext context) async {
    var array = await arrayOfButtons(context);
    return GridView.builder(
      itemCount: ctl.numberOfRows * 7,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1, // square cells
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        var day = ctl.dateOn(index);
        if (day == null) {
          return const Text('');
        } else {
          return array[day - 1];
        }
      },
    );
  }

  Widget mainPart(BuildContext context) {
    return FutureBuilder(
        future: buttonsInGrid(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return frame(
                context, const Center(child: CircularProgressIndicator()));
          } else {
            return frame(context, snapshot.data!);
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        label(context),
        mainPart(context),
      ],
    );
  }
}

/* 
DataButton is a button that represents a date.
Its main function is to switch to DailyScreen when it is clicked.

DataButtons vary in style based on data existance.
So, it should handle Future-Object to consult a data provider.
*/
class DateButtonController {
  final DateTime date;
  final MonthlyCalenderController superCtl;
  SchedulingPageController get page => superCtl.superCtl.superCtl;

  DateButtonController(this.superCtl, {required this.date});
  Future<DateButtonStyle> style() async {
    return await DateButtonHandler().fetchStyleFor(date);
  }

  void setFocusedDate() {
    page.focusedDate = date;
  }
}

class DateButton extends StatelessWidget {
  final DateButtonController ctl;

  const DateButton({super.key, required this.ctl});

  TextButton templ(BuildContext context, Color backgroundColor,
      Color borderColor, Color textColor) {
    return TextButton(
        onPressed: () {
          ctl.setFocusedDate();
          ctl.page.switchToDailyScreen();
        },
        style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
            side: BorderSide(
              width: 1.0,
              color: borderColor,
            )),
        child: Text(
          '${ctl.date.day}',
          style: TextStyle(color: textColor),
        ));
  }

  Widget buttonHasNothing(BuildContext context) {
    return templ(context, Theme.of(context).colorScheme.surface,
        Theme.of(context).disabledColor, Theme.of(context).disabledColor);
  }

  Widget buttonHasTrivialEvent(BuildContext context) {
    return templ(
        context,
        Theme.of(context).colorScheme.surface,
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primary);
  }

  Widget buttonHasNotableEvent(BuildContext context) {
    return templ(
        context,
        Theme.of(context).colorScheme.primaryContainer,
        Theme.of(context).colorScheme.primary,
        Theme.of(context).colorScheme.primary);
  }

  Widget styledButton(BuildContext context, DateButtonStyle style) {
    switch (style) {
      case DateButtonStyle.hasNothing:
        return buttonHasNothing(context);
      case DateButtonStyle.hasTrivialEvent:
        return buttonHasTrivialEvent(context);
      case DateButtonStyle.hasNotableEvent:
        return buttonHasNotableEvent(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ctl.style(),
        builder: (context, snapshot) {
          DateButtonStyle style;
          if (!snapshot.hasData) {
            style = DateButtonStyle.hasNothing;
          } else {
            style = snapshot.data!;
          }
          return styledButton(context, style);
        });
  }
}

/* 
DailyScreen has an infinite horizontal list of TicketContainer widgets, container label and ticket creation button.
DailyScreen implement list-function. It updates label content. It instanciate the button as a floating button.
*/

class DailyScreenController {
  final SchedulingPageController superCtl;
  final ScrollController scroll = ScrollController();
  late final TicketCreationButtonController button;
  late final TicketContainerLabelController label;
  DateTime pivotDate = today();
  DailyScreenController(this.superCtl) {
    label = TicketContainerLabelController(this);
    button = TicketCreationButtonController(this);
  }

  TicketContainerController newTicketContainerController(DateTime date) {
    return TicketContainerController(this, date: date);
  }

  void updateLabel() {
    label.updateLabel();
  }
}

class DailyScreen extends StatelessWidget {
  final DailyScreenController ctl;
  const DailyScreen({super.key, required this.ctl});

  TicketContainer ticketContainer(DateTime forThisDate) {
    ctl.superCtl.predictionController.rendered(forThisDate);
    return TicketContainer(
      ctl: ctl.newTicketContainerController(forThisDate),
    );
  }

  int calcPageIdx(double pixels, BuildContext context) {
    var pageIdx = pixels / TicketContainer.width(context);
    return (pageIdx).round();
  }

  void updateFocusedDateFrom(BuildContext context, ViewportOffset offset) {
    if (offset.hasPixels) {
      ctl.superCtl.focusedDate = DateTime(
          ctl.pivotDate.year,
          ctl.pivotDate.month,
          ctl.pivotDate.day + calcPageIdx(offset.pixels, context));
    }
  }

  Widget ticketContainerList(BuildContext context) {
    // dual-directional infinite horizontally scrollable snapping list
    Key center = UniqueKey(); // this key is to center the list
    SliverList forwardList = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        var date = DateTime(
            ctl.pivotDate.year, ctl.pivotDate.month, ctl.pivotDate.day + index);
        return ticketContainer(date);
      }),
      key: center,
    );

    SliverList reverseList = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        var date = DateTime(ctl.pivotDate.year, ctl.pivotDate.month,
            ctl.pivotDate.day - index - 1);
        return ticketContainer(date);
      }),
    );
    return Scrollable(
      axisDirection: AxisDirection.right,
      controller: ctl.scroll,
      physics:
          MyPageScrollPhysics(pageWidthInPixel: TicketContainer.width(context)),
      viewportBuilder: (context, offset) {
        offset.addListener(() {
          updateFocusedDateFrom(context, offset);
        });
        return Viewport(
          anchor: (1 - TicketContainer.widthFraction(context)) / 2,
          axisDirection: AxisDirection.right,
          offset: offset,
          center: center,
          slivers: [
            reverseList,
            forwardList,
          ],
        );
      },
    );
  }

  // Handles mouse wheel event to scroll the list
  Widget mouseWheelAcceptedTicketContainerList(BuildContext context) {
    const animationDuration = Duration(milliseconds: 300);

    return Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            ctl.scroll.animateTo(
                ctl.scroll.offset +
                    (event.scrollDelta.dy < 0 ? 1 : -1) *
                        TicketContainer.width(context),
                duration: animationDuration,
                curve: Curves.easeInOut);
          }
        },
        child: ticketContainerList(context));
  }

  Widget label() {
    return TextButton(
        onPressed: () {
          ctl.superCtl.switchToMonthlyScreen();
        },
        child: TicketContainerLabel(ctl: ctl.label));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // To use floatingActionButton, it should be wrapped with Scaffold
      body: Column(
        children: [
          label(),
          Expanded(child: mouseWheelAcceptedTicketContainerList(context)),
        ],
      ),
      floatingActionButton: TicketCreationButton(
        ctl: ctl.button,
      ),
    );
  }
}

/*
TicketContainerLabel is a label that shows the date of the focused TicketContainer.

Although TicketContainers are listed horizontally in daily screen, there is only single Label on the top.
So, it should be updated when the shown date is changed. This changing feature is fullfilled by _TicketContainerLabelState.

Additionally, the label performs as a button which navigates to MonthlyScreen.
*/

class TicketContainerLabelController {
  final DailyScreenController superCtl;
  SchedulingPageController get pageCtl => superCtl.superCtl;
  TicketContainerLabelController(this.superCtl);

  void Function()? onLabelUpdateRequired;
  void updateLabel() {
    if (onLabelUpdateRequired != null) {
      onLabelUpdateRequired!();
    }
  }
}

class TicketContainerLabel extends StatefulWidget {
  final TicketContainerLabelController ctl;
  const TicketContainerLabel({super.key, required this.ctl});

  @override
  State<TicketContainerLabel> createState() => _TicketContainerLabelState();
}

class _TicketContainerLabelState extends State<TicketContainerLabel> {
  @override
  void initState() {
    super.initState();
    widget.ctl.onLabelUpdateRequired = () {
      if (!mounted) return;
      // if it is not mounted, there is no need to update the label.
      // because it should be rebuild when it is remounted.
      setState(() {
        // listen to widget.pageController.focusedDate
      });
    };
  }

  String dayToString(int day) {
    if (day == 11) {
      return '11th';
    } else if (day == 12) {
      return '12th';
    } else if (day == 13) {
      return '13th';
    } else if (day % 10 == 1) {
      return '${day}st';
    } else if (day % 10 == 2) {
      return '${day}nd';
    } else if (day % 10 == 3) {
      return '${day}rd';
    }
    return '${day}th';
  }

  String monthToString(int month) {
    switch (month) {
      case 1:
        return 'Jan.';
      case 2:
        return 'Feb.';
      case 3:
        return 'Mar.';
      case 4:
        return 'Apr.';
      case 5:
        return 'May';
      case 6:
        return 'Jun.';
      case 7:
        return 'Jul.';
      case 8:
        return 'Aug.';
      case 9:
        return 'Sep.';
      case 10:
        return 'Oct.';
      case 11:
        return 'Nov.';
      case 12:
        return 'Dec.';
      default:
        return '---.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${widget.ctl.pageCtl.focusedDate.year}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(' ${dayToString(widget.ctl.pageCtl.focusedDate.day)} ',
            style: Theme.of(context).textTheme.headlineLarge),
        Text(monthToString(widget.ctl.pageCtl.focusedDate.month),
            style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

/*
TicketContainer is a container of Tickets. Tickets will be listed vertically in the container.
TicketContainer implements Ticket listing feature.
On daily screen, TicketContainers are listed horizontally.
*/

class TicketContainerController {
  DateTime date;
  final DailyScreenController superCtl;
  TicketContainerController(this.superCtl, {required this.date});

  Future<List<data.Log>> logTickets() {
    return LogHandler().belongsTo(date);
  }

  Future<List<data.DisplayTicket>> displayTickets() {
    return DisplayHandler().belongsTo(date);
  }

  Future<List<data.Schedule>> scheduleTickets() {
    return ScheduleHandler().belongsTo(date);
  }

  Future<List<data.Estimation>> estimationTickets() {
    return EstimationHandler().belongsTo(date);
  }
}

class TicketContainer extends StatelessWidget {
  static const double widthMaximumFraction = 0.9;
  static const double maxWidthInPixel = 400;
  static const double paddingWidthInPixel = 5;
  final TicketContainerController ctl;

  const TicketContainer({super.key, required this.ctl});

  static double width(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return min(maxWidthInPixel, screenWidth * widthMaximumFraction);
  }

  static double widthFraction(BuildContext context) {
    return width(context) / MediaQuery.of(context).size.width;
  }

  // Following methods are separated just to avoid deep nesting.

  Widget frame(BuildContext context, Widget child) {
    var frameBorderSide =
        BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.0);
    return SizedBox(
      width: TicketContainer.width(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: TicketContainer.paddingWidthInPixel),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              top: frameBorderSide,
              left: frameBorderSide,
              right: frameBorderSide,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Future<Widget> listOfTickets(BuildContext context) async {
    await Future.delayed(
        const Duration(milliseconds: 600)); // allow other tasks to run
    List<Future<List<Widget>>> futureBuffer = [];
    // displayTickets
    futureBuffer.add((() async {
      return [
        for (var displayTicket in await ctl.displayTickets())
          DisplayTicket(
              onPressed: () {
                var controller =
                    DisplayTicketConfigSectionController(record: displayTicket);
                showDataEditWindow(
                  context,
                  DisplayTicketConfigSection(sectionController: controller),
                  controller,
                );
              },
              data: displayTicket)
      ];
    })());
    // scheduleTickets
    futureBuffer.add((() async {
      return [
        for (var scheduleTicket in await ctl.scheduleTickets())
          ScheduleTicket(
              onPressed: () {
                var controller = ScheduleTicketConfigSectionController(
                    record: scheduleTicket);
                showDataEditWindow(
                  context,
                  ScheduleTicketConfigSection(sectionController: controller),
                  controller,
                );
              },
              data: scheduleTicket)
      ];
    })());
    // estimationTickets
    futureBuffer.add((() async {
      return [
        for (var estimationTicket in await ctl.estimationTickets())
          EstimationTicket(
              onPressed: () {
                var controller = EstimationTicketConfigSectionController(
                    record: estimationTicket);
                showDataEditWindow(
                  context,
                  EstimationTicketConfigSection(sectionController: controller),
                  controller,
                );
              },
              data: estimationTicket)
      ];
    })());
    // logTickets
    futureBuffer.add((() async {
      return [
        for (var logTicket in await ctl.logTickets())
          LogTicket(
              onPressed: () {
                var controller =
                    LogTicketConfigSectionController(record: logTicket);
                showDataEditWindow(
                  context,
                  LogTicketConfigSection(sectionController: controller),
                  controller,
                );
              },
              data: logTicket)
      ];
    })());
    var results = await Future.wait(futureBuffer);
    return ListView(
      children: [
        for (var res in results) ...res,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: listOfTickets(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return frame(
                context, const Center(child: CircularProgressIndicator()));
          } else {
            return frame(context, snapshot.data!);
          }
        });
  }
}

/* 
TicketCreationButton is a button to create a new ticket.
When it is pressed, it opens the bottom modal sheet which contains configuration sections.
It appears as a floating button on the daily screen.
*/
class TicketCreationButtonController {
  final DailyScreenController superCtl;
  SchedulingPageController get pageCtl => superCtl.superCtl;
  TicketCreationButtonController(this.superCtl);
}

class TicketCreationButton extends StatelessWidget {
  final TicketCreationButtonController ctl;
  const TicketCreationButton({super.key, required this.ctl});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        var controller =
            TicketCreationSectionController(date: ctl.pageCtl.focusedDate);
        var configSection =
            TicketCreationSection(sectionController: controller);
        showDataEditWindow(context, configSection, controller);
      },
      child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
    );
  }
}
