import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPlayerWidget extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final double currentSliderValue;
  final String? imageUrl;

  const AudioPlayerWidget({
    super.key,
    required this.audioPlayer,
    required this.currentSliderValue,
    this.imageUrl,
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
          children: [
            if (imageUrl != null)
              Image.asset(
                imageUrl!,
                height: 150,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 10),
            Slider(
              value: currentSliderValue,
              min: 0,
              max: audioPlayer.duration?.inSeconds.toDouble() ?? 1.0,
              onChanged: (value) {
                audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
