import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:miraibo/category_selector.dart';
import 'package:miraibo/general_widget.dart';
import 'data_types.dart';

// <data edit modal window>
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

// <display ticket configurator>
class DisplayTicketConfiguraitonSection extends StatefulWidget {
  final DataEditWindowController controller;
  final DisplayTicketConfigurationData initialConfigurationData;
  final double? width;

  const DisplayTicketConfiguraitonSection({
    super.key,
    required this.controller,
    this.initialConfigurationData = const DisplayTicketConfigurationData(),
    this.width,
  });

  @override
  State<DisplayTicketConfiguraitonSection> createState() =>
      _DisplayTicketConfiguraitonSectionState();
}

class _DisplayTicketConfiguraitonSectionState
    extends State<DisplayTicketConfiguraitonSection> {
  late DisplayTicketConfigurationData configData;
  late MultipleCategorySelectorController categorySelectorCtl;
  late DatePickButtonController designatedDateCtl;

  @override
  void initState() {
    super.initState();
    configData = widget.initialConfigurationData;
    // < bind controllers >
    categorySelectorCtl = MultipleCategorySelectorController(
      allCategoriesInitiallySelected: configData.targetingAllCategories,
      initiallySelectedCategories: configData.targetCategories,
    );
    designatedDateCtl = DatePickButtonController(
      initialDate: configData.designatedDate,
    );
    // there's no controller for content type
    // there's no controller for term mode
    // there's no controller for period
    // </ bind controllers >
    widget.controller.onSaved(() {
      if (!categorySelectorCtl.isInitialized) {
        // if user tries to save the configuration too early, show a dialog to alert the user
        showErrorDialog(context,
            'Category selector is not prepared yet. Please wait until it is loaded.');
        return;
      }
      configData = configData.copyWith(
          targetCategories: categorySelectorCtl.selectedCategories,
          targetingAllCategories: categorySelectorCtl.allCategoriesSelected,
          designatedDate: designatedDateCtl.selected);
      if (!configData.targetingAllCategories &&
          configData.targetCategories.isEmpty) {
        showErrorDialog(context,
            'Category unselected. Please select at least one category.');
        return;
      }
      // impl: SAVE DATA HERE
      Navigator.of(context).pop();
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
      developer
          .log('DisplayTicketConfiguraitonSection deleted ${configData.id}');
    });
  }

  List<Widget> sector(BuildContext context, String title, Widget child) {
    return [
      Padding(
          padding: const EdgeInsets.only(top: 10),
          child:
              Text(title, style: Theme.of(context).textTheme.headlineMedium)),
      Padding(padding: const EdgeInsets.only(top: 10, bottom: 10), child: child)
    ];
  }

  List<Widget> periodSelector(BuildContext context) {
    return sector(
        context,
        'Period',
        // there is no controller which returns the value of the selected item as 'DisplayTicketPeriod'
        DropdownMenu<DisplayTicketPeriod>(
          initialSelection: configData.designatedPeriod,
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: DisplayTicketPeriod.week, label: 'week'),
            DropdownMenuEntry(value: DisplayTicketPeriod.month, label: 'month'),
            DropdownMenuEntry(
                value: DisplayTicketPeriod.halfYear, label: 'half year'),
            DropdownMenuEntry(value: DisplayTicketPeriod.year, label: 'year'),
          ],
          onSelected: (value) {
            if (value != null) {
              configData = configData.copyWith(designatedPeriod: value);
            }
          },
        ));
  }

  List<Widget> dateSelectionCalenderForm(BuildContext context) {
    configData = configData.copyWith(
        designatedDate: configData.designatedDate ?? DateTime.now());
    return sector(
        context, 'Until', DatePickButton(controller: designatedDateCtl));
  }

  List<Widget> contentTypeSelector(BuildContext context, {bool fixed = false}) {
    if (fixed) {
      // for fixed, only summation is available
      configData =
          configData.copyWith(contentType: DisplayTicketContentType.summation);
      return sector(
          context,
          'Content Type',
          DropdownMenu<DisplayTicketContentType>(
            initialSelection: configData.contentType,
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
            initialSelection: configData.contentType,
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
                configData = configData.copyWith(contentType: value);
              }
            },
          ));
    }
  }

  List<Widget> termModeDependencies(BuildContext context) {
    switch (configData.termMode) {
      case DisplayTicketTermMode.untilDesignatedDate:
        return [
          ...dateSelectionCalenderForm(context),
          ...contentTypeSelector(context, fixed: true),
        ];
      case DisplayTicketTermMode.lastDesignatedPeriod:
        return [
          ...periodSelector(context),
          ...contentTypeSelector(context),
        ];
      case DisplayTicketTermMode.untilToday:
        return [...contentTypeSelector(context)];
    }
  }

  List<Widget> termModeSelector(BuildContext context) {
    return sector(
        context,
        'Term-mode',
        // there is no controller which returns the value of the selected item as 'DisplayTicketTermMode'
        DropdownMenu<DisplayTicketTermMode>(
          initialSelection: configData.termMode,
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
                configData = configData.copyWith(termMode: value);
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        // Target Categories
        ...targetCategories(context),
        // Term mode selector
        ...termModeSelector(context),
        // Term mode dependencies
        ...termModeDependencies(context),
        // spacer to allow the form to scroll
        SizedBox(
          height: MediaQuery.of(context).size.height *
              dataEditWindowHeightFraction /
              2,
        ),
      ],
    ));
  }
}
// </display ticket configurator>

