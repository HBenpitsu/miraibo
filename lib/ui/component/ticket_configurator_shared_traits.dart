import 'package:flutter/material.dart';

// <data edit modal window> a container of a configuration section
/* 
DataEditWindow is a modal bottom sheet that contains a configuration section.
Itself has save and delete buttons, and the configuration section is placed in the window.
To convey save-event and delete-event to the configuration section, it has a controller.
*/
const double dataEditWindowHeightFraction = 0.8;

/// [configurationSection] should have the same [controller] as the [controller] passed to handles save and delete-event.
void showDataEditWindow(BuildContext context, Widget configurationSection,
    SectionController controller) {
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
                          controller.requireSave();
                        },
                        icon: const Icon(Icons.save),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.requireDelete();
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
basicConfigSection has windowControllers to receive save,delete-event.
It also has sectionControllers to manage the data of the configuration section.
*/
abstract class SectionController {
  void save();
  void Function()? onSaveRequired;
  void requireSave() {
    if (onSaveRequired != null) {
      onSaveRequired!();
    }
  }

  void delete();
  void Function()? onDeleteRequired;
  void requireDelete() {
    if (onDeleteRequired != null) {
      onDeleteRequired!();
    }
  }

  bool isSaved();
}

abstract class BasicConfigSectionWidget extends StatefulWidget {
  abstract final SectionController sectionController;

  const BasicConfigSectionWidget({super.key});
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
  List<Widget> sector(String title, Widget child) {
    return [
      Padding(
          padding: const EdgeInsets.only(top: 10),
          child:
              Text(title, style: Theme.of(context).textTheme.headlineMedium)),
      Padding(padding: const EdgeInsets.only(top: 10, bottom: 10), child: child)
    ];
  }

  /// spacer to allow the form to be scrolled
  Widget spacer() {
    return SizedBox(
      height:
          MediaQuery.of(context).size.height * dataEditWindowHeightFraction / 2,
    );
  }

  void onDeleteRequired() {
    if (!widget.sectionController.isSaved()) {
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
                    widget.sectionController.delete();
                    // close the modal bottom sheet at the same time
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Delete')),
            ],
          );
        });
  }

  void initSubModuleControllers();
  void onSaveRequired();

  @override
  void initState() {
    super.initState();
    initSubModuleControllers();
    widget.sectionController.onDeleteRequired = () {
      if (mounted) {
        onDeleteRequired();
      }
    };
    widget.sectionController.onSaveRequired = () {
      if (mounted) {
        onSaveRequired();
      }
    };
  }

  List<Widget> contentColumn();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: SingleChildScrollView(
            child: Column(
      children: contentColumn(),
    )));
  }
}
// </shared traits>
