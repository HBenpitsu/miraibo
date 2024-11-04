import 'dart:math';

import 'package:flutter/material.dart';
import 'package:miraibo/ui/component/category.dart';
import 'package:miraibo/ui/component/configurator_component.dart';
import 'package:miraibo/ui/component/general_widget.dart';
import 'package:miraibo/ui/component/ticket_configurator_shared_traits.dart';
import 'package:miraibo/model/model_surface/log_handler.dart';
import 'package:miraibo/type/view_obj.dart';
import 'package:miraibo/model/model_surface/default_object_provider.dart';
import 'package:miraibo/util/date_time.dart';

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
class LogTicketConfigSectionController extends SectionController {
  Log record;
  LogTicketConfigSectionController({Log? record})
      : record = record ?? DefaultTicketProvider.log;

  @override
  void save() {
    LogHandler().save(record);
  }

  @override
  void delete() {
    LogHandler().delete(record);
  }

  @override
  bool isSaved() {
    return record.id != null;
  }
}

class LogTicketConfigSection extends BasicConfigSectionWidget {
  @override
  final LogTicketConfigSectionController sectionController;
  const LogTicketConfigSection({
    super.key,
    required this.sectionController,
  });

  @override
  State<LogTicketConfigSection> createState() =>
      _LogTicketConfiguraitonSectionState();
}

class _LogTicketConfiguraitonSectionState extends State<LogTicketConfigSection>
    with ConfigSectionState {
  late SingleCategorySelectorController categorySelectorCtl;
  late TextEditingController supplementationCtl;
  late DatePickButtonController registorationDateCtl;
  late MoneyformController amountCtl;
  late PictureSelectorController pictureSelectorCtl;

  @override
  void initSubModuleControllers() {
    categorySelectorCtl = SingleCategorySelectorController(
      initiallySelectedCategory: widget.sectionController.record.category,
    );
    supplementationCtl =
        TextEditingController(text: widget.sectionController.record.supplement);
    registorationDateCtl = DatePickButtonController(
      initialDate: widget.sectionController.record.date,
    );
    amountCtl =
        MoneyformController(amount: widget.sectionController.record.amount);
    pictureSelectorCtl = PictureSelectorController();
  }

  @override
  void onSaveRequired() {
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
    widget.sectionController.record = Log(
      category: categorySelectorCtl.selected!,
      supplement: supplementationCtl.text,
      date: registorationDateCtl.selected ?? today(),
      amount: amountCtl.amount,
      image: pictureSelectorCtl.picture,
      // do not change 'confirmed' field in this section
      confirmed: widget.sectionController.record.confirmed,
    );
    widget.sectionController.save();

    Navigator.of(context).pop();
  }

  // <components> just to avoid deep nesting

  List<Widget> categorySelector() {
    return sector(
        'Category', SingleCategorySelector(controller: categorySelectorCtl));
  }

  List<Widget> supplementationForm() {
    var width = min(300.0, MediaQuery.of(context).size.width * 0.8);
    return sector(
        'Supplementation',
        SizedBox(
          width: width,
          child: TextField(
            controller: supplementationCtl,
          ),
        ));
  }

  List<Widget> datePick() {
    return sector(
        'Date',
        DatePickButton(
          controller: registorationDateCtl,
        ));
  }

  List<Widget> amountForm() {
    return sector(
        'Amount',
        Moneyform(
          controller: amountCtl,
        ));
  }

  List<Widget> pictureSelector() {
    return sector(
        'Picture of receipts',
        PictureSelectButton(
          controller: pictureSelectorCtl,
        ));
  }

  @override
  List<Widget> contentColumn() {
    return [
      ...categorySelector(),
      ...supplementationForm(),
      ...datePick(),
      ...amountForm(),
      ...pictureSelector(),
      spacer(),
    ];
  }
}
// </log ticket configurator>