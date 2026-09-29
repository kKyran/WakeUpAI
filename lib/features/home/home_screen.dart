import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/session_result.dart';
import '../../services/localization_service.dart';
import '../../services/morning_coach_service.dart';
import '../../services/wake_flow_controller.dart';
import '../alarm/alarm_ringing_screen.dart';
import '../alarm/alarm_setup_panel.dart';
import '../pose/pose_task_screen.dart';
import '../stats/stats_panel.dart';

class HomeScreen extends StatefulWidget {
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
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final alarm = widget.controller.currentAlarm;

    if (widget.controller.isRinging && alarm != null) {
      return AlarmRingingScreen(
        alarm: alarm,
        onStopPressed: widget.controller.beginVerification,
      );
    }

    if (widget.controller.isVerifyingTask && alarm != null) {
      return PoseTaskScreen(
        controller: widget.controller,
        task: alarm.task,
      );
    }

    final List<Widget> _pages = [
      _TodayTab(controller: widget.controller, isDarkMode: widget.isDarkMode, onToggleTheme: widget.onToggleTheme),
      _AlarmsTab(controller: widget.controller),
      _StatsTab(controller: widget.controller),
      _ProfileTab(controller: widget.controller),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_rounded),
            label: 'Бүгін',
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm_rounded),
            label: 'Оятқыштар',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Статистика',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_rounded),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}

class _TodayTab extends StatelessWidget {
  const _TodayTab({required this.controller, required this.isDarkMode, required this.onToggleTheme});
  final WakeFlowController controller;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WakeUp AI'),
        actions: [
          IconButton(
            onPressed: onToggleTheme,
            icon: Icon(isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TodayStatusCard(controller: controller),
          const SizedBox(height: 12),
          if (controller.todayResult != null) ...[
            _MorningSummaryPanel(result: controller.todayResult!),
            const SizedBox(height: 12),
          ],
          _SmartInsightsPanel(controller: controller),
        ],
      ),
    );
  }
}

class _AlarmsTab extends StatelessWidget {
  const _AlarmsTab({required this.controller});
  final WakeFlowController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Оятқыштар')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AlarmSetupPanel(controller: controller),
          const SizedBox(height: 12),
          _ChallengePanel(controller: controller),
          const SizedBox(height: 12),
          _SleepPlanPanel(controller: controller),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.controller});
  final WakeFlowController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StatsPanel(summary: controller.statsSummary),
          const SizedBox(height: 12),
          _AchievementsPanel(results: controller.results),
          const SizedBox(height: 12),
          _HistoryPanel(results: controller.results),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab({required this.controller});
  final WakeFlowController controller;

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  final ImagePicker _picker = ImagePicker();
  final LocalizationService _langService = LocalizationService();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = (key) => LocalizationService.translate(context, key);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l('tab_profile')),
        actions: [
          IconButton(
            onPressed: widget.controller.signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: scheme.primaryContainer,
                    child: const Icon(Icons.person_rounded, size: 60),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(blurRadius: 2, color: Colors.black26)],
                  ),
                  child: const Text('🇰🇿', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          _EditableProfileRow(
            icon: Icons.height_rounded,
            label: l('height'),
            value: '175 см',
            onTap: () {},
          ),
          _EditableProfileRow(
            icon: Icons.monitor_weight_outlined,
            label: l('weight'),
            value: '72 кг',
            onTap: () {},
          ),
          _EditableProfileRow(
            icon: Icons.cake_rounded,
            label: l('age'),
            value: '24',
            onTap: () {},
          ),
          _EditableProfileRow(
            icon: Icons.wc_rounded,
            label: l('gender'),
            value: l('male'),
            onTap: () {},
          ),
          
          const Divider(height: 40),
          
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(l('language')),
            trailing: DropdownButton<String>(
              value: _langService.currentLocale.languageCode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'kk', child: Text('Қазақша')),
                DropdownMenuItem(value: 'ru', child: Text('Русский')),
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (val) {
                if (val != null) _langService.changeLanguage(val);
              },
            ),
          ),
          
          const SizedBox(height: 24),
          
          FilledButton.icon(
            onPressed: () {},
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.auto_awesome_rounded),
            label: Text(l('start_calibration')),
          ),
        ],
      ),
    );
  }
}

class _EditableProfileRow extends StatelessWidget {
  const _EditableProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _MorningSummaryPanel extends StatelessWidget {
  const _MorningSummaryPanel({
    required this.result,
  });

  final WakeSessionResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lines = MorningCoachService.morningSummaryLines(result);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.wb_sunny_rounded, color: scheme.primary),
                const SizedBox(width: 10),
                Text(
                  result.summaryTitle ?? 'Morning summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line),
              ),
          ],
        ),
      ),
    );
  }
}

class _SmartInsightsPanel extends StatelessWidget {
  const _SmartInsightsPanel({
    required this.controller,
  });

  final WakeFlowController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final insights = MorningCoachService.smartInsights(
      controller.currentAlarm,
      controller.results,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(Icons.auto_awesome_rounded, color: scheme.secondary),
                const SizedBox(width: 10),
                Text(
                  'Smart coach',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final insight in insights)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.tips_and_updates_rounded),
                title: Text(insight),
              ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsPanel extends StatelessWidget {
  const _AchievementsPanel({
    required this.results,
  });

  final List<WakeSessionResult> results;

  @override
  Widget build(BuildContext context) {
    final achievements = MorningCoachService.achievementsFor(results);
    if (achievements.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Achievement әлі жоқ. Бірінші таңғы тапсырманы орында.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: achievements
                  .map(
                    (achievement) => Chip(
                      avatar: const Icon(Icons.military_tech_rounded, size: 18),
                      label: Text(achievement.title),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengePanel extends StatelessWidget {
  const _ChallengePanel({
    required this.controller,
  });

  final WakeFlowController controller;

  @override
  Widget build(BuildContext context) {
    final alarm = controller.currentAlarm;
    final challenge = alarm?.challengeName;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            const Icon(Icons.groups_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Дос challenge',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge == null || challenge.isEmpty
                        ? 'Challenge атауын alarm setup ішінде қос'
                        : challenge,
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

class _SleepPlanPanel extends StatelessWidget {
  const _SleepPlanPanel({
    required this.controller,
  });

  final WakeFlowController controller;

  @override
  Widget build(BuildContext context) {
    final alarm = controller.currentAlarm;
    if (alarm == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            const Icon(Icons.nights_stay_rounded),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${alarm.sleepLabel} ұйқы, ${alarm.windDownMinutes} мин тыныш режим',
              ),
            ),
          ],
        ),
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
