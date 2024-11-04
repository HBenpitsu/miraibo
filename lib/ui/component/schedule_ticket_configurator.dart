import 'dart:math';

import 'package:flutter/material.dart';
import 'package:miraibo/ui/component/category.dart';
import 'package:miraibo/ui/component/configurator_component.dart';
import 'package:miraibo/ui/component/general_widget.dart';
import 'package:miraibo/ui/component/ticket_configurator_shared_traits.dart';
import 'package:miraibo/util/date_time.dart';
import 'package:miraibo/type/view_obj.dart';
import 'package:miraibo/model/model_surface/default_object_provider.dart';
import 'package:miraibo/model/model_surface/schedule_handler.dart';
import 'package:miraibo/type/enumarations.dart';

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
class ScheduleTicketConfigSectionController extends SectionController {
  Schedule record;
  ScheduleTicketConfigSectionController({Schedule? record})
      : record = record ?? DefaultTicketProvider.schedule;

  @override
  void save() {
    ScheduleHandler().save(record);
  }

  @override
  void delete() {
    ScheduleHandler().delete(record);
  }

  @override
  bool isSaved() {
    return record.id != null;
  }
}

class ScheduleTicketConfigSection extends BasicConfigSectionWidget {
  @override
  final ScheduleTicketConfigSectionController sectionController;
  const ScheduleTicketConfigSection({
    super.key,
    required this.sectionController,
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
  late DatePickButtonController originDateCtl;
  late ScheduleTicketRepeatSettingSectorController repeatSettingCtl;

  @override
  void initSubModuleControllers() {
    categorySelectorCtl = SingleCategorySelectorController(
      initiallySelectedCategory: widget.sectionController.record.category,
    );
    supplementCtl =
        TextEditingController(text: widget.sectionController.record.supplement);
    moneyFormCtl =
        MoneyformController(amount: widget.sectionController.record.amount);
    originDateCtl = DatePickButtonController(
      initialDate: widget.sectionController.record.originDate,
    );
    repeatSettingCtl = ScheduleTicketRepeatSettingSectorController(
      initialRepeatType: widget.sectionController.record.repeatType,
      initialRepeatInterval: widget.sectionController.record.repeatInterval,
      initialRepeatDayOfWeek: widget.sectionController.record.weeklyRepeatOn,
      initialMonthlyRepeatType:
          widget.sectionController.record.monthlyHeadOriginRepeatOffset != null
              ? MonthlyRepeatType.fromHead
              : MonthlyRepeatType.fromTail,
      initialStartDate: widget.sectionController.record.periodBegin,
      initialEndDate: widget.sectionController.record.periodEnd,
    );
  }

  @override
  void onSaveRequired() {
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
    var selectedDate = originDateCtl.selected ?? today();
    var lastDayInMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
    widget.sectionController.record = Schedule(
      category: categorySelectorCtl.selected!,
      supplement: supplementCtl.text,
      originDate: selectedDate,
      amount: moneyFormCtl.amount,
      repeatType: repeatSettingCtl.repeatType,
      repeatInterval: repeatSettingCtl.repeatInterval,
      weeklyRepeatOn: repeatSettingCtl.repeatDayOfWeek,
      monthlyHeadOriginRepeatOffset:
          repeatSettingCtl.monthlyRepeatType == MonthlyRepeatType.fromHead
              ? Duration(days: selectedDate.day - 1)
              : null,
      monthlyTailOriginRepeatOffset:
          repeatSettingCtl.monthlyRepeatType == MonthlyRepeatType.fromTail
              ? Duration(days: lastDayInMonth.day - selectedDate.day)
              : null,
      periodBegin: repeatSettingCtl.startDate,
      periodEnd: repeatSettingCtl.endDate,
    );
    widget.sectionController.save();
    Navigator.of(context).pop();
  }

  // <components> just to avoid deep nesting

  List<Widget> categorySelector() {
    return sector(
      'category',
      SingleCategorySelector(controller: categorySelectorCtl),
    );
  }

  List<Widget> supplementationForm() {
    var width = min(300.0, MediaQuery.of(context).size.width * 0.8);
    return sector(
      'supplement',
      SizedBox(
        width: width,
        child: TextField(
          controller: supplementCtl,
        ),
      ),
    );
  }

  List<Widget> originDateForm() {
    return sector(
      'date',
      DatePickButton(controller: originDateCtl),
    );
  }

  List<Widget> amountForm() {
    return sector(
      'amount',
      Moneyform(controller: moneyFormCtl),
    );
  }

  List<Widget> repeatSettingForm() {
    return sector(
      'repeat',
      ScheduleTicketRepeatSettingSector(controller: repeatSettingCtl),
    );
  }

  // </components>

  @override
  List<Widget> contentColumn() {
    return [
      ...categorySelector(),
      ...supplementationForm(),
      ...originDateForm(),
      ...amountForm(),
      ...repeatSettingForm(),
      spacer(),
    ];
  }
}

/* 
Repeat Setting is separated from Schedule Ticket Configurator because of its complexity.
It has a lot of options and it change actions based on the selected options.
This is because necessary information is different between each repeat type.
*/
class ScheduleTicketRepeatSettingSectorController {
  SCRepeatType _repeatType;
  SCRepeatType get repeatType => _repeatType;
  set repeatType(SCRepeatType value) {
    _repeatType = value;
    _onChanged();
  }

  Duration _repeatInterval;
  Duration get repeatInterval => _repeatInterval;
  set repeatInterval(Duration value) {
    _repeatInterval = value;
    _onChanged();
  }

  final List<Weekday> _repeatDayOfWeek;
  List<Weekday> get repeatDayOfWeek => _repeatDayOfWeek;
  bool dayOfWeekSelected(Weekday day) => _repeatDayOfWeek.contains(day);
  void turnOnDayOfWeek(Weekday day) {
    if (!_repeatDayOfWeek.contains(day)) {
      _repeatDayOfWeek.add(day);
      _onChanged();
    }
  }

  void turnOffDayOfWeek(Weekday day) {
    if (_repeatDayOfWeek.contains(day)) {
      _repeatDayOfWeek.remove(day);
      _onChanged();
    }
  }

  void toggleDayOfWeek(Weekday day) {
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
    SCRepeatType initialRepeatType = SCRepeatType.no,
    Duration initialRepeatInterval = const Duration(days: 1),
    List<Weekday> initialRepeatDayOfWeek = const [],
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
  late InfinitePeriodSelectorController periodCtl;

  @override
  void initState() {
    super.initState();
    intervalCtl = TextEditingController(
        text: widget.controller.repeatInterval.inDays.toString());
    periodCtl = InfinitePeriodSelectorController(
      start: widget.controller.startDate,
      end: widget.controller.endDate,
    );
    periodCtl.onPeriodChanged = () {
      widget.controller.startDate = periodCtl.start;
      widget.controller.endDate = periodCtl.end;
    };
  }

  // <components> just to avoid deep nesting

  Widget repeatTypeSelector() {
    return DropdownMenu<SCRepeatType>(
      initialSelection: widget.controller.repeatType,
      dropdownMenuEntries: const [
        DropdownMenuEntry(value: SCRepeatType.no, label: 'no repeat'),
        DropdownMenuEntry(
            value: SCRepeatType.interval, label: 'repeat in days'),
        DropdownMenuEntry(value: SCRepeatType.weekly, label: 'weekly'),
        DropdownMenuEntry(value: SCRepeatType.monthly, label: 'monthly'),
        DropdownMenuEntry(value: SCRepeatType.anually, label: 'anually'),
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

  Widget repeatIntervalSelector() {
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

  Widget weekDayIconButton(Weekday day) {
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
                child: Text(day.shortString,
                    style: TextStyle(
                        color: widget.controller.dayOfWeekSelected(day)
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor)))));
  }

  Widget weekDaySelector() {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Wrap(
          children: [
            ...Weekday.values.map((day) {
              return Padding(
                  padding: const EdgeInsets.all(2),
                  child: weekDayIconButton(day));
            }),
          ],
        ));
  }

  Widget radioTile(String title, MonthlyRepeatType value) {
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

  Widget monthlyRepeatTypeSelector() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        radioTile('Count days from head', MonthlyRepeatType.fromHead),
        radioTile('Count days from tail', MonthlyRepeatType.fromTail),
      ],
    );
  }

  Widget periodSelector() {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Text('Repeat within: ', style: Theme.of(context).textTheme.bodyLarge),
          InfinitePeriodSelector(controller: periodCtl),
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
            repeatTypeSelector(),
            switch (widget.controller.repeatType) {
              SCRepeatType.no => const SizedBox(),
              SCRepeatType.interval => repeatIntervalSelector(),
              SCRepeatType.weekly => weekDaySelector(),
              SCRepeatType.monthly => monthlyRepeatTypeSelector(),
              SCRepeatType.anually => const SizedBox(),
            },
            switch (widget.controller.repeatType) {
              SCRepeatType.no => const SizedBox(),
              SCRepeatType.interval => periodSelector(),
              SCRepeatType.weekly => periodSelector(),
              SCRepeatType.monthly => periodSelector(),
              SCRepeatType.anually => periodSelector(),
            },
          ],
        ));
  }
}
// </schedule ticket configurator>
