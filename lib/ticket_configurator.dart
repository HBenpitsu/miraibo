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

  void errorDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();
    configData = widget.initialConfigurationData;
    // controllers
    categorySelectorCtl = MultipleCategorySelectorController(
      allCategoriesInitiallySelected: configData.targetingAllCategories,
      initiallySelectedCategories: configData.targetCategories,
    );
    designatedDateCtl = DatePickButtonController(
      initialDate: configData.designatedDate,
    );
    widget.controller.onSaved(() {
      if (!categorySelectorCtl.isInitialized) {
        // if user tries to save the configuration too early, show a dialog to alert the user
        errorDialog(context,
            'Category selector is not prepared yet. Please wait until it is loaded.');
      } else {
        configData = configData.copyWith(
            targetCategories: categorySelectorCtl.selectedCategories,
            targetingAllCategories: categorySelectorCtl.allCategoriesSelected,
            designatedDate: designatedDateCtl.selected);
        if (!configData.targetingAllCategories &&
            configData.targetCategories.isEmpty) {
          errorDialog(context,
              'Category unselected. Please select at least one category.');
        } else {
          Navigator.of(context).pop();
          developer
              .log('DisplayTicketConfiguraitonSection saved ${configData.id}');
        }
      }
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
      configData = configData.copyWith(
          contentType: DisplayTicketContentType.summation);
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
      configData = configData.copyWith(
          category: categorySelectorCtl.selected,
          supplement: supplementCtl.text,
          amount: moneyFormCtl.amount,
          registorationDate: registorationDateCtl.selected);
      Navigator.of(context).pop();
      developer
          .log('ScheduleTicketConfiguraitonSection saved ${configData.id}');
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
      developer
          .log('ScheduleTicketConfiguraitonSection deleted ${configData.id}');
    });
    categorySelectorCtl = SingleCategorySelectorController(
      initiallySelectedCategory: configData.category,
    );
    supplementCtl = TextEditingController(text: configData.supplement);
    moneyFormCtl = MoneyformController(amount: configData.amount);
    registorationDateCtl = DatePickButtonController(
      initialDate: configData.registorationDate,
    );
  }

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
    configData.repeatDayOfWeek;
    configData.repeatInterval;
    configData.repeatType;
    return sector(
      context,
      'repeat',
      const Text('repeatSetting'),
    );
  }

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
        TextButton(
            onPressed: () {
              configData = configData.copyWith(
                  category: categorySelectorCtl.selected,
                  supplement: supplementCtl.text,
                  amount: moneyFormCtl.amount,
                  registorationDate: registorationDateCtl.selected);
              developer.log('''
                category: ${configData.category?.name}
                supplement: ${configData.supplement}
                amount: ${configData.amount}
                registorationDate: ${configData.registorationDate}
              ''');
            },
            child: const Text('show')),
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

  @override
  void initState() {
    super.initState();
    configData = widget.initialConfigurationData;
    widget.controller.onSaved(() {
      Navigator.of(context).pop();
      developer
          .log('EstimationTicketConfiguraitonSection saved ${configData.id}');
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
      developer
          .log('EstimationTicketConfiguraitonSection deleted ${configData.id}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        const Text('Estimation Ticket Configuration'),
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

  @override
  void initState() {
    super.initState();
    configData = widget.initialConfigurationData;
    widget.controller.onSaved(() {
      Navigator.of(context).pop();
      developer.log('LogTicketConfiguraitonSection saved ${configData.id}');
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
      developer.log('LogTicketConfiguraitonSection deleted ${configData.id}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      const Text('Log Ticket Configuration'),
      // spacer to allow the form to scroll
      SizedBox(
        height: MediaQuery.of(context).size.height *
            dataEditWindowHeightFraction /
            2,
      )
    ]));
  }
}

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
// </log ticket configurator>