// <schedule ticket configurator>
class ScheduleTicketConfiguraitonSection extends StatefulWidget {
  final DataEditWindowController controller;
  final ScheduleTicketConfigurationData initialConfigurationData;

  const ScheduleTicketConfiguraitonSection({
    super.key,
    required this.controller,
    this.initialConfigurationData = const ScheduleTicketConfigurationData(),
  });

  @override
  State<ScheduleTicketConfiguraitonSection> createState() =>
      _ScheduleTicketConfiguraitonSectionState();
}

class _ScheduleTicketConfiguraitonSectionState
    extends State<ScheduleTicketConfiguraitonSection> {
  late ScheduleTicketConfigurationData configData;
  late SingleCategorySelectorController categorySelectorCtl;
  late TextEditingController supplementCtl;
  late MoneyformController moneyFormCtl;
  late DatePickButtonController registorationDateCtl;
  late ScheduleTicketRepeatSettingSectorController repeatSettingCtl;

  List<Widget> sector(BuildContext context, String title, Widget child) {
    return [
      Padding(
          padding: const EdgeInsets.only(top: 10),
          child:
              Text(title, style: Theme.of(context).textTheme.headlineMedium)),
      Padding(padding: const EdgeInsets.only(top: 10, bottom: 10), child: child)
    ];
  }

  @override
  void initState() {
    super.initState();
    configData = widget.initialConfigurationData;
    widget.controller.onSaved(() {
      if (!categorySelectorCtl.isInitialized) {
        showErrorDialog(context,
            'Category selector is not prepared yet. Please wait until it is loaded.');
        return;
      }
      configData = configData.copyWith(
        category: categorySelectorCtl.selected,
        supplement: supplementCtl.text,
        amount: moneyFormCtl.amount,
        registorationDate: registorationDateCtl.selected,
        repeatType: repeatSettingCtl.repeatType,
        repeatInterval: repeatSettingCtl.repeatInterval,
        repeatDayOfWeek: repeatSettingCtl.repeatDayOfWeek,
        monthlyRepeatType: repeatSettingCtl.monthlyRepeatType,
        startDate: repeatSettingCtl.startDate,
        startDateDesignated: repeatSettingCtl.startDate != null,
        endDate: repeatSettingCtl.endDate,
        endDateDesignated: repeatSettingCtl.endDate != null,
      );
      if (configData.category == null) {
        showErrorDialog(
            context, 'Category unselected. Please select a category.');
        return;
      }
      // impl: SAVE DATA HERE
      Navigator.of(context).pop();
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
      developer
          .log('ScheduleTicketConfiguraitonSection deleted ${configData.id}');
    });
    // <bind controllers>
    categorySelectorCtl = SingleCategorySelectorController(
      initiallySelectedCategory: configData.category,
    );
    supplementCtl = TextEditingController(text: configData.supplement);
    moneyFormCtl = MoneyformController(amount: configData.amount);
    registorationDateCtl = DatePickButtonController(
      initialDate: configData.registorationDate,
    );
    repeatSettingCtl = ScheduleTicketRepeatSettingSectorController(
      initialRepeatType: configData.repeatType,
      initialRepeatInterval: configData.repeatInterval,
      initialRepeatDayOfWeek: configData.repeatDayOfWeek,
      initialMonthlyRepeatType: configData.monthlyRepeatType,
      initialStartDate: configData.startDate,
      initialEndDate: configData.endDate,
    );
    // </bind controllers>
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        ...categorySelector(context),
        ...supplementationForm(context),
        ...registorationDateForm(context),
        ...amountForm(context),
        ...repeatSettingForm(context),
        // spacer to allow the form to scroll
        SizedBox(
          height: MediaQuery.of(context).size.height *
              dataEditWindowHeightFraction /
              2,
        )
      ],
    ));
  }
}

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

