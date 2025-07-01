import 'package:flutter/material.dart';

class DebugInfoWidget extends StatelessWidget {
  final int numberOfExercise;
  final double x, y, z;
  final Map<int, int> exerciseCount;
  final List<String> debugHistory;
  final VoidCallback onButtonPressed;

  const DebugInfoWidget({
    super.key,
    required this.numberOfExercise,
    required this.x,
    required this.y,
    required this.z,
    required this.exerciseCount,
    required this.debugHistory,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: onButtonPressed, child: Text("Add $numberOfExercise")),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('x: ${x.toStringAsFixed(2)}'),
              Text('y: ${y.toStringAsFixed(2)}'),
              Text('z: ${z.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              Text('Приседания: ${exerciseCount[0]}'),
              Text('Выпады: ${exerciseCount[1]}'),
              Text('Поднятие рук: ${exerciseCount[2]}'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Debug History: \n${debugHistory.join(' ')}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
