import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_all/common/theme/app_theme.dart';

import 'features/condition/presentation/pages/condition_form_page.dart';
import 'features/condition/presentation/pages/statistics_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '안전운임제 계산기',
      theme: appTheme(),
      home: ConditionFormPage(),
      routes: {'/statistics': (context) => const StatisticsPage()},
    );
  }
}