// <estimation ticket configurator>
class EstimationTicketConfiguraitonSection extends StatefulWidget {
  final DataEditWindowController controller;
  final EstimationTicketConfigurationData initialConfigurationData;

  const EstimationTicketConfiguraitonSection({
    super.key,
    required this.controller,
    this.initialConfigurationData = const EstimationTicketConfigurationData(),
  });

  @override
  State<EstimationTicketConfiguraitonSection> createState() =>
      _EstimationTicketConfiguraitonSectionState();
}

class _EstimationTicketConfiguraitonSectionState
    extends State<EstimationTicketConfiguraitonSection> {
  late EstimationTicketConfigurationData configData;
  late MultipleCategorySelectorController categoryCtl;
  late UnlimitedPeriodSelectorController periodCtl;

  @override
  void initState() {
    super.initState();
    configData = widget.initialConfigurationData;
    // <bind controllers>
    categoryCtl = MultipleCategorySelectorController(
      allCategoriesInitiallySelected: configData.selectingAllCategories,
      initiallySelectedCategories: configData.selectedCategories,
    );
    periodCtl = UnlimitedPeriodSelectorController(
      start: configData.startDate,
      end: configData.endDate,
    );
    // there's no controller for content type
    // </bind controllers>
    widget.controller.onSaved(() {
      if (!categoryCtl.isInitialized) {
        showErrorDialog(context,
            'Category selector is not prepared yet. Please wait until it is loaded.');
        return;
      }
      configData = configData.copyWith(
        selectingAllCategories: categoryCtl.allCategoriesSelected,
        selectedCategories: categoryCtl.selectedCategories,
        startDate: periodCtl.start,
        startDateDesignated: periodCtl.start != null,
        endDate: periodCtl.end,
        endDateDesignated: periodCtl.end != null,
      );
      if (!configData.selectingAllCategories &&
          configData.selectedCategories.isEmpty) {
        showErrorDialog(context,
            'Category unselected. Please select at least one category.');
        return;
      }
      Navigator.of(context).pop();
      // impl: SAVE DATA HERE
      developer
          .log('EstimationTicketConfiguraitonSection saved ${configData.id}');
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
      developer
          .log('EstimationTicketConfiguraitonSection deleted ${configData.id}');
    });
  }

  // <components> just to avoid deep nesting
  List<Widget> sector(BuildContext context, String title, Widget child) {
    return [
      Padding(
          padding: const EdgeInsets.only(top: 10),
          child:
              Text(title, style: Theme.of(context).textTheme.headlineMedium)),
      Padding(padding: const EdgeInsets.only(top: 10, bottom: 10), child: child)
    ];
  }

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
          initialSelection: configData.contentType,
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
              setState(() {
                configData = configData.copyWith(contentType: value);
              });
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        ...categorySelector(context),
        ...contentTypeSelector(context),
        ...periodSelector(context),
        SizedBox(
          height: MediaQuery.of(context).size.height *
              dataEditWindowHeightFraction /
              2,
        )
      ],
    ));
  }
}

class LogTicketConfiguraitonSection extends StatefulWidget {
  final DataEditWindowController controller;
  final LogTicketConfigurationData initialConfigurationData;

  const LogTicketConfiguraitonSection({
    super.key,
    required this.controller,
    this.initialConfigurationData = const LogTicketConfigurationData(),
  });

  @override
  State<LogTicketConfiguraitonSection> createState() =>
      _LogTicketConfiguraitonSectionState();
}
// </estimation ticket configurator>

