import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/exercise_task.dart';
import '../models/session_result.dart';
import '../models/wake_alarm.dart';
import 'alarm_repository.dart';
import 'alarm_scheduler.dart';
import 'morning_coach_service.dart';

class WakeFlowController extends ChangeNotifier {
  WakeFlowController({
    required this.repository,
    required this.scheduler,
  });

  final AlarmRepository repository;
  final AlarmScheduler scheduler;
  final _uuid = const Uuid();

  Timer? _alarmTick;
  String? _lastRingMinuteKey;

  var isReady = false;
  var schedulerReady = false;
  var isRinging = false;
  var isVerifyingTask = false;
  var currentTaskCount = 0;

  String? userEmail;
  WakeAlarm? currentAlarm;
  DateTime? taskStartedAt;
  List<WakeSessionResult> results = <WakeSessionResult>[];

  bool get isAuthenticated => userEmail != null;

  StatsSummary get statsSummary => StatsSummary.fromResults(results);

  WakeSessionResult? get todayResult {
    final today = DateTime.now();
    for (final result in results) {
      if (result.isOnDay(today)) {
        return result;
      }
    }
    return null;
  }

  Future<void> bootstrap() async {
    currentAlarm = await repository.getCurrentAlarm();
    results = await repository.fetchResults();

    try {
      await scheduler.initialize(onTap: (_) => triggerRinging());
      await scheduler.requestPermissions();
      final alarm = currentAlarm;
      if (alarm != null && alarm.enabled) {
        await scheduler.scheduleDaily(alarm);
      }
      schedulerReady = true;
    } catch (_) {
      schedulerReady = false;
    }

    _alarmTick = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _checkAlarmDue(),
    );
    _checkAlarmDue();

    isReady = true;
    notifyListeners();
  }

  Future<void> signIn(String email) async {
    final trimmed = email.trim();
    userEmail = trimmed.isEmpty ? 'local@wakeup.ai' : trimmed;
    notifyListeners();
  }

  void signOut() {
    userEmail = null;
    isRinging = false;
    isVerifyingTask = false;
    notifyListeners();
  }

  Future<void> saveAlarm({
    required AlarmClockTime time,
    required ExerciseTask task,
    String? audioPath,
    AlarmDifficulty difficulty = AlarmDifficulty.normal,
    AlarmSoundMood soundMood = AlarmSoundMood.calm,
    bool emergencyModeEnabled = true,
    int sleepHour = 22,
    int sleepMinute = 30,
    int windDownMinutes = 30,
    String? challengeName,
  }) async {
    final alarm = WakeAlarm(
      id: currentAlarm?.id ?? _uuid.v4(),
      userId: userEmail ?? 'local',
      time: time,
      task: task,
      enabled: true,
      updatedAt: DateTime.now(),
      difficulty: difficulty,
      soundMood: soundMood,
      emergencyModeEnabled: emergencyModeEnabled,
      sleepHour: sleepHour,
      sleepMinute: sleepMinute,
      windDownMinutes: windDownMinutes,
      challengeName: challengeName,
      audioPath: audioPath,
    );

    await repository.saveAlarm(alarm);
    currentAlarm = alarm;

    if (schedulerReady) {
      await scheduler.scheduleDaily(alarm);
    }

    notifyListeners();
  }

  Future<void> disableAlarm() async {
    final alarm = currentAlarm;
    if (alarm == null) {
      return;
    }

    final disabled = alarm.copyWith(
      enabled: false,
      updatedAt: DateTime.now(),
    );
    await repository.saveAlarm(disabled);
    await scheduler.cancel(disabled);
    currentAlarm = disabled;
    notifyListeners();
  }

  void triggerRinging() {
    final alarm = currentAlarm;
    if (alarm == null || !alarm.enabled) {
      return;
    }

    isRinging = true;
    isVerifyingTask = false;
    currentTaskCount = 0;
    taskStartedAt = null;
    notifyListeners();
  }

  void beginVerification() {
    isRinging = false;
    isVerifyingTask = true;
    currentTaskCount = 0;
    taskStartedAt = DateTime.now();
    notifyListeners();
  }

  void updateTaskProgress(int count) {
    currentTaskCount = count;
    notifyListeners();
  }

  Future<void> completeTask(
    int repsCompleted, {
    bool emergencyUsed = false,
  }) async {
    final alarm = currentAlarm;
    if (alarm == null) {
      return;
    }

    final draftResult = WakeSessionResult(
      id: _uuid.v4(),
      alarmId: alarm.id,
      startedAt: taskStartedAt ?? DateTime.now(),
      completedAt: DateTime.now(),
      repsCompleted: repsCompleted,
      targetReps: alarm.task.targetCount,
      exerciseKindCode: alarm.task.kind.code,
      difficultyCode: alarm.difficulty.code,
      emergencyUsed: emergencyUsed,
    );
    final projectedResults = <WakeSessionResult>[draftResult, ...results];
    final result = WakeSessionResult(
      id: draftResult.id,
      alarmId: draftResult.alarmId,
      startedAt: draftResult.startedAt,
      completedAt: draftResult.completedAt,
      repsCompleted: draftResult.repsCompleted,
      targetReps: draftResult.targetReps,
      exerciseKindCode: draftResult.exerciseKindCode,
      difficultyCode: draftResult.difficultyCode,
      emergencyUsed: draftResult.emergencyUsed,
      summaryTitle: MorningCoachService.morningSummaryTitle(draftResult),
      achievementCodes: MorningCoachService.achievementCodesForResults(
        projectedResults,
      ),
    );

    await repository.addResult(result);
    results = await repository.fetchResults();
    isRinging = false;
    isVerifyingTask = false;
    currentTaskCount = repsCompleted;
    taskStartedAt = null;

    if (schedulerReady) {
      await scheduler.scheduleDaily(alarm);
    }

    notifyListeners();
  }

  void _checkAlarmDue() {
    final alarm = currentAlarm;
    if (alarm == null || !alarm.enabled || isRinging || isVerifyingTask) {
      return;
    }

    final now = DateTime.now();
    if (now.hour != alarm.time.hour || now.minute != alarm.time.minute) {
      return;
    }

    final minuteKey =
        '${alarm.id}-${now.year}-${now.month}-${now.day}-${now.hour}-${now.minute}';
    if (_lastRingMinuteKey == minuteKey) {
      return;
    }

    _lastRingMinuteKey = minuteKey;
    triggerRinging();
  }

  @override
  void dispose() {
    _alarmTick?.cancel();
    super.dispose();
  }
}
