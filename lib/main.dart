import 'package:flutter/material.dart';
import 'package:miraibo/page/scheduling_page.dart';
import 'package:miraibo/page/ticket_page.dart';
import 'package:miraibo/page/data_page.dart';
import 'package:miraibo/page/utils_page.dart';
import 'package:miraibo/component/motion.dart';

/* 
This is the entry point of the application. 
*/
void main() {
  runApp(const MyApp());
}

/* 
This widget is the root of the application.
It defines app-wide properties, colorThemes and behaviors.
and home page of the application. home page is the most outer widget of the MaterialApp.
In this case, the home page is a TabView with 4 tabs.
*/
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      scrollBehavior: const MyCustomScrollBehavior(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 255, 203, 91)),
        useMaterial3: true,
      ),
      home: const MyTabView(),
    );
  }
}

/* 
This widget is the main content of the application.
The most important part of TabView is 'Page's, which are displayed when the corresponding tab is selected.
This widget manages the TabBar and TabBarView, and displays each page.
*/
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
