import 'dart:math';

import 'package:flutter/material.dart';
import 'package:miraibo/ui/component/category.dart';
import 'package:miraibo/ui/component/configurator_component.dart';
import 'package:miraibo/ui/component/general_widget.dart';
import 'package:miraibo/ui/component/ticket_configurator_shared_traits.dart';
import 'package:miraibo/type/view_obj.dart';
import 'package:miraibo/model/model_surface/estimation_handler.dart';
import 'package:miraibo/model/model_surface/default_object_provider.dart';
import 'package:miraibo/type/enumarations.dart';

/* <estimation ticket configurator>
Estimation Ticket Configurator requires:

- Target Categories
- Content Type
- Period

This section is so simple that there is nothing to mention.

For more details, such as the options for each field, see the component-structure.md or abstruction.md or implementation.
*/
class EstimationTicketConfigSectionController extends SectionController {
  Estimation record;
  EstimationTicketConfigSectionController({Estimation? record})
      : record = record ?? DefaultTicketProvider.estimation;

  @override
  void save() {
    EstimationHandler().save(record);
  }

  @override
  void delete() {
    EstimationHandler().delete(record);
  }

  @override
  bool isSaved() {
    return record.id != null;
  }
}

class EstimationTicketConfigSection extends BasicConfigSectionWidget {
  @override
  final EstimationTicketConfigSectionController sectionController;
  const EstimationTicketConfigSection({
    super.key,
    required this.sectionController,
  });

  @override
  State<EstimationTicketConfigSection> createState() =>
      _EstimationTicketConfiguraitonSectionState();
}

class _EstimationTicketConfiguraitonSectionState
    extends State<EstimationTicketConfigSection> with ConfigSectionState {
  late MultipleCategorySelectorController categoryCtl;
  late InfinitePeriodSelectorController periodCtl;
  late ETContentType contentType;

  @override
  void initSubModuleControllers() {
    categoryCtl = MultipleCategorySelectorController(
      allCategoriesInitiallySelected:
          widget.sectionController.record.targetingAllCategories,
      initiallySelectedCategories:
          widget.sectionController.record.targetCategories,
    );
    periodCtl = InfinitePeriodSelectorController(
      start: widget.sectionController.record.periodBeign,
      end: widget.sectionController.record.periodEnd,
    );
    contentType = widget.sectionController.record.contentType;
  }

  @override
  void onSaveRequired() {
    if (!categoryCtl.isInitialized) {
      showErrorDialog(context,
          'Category selector is not prepared yet. Please wait until it is loaded.');
      return;
    }
    if (!categoryCtl.allCategoriesSelected &&
        categoryCtl.selectedCategories.isEmpty) {
      showErrorDialog(
          context, 'Category unselected. Please select at least one category.');
      return;
    }
    widget.sectionController.record = Estimation(
      targetCategories: categoryCtl.selectedCategories,
      targetingAllCategories: categoryCtl.allCategoriesSelected,
      periodBeign: periodCtl.start,
      periodEnd: periodCtl.end,
      contentType: contentType,
    );
    widget.sectionController.save();
    Navigator.of(context).pop();
  }

  // <components> just to avoid deep nesting

  List<Widget> categorySelector() {
    var width = min(250.0, MediaQuery.of(context).size.width * 0.8);
    return sector('Target Categories',
        MultipleCategorySelector(controller: categoryCtl, width: width));
  }

  List<Widget> contentTypeSelector() {
    return sector(
        'Content Type',
        DropdownMenu<ETContentType>(
          initialSelection: contentType,
          dropdownMenuEntries: const [
            DropdownMenuEntry(
                value: ETContentType.perDay, label: 'estimation per day'),
            DropdownMenuEntry(
                value: ETContentType.perWeek, label: 'estimation per week'),
            DropdownMenuEntry(
                value: ETContentType.perMonth, label: 'estimation per month'),
            DropdownMenuEntry(
                value: ETContentType.perYear, label: 'estimation per year'),
          ],
          onSelected: (value) {
            if (value != null) {
              contentType = value;
            }
          },
        ));
  }

  List<Widget> periodSelector() {
    return sector(
        'Period',
        SizedBox(
            width: min(400, MediaQuery.of(context).size.width * 0.9),
            child: InfinitePeriodSelector(controller: periodCtl)));
  }

  // </components>

  @override
  List<Widget> contentColumn() {
    return [
      ...categorySelector(),
      ...contentTypeSelector(),
      ...periodSelector(),
      spacer(),
    ];
  }
}
// </estimation ticket configurator>
