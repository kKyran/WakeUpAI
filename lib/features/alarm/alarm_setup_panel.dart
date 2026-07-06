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
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    final alarm = widget.controller.currentAlarm;
    _time = TimeOfDay(
      hour: alarm?.time.hour ?? 7,
      minute: alarm?.time.minute ?? 0,
    );
    _kind = alarm?.task.kind ?? ExerciseKind.pushUps;
    _targetCount = alarm?.task.targetCount ?? 15;
    _selectedAudio = alarm?.audioPath;
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.tune_rounded, color: scheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Будильник',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _pickTime,
              icon: const Icon(Icons.schedule_rounded),
              label: Text(_time.format(context)),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ExerciseKind>(
              value: _kind,
              decoration: const InputDecoration(
                labelText: 'Тапсырма',
                prefixIcon: Icon(Icons.fitness_center_rounded),
              ),
              items: ExerciseKind.values
                  .map(
                    (kind) => DropdownMenuItem<ExerciseKind>(
                      value: kind,
                      child: Text(kind.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _kind = value);
                }
              },
            ),
            const SizedBox(height: 12),
            _MusicSelectionTile(
              selectedAudio: _selectedAudio,
              audioService: _audioService,
              onSelected: (path) => setState(() => _selectedAudio = path),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Саны: $_targetCount',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                IconButton.outlined(
                  tooltip: 'Азайту',
                  onPressed: _targetCount <= 5
                      ? null
                      : () => setState(() => _targetCount -= 1),
                  icon: const Icon(Icons.remove_rounded),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Көбейту',
                  onPressed: () => setState(() => _targetCount += 1),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Сақтау'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: 'Сынау',
                  onPressed: () {
                    _audioService.stop();
                    widget.controller.triggerRinging();
                  },
                  icon: const Icon(Icons.notifications_active_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
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

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Будильник сақталды')),
    );
  }
}

class _MusicSelectionTile extends StatelessWidget {
  const _MusicSelectionTile({
    required this.selectedAudio,
    required this.audioService,
    required this.onSelected,
  });

  final String? selectedAudio;
  final AudioService audioService;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = selectedAudio == null
        ? 'Музыка таңдалмаған'
        : selectedAudio!.startsWith('assets/')
            ? 'Музыка ${selectedAudio!.split('_').last.split('.').first}'
            : selectedAudio!.split('/').last;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(Icons.music_note_rounded, color: scheme.onPrimaryContainer),
      ),
      title: const Text('Оятқыш әуені'),
      subtitle: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: IconButton.filledTonal(
        icon: const Icon(Icons.chevron_right_rounded),
        onPressed: () => _showMusicPicker(context),
      ),
      onTap: () => _showMusicPicker(context),
    );
  }

  void _showMusicPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _MusicPickerSheet(
        audioService: audioService,
        currentSelection: selectedAudio,
        onSelected: onSelected,
      ),
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
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Әуен таңдау',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _pickLocalFile,
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('Файл'),
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
                      iconSize: 32,
                      onPressed: () => _togglePlay(sound.url, true),
                    ),
                    title: Text(sound.name),
                    trailing: IconButton(
                      icon: Icon(isSelected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded),
                      color: isSelected ? Colors.blue : null,
                      onPressed: () {
                        widget.onSelected(sound.url);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _togglePlay(String url, bool isUrl) {
    if (_playingUrl == url) {
      widget.audioService.stop();
      setState(() => _playingUrl = null);
    } else {
      widget.audioService.play(url, isUrl: isUrl);
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
