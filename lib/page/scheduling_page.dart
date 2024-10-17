import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:miraibo/data/objects.dart';
import 'package:miraibo/component/ticket_configurator.dart';

import '../component/motion.dart';
import '../component/ticket.dart';
import '../data/handler.dart';

/* 
SchedulingPage has two screens: MonthlyScreen and DailyScreen
The main function of SchedulingPage is to switch between these two screens
*/

enum Screen { monthly, daily }

class SchedulingPage extends StatefulWidget {
  static const Duration screenSwitchingDuration = Duration(milliseconds: 300);
  const SchedulingPage({super.key});

  @override
  State<SchedulingPage> createState() => _SchedulingPageState();
}

class _SchedulingPageState extends State<SchedulingPage> {
  Screen _currentScreen = Screen.monthly;

  void switchToMonthlyScreen() {
    setState(() {
      _currentScreen = Screen.monthly;
    });
  }

  void switchToDailyScreen() {
    setState(() {
      _currentScreen = Screen.daily;
    });
  }

  DateTime _shownDate = DateTime.now();

  void setShownDate(DateTime date) {
    _shownDate = date;
  }

  DateTime getShownDate() {
    return _shownDate;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: SchedulingPage.screenSwitchingDuration,
        child: _currentScreen == Screen.monthly
            ? MonthlyScreen(
                initialShownDate: _shownDate,
                setShownDate: setShownDate,
                switchToDailyScreen: switchToDailyScreen,
              )
            : DailyScreen(
                initialShownDate: _shownDate,
                setShownDate: setShownDate,
                getShownDate: getShownDate,
                switchToMonthlyScreen: switchToMonthlyScreen));
  }
}

/* 
MonthlyScreen has infinite list of MonthlyCalendar widgets
Main function of MonthlyScreen is to show a list of MonthlyCalendar widgets

And MonthlyScreen should notify Monthlycalendars to start making buttons when its scrolling is setteled.
*/
class MonthlyScreen extends StatefulWidget {
  static const Duration buildDelay = Duration(milliseconds: 600);
  static const Duration settleDelay = Duration(milliseconds: 300);
  final DateTime initialShownDate;
  final void Function(DateTime) setShownDate;
  final void Function() switchToDailyScreen;

  const MonthlyScreen({
    super.key,
    required this.initialShownDate,
    required this.setShownDate,
    required this.switchToDailyScreen,
  });

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  // <scroll speed notifier> It notifies Monthlycalendars to start making buttons when its scrolling is setteled.
  final List<GlobalKey<_MonthlyCalendarState>> _monthlycalendarKeys = [];
  bool isSettled = true;
  bool isScrolling = false;

  bool onNotification(Notification notification) {
    if (notification is ScrollUpdateNotification) {
      onStartMoving();
      return false;
    }

    if (notification is ScrollEndNotification) {
      Future(() async {
        isScrolling = false;
        await Future.delayed(MonthlyScreen.settleDelay);
        if (isScrolling) {
          // cancel to issue slowDown-event if it is not settled
          return;
        }
        // settled - MonthlyScreen.settleDelay has passed after the last scroll event
        isSettled = true;
        onSettled();
      });
      return false;
    } else if (notification is ScrollStartNotification) {
      isScrolling = true;
      isSettled = false;
      return false;
    }

    return false;
  }

  void onSettled() {
    for (var key in _monthlycalendarKeys) {
      if (key.currentState?.mounted ?? false) {
        key.currentState?.startMakingButtons();
      }
    }
  }

  void onStartMoving() {
    for (var key in _monthlycalendarKeys) {
      if (key.currentState?.mounted ?? false) {
        key.currentState?.stopMakingButtons();
      }
    }
  }
  // </scroll speed notifier>

  MonthlyCalendar bindedMonthlyCalendar(DateTime forThisDate) {
    var key = GlobalKey<_MonthlyCalendarState>();
    var calendar = MonthlyCalendar(
        forThisDate: forThisDate,
        setShownDate: widget.setShownDate,
        switchToDailyScreen: widget.switchToDailyScreen,
        makeButtonsNow: isSettled,
        key: key);
    _monthlycalendarKeys.add(key);
    return calendar;
  }