// <log ticket configurator>
class _LogTicketConfiguraitonSectionState
    extends State<LogTicketConfiguraitonSection> {
  late LogTicketConfigurationData configData;
  late SingleCategorySelectorController categorySelectorCtl;
  late TextEditingController supplementationCtl;
  late DatePickButtonController registorationDateCtl;
  late MoneyformController amountCtl;
  late PictureSelectorController pictureSelectorCtl;

  List<Widget> sector(BuildContext context, String title, Widget child) {
    return [
      Padding(
          padding: const EdgeInsets.only(top: 10),
          child:
              Text(title, style: Theme.of(context).textTheme.headlineMedium)),
      Padding(padding: const EdgeInsets.only(top: 10, bottom: 10), child: child)
    ];
  }

  @override
  void initState() {
    super.initState();
    configData = widget.initialConfigurationData;
    // < bind controllers >
    categorySelectorCtl = SingleCategorySelectorController(
      initiallySelectedCategory: configData.category,
    );
    supplementationCtl =
        TextEditingController(text: configData.supplementation);
    registorationDateCtl = DatePickButtonController(
      initialDate: configData.registorationDate,
    );
    amountCtl = MoneyformController(amount: configData.amount);
    pictureSelectorCtl = PictureSelectorController();
    // </ bind controllers >
    widget.controller.onSaved(() {
      if (!categorySelectorCtl.isInitialized) {
        // if user tries to save the configuration too early, show a dialog to alert the user
        showErrorDialog(context,
            'Category selector is not prepared yet. Please wait until it is loaded.');
        return;
      }
      configData = configData.copyWith(
        category: categorySelectorCtl.selected,
        supplementation: supplementationCtl.text,
        registorationDate: registorationDateCtl.selected,
        amount: amountCtl.amount,
        image: pictureSelectorCtl.picture,
        isImageAttached: pictureSelectorCtl.picture != null,
      );
      if (configData.category == null) {
        showErrorDialog(
            context, 'Category unselected. Please select a category.');
        return;
      }
      Navigator.of(context).pop();
      // impl: SAVE DATA HERE
      developer.log('LogTicketConfiguraitonSection saved ${configData.id}');
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
      developer.log('LogTicketConfiguraitonSection deleted ${configData.id}');
    });
  }

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
        'Picture',
        PictureSelectButton(
          controller: pictureSelectorCtl,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      ...categorySelector(context),
      ...supplementationForm(context),
      ...datePick(context),
      ...amountForm(context),
      ...pictureSelector(context),
      // spacer to allow the form to scroll
      SizedBox(
        height: MediaQuery.of(context).size.height *
            dataEditWindowHeightFraction /
            2,
      )
    ]));
  }
}
// </log ticket configurator>

// <ticket creation section>
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
  static const int tabCount = 3;
  TabController? tabController;

  DataEditWindowController displayTicketConfigCtl = DataEditWindowController();
  late DisplayTicketConfigurationData initialDisplayTicketConfigData;
  DataEditWindowController scheduleTicketConfigCtl = DataEditWindowController();
  late ScheduleTicketConfigurationData initialScheduleTicketConfigData;
  DataEditWindowController estimationTicketConfigCtl =
      DataEditWindowController();

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
      }
    });
    widget.controller.onDeleted(() {
      // because this is creation section, it does not have delete function
      // just close the window
      Navigator.of(context).pop();
    });
    initialDisplayTicketConfigData = DisplayTicketConfigurationData(
      designatedDate: widget.initialDate,
    );
    initialScheduleTicketConfigData = ScheduleTicketConfigurationData(
      registorationDate: widget.initialDate,
    );
  }

  Widget body(BuildContext context) {
    return TabBarView(controller: tabController, children: [
      DisplayTicketConfiguraitonSection(
        controller: displayTicketConfigCtl,
        initialConfigurationData: initialDisplayTicketConfigData,
      ),
      ScheduleTicketConfiguraitonSection(
        controller: scheduleTicketConfigCtl,
        initialConfigurationData: initialScheduleTicketConfigData,
      ),
      EstimationTicketConfiguraitonSection(
        controller: estimationTicketConfigCtl,
      ),
    ]);
  }

  Widget tab(BuildContext context) {
    return TabBar(controller: tabController, tabs: const [
      Tab(icon: Icon(Icons.tv), text: 'Display'),
      Tab(icon: Icon(Icons.calendar_today), text: 'Schedule'),
      Tab(icon: Icon(Icons.bar_chart), text: 'Estimation'),
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

// <logger section>
class LoggerSection extends StatefulWidget {
  final DataEditWindowController controller;
  final DateTime initialDate;

  const LoggerSection(
      {super.key, required this.controller, required this.initialDate});

  @override
  State<LoggerSection> createState() => _LoggerSectionState();
}

class _LoggerSectionState extends State<LoggerSection> {
  DataEditWindowController logTicketConfigCtl = DataEditWindowController();
  late LogTicketConfigurationData initialLogTicketConfigData;

  @override
  void initState() {
    super.initState();
    widget.controller.onSaved(() {
      logTicketConfigCtl.save();
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
    });
    initialLogTicketConfigData = LogTicketConfigurationData(
      registorationDate: widget.initialDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    // impl: preset function
    return LogTicketConfiguraitonSection(
      controller: logTicketConfigCtl,
      initialConfigurationData: initialLogTicketConfigData,
    );
  }
}
// </logger section>
