import 'package:flutter/material.dart';
import 'package:miraibo/data/handler.dart';
import 'package:miraibo/data/objects.dart';

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
  final LogTicketConfigData data;
  const LogTicket({super.key, required this.onPressed, required this.data});

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(ticketKind: 'Log', onPressed: onPressed, topLabel: [
      data.category?.name ?? '',
      data.supplement == '' ? '' : ' - ${data.supplement}'
    ], content: [
      Text(data.amount < 0 ? 'outcome  ' : 'income  '),
      Text(
        '${data.amount.abs()}',
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    ], bottomLabel: [
      '${data.registorationDate?.year}-${data.registorationDate?.month}-${data.registorationDate?.day}'
    ]);
  }
}

class ScheduleTicket extends StatelessWidget {
  final void Function() onPressed;
  final ScheduleTicketConfigData data;
  final bool forSchedule;
  const ScheduleTicket(
      {super.key,
      required this.onPressed,
      required this.data,
      this.forSchedule = true});

  String dateLabel() {
    String label = '';
    if (forSchedule) {
      if (data.repeatType != RepeatType.no) {
        label += 'repeated ';
        if (data.startDateDesignated) {
          label +=
              'from ${data.startDate?.year}-${data.startDate?.month}-${data.startDate?.day} ';
        }
        if (data.endDateDesignated) {
          label +=
              'until ${data.endDate?.year}-${data.endDate?.month}-${data.endDate?.day} ';
        }
      } else {
        label +=
            'scheduled at: ${data.startDate?.year}-${data.startDate?.month}-${data.startDate?.day} ';
      }
    } else {
      label +=
          '${data.startDate?.year}-${data.startDate?.month}-${data.startDate?.day} ';
    }
    return label;
  }

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
        ticketKind: 'Schedule',
        onPressed: onPressed,
        topLabel: [
          data.category?.name ?? '',
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
  final DisplayTicketConfigData data;
  const DisplayTicket({super.key, required this.onPressed, required this.data});

  List<String> categoryLabel() {
    if (data.targetingAllCategories) {
      return ['all categories'];
    } else {
      return [for (var category in data.targetCategories) '${category.name}, '];
    }
  }

  Widget content(BuildContext context) {
    return FutureBuilder(
        future: StatisticalAnalyzer().calcValueForDisplayTicket(data),
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
      DisplayTicketContentType.dailyAverage => 'daily average ',
      DisplayTicketContentType.dailyQuartileAverage =>
        'daily quartile average ',
      DisplayTicketContentType.monthlyAverage => 'monthly average: ',
      DisplayTicketContentType.monthlyQuartileAverage =>
        'monthly quartile average ',
      DisplayTicketContentType.summation => 'summation ',
    };
  }

  String dateLabel() {
    return switch (data.termMode) {
      DisplayTicketTermMode.untilToday => 'until today',
      DisplayTicketTermMode.lastDesignatedPeriod => switch (
            data.designatedPeriod) {
          DisplayTicketPeriod.week => 'for last week',
          DisplayTicketPeriod.month => 'for last month',
          DisplayTicketPeriod.halfYear => 'for last half year',
          DisplayTicketPeriod.year => 'for last year',
        },
      DisplayTicketTermMode.untilDesignatedDate =>
        'until ${data.designatedDate?.year}-${data.designatedDate?.month}-${data.designatedDate?.day}',
    };
  }

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
      ticketKind: 'Display',
      onPressed: onPressed,
      topLabel: categoryLabel(),
      content: [content(context)],
      bottomLabel: [contentTypeLabel(), dateLabel()],
    );
  }
}

class EstimationTicket extends StatelessWidget {
  final void Function() onPressed;
  final EstimationTicketConfigData data;
  const EstimationTicket(
      {super.key, required this.onPressed, required this.data});

  List<String> categoryLabel(BuildContext context) {
    if (data.targetingAllCategories) {
      return ['all categories'];
    } else {
      return [for (var category in data.targetCategories) '${category.name}, '];
    }
  }

  Widget content(BuildContext context) {
    return FutureBuilder(
        future: StatisticalAnalyzer().calcValueForEstimationTicket(data),
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

  String contentTypeLabel(BuildContext context) {
    return switch (data.contentType) {
      EstimationTicketContentType.perDay => 'per day ',
      EstimationTicketContentType.perWeek => 'per week ',
      EstimationTicketContentType.perMonth => 'per month ',
      EstimationTicketContentType.perYear => 'per year ',
    };
  }

  List<String> dateLabel(BuildContext context) {
    return [
      if (!data.startDateDesignated && !data.endDateDesignated)
        'for all period',
      if (data.startDateDesignated)
        'from ${data.startDate?.year}-${data.startDate?.month}-${data.startDate?.day} ',
      if (data.endDateDesignated)
        'until ${data.endDate?.year}-${data.endDate?.month}-${data.endDate?.day} ',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
      ticketKind: 'Estimation',
      onPressed: onPressed,
      topLabel: categoryLabel(context),
      content: [content(context)],
      bottomLabel: [contentTypeLabel(context), ...dateLabel(context)],
    );
  }
}

// </ticket instances>
