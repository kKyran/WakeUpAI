class WakeSessionResult {
  const WakeSessionResult({
    required this.id,
    required this.alarmId,
    required this.startedAt,
    required this.completedAt,
    required this.repsCompleted,
    required this.targetReps,
    this.exerciseKindCode = 'push_ups',
    this.difficultyCode = 'normal',
    this.emergencyUsed = false,
    this.summaryTitle,
    this.achievementCodes = const <String>[],
  });

  final String id;
  final String alarmId;
  final DateTime startedAt;
  final DateTime completedAt;
  final int repsCompleted;
  final int targetReps;
  final String exerciseKindCode;
  final String difficultyCode;
  final bool emergencyUsed;
  final String? summaryTitle;
  final List<String> achievementCodes;

  int get durationSeconds {
    return completedAt.difference(startedAt).inSeconds.clamp(0, 86400).toInt();
  }

  bool isOnDay(DateTime day) {
    return completedAt.year == day.year &&
        completedAt.month == day.month &&
        completedAt.day == day.day;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'alarmId': alarmId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt.toIso8601String(),
      'repsCompleted': repsCompleted,
      'targetReps': targetReps,
      'exerciseKindCode': exerciseKindCode,
      'difficultyCode': difficultyCode,
      'emergencyUsed': emergencyUsed,
      'summaryTitle': summaryTitle,
      'achievementCodes': achievementCodes,
    };
  }

  factory WakeSessionResult.fromJson(Map<String, dynamic> json) {
    return WakeSessionResult(
      id: json['id'] as String? ?? '',
      alarmId: json['alarmId'] as String? ?? '',
      startedAt: DateTime.tryParse(json['startedAt'] as String? ?? '') ??
          DateTime.now(),
      completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ??
          DateTime.now(),
      repsCompleted: json['repsCompleted'] as int? ?? 0,
      targetReps: json['targetReps'] as int? ?? 0,
      exerciseKindCode: json['exerciseKindCode'] as String? ?? 'push_ups',
      difficultyCode: json['difficultyCode'] as String? ?? 'normal',
      emergencyUsed: json['emergencyUsed'] as bool? ?? false,
      summaryTitle: json['summaryTitle'] as String?,
      achievementCodes:
          (json['achievementCodes'] as List<dynamic>? ?? <dynamic>[])
              .map((item) => item.toString())
              .toList(),
    );
  }
}

class StatsSummary {
  const StatsSummary({
    required this.daysCompleted,
    required this.currentStreak,
    required this.totalReps,
    required this.averageDurationSeconds,
  });

  final int daysCompleted;
  final int currentStreak;
  final int totalReps;
  final int averageDurationSeconds;

  static const empty = StatsSummary(
    daysCompleted: 0,
    currentStreak: 0,
    totalReps: 0,
    averageDurationSeconds: 0,
  );

  factory StatsSummary.fromResults(
    List<WakeSessionResult> results, {
    DateTime? now,
  }) {
    if (results.isEmpty) {
      return StatsSummary.empty;
    }

    final completedDays = <String>{};
    var totalReps = 0;
    var totalDuration = 0;

    for (final result in results) {
      completedDays.add(_dayKey(result.completedAt));
      totalReps += result.repsCompleted;
      totalDuration += result.durationSeconds;
    }

    var cursor = _dateOnly(now ?? DateTime.now());
    if (!completedDays.contains(_dayKey(cursor))) {
      cursor = cursor.subtract(const Duration(days: 1));
    }

    var streak = 0;
    while (completedDays.contains(_dayKey(cursor))) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return StatsSummary(
      daysCompleted: completedDays.length,
      currentStreak: streak,
      totalReps: totalReps,
      averageDurationSeconds: (totalDuration / results.length).round(),
    );
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static String _dayKey(DateTime value) {
    final local = _dateOnly(value);
    return '${local.year}-${local.month}-${local.day}';
  }
}
