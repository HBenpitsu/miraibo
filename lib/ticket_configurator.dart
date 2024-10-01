import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:miraibo/category_selector.dart';
import 'data_types.dart';

// <data edit modal window>
class DataEditWindowController {
  void Function()? _saveHandler;
  void Function()? _deleteHandler;
  void Function()? _dismisser;

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

  @override
  void initState() {
    super.initState();
    configData = widget.initialConfigurationData;
    // controllers
    categorySelectorCtl = MultipleCategorySelectorController(
      allCategoriesInitiallySelected: configData.targetingAllCategories,
      initiallySelectedCategories: configData.targetCategories,
    );
    categorySelectorCtl.onUpdate = () {
      if (!mounted) {
        return;
      }
      setState(() {
        configData = configData.copyWith(
            targetCategories: categorySelectorCtl.categories,
            targetingAllCategories: categorySelectorCtl.allCategoriesSelected);
      });
    };
    widget.controller.onSaved(() {
      if (!categorySelectorCtl.isInitialized) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Error'),
                content: const Text(
                    'Category selector is not prepared yet. Please wait until it is loaded.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'))
                ],
              );
            });
      } else {
        Navigator.of(context).pop();
        log('DisplayTicketConfiguraitonSection saved ${configData.id}');
      }
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
      log('DisplayTicketConfiguraitonSection deleted ${configData.id}');
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
              setState(() {
                configData = configData.copyWith(designatedPeriod: value);
              });
            }
          },
        ));
  }

  List<Widget> dateSelectionCalenderForm(BuildContext context) {
    configData = configData.copyWith(
        designatedDate: configData.designatedDate ?? DateTime.now());
    return sector(
        context,
        'Until',
        ElevatedButton(
            onPressed: () {
              showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(3000))
                  .then((value) {
                if (!mounted) {
                  return;
                }
                if (value != null) {
                  setState(() {
                    configData = configData.copyWith(designatedDate: value);
                  });
                }
              });
            },
            child: configData.designatedDate == null
                ? const Text('tap to pick a date')
                : Text(
                    '${configData.designatedDate!.year}-${configData.designatedDate!.month}-${configData.designatedDate!.day}')));
  }

  List<Widget> contentTypeSelector(BuildContext context, {bool fixed = false}) {
    if (fixed) {
      // for fixed, only summation is available
      setState(() {
        configData = configData.copyWith(
            contentTypes: DisplayTicketContentTypes.summation);
      });
      return sector(
          context,
          'Content Type',
          DropdownMenu<DisplayTicketContentTypes>(
            initialSelection: configData.contentType,
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                  value: DisplayTicketContentTypes.summation,
                  label: 'summation'),
            ],
          ));
    } else {
      return sector(
          context,
          'Content Type',
          DropdownMenu<DisplayTicketContentTypes>(
            initialSelection: configData.contentType,
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                  value: DisplayTicketContentTypes.dailyAverage,
                  label: 'daily average'),
              DropdownMenuEntry(
                  value: DisplayTicketContentTypes.dailyQuartileAverage,
                  label: 'daily quartile average'),
              DropdownMenuEntry(
                  value: DisplayTicketContentTypes.monthlyAverage,
                  label: 'monthly average'),
              DropdownMenuEntry(
                  value: DisplayTicketContentTypes.monthlyQuartileAverage,
                  label: 'monthly quartile average'),
              DropdownMenuEntry(
                  value: DisplayTicketContentTypes.summation,
                  label: 'summation'),
            ],
            onSelected: (value) {
              if (value != null) {
                setState(() {
                  configData = configData.copyWith(contentTypes: value);
                });
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
    return sector(context, 'Target Categories',
        MultipleCategorySelector(controller: categorySelectorCtl));
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
      Navigator.of(context).pop();
      log('ScheduleTicketConfiguraitonSection saved ${configData.id}');
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
      log('ScheduleTicketConfiguraitonSection deleted ${configData.id}');
    });
  }

  List<Widget> categorySelector(BuildContext context) {
    return sector(
      context,
      'category',
      const Text('category selector'),
    );
  }

  List<Widget> supplementationForm(BuildContext context) {
    return sector(
      context,
      'supplement',
      const Text('supplement'),
    );
  }

  List<Widget> registorationDateForm(BuildContext context) {
    return sector(
      context,
      'date',
      const Text('registorationDate'),
    );
  }

  List<Widget> amountForm(BuildContext context) {
    return sector(
      context,
      'amount',
      const Text('amountForm'),
    );
  }

  List<Widget> repeatSettingForm(BuildContext context) {
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
      log('EstimationTicketConfiguraitonSection saved ${configData.id}');
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
      log('EstimationTicketConfiguraitonSection deleted ${configData.id}');
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
      log('LogTicketConfiguraitonSection saved ${configData.id}');
    });
    widget.controller.onDeleted(() {
      Navigator.of(context).pop();
      log('LogTicketConfiguraitonSection deleted ${configData.id}');
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

  const TicketCreationSection({super.key, required this.controller});

  @override
  State<TicketCreationSection> createState() => _TicketCreationSectionState();
}

// to get the index of the tab, it uses 'SingleTickerProviderStateMixin' instead of 'DefaultTabController'
class _TicketCreationSectionState extends State<TicketCreationSection>
    with SingleTickerProviderStateMixin {
  static const int tabCount = 3;
  TabController? tabController;

  DataEditWindowController displayTicketConfigCtl = DataEditWindowController();
  DataEditWindowController scheduleTicketConfigCtl = DataEditWindowController();
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
  }

  Widget body(BuildContext context) {
    return TabBarView(controller: tabController, children: [
      DisplayTicketConfiguraitonSection(
        controller: displayTicketConfigCtl,
      ),
      ScheduleTicketConfiguraitonSection(
        controller: scheduleTicketConfigCtl,
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
