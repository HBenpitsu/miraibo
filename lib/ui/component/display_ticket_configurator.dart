import 'dart:math';

import 'package:flutter/material.dart';
import 'package:miraibo/ui/component/category.dart';
import 'package:miraibo/ui/component/configurator_component.dart';
import 'package:miraibo/ui/component/general_widget.dart';
import 'package:miraibo/ui/component/ticket_configurator_shared_traits.dart';
import 'package:miraibo/type/enumarations.dart';
import 'package:miraibo/util/date_time.dart';
import 'package:miraibo/type/view_obj.dart';
import 'package:miraibo/model_v2/model_v2.dart';

/* <display ticket configurator>

Display Ticket Configurator requires:

- Target Categories
- Term Mode

for all cases.

The other fields are optional and depend on the term mode.
For more details, such as the options for each field, see the component-structure.md or abstruction.md or implementation.
*/
class DisplayTicketConfigSectionController extends SectionController {
  Display record;
  DisplayTicketConfigSectionController({Display? record})
      : record = record ??
            Display(
              displayPeriod: DisplayPeriod.week,
              termMode: DisplayTermMode.untilToday,
              contentType: DisplayContentType.summation,
              targetingAllCategories: true,
              targetCategories: [],
            );

  @override
  void save() {
    Model.display.save(record);
  }

  @override
  void delete() {
    if (record.id == null) {
      return;
    }
    Model.display.delete(record.id!);
  }

  @override
  bool isSaved() {
    return record.id != null;
  }
}

class DisplayTicketConfigSection extends BasicConfigSectionWidget {
  @override
  final DisplayTicketConfigSectionController sectionController;
  final double? width;

  const DisplayTicketConfigSection({
    super.key,
    required this.sectionController,
    this.width,
  });

  @override
  State<DisplayTicketConfigSection> createState() =>
      _DisplayTicketConfigSectionState();
}