  Scrollable calendarList(BuildContext context) {
    // dual-directional infinite vertically scrollable list
    Key center = UniqueKey(); // this key is to center the list
    SliverList forwardList = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        var date = DateTime(widget.initialShownDate.year,
            widget.initialShownDate.month + index, 1);
        return bindedMonthlyCalendar(date);
      }),
      key: center,
    );

    SliverList reverseList = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        var date = DateTime(widget.initialShownDate.year,
            widget.initialShownDate.month - index - 1, 1);
        return bindedMonthlyCalendar(date);
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
    /*
    not to interrupt page transition, wrap it with FutureBuilder
    because rendering MonthlyCalendar widgets is time-consuming 
    */
    // TODO: make it more efficient
    return FutureBuilder(
        future: Future.delayed(MonthlyScreen.buildDelay),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // notify based on scroll speed
            return NotificationListener(
              onNotification: onNotification,
              child: calendarList(context),
            );
          }
        });
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

class MonthlyCalendar extends StatefulWidget {
  final DateTime forThisDate;
  final void Function(DateTime) setShownDate;
  final void Function() switchToDailyScreen;
  final bool makeButtonsNow;

  const MonthlyCalendar(
      {super.key,
      required this.forThisDate,
      required this.setShownDate,
      required this.switchToDailyScreen,
      required this.makeButtonsNow});

  @override
  State<MonthlyCalendar> createState() => _MonthlyCalendarState();
}

class _MonthlyCalendarState extends State<MonthlyCalendar> {
  @override
  void initState() {
    super.initState();
    shouldMakeButtons = widget.makeButtonsNow;
  }

  // <button making control> It is used to control the building of buttons.
  late bool shouldMakeButtons;
  bool buttonsAreDrawn = false;
  void startMakingButtons() {
    if (shouldMakeButtons || buttonsAreDrawn) {
      return;
    }
    setState(() {
      shouldMakeButtons = true;
    });
  }

  void stopMakingButtons() {
    // if buttons are already drawn, it does not cause building buttons again.
    if (!shouldMakeButtons || buttonsAreDrawn) {
      return;
    }
    setState(() {
      shouldMakeButtons = false;
    });
  }
  // </button making control>

  // <values> value caluculations
  int? _numberOfRows;
  int get numberOfRows {
    const int daysInWeek = 7;
    _numberOfRows ??= ((daysInMonth + indexDateMapOffset) / daysInWeek).ceil();
    return _numberOfRows!;
  }

  int get indexDateMapOffset {
    return widget.forThisDate.weekday - 1;
  }

  int? _daysInMonth;
  int get daysInMonth {
    _daysInMonth ??=
        DateTime(widget.forThisDate.year, widget.forThisDate.month + 1, 0).day;
    return _daysInMonth!;
  }

  double calendarWidthFor(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    const double maxWidth = 350;
    return min(maxWidth, screenWidth);
  }

  int? calcDayFrom(int index) {
    if (index < indexDateMapOffset) {
      return null;
    }
    if (index - indexDateMapOffset >= daysInMonth) {
      return null;
    }
    return index - indexDateMapOffset + 1;
  }

  // </values>

  // <makeDateButtons> Fetching data is needed to calclating styles for DateButtons; it is done in a separate thread.

  Future<List<DateButton>> makeDateButtons() async {
    List<DateButton> result = [];
    for (int i = 0; i < daysInMonth; i++) {
      await Future.delayed(
          Duration(milliseconds: 30)); // allow other tasks to run
      result.add(await DateButton.make(
          DateTime(widget.forThisDate.year, widget.forThisDate.month, i + 1),
          widget.setShownDate,
          widget.switchToDailyScreen));
    }
    return result;
  }
  // </makeDateButtons>

