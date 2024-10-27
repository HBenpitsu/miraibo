import 'dart:math';

import 'package:flutter/material.dart';
import 'package:miraibo/component/category.dart';
import 'package:miraibo/component/configurator_component.dart';
import 'package:miraibo/data/handler.dart';
import '../data/ticket_data.dart';
import '../data/general_enum.dart';
import 'general_widget.dart';

// <data edit modal window> a container of a configuration section
/* 
DataEditWindow is a modal bottom sheet that contains a configuration section.
Itself has save and delete buttons, and the configuration section is placed in the window.
To convey save-event and delete-event to the configuration section, it has a controller.
*/
class DataEditWindowController {
  void Function()? _saveHandler;
  void Function()? _deleteHandler;

  void save() {
    if (_saveHandler != null) {
      _saveHandler!();
    }
  }

  void delete() {
    if (_deleteHandler != null) {
      _deleteHandler!();
    }
  }

  void onSaved(void Function() saveHandler) {
    _saveHandler = saveHandler;
  }

  void onDeleted(void Function() deleteHandler) {
    _deleteHandler = deleteHandler;
  }
}

const double dataEditWindowHeightFraction = 0.8;

/// [configurationSection] should have the same [controller] as the [controller] passed to this function to convey save,delete-event.
void showDataEditWindow(DataEditWindowController controller,
    BuildContext context, Widget configurationSection) {
  showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SizedBox(
          height:
              MediaQuery.of(context).size.height * dataEditWindowHeightFraction,
          child: Column(
            children: [
              Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          controller.save();
                        },
                        icon: const Icon(Icons.save),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.delete();
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  )),
              Expanded(child: configurationSection),
            ],
          ),
        );
      });
}
// </data edit modal window>

// all configurationSections are intended to be passed to showDataEditWindow

// <shared traits> for display, schedule, estimation, log ticket configurators
/*
basicConfigSection has controllers to receive save,delete-event.
And its initial content is defined by initialConfigData.
*/
abstract class BasicConfigSectionWidget extends StatefulWidget {
  final DataEditWindowController controller;
  abstract final TicketConfigRecord initialConfigData;

  const BasicConfigSectionWidget({super.key, required this.controller});
}

/* 
shered behaviors and codes for display, schedule, estimation, log ticket configurators are extracted into this mixin.
Basic configurators include display, schedule, estimation, and log ticket configuration sections, which extend BasicConfigSectionWidget.
These basic configurators are directly related to each Ticket type.

The primary responsibility of a basic config section is to convert configData (into String then) into Widgets.
It should also detect modifications to the data before saving it.
To achieve this, they typically have controllers for each sub-module and fetch data from these controllers just before saving.
Some may register listeners to the controllers to detect modifications, as there is no controller that fulfills requirements.

The spacer is used exclusively to make the form scrollable. If the content is near the bottom of the screen, it can be difficult to see or interact with.
*/
/// [initSubModuleControllers], [onSaved], [contentColumn] should be implemented in the subclass
mixin ConfigSectionState<T extends BasicConfigSectionWidget> on State<T> {
  /// Titled, Padded part of the form. Expand return value (by `...ret`) and make them children of a Column to conbine multiple sectors.
  List<Widget> sector(BuildContext context, String title, Widget child) {
    return [
      Padding(
          padding: const EdgeInsets.only(top: 10),
          child:
              Text(title, style: Theme.of(context).textTheme.headlineMedium)),
      Padding(padding: const EdgeInsets.only(top: 10, bottom: 10), child: child)
    ];
  }

  /// spacer to allow the form to be scrolled
  Widget spacer(BuildContext context) {
    return SizedBox(
      height:
          MediaQuery.of(context).size.height * dataEditWindowHeightFraction / 2,
    );
  }

  void initSubModuleControllers();

  // <bind listeners>
  void bindWindowControllerListeners() {
    widget.controller.onSaved(onSaved);
    widget.controller.onDeleted(onDeleted);
  }

  void onSaved();
  void onDeleted() {
    if (widget.initialConfigData.id == null) {
      // if the configuration is not saved yet, just close the window
      Navigator.of(context).pop();
      return;
    }
    // otherwise, show a dialog to confirm the deletion
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('CAUTION!'),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'This action is irreversible.',
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text('Are you sure you want to delete this ticket?',
                      textAlign: TextAlign.start),
                ]),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    widget.initialConfigData.delete();
                    // close the modal bottom sheet at the same time
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete')),
            ],
          );
        });
  }
  // </bind listeners>

  @override
  void initState() {
    super.initState();
    initSubModuleControllers();
    bindWindowControllerListeners();
  }

  List<Widget> contentColumn(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: SingleChildScrollView(
            child: Column(
      children: contentColumn(context),
    )));
  }
}
// </shared traits>

// <basic configurators>

