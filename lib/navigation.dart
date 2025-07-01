import 'package:flutter/material.dart';
import 'package:smart_alarm/pages/alarm_page.dart';
import 'package:smart_alarm/pages/choice_page.dart';
import 'package:smart_alarm/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({required this.onThemeChanged, super.key});

  final void Function(bool) onThemeChanged;

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _readyToWorkout = false;
  int _currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _readyToWorkout = prefs.getBool('readyToWorkout') ?? false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _resetReadyToWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('readyToWorkout', false);
    setState(() {
      _readyToWorkout = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Умный будильник'),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 2) {
              _resetReadyToWorkout();
            }
          });
        },
        children: <Widget>[
          SettingsPage(onThemeChanged: widget.onThemeChanged),
          const AlarmPage(),
          const ChoicePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            if (index == 2) {
              _resetReadyToWorkout();
            }
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Будильники',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.fitness_center,
              color: _readyToWorkout ? Colors.red : null,
            ),
            label: 'Разминка',
          ),
        ],
      ),
    );
  }
}
