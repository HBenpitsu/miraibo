import 'package:flutter/material.dart';
import 'package:miraibo/data_types.dart';

class TicketTemplate extends StatelessWidget {
  final void Function() onPressed;
  final String ticketName;
  final Widget content;
  const TicketTemplate(
      {super.key,
      required this.onPressed,
      required this.ticketName,
      required this.content});

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
                  Row(children: [
                    Text(ticketName,
                        style: Theme.of(context).textTheme.labelSmall),
                    Spacer()
                  ]),
                  Expanded(child: content),
                ])),
          ),
        ));
  }
}

class LogTicket extends StatelessWidget {
  final void Function() onPressed;
  final LogTicketConfigurationData data;
  const LogTicket({super.key, required this.onPressed, required this.data});

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
        ticketName: 'Log',
        onPressed: onPressed,
        content: Column(children: [
          Row(children: [
            Flexible(
                child: data.supplement == ''
                    ? Text('${data.category?.name}',
                        style: Theme.of(context).textTheme.labelLarge)
                    : Text('${data.category?.name} - ${data.supplement}',
                        style: Theme.of(context).textTheme.labelLarge)),
          ]),
          Spacer(),
          Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Spacer(),
                Text(data.amount < 0 ? 'outcome  ' : 'income  '),
                Text(
                  '${data.amount.abs()}',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Spacer(),
              ]),
          Spacer(),
          Row(
            children: [
              Spacer(),
              Text(
                  '${data.registorationDate?.year}-${data.registorationDate?.month}-${data.registorationDate?.day}'),
            ],
          )
        ]));
  }
}

class ScheduleTicket extends StatelessWidget {
  final void Function() onPressed;
  final ScheduleTicketConfigurationData data;
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
        ticketName: 'Schedule',
        onPressed: onPressed,
        content: Column(
          children: [
            Row(children: [
              Flexible(
                child: data.supplement == ''
                    ? Text('${data.category?.name}',
                        style: Theme.of(context).textTheme.labelLarge)
                    : Text('${data.category?.name} - ${data.supplement}',
                        style: Theme.of(context).textTheme.labelLarge),
              )
            ]),
            Spacer(),
            Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Spacer(),
                  Text(data.amount < 0 ? 'outcome  ' : 'income  '),
                  Text(
                    '${data.amount.abs()}',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Spacer(),
                ]),
            Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [Flexible(child: Text(dateLabel()))],
            )
          ],
        ));
  }
}

class DisplayTicket extends StatelessWidget {
  final void Function() onPressed;
  final DisplayTicketConfigurationData data;
  const DisplayTicket({super.key, required this.onPressed, required this.data});

  Widget termMode() {
    return Text('');
  }

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
        ticketName: 'Display',
        onPressed: onPressed,
        content: Column(
          children: [],
        ));
  }
}

class EstimationTicket extends StatelessWidget {
  final void Function() onPressed;
  final EstimationTicketConfigurationData data;
  const EstimationTicket(
      {super.key, required this.onPressed, required this.data});

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
        ticketName: 'Estimation',
        onPressed: onPressed,
        content: Column(
          children: [],
        ));
  }
}
