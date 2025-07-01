import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({required this.onThemeChanged, super.key});

  final void Function(bool) onThemeChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isWorkoutEnabled = false;
  bool _isDarkTheme = false;
  int _musicDuration = 30;
  List<String> _customMusicPaths = [];
  String? _selectedMusic;

  final List<String> _defaultMusic = [
    'assets/summer_rain_lofi.mp3',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isWorkoutEnabled = prefs.getBool('isWorkoutEnabled') ?? false;
      _isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
      _musicDuration = prefs.getInt('musicDuration') ?? 30;
      _customMusicPaths = prefs.getStringList('customMusicPaths') ?? [];
      _selectedMusic = prefs.getString('selectedMusic') ?? _defaultMusic.first;
    });
  }

  Future<void> _saveWorkoutSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isWorkoutEnabled', value);
  }

  Future<void> _saveThemeSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', value);
  }

  Future<void> _saveMusicDuration(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('musicDuration', value);
  }

  Future<void> _saveCustomMusicPaths(List<String> paths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('customMusicPaths', paths);
  }

  Future<void> _saveSelectedMusic(String music) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedMusic', music);
  }

  Future<void> _pickCustomMusic() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final paths = result.files.map((file) => file.path).whereType<String>().toList();
      setState(() {
        _customMusicPaths.addAll(paths);
      });
      await _saveCustomMusicPaths(_customMusicPaths);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allMusic = [..._defaultMusic, ..._customMusicPaths];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Утренняя разминка после будильника'),
            value: _isWorkoutEnabled,
            onChanged: (bool value) {
              setState(() {
                _isWorkoutEnabled = value;
                _saveWorkoutSetting(value);
              });
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Темная тема'),
            value: _isDarkTheme,
            onChanged: (bool value) {
              setState(() {
                _isDarkTheme = value;
                _saveThemeSetting(value);
                widget.onThemeChanged(value);
              });
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Продолжительность фоновой музыки'),
            subtitle: Slider(
              value: _musicDuration.toDouble(),
              min: 5,
              max: 100,
              divisions: 19,
              label: '$_musicDuration минут',
              onChanged: (double value) {
                setState(() {
                  _musicDuration = value.toInt();
                });
              },
              onChangeEnd: (double value) {
                _saveMusicDuration(value.toInt());
              },
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text('Выбрать свою музыку'),
            trailing: IconButton(
              icon: const Icon(Icons.folder),
              onPressed: _pickCustomMusic,
            ),
          ),
          if (allMusic.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedMusic,
                hint: const Text('Выберите музыку'),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedMusic = value;
                    });
                    _saveSelectedMusic(value);
                  }
                },
                items: allMusic.map((path) {
                  return DropdownMenuItem(
                    value: path,
                    child: Text(
                      path.contains('assets/')
                          ? 'Встроенная: ${path.split('/').last}'
                          : '- ${path.split('/').last}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }).toList(),
              ),
            ),
          if (_selectedMusic != null)
            Text(
              'Текущая музыка: ${_selectedMusic!.split('/').last}',
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }
}