/* <display ticket configurator>

Display Ticket Configurator requires:

- Target Categories
- Term Mode

for all cases.

The other fields are optional and depend on the term mode.
For more details, such as the options for each field, see the component-structure.md or abstruction.md or implementation.
*/
class DisplayTicketConfigSection extends BasicConfigSectionWidget {
  @override
  final DisplayTicketRecord initialConfigData;
  final double? width;

  const DisplayTicketConfigSection({
    super.key,
    required super.controller,
    this.initialConfigData = const DisplayTicketRecord(),
    this.width,
  });

  @override
  State<DisplayTicketConfigSection> createState() =>
      _DisplayTicketConfigSectionState();
}

class _DisplayTicketConfigSectionState extends State<DisplayTicketConfigSection>
    with ConfigSectionState {
  late MultipleCategorySelectorController categorySelectorCtl;
  late DatePickButtonController datePickerCtl;
  late DisplayTicketContentType contentType;
  late DisplayTicketTermMode termMode;
  late DisplayTicketPeriod period;

  @override
  void initSubModuleControllers() {
    categorySelectorCtl = MultipleCategorySelectorController(
      allCategoriesInitiallySelected:
          widget.initialConfigData.targetingAllCategories,
      initiallySelectedCategories: widget.initialConfigData.targetCategories,
    );
    datePickerCtl = DatePickButtonController(
      initialDate: widget.initialConfigData.designatedDate ?? DateTime.now(),
    );
    contentType = widget.initialConfigData.contentType;
    termMode = widget.initialConfigData.termMode;
    period = widget.initialConfigData.designatedPeriod;
  }

  @override
  void onSaved() {
    if (!categorySelectorCtl.isInitialized) {
      // if user tries to save the configuration too early, show a dialog to alert the user
      showErrorDialog(context,
          'Category selector is not prepared yet. Please wait until it is loaded.');
      return;
    }
    if (categorySelectorCtl.allCategoriesSelected &&
        categorySelectorCtl.selectedCategories.isEmpty) {
      showErrorDialog(
          context, 'Category unselected. Please select at least one category.');
      return;
    }
    var configData = DisplayTicketRecord(
      targetCategories: categorySelectorCtl.selectedCategories,
      targetingAllCategories: categorySelectorCtl.allCategoriesSelected,
      termMode: termMode,
      designatedDate: datePickerCtl.selected,
      designatedPeriod: period,
      contentType: contentType,
    );
    configData.save();
    Navigator.of(context).pop();
  }

  // <components> just to avoid deep nesting

  List<Widget> periodSelector(BuildContext context) {
    return sector(
        context,
        'Period',
        // there is no controller which returns the value of the selected item as 'DisplayTicketPeriod'
        DropdownMenu<DisplayTicketPeriod>(
          initialSelection: period,
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: DisplayTicketPeriod.week, label: 'week'),
            DropdownMenuEntry(value: DisplayTicketPeriod.month, label: 'month'),
            DropdownMenuEntry(
                value: DisplayTicketPeriod.halfYear, label: 'half year'),
            DropdownMenuEntry(value: DisplayTicketPeriod.year, label: 'year'),
          ],
          onSelected: (value) {
            if (value != null) {
              period = value;
            }
          },
        ));
  }

  List<Widget> dateSelectionCalenderForm(BuildContext context) {
    return sector(context, 'Until', DatePickButton(controller: datePickerCtl));
  }

  List<Widget> contentTypeSelector(BuildContext context, {bool fixed = false}) {
    if (fixed) {
      // for fixed situation, only summation is available
      contentType = DisplayTicketContentType.summation;
      return sector(
          context,
          'Content Type',
          DropdownMenu<DisplayTicketContentType>(
            initialSelection: contentType,
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                  value: DisplayTicketContentType.summation,
                  label: 'summation'),
            ],
          ));
    } else {
      return sector(
          context,
          'Content Type',
          // there is no controller which returns the value of the selected item as 'DisplayTicketContentTypes'
          DropdownMenu<DisplayTicketContentType>(
            initialSelection: contentType,
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                  value: DisplayTicketContentType.dailyAverage,
                  label: 'daily average'),
              DropdownMenuEntry(
                  value: DisplayTicketContentType.dailyQuartileAverage,
                  label: 'daily quartile average'),
              DropdownMenuEntry(
                  value: DisplayTicketContentType.monthlyAverage,
                  label: 'monthly average'),
              DropdownMenuEntry(
                  value: DisplayTicketContentType.monthlyQuartileAverage,
                  label: 'monthly quartile average'),
              DropdownMenuEntry(
                  value: DisplayTicketContentType.summation,
                  label: 'summation'),
            ],
            onSelected: (value) {
              if (value != null) {
                contentType = value;
              }
            },
          ));
    }
  }

  List<Widget> termModeSelector(BuildContext context) {
    return sector(
        context,
        'Term-mode',
        // there is no controller which returns the value of the selected item as 'DisplayTicketTermMode'
        DropdownMenu<DisplayTicketTermMode>(
          initialSelection: termMode,
          dropdownMenuEntries: const [
            DropdownMenuEntry(
                value: DisplayTicketTermMode.untilToday, label: 'until today'),
            DropdownMenuEntry(
                value: DisplayTicketTermMode.untilDesignatedDate,
                label: 'until designated date'),
            DropdownMenuEntry(
                value: DisplayTicketTermMode.lastDesignatedPeriod,
                label: 'last designated period'),
          ],
          onSelected: (value) {
            if (value != null) {
              setState(() {
                termMode = value;
              });
            }
          },
        ));
  }

  List<Widget> targetCategories(BuildContext context) {
    var categorySelectorWidth =
        widget.width ?? min(250.0, MediaQuery.of(context).size.width * 0.8);
    return sector(
        context,
        'Target Categories',
        MultipleCategorySelector(
            controller: categorySelectorCtl, width: categorySelectorWidth));
  }

  // </components>

  @override
  List<Widget> contentColumn(BuildContext context) {
    return [
      ...targetCategories(context),
      ...termModeSelector(context),
      // Term mode dependencies
      ...switch (termMode) {
        DisplayTicketTermMode.untilDesignatedDate => [
            ...dateSelectionCalenderForm(context),
            ...contentTypeSelector(context, fixed: true),
          ],
        DisplayTicketTermMode.lastDesignatedPeriod => [
            ...periodSelector(context),
            ...contentTypeSelector(context),
          ],
        DisplayTicketTermMode.untilToday => [...contentTypeSelector(context)],
      },
      spacer(context),
    ];
  }
}
// </display ticket configurator>

