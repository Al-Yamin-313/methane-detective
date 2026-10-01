import 'package:flutter/material.dart';
import 'theme.dart';
import 'app/app_shell.dart';

void main() {
  runApp(const MethaneDetectiveApp());
}

class MethaneDetectiveApp extends StatelessWidget {
  const MethaneDetectiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Methane Detective',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const AppShell(),
    );
  }
}
