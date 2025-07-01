import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:smart_alarm/pages/widgets/alarm_card.dart';
import 'package:smart_alarm/pages/widgets/audio_player_widget.dart';
import 'package:smart_alarm/pages/widgets/styled_card.dart';

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key});

  @override
  State<AlarmPage> createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  bool _isWorkoutEnabled = false;
  bool isPlaying = false;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 7, minute: 0);
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _currentSliderValue = 0.0;
  String? _currentImageUrl;
  Timer? _stopMusicTimer;
  int _remainingTime = 0;

  final List<String> _imageUrls = [
    'assets/image.jpg',
    'assets/image2.jpg',
    'assets/image3.jpg'
  ];

  final List<String> _wishes = [
    'Пусть ночь принесет тебе покой и восстановит силы для нового дня. Спокойной ночи!',
    'Пусть сны будут светлыми, а утро — радостным. Спокойной ночи и сладких снов!',
    'Желаю, чтобы ночь была уютной, а утро принесло только радость и удачу. Спокойной ночи!',
    'Пусть ночь наполнится тишиной и покоем, а новый день — яркими событиями и счастливыми моментами. Спокойной ночи!',
    'Пусть звезды освещают твой сон, а утро принесет новые возможности. Спокойной ночи!',
    'Пусть эта ночь будет волшебной, а сны полными радости и вдохновения. Спокойной ночи!',
    'Пусть все заботы останутся за дверью, а ночь принесет тебе только мир и спокойствие. Спокойной ночи!',
    'Желаю тебе сладких снов и прекрасных грёз, которые принесут в твой день счастье. Спокойной ночи!',
    'Пусть ты проснешься с улыбкой и настроением на лучший день. Спокойной ночи!',
    'Пусть ночь будет тихой, а сны — яркими и добрыми. Спокойной ночи и до встречи утром!'
  ];


  @override
  void initState() {
    super.initState();
    _loadSettings();
    _currentImageUrl = _imageUrls[0];
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _stopMusicTimer?.cancel();
    super.dispose();
  }

  int _musicDuration = 30;
  late String _selectedMusic;
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isWorkoutEnabled = prefs.getBool('isWorkoutEnabled') ?? false;
      _musicDuration = prefs.getInt('musicDuration') ?? 30;
      _selectedMusic = prefs.getString('selectedMusic') ?? "assets/summer_rain_lofi.mp3";
    });
  }

  void createAlarm(int hours, int minutes, String title) async {
    FlutterAlarmClock.createAlarm(hour: hours, minutes: minutes, title: title);
    final now = DateTime.now();
    final alarmTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    if (_isWorkoutEnabled) {
      if (now.isAfter(alarmTime) || now.isAtSameMomentAs(alarmTime)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('readyToWorkout', true);
        if (kDebugMode) {
          print('Сохранено значение readyToWorkout: true');
        }
      }
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() async {
        _selectedTime = picked;
      });
    }
  }


  Future<void> _playMusic() async {
    if (isPlaying) {
      _audioPlayer.stop();
      _stopMusicTimer?.cancel();
      setState(() {
        isPlaying = false;
        _remainingTime = 0;
      });
      return;
    }
    final randomWish = Random().nextInt(_wishes.length);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(_wishes[randomWish], style: const TextStyle(fontSize: 18)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
    try {
      if(_selectedMusic!="assets/summer_rain_lofi.mp3"){
        await _audioPlayer.setFilePath(_selectedMusic);
      }
      else{
        await _audioPlayer.setAsset('assets/summer_rain_lofi.mp3');
      }
      await _audioPlayer.setLoopMode(LoopMode.all);
      _audioPlayer.play();
      setState(() {
        isPlaying = true;
        _remainingTime = _musicDuration >= 100 ? 10 : _musicDuration*60;
      });

      final randomIndex = Random().nextInt(_imageUrls.length);
      setState(() {
        _currentImageUrl = _imageUrls[randomIndex];
      });

      _stopMusicTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _audioPlayer.stop();
            _stopMusicTimer?.cancel();
            isPlaying = false;
          }
        });
      });

      _audioPlayer.positionStream.listen((position) {
        setState(() {
          _currentSliderValue = position.inSeconds.toDouble();
        });
      });

      _audioPlayer.durationStream.listen((duration) {
        if (duration != null) {
          setState(() {
            _currentSliderValue = duration.inSeconds.toDouble();
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при воспроизведении музыки: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        padding: const EdgeInsets.all(10),
        children: <Widget>[
          buildAlarmCard(),
          buildStyledCard(
            'Показать будильники',
            Icons.access_time,
                () => FlutterAlarmClock.showAlarms(),
          ),
          buildStyledCard(
            isPlaying ? 'Выключить' : 'Включить фоновую музыку',
            Icons.music_note,
            _playMusic,
          ),
          if (isPlaying) ...[
            buildAudioPlayer(),
            Center(
              child: Text(
                'Осталось времени: ${_remainingTime ~/ 60}:${(_remainingTime % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildAudioPlayer() {
    return AudioPlayerWidget(
      audioPlayer: _audioPlayer,
      currentSliderValue: _currentSliderValue,
      imageUrl: _currentImageUrl,
    );
  }

  Widget buildAlarmCard() {
    return AlarmCard(
      selectedTime: _selectedTime,
      onSelectTime: () => _selectTime(context),
      onCreateAlarm: () => createAlarm(
        _selectedTime.hour,
        _selectedTime.minute,
        'Будильник',
      ),
    );
  }

  Widget buildStyledCard(String text, IconData icon, VoidCallback onPressed) {
    return StyledCard(
      text: text,
      icon: icon,
      onPressed: onPressed,
    );
  }
}