/*  <schedule ticket configurator>
Schedule Ticket Configurator requires:

- Category
- Supplement
- Registration Date
- Amount
- Repeat Setting
(Some are optional)

This is similar to Log Ticket Configurator, but it has a complex repeat setting. and do not have pictureSelector.
This is because schedule ticket exists to generate log tickets automatically.

Repeat setting is extracted into a separated Widget because of its complexity.

For more details, such as the options for each field, see the component-structure.md or abstruction.md or implementation.
*/
class ScheduleTicketConfigSection extends BasicConfigSectionWidget {
  @override
  final ScheduleRecord initialConfigData;
  const ScheduleTicketConfigSection({
    super.key,
    required super.controller,
    this.initialConfigData = const ScheduleRecord(),
  });

  @override
  State<ScheduleTicketConfigSection> createState() =>
      _ScheduleTicketConfiguraitonSectionState();
}

class _ScheduleTicketConfiguraitonSectionState
    extends State<ScheduleTicketConfigSection> with ConfigSectionState {
  late SingleCategorySelectorController categorySelectorCtl;
  late TextEditingController supplementCtl;
  late MoneyformController moneyFormCtl;
  late DatePickButtonController registorationDateCtl;
  late ScheduleTicketRepeatSettingSectorController repeatSettingCtl;

  @override
  void initSubModuleControllers() {
    categorySelectorCtl = SingleCategorySelectorController(
      initiallySelectedCategory: widget.initialConfigData.category,
    );
    supplementCtl =
        TextEditingController(text: widget.initialConfigData.supplement);
    moneyFormCtl = MoneyformController(amount: widget.initialConfigData.amount);
    registorationDateCtl = DatePickButtonController(
      initialDate: widget.initialConfigData.originDate ?? DateTime.now(),
    );
    repeatSettingCtl = ScheduleTicketRepeatSettingSectorController(
      initialRepeatType: widget.initialConfigData.repeatType,
      initialRepeatInterval: widget.initialConfigData.repeatInterval,
      initialRepeatDayOfWeek: widget.initialConfigData.repeatDayOfWeek,
      initialMonthlyRepeatType: widget.initialConfigData.monthlyRepeatType,
      initialStartDate: widget.initialConfigData.startDate,
      initialEndDate: widget.initialConfigData.endDate,
    );
  }

  @override
  void onSaved() {
    if (!categorySelectorCtl.isInitialized) {
      showErrorDialog(context,
          'Category selector is not prepared yet. Please wait until it is loaded.');
      return;
    }
    if (categorySelectorCtl.selected == null) {
      showErrorDialog(
          context, 'Category unselected. Please select a category.');
      return;
    }
    var configData = ScheduleRecord(
      category: categorySelectorCtl.selected!,
      supplement: supplementCtl.text,
      originDate: registorationDateCtl.selected,
      amount: moneyFormCtl.amount,
      repeatType: repeatSettingCtl.repeatType,
      repeatInterval: repeatSettingCtl.repeatInterval,
      repeatDayOfWeek: repeatSettingCtl.repeatDayOfWeek,
      monthlyRepeatType: repeatSettingCtl.monthlyRepeatType,
      monthlyRepeatOffset: registorationDateCtl.selected == null
          ? 0
          : repeatSettingCtl
              .monthlyRepeatOffset(registorationDateCtl.selected!),
      startDate: repeatSettingCtl.startDate,
      endDate: repeatSettingCtl.endDate,
    );
    configData.save();
    Navigator.of(context).pop();
  }

  // <components> just to avoid deep nesting

  List<Widget> categorySelector(BuildContext context) {
    return sector(
      context,
      'category',
      SingleCategorySelector(controller: categorySelectorCtl),
    );
  }

  List<Widget> supplementationForm(BuildContext context) {
    var width = min(300.0, MediaQuery.of(context).size.width * 0.8);
    return sector(
      context,
      'supplement',
      SizedBox(
        width: width,
        child: TextField(
          controller: supplementCtl,
        ),
      ),
    );
  }

  List<Widget> registorationDateForm(BuildContext context) {
    return sector(
      context,
      'date',
      DatePickButton(controller: registorationDateCtl),
    );
  }

  List<Widget> amountForm(BuildContext context) {
    return sector(
      context,
      'amount',
      Moneyform(controller: moneyFormCtl),
    );
  }

  List<Widget> repeatSettingForm(BuildContext context) {
    return sector(
      context,
      'repeat',
      ScheduleTicketRepeatSettingSector(controller: repeatSettingCtl),
    );
  }

  // </components>

  @override
  List<Widget> contentColumn(BuildContext context) {
    return [
      ...categorySelector(context),
      ...supplementationForm(context),
      ...registorationDateForm(context),
      ...amountForm(context),
      ...repeatSettingForm(context),
      spacer(context),
    ];
  }
}