  // <Components> They are separated just to avoid deep nesting.
  SizedBox labelBox(BuildContext context) {
    return SizedBox(
      width: calendarWidthFor(context),
      child: Text(
        '${widget.forThisDate.year} - ${widget.forThisDate.month}',
        style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 38), //Theme.of(context).textTheme.headlineLarge
      ),
    );
  }

  Container sizedContainer(BuildContext context, Widget child) {
    return Container(
      height: calendarWidthFor(context) * (numberOfRows / 7),
      width: calendarWidthFor(context),
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  Container loadingIndicator(BuildContext context) {
    return sizedContainer(
        context, const Center(child: CircularProgressIndicator()));
  }

  Container arrengedButtons(BuildContext context, List<DateButton> buttons) {
    return sizedContainer(
      context,
      GridView.builder(
        itemCount: numberOfRows * 7,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1, // square cells
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          var day = calcDayFrom(index);
          if (day == null) {
            return const Text('');
          } else {
            return buttons[day - 1];
          }
        },
      ),
    );
  }

  Container errorMessage(BuildContext context, {String? message}) {
    return sizedContainer(context, Text('somethingWentWrong:: $message'));
  }
  // </Components>

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        labelBox(context),
        shouldMakeButtons
            ? FutureBuilder(
                future: makeDateButtons(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<DateButton>> snapshot) {
                  Widget completed;
                  if (snapshot.connectionState != ConnectionState.done) {
                    return loadingIndicator(context);
                  } else if (snapshot.hasData) {
                    completed = arrengedButtons(context, snapshot.data!);
                  } else {
                    completed = errorMessage(context,
                        message: snapshot.error?.toString());
                  }
                  buttonsAreDrawn = true;
                  return completed;
                },
              )
            : loadingIndicator(context),
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

enum DateButtonStyle {
  hasNothing,
  hasPeriodicEvent,
  hasSpecialEvent,
}

class DateButton extends StatelessWidget {
  final DateTime date;
  final void Function(DateTime) setShownDate;
  final void Function() switchToDailyScreen;
  final DateButtonStyle style;

  static Future<DateButton> make(DateTime date,
      void Function(DateTime) setShownDate, void Function() switchToDailyScreen,
      {Key? key}) async {
    return DateButton(
        date: date,
        setShownDate: setShownDate,
        switchToDailyScreen: switchToDailyScreen,
        style: await TicketDataManager().calcStyleForDateButton(date));
  }

  const DateButton({
    super.key,
    required this.date,
    required this.setShownDate,
    required this.switchToDailyScreen,
    required this.style,
  });

  TextButton button(BuildContext context, Color backgroundColor,
      Color borderColor, Color textColor) {
    return TextButton(
        onPressed: () {
          setShownDate(date);
          switchToDailyScreen();
        },
        style: TextButton.styleFrom(
            backgroundColor: backgroundColor,
            side: BorderSide(
              width: 1.0,
              color: borderColor,
            )),
        child: Text(
          '${date.day}',
          style: TextStyle(color: textColor),
        ));
  }

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case DateButtonStyle.hasNothing:
        return button(context, Theme.of(context).colorScheme.surface,
            Theme.of(context).disabledColor, Theme.of(context).disabledColor);
      case DateButtonStyle.hasPeriodicEvent:
        return button(
            context,
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary);
      case DateButtonStyle.hasSpecialEvent:
        return button(
            context,
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary);
    }
  }
}

/* 
DailyScreen has an infinite horizontal list of TicketContainer widgets, container label and ticket creation button.
DailyScreen implement list-function. It updates label content. It instanciate the button as a floating button.
*/

class DailyScreen extends StatefulWidget {
  final DateTime initialShownDate;
  final void Function(DateTime) setShownDate;
  final DateTime Function() getShownDate;
  final void Function() switchToMonthlyScreen;

  const DailyScreen(
      {super.key,
      required this.initialShownDate,
      required this.setShownDate,
      required this.getShownDate,
      required this.switchToMonthlyScreen});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  // to update label content along with changing of shown date
  final GlobalKey<_TicketContainerLabelState> _labelKey =
      GlobalKey<_TicketContainerLabelState>();

  // Following methods are separated just to avoid deep nesting.
  TicketContainer bindedTicketContainer(DateTime forThisDate) {
    return TicketContainer(forThisDate: forThisDate);
  }

  int calcPageIdx(double pixels, BuildContext context) {
    var pageIdx = pixels / TicketContainer.width(context);
    return (pageIdx).round();
  }

  void updateShownDateFrom(BuildContext context, ViewportOffset offset) {
    if (offset.hasPixels) {
      widget.setShownDate(DateTime(
          widget.initialShownDate.year,
          widget.initialShownDate.month,
          widget.initialShownDate.day + calcPageIdx(offset.pixels, context)));
      _labelKey.currentState?.update(widget.getShownDate());
    }
  }

