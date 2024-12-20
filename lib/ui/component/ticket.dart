import 'package:flutter/material.dart';
import 'package:miraibo/model_v2/model_v2.dart';
import 'package:miraibo/type/view_obj.dart' as view_obj;
import 'package:miraibo/type/enumarations.dart';

/*
TicketTemplate is a template widget for displaying tickets.
Tickets are basically a sized card that contains some information about the data.

Primary responsibility of `Ticket` Widgets is to convert config data into String and then into widgets.
Generally, the Template helps converting String into widgets.
*/
class TicketTemplate extends StatelessWidget {
  final void Function() onPressed;
  final String ticketKind;
  final List<String> topLabel;
  final List<Widget> content;
  final List<String> bottomLabel;
  const TicketTemplate({
    super.key,
    required this.onPressed,
    required this.ticketKind,
    required this.topLabel,
    required this.content,
    required this.bottomLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onPressed(),
        child: Card(
          child: SizedBox(
            height: 150,
            child: Padding(
                padding: EdgeInsets.all(5),
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Text(ticketKind,
                        style: Theme.of(context).textTheme.labelSmall),
                  ]),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Wrap(
                        alignment: WrapAlignment.start,
                        runAlignment: WrapAlignment.start,
                        children: [
                          for (var label in topLabel)
                            Text(label,
                                style: Theme.of(context).textTheme.labelLarge)
                        ])
                  ]),
                  Spacer(),
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      mainAxisAlignment: MainAxisAlignment.center,
                      textBaseline: TextBaseline.alphabetic,
                      children: [...content]),
                  Spacer(),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Wrap(children: [
                      for (var label in bottomLabel)
                        Text(label,
                            style: Theme.of(context).textTheme.labelMedium)
                    ])
                  ]),
                ])),
          ),
        ));
  }
}

/* <ticket instances>
All Tickets do is to convert config data into Widgets.
Some consult data_handler to calculate the value to display.
*/
class LogTicket extends StatelessWidget {
  final void Function() onPressed;
  final view_obj.Log data;
  const LogTicket({super.key, required this.onPressed, required this.data});

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(ticketKind: 'Log', onPressed: onPressed, topLabel: [
      data.category.name,
      data.supplement == '' ? '' : ' - ${data.supplement}'
    ], content: [
      Text(data.amount < 0 ? 'outcome  ' : 'income  '),
      Text(
        '${data.amount.abs()}',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    ], bottomLabel: [
      '${data.date.year}-${data.date.month}-${data.date.day}'
    ]);
  }
}

class ScheduleTicket extends StatelessWidget {
  final void Function() onPressed;
  final view_obj.Schedule data;
  const ScheduleTicket(
      {super.key, required this.onPressed, required this.data});

  String dateLabel() {
    String label = '';
    if (data.repeatType != ScheduleRepeatType.no) {
      label += 'repeated ';
      if (data.periodBegin != null) {
        label +=
            'from ${data.periodBegin?.year}-${data.periodBegin?.month}-${data.periodBegin?.day} ';
      }
      if (data.periodEnd != null) {
        label +=
            'until ${data.periodEnd?.year}-${data.periodEnd?.month}-${data.periodEnd?.day} ';
      }
    } else {
      label +=
          'scheduled at: ${data.originDate.year}-${data.originDate.month}-${data.originDate.day} ';
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
        ticketKind: 'Schedule',
        onPressed: onPressed,
        topLabel: [
          data.category.name,
          data.supplement == '' ? '' : ' - ${data.supplement}'
        ],
        content: [
          Text(data.amount < 0 ? 'outcome  ' : 'income  '),
          Text(
            '${data.amount.abs()}',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
        bottomLabel: [
          dateLabel()
        ]);
  }
}

class DisplayTicket extends StatelessWidget {
  final void Function() onPressed;
  final view_obj.Display data;
  const DisplayTicket({super.key, required this.onPressed, required this.data});

  List<String> categoryLabel() {
    if (data.targetingAllCategories) {
      return ['all categories'];
    } else {
      return [for (var category in data.targetCategories) '${category.name}, '];
    }
  }

  Widget content() {
    return FutureBuilder(
        future: Model.display.content(data),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Text(snapshot.data!.toString(),
                style: Theme.of(context).textTheme.headlineLarge);
          } else {
            return Text('---',
                style: Theme.of(context).textTheme.headlineLarge);
          }
        });
  }

  String contentTypeLabel() {
    return switch (data.contentType) {
      DisplayContentType.dailyAverage => 'daily average ',
      DisplayContentType.dailyQuartileAverage => 'daily quartile average ',
      DisplayContentType.monthlyAverage => 'monthly average: ',
      DisplayContentType.monthlyQuartileAverage => 'monthly quartile average ',
      DisplayContentType.summation => 'summation ',
    };
  }

  String dateLabel() {
    return switch (data.termMode) {
      DisplayTermMode.untilToday => 'until today',
      DisplayTermMode.lastPeriod => switch (data.displayPeriod) {
          DisplayPeriod.week => 'for last week',
          DisplayPeriod.month => 'for last month',
          DisplayPeriod.halfYear => 'for last half year',
          DisplayPeriod.year => 'for last year',
        },
      DisplayTermMode.untilDate =>
        'until ${data.periodEnd?.year}-${data.periodEnd?.month}-${data.periodEnd?.day}',
      DisplayTermMode.specificPeriod =>
        'from ${data.periodBegin?.year}-${data.periodBegin?.month}-${data.periodBegin?.day} '
            'until ${data.periodEnd?.year}-${data.periodEnd?.month}-${data.periodEnd?.day}',
    };
  }

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
      ticketKind: 'Display',
      onPressed: onPressed,
      topLabel: categoryLabel(),
      content: [content()],
      bottomLabel: [contentTypeLabel(), dateLabel()],
    );
  }
}

class EstimationTicket extends StatelessWidget {
  final void Function() onPressed;
  final view_obj.Estimation data;
  const EstimationTicket(
      {super.key, required this.onPressed, required this.data});

  List<String> categoryLabel() {
    if (data.targetingAllCategories) {
      return ['all categories'];
    } else {
      return [for (var category in data.targetCategories) '${category.name}, '];
    }
  }

  Widget content() {
    return FutureBuilder(
        future: Model.estimation.content(data),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Text(snapshot.data!.toString(),
                style: Theme.of(context).textTheme.headlineLarge);
          } else {
            return Text('---',
                style: Theme.of(context).textTheme.headlineLarge);
          }
        });
  }

  String contentTypeLabel() {
    return switch (data.contentType) {
      EstimationContentType.perDay => 'per day ',
      EstimationContentType.perWeek => 'per week ',
      EstimationContentType.perMonth => 'per month ',
      EstimationContentType.perYear => 'per year ',
    };
  }

  List<String> dateLabel() {
    return [
      if (data.periodBeign == null && data.periodEnd == null) 'for all period',
      if (data.periodBeign != null)
        'from ${data.periodBeign?.year}-${data.periodBeign?.month}-${data.periodBeign?.day} ',
      if (data.periodEnd != null)
        'until ${data.periodEnd?.year}-${data.periodEnd?.month}-${data.periodEnd?.day} ',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
      ticketKind: 'Estimation',
      onPressed: onPressed,
      topLabel: categoryLabel(),
      content: [content()],
      bottomLabel: [contentTypeLabel(), ...dateLabel()],
    );
  }
}

// </ticket instances>
