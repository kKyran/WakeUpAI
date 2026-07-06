enum ExerciseKind {
  pushUps('push_ups', 'Отжимание'),
  squats('squats', 'Приседание'),
  jumpingJacks('jumping_jacks', 'Секіру');

  const ExerciseKind(this.code, this.label);

  final String code;
  final String label;

  static ExerciseKind fromCode(String code) {
    return ExerciseKind.values.firstWhere(
      (kind) => kind.code == code,
      orElse: () => ExerciseKind.pushUps,
    );
  }
}

class ExerciseTask {
  const ExerciseTask({
    required this.kind,
    required this.targetCount,
  });

  final ExerciseKind kind;
  final int targetCount;

  String get title => '${kind.label}: $targetCount рет';

  ExerciseTask copyWith({
    ExerciseKind? kind,
    int? targetCount,
  }) {
    return ExerciseTask(
      kind: kind ?? this.kind,
      targetCount: targetCount ?? this.targetCount,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'kind': kind.code,
      'targetCount': targetCount,
    };
  }

  factory ExerciseTask.fromJson(Map<String, dynamic> json) {
    return ExerciseTask(
      kind: ExerciseKind.fromCode(json['kind'] as String? ?? ''),
      targetCount: json['targetCount'] as int? ?? 15,
    );
  }
}
