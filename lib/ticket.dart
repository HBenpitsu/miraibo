import 'package:flutter/material.dart';

class TicketTemplate extends StatelessWidget {
  final void Function() onPressed;
  final Widget content;
  const TicketTemplate(
      {super.key, required this.onPressed, required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => onPressed(),
        child: Card(
          child: SizedBox(
            height: 150,
            child: content,
          ),
        ));
  }
}

class LogTicket extends StatelessWidget {
  final void Function() onPressed;
  const LogTicket({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
        onPressed: onPressed, content: const Text('Log Ticket'));
  }
}

class ScheduleTicket extends StatelessWidget {
  final void Function() onPressed;
  const ScheduleTicket({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
        onPressed: onPressed, content: const Text('Schedule Ticket'));
  }
}

class DisplayTicket extends StatelessWidget {
  final void Function() onPressed;
  const DisplayTicket({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
        onPressed: onPressed, content: const Text('Display Ticket'));
  }
}

class EstimationTicket extends StatelessWidget {
  final void Function() onPressed;
  const EstimationTicket({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TicketTemplate(
        onPressed: onPressed, content: const Text('Estimation Ticket'));
  }
}
