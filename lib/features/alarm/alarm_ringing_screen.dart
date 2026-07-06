import 'package:flutter/material.dart';

import '../../models/wake_alarm.dart';
import '../../services/audio_service.dart';

class AlarmRingingScreen extends StatefulWidget {
  const AlarmRingingScreen({
    required this.alarm,
    required this.onStopPressed,
    super.key,
  });

  final WakeAlarm alarm;
  final VoidCallback onStopPressed;

  @override
  State<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends State<AlarmRingingScreen> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _startAlarmSound();
  }

  void _startAlarmSound() {
    final path = widget.alarm.audioPath;
    if (path != null) {
      final isUrl = path.startsWith('http');
      _audioService.play(path, isUrl: isUrl);
    }
  }

  @override
  void dispose() {
    _audioService.stop();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.errorContainer,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.alarm_rounded,
                  size: 72,
                  color: scheme.onErrorContainer,
                ),
                const SizedBox(height: 24),
                Text(
                  widget.alarm.time.label,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: scheme.onErrorContainer,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.alarm.task.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scheme.onErrorContainer,
                      ),
                ),
                const SizedBox(height: 44),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      _audioService.stop();
                      widget.onStopPressed();
                    },
                    icon: const Icon(Icons.power_settings_new_rounded),
                    label: const Text('Өшіру'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
