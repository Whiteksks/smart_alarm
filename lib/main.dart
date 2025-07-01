import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_alarm/pages/alarm_page.dart';
import 'package:smart_alarm/pages/exercise_page.dart';
import 'package:smart_alarm/pages/settings_page.dart';

import 'navigation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    });
    _updateSystemUI();
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
    });
    _saveThemePreference(isDark);
    _updateSystemUI();
  }

  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
  }

  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: _isDarkTheme ? Colors.black : Colors.white,
      systemNavigationBarIconBrightness: _isDarkTheme ? Brightness.light : Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => NavigationPage(onThemeChanged: _toggleTheme),
        '/alarm': (context) => const AlarmPage(),
        '/settings': (context) => SettingsPage(onThemeChanged: _toggleTheme),
        '/exercises': (context) => const ExercisePage(),
      },
    );
  }
}