/* 
Repeat Setting is separated from Schedule Ticket Configurator because of its complexity.
It has a lot of options and it change actions based on the selected options.
This is because necessary information is different between each repeat type.
*/
class ScheduleTicketRepeatSettingSectorController {
  RepeatType _repeatType;
  RepeatType get repeatType => _repeatType;
  set repeatType(RepeatType value) {
    _repeatType = value;
    _onChanged();
  }

  Duration _repeatInterval;
  Duration get repeatInterval => _repeatInterval;
  set repeatInterval(Duration value) {
    _repeatInterval = value;
    _onChanged();
  }

  final List<DayOfWeek> _repeatDayOfWeek;
  List<DayOfWeek> get repeatDayOfWeek => _repeatDayOfWeek;
  bool dayOfWeekSelected(DayOfWeek day) => _repeatDayOfWeek.contains(day);
  void turnOnDayOfWeek(DayOfWeek day) {
    if (!_repeatDayOfWeek.contains(day)) {
      _repeatDayOfWeek.add(day);
      _onChanged();
    }
  }

  void turnOffDayOfWeek(DayOfWeek day) {
    if (_repeatDayOfWeek.contains(day)) {
      _repeatDayOfWeek.remove(day);
      _onChanged();
    }
  }

  void toggleDayOfWeek(DayOfWeek day) {
    if (_repeatDayOfWeek.contains(day)) {
      _repeatDayOfWeek.remove(day);
    } else {
      _repeatDayOfWeek.add(day);
    }
    _onChanged();
  }

  MonthlyRepeatType _monthlyRepeatType;
  MonthlyRepeatType get monthlyRepeatType => _monthlyRepeatType;
  set monthlyRepeatType(MonthlyRepeatType value) {
    _monthlyRepeatType = value;
    _onChanged();
  }

  DateTime? _startDate;
  DateTime? get startDate => _startDate;
  set startDate(DateTime? value) {
    _startDate = value;
    _onChanged();
  }

  void setStartDate() {
    _startDate = null;
    _onChanged();
  }

  DateTime? _endDate;
  DateTime? get endDate => _endDate;
  set endDate(DateTime? value) {
    _endDate = value;
    _onChanged();
  }

  void setEndDate() {
    _endDate = null;
    _onChanged();
  }

  int monthlyRepeatOffset(DateTime date) {
    switch (_monthlyRepeatType) {
      case MonthlyRepeatType.fromHead:
        return date.day - 1;
      case MonthlyRepeatType.fromTail:
        var lastDayInMonth = DateTime(date.year, date.month + 1, 0);
        return lastDayInMonth.day - date.day;
    }
  }

  void Function()? onChanged;
  void _onChanged() {
    if (onChanged != null) {
      onChanged!();
    }
  }

  ScheduleTicketRepeatSettingSectorController({
    RepeatType initialRepeatType = RepeatType.no,
    Duration initialRepeatInterval = const Duration(days: 1),
    List<DayOfWeek> initialRepeatDayOfWeek = const [],
    MonthlyRepeatType initialMonthlyRepeatType = MonthlyRepeatType.fromHead,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    this.onChanged,
  })  : _repeatType = initialRepeatType,
        _repeatInterval = initialRepeatInterval,
        _repeatDayOfWeek = List.from(initialRepeatDayOfWeek),
        _monthlyRepeatType = initialMonthlyRepeatType,
        _startDate = initialStartDate,
        _endDate = initialEndDate;
}

