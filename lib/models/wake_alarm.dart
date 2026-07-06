import 'exercise_task.dart';

class AlarmClockTime {
  const AlarmClockTime({
    required this.hour,
    required this.minute,
  })  : assert(hour >= 0 && hour < 24),
        assert(minute >= 0 && minute < 60);

  final int hour;
  final int minute;

  String get label {
    final paddedHour = hour.toString().padLeft(2, '0');
    final paddedMinute = minute.toString().padLeft(2, '0');
    return '$paddedHour:$paddedMinute';
  }

  DateTime nextOccurrence([DateTime? base]) {
    final now = base ?? DateTime.now();
    var scheduled = DateTime(now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'hour': hour,
      'minute': minute,
    };
  }

  factory AlarmClockTime.fromJson(Map<String, dynamic> json) {
    return AlarmClockTime(
      hour: json['hour'] as int? ?? 7,
      minute: json['minute'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AlarmClockTime &&
            runtimeType == other.runtimeType &&
            hour == other.hour &&
            minute == other.minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);
}

class WakeAlarm {
  const WakeAlarm({
    required this.id,
    required this.userId,
    required this.time,
    required this.task,
    required this.enabled,
    required this.updatedAt,
    this.audioPath,
  });

  final String id;
  final String userId;
  final AlarmClockTime time;
  final ExerciseTask task;
  final bool enabled;
  final DateTime updatedAt;
  final String? audioPath;

  WakeAlarm copyWith({
    String? id,
    String? userId,
    AlarmClockTime? time,
    ExerciseTask? task,
    bool? enabled,
    DateTime? updatedAt,
    String? audioPath,
  }) {
    return WakeAlarm(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      time: time ?? this.time,
      task: task ?? this.task,
      enabled: enabled ?? this.enabled,
      updatedAt: updatedAt ?? this.updatedAt,
      audioPath: audioPath ?? this.audioPath,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'userId': userId,
      'time': time.toJson(),
      'task': task.toJson(),
      'enabled': enabled,
      'updatedAt': updatedAt.toIso8601String(),
      'audioPath': audioPath,
    };
  }

  factory WakeAlarm.fromJson(Map<String, dynamic> json) {
    return WakeAlarm(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? 'local',
      time: AlarmClockTime.fromJson(
        Map<String, dynamic>.from(json['time'] as Map? ?? <String, dynamic>{}),
      ),
      task: ExerciseTask.fromJson(
        Map<String, dynamic>.from(json['task'] as Map? ?? <String, dynamic>{}),
      ),
      enabled: json['enabled'] as bool? ?? true,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      audioPath: json['audioPath'] as String?,
    );
  }
}
