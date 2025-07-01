import 'package:flutter/material.dart';

class AlarmCard extends StatelessWidget {
  final TimeOfDay selectedTime;
  final VoidCallback onSelectTime;
  final VoidCallback onCreateAlarm;

  const AlarmCard({
    super.key,
    required this.selectedTime,
    required this.onSelectTime,
    required this.onCreateAlarm,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.alarm,
                  size: 30,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    'Создать будильник на ${selectedTime.format(context)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: onSelectTime,
                  child: const Text('Изменить время'),
                ),
                ElevatedButton(
                  onPressed: onCreateAlarm,
                  child: const Text('Создать'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