class ScheduleTicketRepeatSettingSector extends StatefulWidget {
  final ScheduleTicketRepeatSettingSectorController controller;
  final double? width;

  const ScheduleTicketRepeatSettingSector(
      {super.key, required this.controller, this.width});

  @override
  State<ScheduleTicketRepeatSettingSector> createState() =>
      _ScheduleTicketRepeatSettingSectorState();
}

class _ScheduleTicketRepeatSettingSectorState
    extends State<ScheduleTicketRepeatSettingSector> {
  late TextEditingController intervalCtl;
  late UnlimitedPeriodSelectorController periodCtl;

  @override
  void initState() {
    super.initState();
    intervalCtl = TextEditingController(
        text: widget.controller.repeatInterval.inDays.toString());
    periodCtl = UnlimitedPeriodSelectorController(
      start: widget.controller.startDate,
      end: widget.controller.endDate,
    );
    periodCtl.onPeriodChanged = () {
      widget.controller.startDate = periodCtl.start;
      widget.controller.endDate = periodCtl.end;
    };
  }

  // <components> just to avoid deep nesting

  Widget repeatTypeSelector(BuildContext context) {
    return DropdownMenu<RepeatType>(
      initialSelection: widget.controller.repeatType,
      dropdownMenuEntries: const [
        DropdownMenuEntry(value: RepeatType.no, label: 'no repeat'),
        DropdownMenuEntry(value: RepeatType.interval, label: 'repeat in days'),
        DropdownMenuEntry(value: RepeatType.weekly, label: 'weekly'),
        DropdownMenuEntry(value: RepeatType.monthly, label: 'monthly'),
        DropdownMenuEntry(value: RepeatType.anually, label: 'anually'),
      ],
      onSelected: (value) {
        if (value != null) {
          setState(() {
            widget.controller.repeatType = value;
          });
        }
      },
    );
  }

  Widget repeatIntervalSelector(BuildContext context) {
    return Row(children: [
      const Spacer(),
      const Text('Repeat in every '),
      SizedBox(
          width: 50,
          child: TextField(
            controller: intervalCtl,
            keyboardType: TextInputType.number,
            onTap: () {
              intervalCtl.selection = TextSelection(
                  baseOffset: 0, extentOffset: intervalCtl.text.length);
            },
            onChanged: (value) {
              var days = int.tryParse(value) ?? 1;
              if (days < 1) {
                days = 1;
              }
              widget.controller.repeatInterval = Duration(days: days);
              intervalCtl.text = days.toString();
            },
          )),
      const Text(' days.'),
      const Spacer(),
    ]);
  }

  String dayOfWeekLabel(DayOfWeek day) {
    switch (day) {
      case DayOfWeek.sunday:
        return 'Sun';
      case DayOfWeek.monday:
        return 'Mon';
      case DayOfWeek.tuesday:
        return 'Tue';
      case DayOfWeek.wednesday:
        return 'Wed';
      case DayOfWeek.thursday:
        return 'Thu';
      case DayOfWeek.friday:
        return 'Fri';
      case DayOfWeek.saturday:
        return 'Sat';
    }
  }

  Widget weekDayIconButton(BuildContext context, DayOfWeek day) {
    return IconButton(
        onPressed: () {
          setState(() {
            widget.controller.toggleDayOfWeek(day);
          });
        },
        style: IconButton.styleFrom(
            side: BorderSide(
          width: 1.0,
          color: widget.controller.dayOfWeekSelected(day)
              ? Theme.of(context).primaryColor
              : Theme.of(context).disabledColor,
        )),
        icon: SizedBox(
            width: 30,
            child: Center(
                child: Text(dayOfWeekLabel(day),
                    style: TextStyle(
                        color: widget.controller.dayOfWeekSelected(day)
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor)))));
  }

  Widget weekDaySelector(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Wrap(
          children: [
            ...DayOfWeek.values.map((day) {
              return Padding(
                  padding: const EdgeInsets.all(2),
                  child: weekDayIconButton(context, day));
            }),
          ],
        ));
  }

  Widget radioTile(
      BuildContext context, String title, MonthlyRepeatType value) {
    const double listTileWidth = 300.0;
    return SizedBox(
        width: listTileWidth,
        child: InkWell(
            onTap: () {
              setState(() {
                widget.controller.monthlyRepeatType = value;
              });
            },
            child: ListTile(
              title: Text(title),
              leading: Radio(
                value: value,
                groupValue: widget.controller.monthlyRepeatType,
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      widget.controller.monthlyRepeatType = value;
                    });
                  }
                },
              ),
            )));
  }

  Widget monthlyRepeatTypeSelector(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        radioTile(context, 'Count days from head', MonthlyRepeatType.fromHead),
        radioTile(context, 'Count days from tail', MonthlyRepeatType.fromTail),
      ],
    );
  }

  Widget periodSelector(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text('Repeat within: ', style: Theme.of(context).textTheme.bodyLarge),
          UnlimitedPeriodSelector(controller: periodCtl),
        ]));
  }

  // </components>

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width:
            widget.width ?? min(400.0, MediaQuery.of(context).size.width * 0.9),
        child: Column(
          children: [
            repeatTypeSelector(context),
            switch (widget.controller.repeatType) {
              RepeatType.no => const SizedBox(),
              RepeatType.interval => repeatIntervalSelector(context),
              RepeatType.weekly => weekDaySelector(context),
              RepeatType.monthly => monthlyRepeatTypeSelector(context),
              RepeatType.anually => const SizedBox(),
            },
            switch (widget.controller.repeatType) {
              RepeatType.no => const SizedBox(),
              RepeatType.interval => periodSelector(context),
              RepeatType.weekly => periodSelector(context),
              RepeatType.monthly => periodSelector(context),
              RepeatType.anually => periodSelector(context),
            },
          ],
        ));
  }
}
// </schedule ticket configurator>

