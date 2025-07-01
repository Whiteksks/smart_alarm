import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MathPage extends StatefulWidget {
  const MathPage({super.key});

  @override
  State<MathPage> createState() => _MathPageState();
}

class _MathPageState extends State<MathPage> {
  final List<int> _numbers1 = List.generate(3, (_) => Random().nextInt(81) + 10);
  final List<int> _numbers2 = List.generate(3, (_) => Random().nextInt(81) + 10);
  final List<TextEditingController> _controllers = List.generate(3, (_) => TextEditingController());
  final List<bool?> _results = List.generate(3, (_) => null);
  bool _allTasksCompleted = false;

  Future<void> _checkAnswers() async {
    setState(() {
      for (int i = 0; i < 3; i++) {
        final userAnswer = int.tryParse(_controllers[i].text);
        _results[i] = userAnswer == (_numbers1[i] + _numbers2[i]);
      }
      _allTasksCompleted = _results.every((result) => result == true);
    });

    if (_allTasksCompleted) {
      await _saveTaskCompletionDate();
      _showCompletionMessage();
    }
  }

  Future<void> _saveTaskCompletionDate() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('dd.MM.yyyy').format(DateTime.now());
    await prefs.setString('lastMathTaskDate', today);
  }

  Future<void> _checkTaskStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCompletedDate = prefs.getString('lastMathTaskDate');
    final today = DateFormat('dd.MM.yyyy').format(DateTime.now());

    if (lastCompletedDate == today) {
      setState(() {
        _allTasksCompleted = true;
      });
    }
  }

  void _showCompletionMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Поздравляем!'),
        content: const Text('Вы правильно решили все задачи!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _checkTaskStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Математические задачи'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ...List.generate(3, (index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_numbers1[index]} + ${_numbers2[index]} = ',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Ответ',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (_results[index] != null)
                        Icon(
                          _results[index]! ? Icons.check_circle : Icons.cancel,
                          color: _results[index]! ? Colors.green : Colors.red,
                        ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkAnswers,
              child: const Text('Проверить'),
            ),
            if (_allTasksCompleted)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(
                  'Все задачи решены правильно! Отличная работа!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
