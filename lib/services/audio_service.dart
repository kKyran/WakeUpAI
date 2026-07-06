import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

class AlarmSound {
  final String name;
  final String url;

  const AlarmSound({required this.name, required this.url});
}

class AudioService {
  final AudioPlayer _player = AudioPlayer();

  // Тегін интернеттегі оятқыш әуендерінің тізімі
  final List<AlarmSound> builtInSounds = [
    const AlarmSound(name: 'Жұмсақ ояну', url: 'https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg'),
    const AlarmSound(name: 'Классикалық дабыл', url: 'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg'),
    const AlarmSound(name: 'Таңғы энергия', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
    const AlarmSound(name: 'Құстар дауысы', url: 'https://actions.google.com/sounds/v1/foley/morning_birds.ogg'),
    const AlarmSound(name: 'Сандық сағат', url: 'https://actions.google.com/sounds/v1/alarms/beep_short.ogg'),
    const AlarmSound(name: 'Жеңіл қоңырау', url: 'https://actions.google.com/sounds/v1/alarms/mechanical_clock_ring.ogg'),
    const AlarmSound(name: 'Табиғат үні', url: 'https://actions.google.com/sounds/v1/water/rain_on_roof.ogg'),
    const AlarmSound(name: 'Ырғақты әуен', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'),
    const AlarmSound(name: 'Космос', url: 'https://actions.google.com/sounds/v1/science_fiction/alien_beacon.ogg'),
    const AlarmSound(name: 'Мұхит толқыны', url: 'https://actions.google.com/sounds/v1/water/ocean_waves.ogg'),
  ];

  Future<void> play(String path, {bool isUrl = true}) async {
    await _player.stop();
    await _player.setReleaseMode(ReleaseMode.loop); // Әуен қайталана беретін режим (loop)
    if (isUrl) {
      await _player.play(UrlSource(path));
    } else {
      await _player.play(DeviceFileSource(path));
    }
  }

  Future<void> stop() async {
    await _player.setReleaseMode(ReleaseMode.stop); // Қайталауды тоқтату
    await _player.stop();
  }

  Future<String?> pickLocalFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    return result?.files.single.path;
  }

  void dispose() {
    _player.dispose();
  }
}