/* <estimation ticket configurator>
Estimation Ticket Configurator requires:

- Target Categories
- Content Type
- Period

This section is so simple that there is nothing to mention.

For more details, such as the options for each field, see the component-structure.md or abstruction.md or implementation.
*/
class EstimationTicketConfigSection extends BasicConfigSectionWidget {
  @override
  final EstimationRecord initialConfigData;
  const EstimationTicketConfigSection({
    super.key,
    required super.controller,
    this.initialConfigData = const EstimationRecord(),
  });

  @override
  State<EstimationTicketConfigSection> createState() =>
      _EstimationTicketConfiguraitonSectionState();
}

class _EstimationTicketConfiguraitonSectionState
    extends State<EstimationTicketConfigSection> with ConfigSectionState {
  late MultipleCategorySelectorController categoryCtl;
  late UnlimitedPeriodSelectorController periodCtl;
  late EstimationTicketContentType contentType;

  @override
  void initSubModuleControllers() {
    categoryCtl = MultipleCategorySelectorController(
      allCategoriesInitiallySelected:
          widget.initialConfigData.targetingAllCategories,
      initiallySelectedCategories: widget.initialConfigData.targetCategories,
    );
    periodCtl = UnlimitedPeriodSelectorController(
      start: widget.initialConfigData.startDate,
      end: widget.initialConfigData.endDate,
    );
    contentType = widget.initialConfigData.contentType;
  }

  @override
  void onSaved() {
    if (!categoryCtl.isInitialized) {
      showErrorDialog(context,
          'Category selector is not prepared yet. Please wait until it is loaded.');
      return;
    }
    if (!categoryCtl.allCategoriesInitiallySelected &&
        categoryCtl.selectedCategories.isEmpty) {
      showErrorDialog(
          context, 'Category unselected. Please select at least one category.');
      return;
    }
    var configData = EstimationRecord(
      targetCategories: categoryCtl.selectedCategories,
      targetingAllCategories: categoryCtl.allCategoriesSelected,
      startDate: periodCtl.start,
      endDate: periodCtl.end,
      contentType: contentType,
    );
    configData.save();
    Navigator.of(context).pop();
  }

  // <components> just to avoid deep nesting

  List<Widget> categorySelector(BuildContext context) {
    var width = min(250.0, MediaQuery.of(context).size.width * 0.8);
    return sector(context, 'Target Categories',
        MultipleCategorySelector(controller: categoryCtl, width: width));
  }

  List<Widget> contentTypeSelector(BuildContext context) {
    return sector(
        context,
        'Content Type',
        DropdownMenu<EstimationTicketContentType>(
          initialSelection: contentType,
          dropdownMenuEntries: const [
            DropdownMenuEntry(
                value: EstimationTicketContentType.perDay,
                label: 'estimation per day'),
            DropdownMenuEntry(
                value: EstimationTicketContentType.perWeek,
                label: 'estimation per week'),
            DropdownMenuEntry(
                value: EstimationTicketContentType.perMonth,
                label: 'estimation per month'),
            DropdownMenuEntry(
                value: EstimationTicketContentType.perYear,
                label: 'estimation per year'),
          ],
          onSelected: (value) {
            if (value != null) {
              contentType = value;
            }
          },
        ));
  }

  List<Widget> periodSelector(BuildContext context) {
    return sector(
        context,
        'Period',
        SizedBox(
            width: min(400, MediaQuery.of(context).size.width * 0.9),
            child: UnlimitedPeriodSelector(controller: periodCtl)));
  }

  // </components>

  @override
  List<Widget> contentColumn(BuildContext context) {
    return [
      ...categorySelector(context),
      ...contentTypeSelector(context),
      ...periodSelector(context),
      spacer(context),
    ];
  }
}
// </estimation ticket configurator>

