import 'package:flutter/material.dart';
import 'package:miraibo/ui/component/ticket_configurator_shared_traits.dart';
import 'package:miraibo/ui/component/display_ticket_configurator.dart';
import 'package:miraibo/ui/component/estimation_ticket_configurator.dart';
import 'package:miraibo/ui/component/schedule_ticket_configurator.dart';
import 'package:miraibo/ui/component/log_ticket_configurator.dart';
import 'package:miraibo/model_v2/model_v2.dart';
import 'package:miraibo/type/view_obj.dart' as obj;

/* <applied configurators>
Applied Configurators are the configurators which have some additional features.
*/

/* <logTicket section with preset>
It is extension of LogTicketConfiguraitonSection.
It has a feature to apply preset configurations to the configuration.
The essential log for presetting is implemented in `data_fetcher.dart` (not here), because it exceeds the scope of UI-definition.
*/

class LogTicketConfigSectionWithPreset extends StatefulWidget {
  final LogTicketConfigSectionController sectionController;

  const LogTicketConfigSectionWithPreset(
      {super.key, required this.sectionController});

  @override
  State<LogTicketConfigSectionWithPreset> createState() =>
      _LogTicketConfigSectionWithPresetState();
}

class _LogTicketConfigSectionWithPresetState
    extends State<LogTicketConfigSectionWithPreset> {
  static const int nPreset = 5;
  late Future<List<obj.Preset>> fPresets;

  @override
  void initState() {
    super.initState();
    fPresets = Model.log.presets(nPreset).toList();
  }

  void applyPreset(obj.Preset data) {
    setState(() {
      widget.sectionController.record.category = data.category;
      widget.sectionController.record.supplement = data.supplement;
    });
  }

  Widget presets() {
    return FutureBuilder(
        future: fPresets,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LinearProgressIndicator();
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Text('Error: ${snapshot.error}');
          }
          var fetchedPresetCount = snapshot.data!.length;
          return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(5),
                      child: const Text('Presets: ')),
                  for (var i = 0; i < fetchedPresetCount; i++)
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: TextButton(
                          onPressed: () {
                            applyPreset(snapshot.data![i]);
                          },
                          child: snapshot.data![i].supplement == ''
                              ? Text(snapshot.data![i].category.name)
                              : Text(
                                  '${snapshot.data![i].category.name} - ${snapshot.data![i].supplement}')),
                    )
                ],
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Expanded(
          child: LogTicketConfigSection(
              key: UniqueKey(), // to invoke rebuild after applying preset
              sectionController: widget.sectionController)),
      presets(),
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
class TicketCreationSectionController extends SectionController {
  DateTime date;
  TicketCreationSectionController({required this.date});

  @override
  void save() {}

  @override
  void delete() {
    // nothing to delete.
    // because this is creation section.
  }

  @override
  bool isSaved() {
    return false;
  }
}

class TicketCreationSection extends StatefulWidget {
  final TicketCreationSectionController sectionController;

  const TicketCreationSection({super.key, required this.sectionController});

  @override
  State<TicketCreationSection> createState() => _TicketCreationSectionState();
}

// to get the index of the tab, it uses 'SingleTickerProviderStateMixin' instead of 'DefaultTabController'
class _TicketCreationSectionState extends State<TicketCreationSection>
    with SingleTickerProviderStateMixin {
  static const int tabCount = 4;
  TabController? tabController;

  DisplayTicketConfigSectionController displayTicketConfigCtl =
      DisplayTicketConfigSectionController();
  ScheduleTicketConfigSectionController scheduleTicketConfigCtl =
      ScheduleTicketConfigSectionController();
  EstimationTicketConfigSectionController estimationTicketConfigCtl =
      EstimationTicketConfigSectionController();
  LogTicketConfigSectionController logTicketConfigCtl =
      LogTicketConfigSectionController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: tabCount, vsync: this);
    widget.sectionController.onSaveRequired = () {
      switch (tabController?.index) {
        case 0:
          displayTicketConfigCtl.requireSave();
          break;
        case 1:
          scheduleTicketConfigCtl.requireSave();
          break;
        case 2:
          estimationTicketConfigCtl.requireSave();
          break;
        case 3:
          logTicketConfigCtl.requireSave();
          break;
      }
    };
    // ! this is override !
    widget.sectionController.onDeleteRequired = () {
      // because this is creation section, it does not have delete function
      // just close the window
      Navigator.of(context).pop();
    };
    // <set initial date to each configurator>
    displayTicketConfigCtl.record.periodBegin = widget.sectionController.date;
    displayTicketConfigCtl.record.periodEnd = widget.sectionController.date;
    scheduleTicketConfigCtl.record.originDate = widget.sectionController.date;
    scheduleTicketConfigCtl.record.periodBegin = widget.sectionController.date;
    scheduleTicketConfigCtl.record.periodEnd = widget.sectionController.date;
    estimationTicketConfigCtl.record.periodBeign =
        widget.sectionController.date;
    estimationTicketConfigCtl.record.periodEnd = widget.sectionController.date;
    logTicketConfigCtl.record.date = widget.sectionController.date;
    // </set initial date to each configurator>
  }

  Widget body() {
    return TabBarView(controller: tabController, children: [
      DisplayTicketConfigSection(
        sectionController: displayTicketConfigCtl,
      ),
      ScheduleTicketConfigSection(
        sectionController: scheduleTicketConfigCtl,
      ),
      EstimationTicketConfigSection(
        sectionController: estimationTicketConfigCtl,
      ),
      LogTicketConfigSectionWithPreset(
        sectionController: logTicketConfigCtl,
      ),
    ]);
  }

  Widget tab() {
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
      Expanded(child: body()),
      tab(),
    ]);
  }
}

// </ticket creation section>

// </applied configurators>