  Widget ticketContainerList(
      BuildContext context, ScrollController scrollController) {
    // dual-directional infinite horizontally scrollable snapping list
    Key center = UniqueKey(); // this key is to center the list
    SliverList forwardList = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        var date = DateTime(widget.initialShownDate.year,
            widget.initialShownDate.month, widget.initialShownDate.day + index);
        return bindedTicketContainer(date);
      }),
      key: center,
    );

    SliverList reverseList = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        var date = DateTime(
            widget.initialShownDate.year,
            widget.initialShownDate.month,
            widget.initialShownDate.day - index - 1);
        return bindedTicketContainer(date);
      }),
    );
    return Scrollable(
      axisDirection: AxisDirection.right,
      controller: scrollController,
      physics:
          MyPageScrollPhysics(pageWidthInPixel: TicketContainer.width(context)),
      viewportBuilder: (context, offset) {
        offset.addListener(() {
          updateShownDateFrom(context, offset);
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
    ScrollController scrollController = ScrollController();

    return Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            scrollController.animateTo(
                scrollController.offset +
                    (event.scrollDelta.dy < 0 ? 1 : -1) *
                        TicketContainer.width(context),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
          }
        },
        child: ticketContainerList(context, scrollController));
  }

  Widget label() {
    return TicketContainerLabel(
        key: _labelKey,
        initDate: widget.getShownDate(),
        toSwitchMonthlyScreen: widget.switchToMonthlyScreen);
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
        getShownDate: widget.getShownDate,
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

class TicketContainerLabel extends StatefulWidget {
  final DateTime initDate;
  final void Function() toSwitchMonthlyScreen;
  const TicketContainerLabel(
      {super.key, required this.initDate, required this.toSwitchMonthlyScreen});

  @override
  State<TicketContainerLabel> createState() => _TicketContainerLabelState();
}

class _TicketContainerLabelState extends State<TicketContainerLabel> {
  late DateTime date;

  void update(DateTime date) {
    setState(() {
      this.date = date;
    });
  }

  @override
  void initState() {
    super.initState();
    date = widget.initDate;
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
    return TextButton(
        onPressed: () {
          widget.toSwitchMonthlyScreen();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.year}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(' ${dayToString(date.day)} ',
                style: Theme.of(context).textTheme.headlineLarge),
            Text(monthToString(date.month),
                style: Theme.of(context).textTheme.headlineSmall),
          ],
        ));
  }
}

/*
TicketContainer is a container of Tickets. Tickets will be listed vertically in the container.
TicketContainer implements Ticket listing feature.
On daily screen, TicketContainers are listed horizontally.
*/
class TicketContainer extends StatelessWidget {
  static const double widthMaximumFraction = 0.9;
  static const double maxWidthInPixel = 400;
  static const double paddingWidthInPixel = 5;
  final DateTime forThisDate;

  const TicketContainer({super.key, required this.forThisDate});

  static double width(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return min(maxWidthInPixel, screenWidth * widthMaximumFraction);
  }

  static double widthFraction(BuildContext context) {
    return width(context) / MediaQuery.of(context).size.width;
  }

  // Following methods are separated just to avoid deep nesting.

  Widget box(BuildContext context, Widget child) {
    var boxBorderSide =
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
              top: boxBorderSide,
              left: boxBorderSide,
              right: boxBorderSide,
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
    return ListView(
      children: [
        for (var ticketConfig
            in await TicketDataManager().fetchTicketConfigsFor(forThisDate))
          switch (ticketConfig) {
            DisplayTicketConfigData() => DisplayTicket(
                onPressed: () {
                  var controller = DataEditWindowController();
                  showDataEditWindow(
                      controller,
                      context,
                      DisplayTicketConfigSection(
                          controller: controller,
                          initialConfigData: ticketConfig));
                },
                data: ticketConfig),
            ScheduleTicketConfigData() => ScheduleTicket(
                onPressed: () {
                  var controller = DataEditWindowController();
                  showDataEditWindow(
                      controller,
                      context,
                      ScheduleTicketConfigSection(
                          controller: controller,
                          initialConfigData: ticketConfig));
                },
                data: ticketConfig),
            EstimationTicketConfigData() => EstimationTicket(
                onPressed: () {
                  var controller = DataEditWindowController();
                  showDataEditWindow(
                      controller,
                      context,
                      EstimationTicketConfigSection(
                          controller: controller,
                          initialConfigData: ticketConfig));
                },
                data: ticketConfig),
            LogTicketConfigData() => LogTicket(
                onPressed: () {
                  var controller = DataEditWindowController();
                  showDataEditWindow(
                      controller,
                      context,
                      LogTicketConfiguraitonSection(
                          controller: controller,
                          initialConfigData: ticketConfig));
                },
                data: ticketConfig),
            // lines below should not be reached
            _ => TicketTemplate(
                onPressed: () {},
                ticketKind: 'unknown',
                topLabel: [],
                content: [Text('broken ticket config was found')],
                bottomLabel: [])
          }
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: listOfTickets(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return box(
                context, const Center(child: CircularProgressIndicator()));
          } else {
            return box(context, snapshot.data!);
          }
        });
  }
}

/* 
TicketCreationButton is a button to create a new ticket.
When it is pressed, it opens the bottom modal sheet which contains configuration sections.
It appears as a floating button on the daily screen.
*/
class TicketCreationButton extends StatelessWidget {
  final DateTime Function() getShownDate;
  const TicketCreationButton({super.key, required this.getShownDate});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        var controller = DataEditWindowController();
        var configSection = TicketCreationSection(
            controller: controller, initialDate: getShownDate());
        showDataEditWindow(controller, context, configSection);
      },
      child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
    );
  }
}