/* <log ticket configurator>
Log Ticket Configurator requires:

- Category
- Supplement
- Registration Date
- Amount
- Picture of Receipts

some fields are optional, otherwise, there is nothing to mention.

For more details, such as the options for each field, see the component-structure.md or abstruction.md or implementation.
*/
class LogTicketConfiguraitonSection extends BasicConfigSectionWidget {
  @override
  final LogRecord initialConfigData;
  const LogTicketConfiguraitonSection({
    super.key,
    required super.controller,
    this.initialConfigData = const LogRecord(),
  });

  @override
  State<LogTicketConfiguraitonSection> createState() =>
      _LogTicketConfiguraitonSectionState();
}

class _LogTicketConfiguraitonSectionState
    extends State<LogTicketConfiguraitonSection> with ConfigSectionState {
  late SingleCategorySelectorController categorySelectorCtl;
  late TextEditingController supplementationCtl;
  late DatePickButtonController registorationDateCtl;
  late MoneyformController amountCtl;
  late PictureSelectorController pictureSelectorCtl;

  @override
  void initSubModuleControllers() {
    categorySelectorCtl = SingleCategorySelectorController(
      initiallySelectedCategory: widget.initialConfigData.category,
    );
    supplementationCtl =
        TextEditingController(text: widget.initialConfigData.supplement);
    registorationDateCtl = DatePickButtonController(
      initialDate: widget.initialConfigData.registorationDate,
    );
    amountCtl = MoneyformController(amount: widget.initialConfigData.amount);
    pictureSelectorCtl = PictureSelectorController();
  }

  @override
  void onSaved() {
    if (!categorySelectorCtl.isInitialized) {
      // if user tries to save the configuration too early, show a dialog to alert the user
      showErrorDialog(context,
          'Category selector is not prepared yet. Please wait until it is loaded.');
      return;
    }
    if (categorySelectorCtl.selected == null) {
      showErrorDialog(
          context, 'Category unselected. Please select a category.');
      return;
    }
    var configData = LogRecord(
      category: categorySelectorCtl.selected!,
      supplement: supplementationCtl.text,
      registorationDate: registorationDateCtl.selected,
      amount: amountCtl.amount,
      image: pictureSelectorCtl.picture,
      // do not change 'confirmed' field in this section
      confirmed: widget.initialConfigData.confirmed,
    );
    configData.save();
    Navigator.of(context).pop();
  }

  // <components> just to avoid deep nesting

  List<Widget> categorySelector(BuildContext context) {
    return sector(context, 'Category',
        SingleCategorySelector(controller: categorySelectorCtl));
  }

  List<Widget> supplementationForm(BuildContext context) {
    var width = min(300.0, MediaQuery.of(context).size.width * 0.8);
    return sector(
        context,
        'Supplementation',
        SizedBox(
          width: width,
          child: TextField(
            controller: supplementationCtl,
          ),
        ));
  }

  List<Widget> datePick(BuildContext context) {
    return sector(
        context,
        'Date',
        DatePickButton(
          controller: registorationDateCtl,
        ));
  }

  List<Widget> amountForm(BuildContext context) {
    return sector(
        context,
        'Amount',
        Moneyform(
          controller: amountCtl,
        ));
  }

  List<Widget> pictureSelector(BuildContext context) {
    return sector(
        context,
        'Picture of receipts',
        PictureSelectButton(
          controller: pictureSelectorCtl,
        ));
  }

  @override
  List<Widget> contentColumn(BuildContext context) {
    return [
      ...categorySelector(context),
      ...supplementationForm(context),
      ...datePick(context),
      ...amountForm(context),
      ...pictureSelector(context),
      spacer(context),
    ];
  }
}
// </log ticket configurator>

// </basic configurators>

/* <applied configurators>
Applied Configurators are the configurators which have some additional features.
*/

/* <logTicket section with preset>
It is extension of LogTicketConfiguraitonSection.
It has a feature to apply preset configurations to the configuration.
The essential log for presetting is implemented in `data_fetcher.dart` (not here), because it exceeds the scope of UI-definition.
*/
class LogTicketConfigurationSectionWithPreset extends StatefulWidget {
  final DataEditWindowController controller;
  final LogRecord initialConfigData;

  const LogTicketConfigurationSectionWithPreset(
      {super.key,
      required this.controller,
      this.initialConfigData = const LogRecord()});

  @override
  State<LogTicketConfigurationSectionWithPreset> createState() =>
      _LogTicketConfigurationSectionWithPresetState();
}

