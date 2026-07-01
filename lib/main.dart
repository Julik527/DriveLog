import 'package:flutter/material.dart';

import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DriveLogApp());
}

/// Haupt-App von DriveLog.
///
/// DriveLog ist bewusst als echte Flutter-App aufgebaut. Die App speichert Daten
/// lokal auf dem Gerät und kann später weiter ausgebaut werden.
class DriveLogApp extends StatelessWidget {
  const DriveLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: const DashboardScreen(),
    );
  }
}
