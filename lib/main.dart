import 'package:flutter/material.dart';
import 'package:miraibo/ui/page/scheduling_page.dart';
import 'package:miraibo/ui/page/ticket_page.dart';
import 'package:miraibo/ui/page/data_page.dart';
import 'package:miraibo/ui/page/utils_page.dart';
import 'package:miraibo/ui/component/motion.dart';
import 'package:miraibo/ui/component/modal_controller.dart';
import 'package:miraibo/model_v2/model_v2.dart';

/* 
This is the entry point of the application. 
*/
void main() async {
  runApp(const MyApp());
}

// /* clear db */
// void main() async {
//   RelationalDatabaseProvider dbProvider = MainDatabaseProvider();
//   await dbProvider.clear();
// }

// RootController is a controller which has all the controllers as tree structure.
class RootController {
  final SchedulingPageController schedulingPageController =
      SchedulingPageController();
  final ModalController modalController = ModalController();
  Future<void> initializeModel() async {
    await regularEventDispacher.initApp();
  }
}

final rootController = RootController();

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
      home: FutureBuilder(
        future: rootController.initializeModel(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AppLoadingScreen();
          }
          return const MyTabView();
        },
      ),
    );
  }
}

/*
Until the model is initialized, this widget displays a Loading Screen rather than black screen.
*/

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Miraibo')));
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
    return Scaffold(
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
                          SchedulingPage(
                              ctl: rootController.schedulingPageController),
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