class _LogTicketConfigurationSectionWithPresetState
    extends State<LogTicketConfigurationSectionWithPreset> {
  DataEditWindowController sectionCtl = DataEditWindowController();
  late LogRecord logTicketConfigData;
  static const int nPreset = 5;
  late Future<List<LogRecord>> fPresets;

  @override
  void initState() {
    super.initState();
    // <bypass the event>
    widget.controller.onSaved(() {
      sectionCtl.save();
    });
    widget.controller.onDeleted(() {
      sectionCtl.delete();
    });
    // </bypass the event>
    logTicketConfigData = widget.initialConfigData;
    fPresets = TicketDataManager().fetchLogTicketPresets(nPreset);
  }

  void applyPreset(LogRecord data) {
    setState(() {
      logTicketConfigData = logTicketConfigData.applyPreset(data);
    });
  }

  Widget presets(BuildContext context) {
    return FutureBuilder(
        future: fPresets,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LinearProgressIndicator();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Text('Error: ${snapshot.error}');
          }
          return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(5),
                      child: const Text('Presets: ')),
                  for (var i = 0; i < nPreset; i++)
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: TextButton(
                          onPressed: () {
                            applyPreset(snapshot.data![i]);
                          },
                          child: snapshot.data![i].supplement == ''
                              ? Text('${snapshot.data![i].category?.name}')
                              : Text(
                                  '${snapshot.data![i].category?.name} - ${snapshot.data![i].supplement}')),
                    )
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
          child: LogTicketConfiguraitonSection(
              key: UniqueKey(), // to invoke rebuild after applying preset
              controller: sectionCtl,
              initialConfigData: logTicketConfigData)),
      presets(context),
    ]);
  }
}
// </logTicket section with preset>

/* <ticket creation section>
Ticket Creation Section is TabView which contains all the configurators for creating a ticket.
This is specialized for creating a ticket, so its performance is distinct.
- It only takes DateTime as an initial value.
- It have many controllers for each configurator to save the proper data.
and so on.
*/
class TicketCreationSection extends StatefulWidget {
  final DataEditWindowController controller;
  final DateTime initialDate;

  const TicketCreationSection(
      {super.key, required this.controller, required this.initialDate});

  @override
  State<TicketCreationSection> createState() => _TicketCreationSectionState();
}

// to get the index of the tab, it uses 'SingleTickerProviderStateMixin' instead of 'DefaultTabController'
class _TicketCreationSectionState extends State<TicketCreationSection>
    with SingleTickerProviderStateMixin {
  static const int tabCount = 4;
  TabController? tabController;

  DataEditWindowController displayTicketConfigCtl = DataEditWindowController();
  late DisplayTicketRecord initialDisplayTicketConfigData;
  DataEditWindowController scheduleTicketConfigCtl = DataEditWindowController();
  late ScheduleRecord initialScheduleTicketConfigData;
  DataEditWindowController estimationTicketConfigCtl =
      DataEditWindowController();
  late EstimationRecord initialEstimationTicketConfigData;
  DataEditWindowController logTicketConfigCtl = DataEditWindowController();
  late LogRecord initialLogTicketConfigData;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabCount, vsync: this);
    widget.controller.onSaved(() {
      switch (tabController?.index) {
        case 0:
          displayTicketConfigCtl.save();
          break;
        case 1:
          scheduleTicketConfigCtl.save();
          break;
        case 2:
          estimationTicketConfigCtl.save();
          break;
        case 3:
          logTicketConfigCtl.save();
          break;
      }
    });
    widget.controller.onDeleted(() {
      // because this is creation section, it does not have delete function
      // just close the window
      Navigator.of(context).pop();
    });
    initialDisplayTicketConfigData = DisplayTicketRecord(
      designatedDate: widget.initialDate,
    );
    initialScheduleTicketConfigData = ScheduleRecord(
      originDate: widget.initialDate,
    );
    initialEstimationTicketConfigData = EstimationRecord(
      startDate: widget.initialDate,
    );
    initialLogTicketConfigData = LogRecord(
      registorationDate: widget.initialDate,
    );
  }

  Widget body(BuildContext context) {
    return TabBarView(controller: tabController, children: [
      DisplayTicketConfigSection(
        controller: displayTicketConfigCtl,
        initialConfigData: initialDisplayTicketConfigData,
      ),
      ScheduleTicketConfigSection(
        controller: scheduleTicketConfigCtl,
        initialConfigData: initialScheduleTicketConfigData,
      ),
      EstimationTicketConfigSection(
        controller: estimationTicketConfigCtl,
        initialConfigData: initialEstimationTicketConfigData,
      ),
      LogTicketConfigurationSectionWithPreset(
        controller: logTicketConfigCtl,
        initialConfigData: initialLogTicketConfigData,
      ),
    ]);
  }

  Widget tab(BuildContext context) {
    return TabBar(controller: tabController, tabs: const [
      Tab(icon: Icon(Icons.tv), text: 'Display'),
      Tab(icon: Icon(Icons.calendar_today), text: 'Schedule'),
      Tab(icon: Icon(Icons.bar_chart), text: 'Estimation'),
      Tab(icon: Icon(Icons.bookmark), text: 'Log'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(child: body(context)),
      tab(context),
    ]);
  }
}

// </ticket creation section>

// </applied configurators>
