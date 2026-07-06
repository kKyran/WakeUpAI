import 'package:flutter/material.dart';

import '../../models/session_result.dart';
import '../../services/wake_flow_controller.dart';
import '../alarm/alarm_ringing_screen.dart';
import '../alarm/alarm_setup_panel.dart';
import '../pose/pose_task_screen.dart';
import '../stats/stats_panel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.controller,
    required this.isDarkMode,
    required this.onToggleTheme,
    super.key,
  });

  final WakeFlowController controller;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final alarm = controller.currentAlarm;

    if (controller.isRinging && alarm != null) {
      return AlarmRingingScreen(
        alarm: alarm,
        onStopPressed: controller.beginVerification,
      );
    }

    if (controller.isVerifyingTask && alarm != null) {
      return PoseTaskScreen(
        controller: controller,
        task: alarm.task,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('WakeUp AI'),
        actions: <Widget>[
          IconButton(
            tooltip: isDarkMode ? 'Ақ режим' : 'Қара режим',
            onPressed: onToggleTheme,
            icon: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
          IconButton(
            tooltip: 'Шығу',
            onPressed: controller.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          _TodayStatusCard(controller: controller),
          const SizedBox(height: 12),
          AlarmSetupPanel(controller: controller),
          const SizedBox(height: 12),
          StatsPanel(summary: controller.statsSummary),
          const SizedBox(height: 12),
          _HistoryPanel(results: controller.results),
        ],
      ),
    );
  }
}

class _TodayStatusCard extends StatelessWidget {
  const _TodayStatusCard({
    required this.controller,
  });

  final WakeFlowController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final alarm = controller.currentAlarm;
    final todayResult = controller.todayResult;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: todayResult == null
                    ? scheme.secondaryContainer
                    : scheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                todayResult == null
                    ? Icons.alarm_rounded
                    : Icons.check_circle_rounded,
                color: todayResult == null
                    ? scheme.onSecondaryContainer
                    : scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    todayResult == null ? 'Бүгінгі тапсырма' : 'Орындалды',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alarm == null
                        ? 'Будильник әлі қойылған жоқ'
                        : '${alarm.time.label} - ${alarm.task.title}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({
    required this.results,
  });

  final List<WakeSessionResult> results;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Нәтиже тарихы бос'),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Соңғы нәтижелер',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
          for (final result in results.take(5))
            ListTile(
              leading: const Icon(Icons.fitness_center_rounded),
              title: Text('${result.repsCompleted}/${result.targetReps} рет'),
              subtitle: Text('${result.durationSeconds} секунд'),
              trailing: Text(
                '${result.completedAt.hour.toString().padLeft(2, '0')}:'
                '${result.completedAt.minute.toString().padLeft(2, '0')}',
              ),
            ),
        ],
      ),
    );
  }
}
