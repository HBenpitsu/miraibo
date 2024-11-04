import 'dart:math';

import 'package:flutter/material.dart';
import 'package:miraibo/ui/component/category.dart';

class UtilsPage extends StatefulWidget {
  const UtilsPage({super.key});

  @override
  State<UtilsPage> createState() => _UtilsPageState();
}

class _UtilsPageState extends State<UtilsPage> {
  @override
  Widget build(BuildContext context) {
    var categorySelectorWidth =
        min(500.0, MediaQuery.of(context).size.width * 0.8);
    return Scaffold(
      body: Center(
        child: CategoryEditorSection(width: categorySelectorWidth),
      ),
    );
  }
}
