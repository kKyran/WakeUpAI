import 'exercise_task.dart';

class JointAngles {
  const JointAngles({
    required this.elbow,
    required this.back,
    required this.hip,
    required this.knee,
  });

  final double elbow;
  final double back;
  final double hip;
  final double knee;

  Map<String, dynamic> toJson() => {
        'elbow': elbow,
        'back': back,
        'hip': hip,
        'knee': knee,
      };

  factory JointAngles.fromJson(Map<String, dynamic> json) => JointAngles(
        elbow: (json['elbow'] as num).toDouble(),
        back: (json['back'] as num).toDouble(),
        hip: (json['hip'] as num).toDouble(),
        knee: (json['knee'] as num).toDouble(),
      );
}

class ExerciseTemplate {
  const ExerciseTemplate({
    required this.userId,
    required this.kind,
    required this.minAngles, // Төменгі нүктедегі бұрыштар
    required this.maxAngles, // Жоғарғы нүктедегі бұрыштар
    required this.calibratedAt,
  });

  final String userId;
  final ExerciseKind kind;
  final JointAngles minAngles;
  final JointAngles maxAngles;
  final DateTime calibratedAt;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'kind': kind.code,
        'minAngles': minAngles.toJson(),
        'maxAngles': maxAngles.toJson(),
        'calibratedAt': calibratedAt.toIso8601String(),
      };

  factory ExerciseTemplate.fromJson(Map<String, dynamic> json) => ExerciseTemplate(
        userId: json['userId'] as String,
        kind: ExerciseKind.fromCode(json['kind'] as String),
        minAngles: JointAngles.fromJson(json['minAngles']),
        maxAngles: JointAngles.fromJson(json['maxAngles']),
        calibratedAt: DateTime.parse(json['calibratedAt']),
      );
}
