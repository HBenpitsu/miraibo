import 'package:flutter/material.dart';
import 'page/scheduling_page.dart';
import 'page/ticket_page.dart';
import 'page/data_page.dart';
import 'page/utils_page.dart';
import 'general_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      scrollBehavior: const MyCustomScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 190, 156, 81)),
        useMaterial3: true,
      ),
      home: const MyTabView(),
    );
  }
}

class MyTabView extends StatelessWidget {
  const MyTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: SafeArea(
            child: DefaultTabController(
                length: 4,
                initialIndex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TabBar(tabs: [
                      Tab(icon: Icon(Icons.calendar_today)),
                      Tab(icon: Icon(Icons.dashboard)),
                      Tab(icon: Icon(Icons.dataset)),
                      Tab(icon: Icon(Icons.menu)),
                    ]),
                    Expanded(
                      child: TabBarView(
                        children: [
                          SchedulingPage(),
                          TicketPage(),
                          DataPage(),
                          UtilsPage(),
                        ],
                      ),
                    ),
                  ],
                ))));
  }
}
