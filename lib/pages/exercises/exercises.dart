import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ExerciseInstructionWidget extends StatefulWidget {
  final int numberOfExercise;
  final Map<int, String> exerciseInfo;
  final int targetReps;
  final int currentReps;
  final Map<int, int> exerciseCount;
  final Map<int, bool> completedExercises;
  final VoidCallback onExerciseCompleted;

  const ExerciseInstructionWidget({
    super.key,
    required this.numberOfExercise,
    required this.exerciseInfo,
    required this.targetReps,
    required this.currentReps,
    required this.exerciseCount,
    required this.completedExercises,
    required this.onExerciseCompleted,
  });

  @override
  State<ExerciseInstructionWidget> createState() =>
      _ExerciseInstructionWidgetState();
}

class _ExerciseInstructionWidgetState
    extends State<ExerciseInstructionWidget> {
  bool _isWarmupCompletedToday = false;

  @override
  void initState() {
    super.initState();
    _checkWarmupStatus();
  }

  Future<void> _checkWarmupStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCompletedDate = prefs.getString('lastWarmupDate');
    final today = DateFormat('dd.MM.yyyy').format(DateTime.now());

    if (lastCompletedDate == today) {
      setState(() {
        _isWarmupCompletedToday = true;
      });
    } else {
      widget.completedExercises.clear();
      setState(() {
        _isWarmupCompletedToday = false;
      });
    }
  }

  Future<void> _saveWarmupCompletionDate() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('dd.MM.yyyy').format(DateTime.now());
    await prefs.setString('lastWarmupDate', today);
  }

  @override
  Widget build(BuildContext context) {
    final allExercisesCompleted =
        widget.completedExercises.length == widget.exerciseInfo.length &&
            widget.completedExercises.values.every((isCompleted) => isCompleted);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Тренировка"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.exerciseInfo.length,
                itemBuilder: (context, index) {
                  final isCurrent = index == widget.numberOfExercise;
                  final exerciseName = widget.exerciseInfo[index]!;
                  final completedReps = widget.exerciseCount[index] ?? 0;
                  final isCompleted = widget.completedExercises[index] ?? false;

                  return Card(
                    elevation: isCurrent ? 8 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isCurrent
                          ? const BorderSide(color: Colors.blue, width: 2)
                          : BorderSide.none,
                    ),
                    color: (isCompleted || _isWarmupCompletedToday)
                        ? Colors.grey[300]
                        : isCurrent
                        ? Colors.blue[50]
                        : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Упражнение ${index + 1}: $exerciseName',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: (isCompleted || _isWarmupCompletedToday)
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  color: (isCompleted || _isWarmupCompletedToday)
                                      ? Colors.black38
                                      : Colors.black,
                                ),
                              ),
                              if (isCurrent && !isCompleted && !_isWarmupCompletedToday)
                                const Icon(
                                  Icons.fitness_center,
                                  color: Colors.blueAccent,
                                ),
                              if (isCompleted || _isWarmupCompletedToday)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Цель: ${widget.targetReps} повторений',
                            style: TextStyle(
                              fontSize: 16,
                              color: (isCompleted || _isWarmupCompletedToday) ? Colors.black38 : Colors.black,
                            ),
                          ),
                          Text(
                            _isWarmupCompletedToday
                                ? 'Выполнено: ${widget.targetReps} / ${widget.targetReps}'
                                : 'Выполнено: $completedReps / ${widget.targetReps}',
                            style: TextStyle(
                              fontSize: 16,
                              color: (isCompleted || _isWarmupCompletedToday)
                                  ? Colors.black38
                                  : isCurrent
                                  ? Colors.blueAccent
                                  : Colors.black87,
                            ),
                          ),
                          if (isCurrent && !isCompleted && !_isWarmupCompletedToday) ...[
                            const SizedBox(height: 10),
                            LinearProgressIndicator(
                              value: (widget.exerciseCount[widget.numberOfExercise] ?? 0) / widget.targetReps,
                              backgroundColor: Colors.blue[100],
                              color: Colors.blueAccent,
                              minHeight: 8,
                            ),
                            const SizedBox(height: 10),
                            // ElevatedButton(
                            //   onPressed: widget.onExerciseCompleted,
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: Colors.blueAccent,
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(12),
                            //     ),
                            //   ),
                            //   child: const Text('Завершить упражнение'),
                            // ),
                          ],
                        ],
                      ),

                    ),
                  );
                },
              ),
            ),
            if (allExercisesCompleted && !_isWarmupCompletedToday) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveWarmupCompletionDate();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Поздравляем!"),
                      content: const Text("Вы завершили тренировку."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Закрыть"),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  "Завершить тренировку",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
            ],
            if (_isWarmupCompletedToday) ...[
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('lastWarmupDate', '01.01.2021');
                  setState(() {
                    _isWarmupCompletedToday = false;
                  });
                },
                child: const Text("Restart"),
              ),
              const Text(
                "Вы уже завершили тренировку сегодня. Попробуйте снова завтра.",
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
