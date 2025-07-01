import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_alarm/pages/exercise_page.dart';
import 'package:smart_alarm/pages/math_page.dart';

class ChoicePage extends StatefulWidget {
  const ChoicePage({super.key});

  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  bool _isExerciseCompleted = false;
  bool _isMathCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadCompletionStatus();
  }

  Future<void> _loadCompletionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('dd.MM.yyyy').format(DateTime.now());

    setState(() {
      _isExerciseCompleted = prefs.getString('lastExerciseDate') == today;
      _isMathCompleted = prefs.getString('lastMathDate') == today;
    });
  }

  void _showAlreadyCompletedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Задача уже выполнена!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбор упражнений'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(
              context,
              title: 'Физические упражнения',
              description: 'Помогает улучшить физическое состояние',
              isCompleted: _isExerciseCompleted,
              onTap: () {
                if (_isExerciseCompleted) {
                  _showAlreadyCompletedMessage();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExercisePage()),
                  );
                }
              },
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              title: 'Математические задачи',
              description: 'Разминка мозга тоже важна',
              isCompleted: _isMathCompleted,
              onTap: () {
                if (_isMathCompleted) {
                  _showAlreadyCompletedMessage();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MathPage()),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {
    required String title,
    required String description,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
