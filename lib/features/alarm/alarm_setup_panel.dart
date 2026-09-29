import 'package:flutter/material.dart';
import '../../models/exercise_task.dart';
import '../../models/wake_alarm.dart';
import '../../services/audio_service.dart';
import '../../services/wake_flow_controller.dart';

class AlarmSetupPanel extends StatefulWidget {
  const AlarmSetupPanel({
    required this.controller,
    super.key,
  });

  final WakeFlowController controller;

  @override
  State<AlarmSetupPanel> createState() => _AlarmSetupPanelState();
}

class _AlarmSetupPanelState extends State<AlarmSetupPanel> {
  late TimeOfDay _time;
  late ExerciseKind _kind;
  late int _targetCount;
  String? _selectedAudio;
  bool _enabled = true;
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    final alarm = widget.controller.currentAlarm;
    _time = TimeOfDay(
      hour: alarm?.time.hour ?? 7,
      minute: alarm?.time.minute ?? 30,
    );
    _kind = alarm?.task.kind ?? ExerciseKind.pushUps;
    _targetCount = alarm?.task.targetCount ?? 15;
    _selectedAudio = alarm?.audioPath;
    _enabled = alarm?.enabled ?? true;
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // iOS стиліндегі үлкен уақыт
        GestureDetector(
          onTap: _pickTime,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              _time.format(context),
              style: const TextStyle(
                fontSize: 90,
                fontWeight: FontWeight.w200,
                letterSpacing: -2,
              ),
            ),
          ),
        ),
        
        // Минималистік баптаулар блогы
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _SettingRow(
                icon: Icons.fitness_center_rounded,
                title: 'Миссия',
                value: _kind.label,
                onTap: _showExercisePicker,
              ),
              const Divider(height: 1, indent: 56),
              _SettingRow(
                icon: Icons.repeat_rounded,
                title: 'Қайталау',
                value: '$_targetCount рет',
                onTap: _showCountPicker,
              ),
              const Divider(height: 1, indent: 56),
              _SettingRow(
                icon: Icons.music_note_rounded,
                title: 'Әуен',
                value: _selectedAudio == null ? 'Әдепкі' : 'Таңдалды',
                onTap: () => _showMusicPicker(context),
              ),
              const Divider(height: 1, indent: 56),
              SwitchListTile.adaptive(
                secondary: Icon(Icons.alarm_on_rounded, color: scheme.primary),
                title: const Text('Қосулы'),
                value: _enabled,
                onChanged: (val) => setState(() => _enabled = val),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Сақтау батырмасы
        SizedBox(
          width: double.infinity,
          height: 60,
          child: FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('Сақтау', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () {
            _audioService.stop();
            widget.controller.triggerRinging();
          },
          icon: const Icon(Icons.notifications_active_rounded),
          label: const Text('Тесттік қоңырау'),
        ),
      ],
    );
  }

  void _showExercisePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ExerciseKind.values.map((k) => ListTile(
            title: Text(k.label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
            onTap: () {
              setState(() => _kind = k);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _showCountPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SizedBox(
        height: 300,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('Санын таңдаңыз', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) {
                  final val = index + 5;
                  return ListTile(
                    title: Text('$val', textAlign: TextAlign.center),
                    selected: _targetCount == val,
                    onTap: () {
                      setState(() => _targetCount = val);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMusicPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _MusicPickerSheet(
        audioService: _audioService,
        currentSelection: _selectedAudio,
        onSelected: (path) => setState(() => _selectedAudio = path),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _time = picked);
    }
  }

  Future<void> _save() async {
    _audioService.stop();
    await widget.controller.saveAlarm(
      time: AlarmClockTime(hour: _time.hour, minute: _time.minute),
      task: ExerciseTask(kind: _kind, targetCount: _targetCount),
      audioPath: _selectedAudio,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Оятқыш сақталды'), behavior: SnackBarBehavior.floating),
      );
    }
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
          const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _MusicPickerSheet extends StatefulWidget {
  const _MusicPickerSheet({
    required this.audioService,
    required this.currentSelection,
    required this.onSelected,
  });

  final AudioService audioService;
  final String? currentSelection;
  final ValueChanged<String?> onSelected;

  @override
  State<_MusicPickerSheet> createState() => _MusicPickerSheetState();
}

class _MusicPickerSheetState extends State<_MusicPickerSheet> {
  String? _playingUrl;

  @override
  void dispose() {
    widget.audioService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('Әуен таңдау', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    onPressed: _pickLocalFile,
                    icon: const Icon(Icons.folder_open_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.audioService.builtInSounds.length,
                itemBuilder: (context, index) {
                  final sound = widget.audioService.builtInSounds[index];
                  final isPlaying = _playingUrl == sound.url;
                  final isSelected = widget.currentSelection == sound.url;

                  return ListTile(
                    leading: IconButton(
                      icon: Icon(isPlaying ? Icons.stop_circle_rounded : Icons.play_circle_filled_rounded),
                      color: isPlaying ? Colors.red : Colors.green,
                      onPressed: () => _togglePlay(sound.url),
                    ),
                    title: Text(sound.name),
                    trailing: isSelected ? const Icon(Icons.check_rounded, color: Colors.blue) : null,
                    onTap: () {
                      widget.onSelected(sound.url);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _togglePlay(String url) {
    if (_playingUrl == url) {
      widget.audioService.stop();
      setState(() => _playingUrl = null);
    } else {
      widget.audioService.play(url);
      setState(() => _playingUrl = url);
    }
  }

  Future<void> _pickLocalFile() async {
    final path = await widget.audioService.pickLocalFile();
    if (path != null) {
      widget.onSelected(path);
      if (mounted) Navigator.pop(context);
    }
  }
}
