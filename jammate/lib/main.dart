import 'package:flutter/material.dart';

import 'data/app_state.dart';
import 'db/app_database.dart';
import 'screens/main_shell.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Open (or create) the SQLite database.
  await AppDatabase.instance.init();

  // If the user logged in before, go straight to the app.
  Widget home = const WelcomeScreen();
  final email = await AppDatabase.instance.getSetting('session');
  if (email != null && email.isNotEmpty) {
    final ok = await AppState.loadAll(email);
    if (ok) home = const MainShell();
  }

  runApp(JamMateApp(home: home));
}

class JamMateApp extends StatelessWidget {
  final Widget home;
  const JamMateApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JamMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: home,
    );
  }
}