class _DisplayTicketConfigSectionState extends State<DisplayTicketConfigSection>
    with ConfigSectionState {
  late MultipleCategorySelectorController categorySelectorCtl;
  late FinitePeriodSelectorController periodPickerCtl;
  late DatePickButtonController datePickerCtl;
  late DisplayContentType contentType;
  late DisplayTermMode termMode;
  late DisplayPeriod period;

  @override
  void initSubModuleControllers() {
    categorySelectorCtl = MultipleCategorySelectorController(
      allCategoriesInitiallySelected:
          widget.sectionController.record.targetingAllCategories,
      initiallySelectedCategories:
          widget.sectionController.record.targetCategories,
    );
    periodPickerCtl = FinitePeriodSelectorController(
      start: widget.sectionController.record.periodBegin ?? today(),
      end: widget.sectionController.record.periodEnd ?? today(),
    );
    datePickerCtl = DatePickButtonController(
      initialDate: widget.sectionController.record.periodEnd ?? today(),
    );
    contentType = widget.sectionController.record.contentType;
    termMode = widget.sectionController.record.termMode;
    period = widget.sectionController.record.displayPeriod;
  }

  @override
  void onSaveRequired() {
    if (!categorySelectorCtl.isInitialized) {
      // if user tries to save the configuration too early, show a dialog to alert the user
      showErrorDialog(context,
          'Category selector is not prepared yet. Please wait until it is loaded.');
      return;
    }
    if (!categorySelectorCtl.allCategoriesSelected &&
        categorySelectorCtl.selectedCategories.isEmpty) {
      showErrorDialog(
          context, 'Category unselected. Please select at least one category.');
      return;
    }
    widget.sectionController.record = Display(
      targetCategories: categorySelectorCtl.selectedCategories,
      targetingAllCategories: categorySelectorCtl.allCategoriesSelected,
      termMode: termMode,
      periodBegin: periodPickerCtl.start,
      periodEnd: termMode == DisplayTermMode.untilDate
          ? datePickerCtl.selected
          : periodPickerCtl.end,
      displayPeriod: period,
      contentType: contentType,
    );
    widget.sectionController.save();
    Navigator.of(context).pop();
  }

  // <components> just to avoid deep nesting

  List<Widget> lastPeriodSelector() {
    return sector(
        'Period',
        // there is no controller which returns the value of the selected item as 'DisplayTicketPeriod'
        DropdownMenu<DisplayPeriod>(
          initialSelection: period,
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: DisplayPeriod.week, label: 'week'),
            DropdownMenuEntry(value: DisplayPeriod.month, label: 'month'),
            DropdownMenuEntry(
                value: DisplayPeriod.halfYear, label: 'half year'),
            DropdownMenuEntry(value: DisplayPeriod.year, label: 'year'),
          ],
          onSelected: (value) {
            if (value != null) {
              period = value;
            }
          },
        ));
  }

  List<Widget> dateSelectionCalenderForm() {
    return sector('Until', DatePickButton(controller: datePickerCtl));
  }

  List<Widget> specificPeriodSelector() {
    return sector('Period', FinitePeriodSelector(controller: periodPickerCtl));
  }

  List<Widget> contentTypeSelector({bool fixed = false}) {
    if (fixed) {
      // for fixed situation, only summation is available
      contentType = DisplayContentType.summation;
      return sector(
          'Content Type',
          DropdownMenu<DisplayContentType>(
            initialSelection: contentType,
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                  value: DisplayContentType.summation, label: 'summation'),
            ],
          ));
    } else {
      return sector(
          'Content Type',
          // there is no controller which returns the value of the selected item as 'DisplayTicketContentTypes'
          DropdownMenu<DisplayContentType>(
            initialSelection: contentType,
            dropdownMenuEntries: const [
              DropdownMenuEntry(
                  value: DisplayContentType.dailyAverage,
                  label: 'daily average'),
              DropdownMenuEntry(
                  value: DisplayContentType.dailyQuartileAverage,
                  label: 'daily quartile average'),
              DropdownMenuEntry(
                  value: DisplayContentType.monthlyAverage,
                  label: 'monthly average'),
              DropdownMenuEntry(
                  value: DisplayContentType.monthlyQuartileAverage,
                  label: 'monthly quartile average'),
              DropdownMenuEntry(
                  value: DisplayContentType.summation, label: 'summation'),
            ],
            onSelected: (value) {
              if (value != null) {
                contentType = value;
              }
            },
          ));
    }
  }

  List<Widget> termModeSelector() {
    return sector(
        'Term-mode',
        // there is no controller which returns the value of the selected item as 'DisplayTicketTermMode'
        DropdownMenu<DisplayTermMode>(
          initialSelection: termMode,
          dropdownMenuEntries: const [
            DropdownMenuEntry(
                value: DisplayTermMode.untilToday, label: 'until today'),
            DropdownMenuEntry(
                value: DisplayTermMode.untilDate,
                label: 'until designated date'),
            DropdownMenuEntry(
                value: DisplayTermMode.lastPeriod,
                label: 'last designated period'),
            DropdownMenuEntry(
                value: DisplayTermMode.specificPeriod,
                label: 'designated specific period'),
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

  List<Widget> targetCategories() {
    var categorySelectorWidth =
        widget.width ?? min(250.0, MediaQuery.of(context).size.width * 0.8);
    return sector(
        'Target Categories',
        MultipleCategorySelector(
            controller: categorySelectorCtl, width: categorySelectorWidth));
  }

  // </components>

  @override
  List<Widget> contentColumn() {
    return [
      ...targetCategories(),
      ...termModeSelector(),
      // Term mode dependencies
      ...switch (termMode) {
        DisplayTermMode.untilDate => [
            ...dateSelectionCalenderForm(),
            ...contentTypeSelector(fixed: true),
          ],
        DisplayTermMode.lastPeriod => [
            ...lastPeriodSelector(),
            ...contentTypeSelector(),
          ],
        DisplayTermMode.untilToday => [...contentTypeSelector()],
        DisplayTermMode.specificPeriod => [
            ...specificPeriodSelector(),
            ...contentTypeSelector(),
          ],
      },
      spacer(),
    ];
  }
}
// </display ticket configurator>