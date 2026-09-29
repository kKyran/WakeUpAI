enum ExerciseKind {
  pushUps('push_ups', 'Отжимание'),
  squats('squats', 'Приседание'),
  jumpingJacks('jumping_jacks', 'Секіру'),
  plank('plank', 'Планка'),
  water('water', 'Су ішу'),
  mathPuzzle('math_puzzle', 'Математика'),
  qrScan('qr_scan', 'QR тексеру');

  const ExerciseKind(this.code, this.label);

  final String code;
  final String label;

  bool get usesPose {
    return switch (this) {
      ExerciseKind.pushUps => true,
      ExerciseKind.squats => true,
      ExerciseKind.jumpingJacks => true,
      ExerciseKind.plank => false,
      ExerciseKind.water => false,
      ExerciseKind.mathPuzzle => false,
      ExerciseKind.qrScan => false,
    };
  }

  bool get countsSeconds => this == ExerciseKind.plank;

  String get unit {
    return countsSeconds ? 'секунд' : 'рет';
  }

  String get instruction {
    return switch (this) {
      ExerciseKind.pushUps => 'Камераға толық көрініп, отжимание жаса',
      ExerciseKind.squats => 'Аяқ толық көрінетіндей тұрып, приседание жаса',
      ExerciseKind.jumpingJacks => 'Қол мен аяқ қозғалысын толық көрсет',
      ExerciseKind.plank => 'Планкада таймер біткенше тұр',
      ExerciseKind.water => 'Су ішіп, растау батырмасын бас',
      ExerciseKind.mathPuzzle => 'Ұйқыны ашу үшін есеп шығар',
      ExerciseKind.qrScan => 'Ваннадағы немесе асүйдегі QR кодты сканерле',
    };
  }

  static ExerciseKind fromCode(String code) {
    return ExerciseKind.values.firstWhere(
      (kind) => kind.code == code,
      orElse: () => ExerciseKind.pushUps,
    );
  }
}

enum AlarmDifficulty {
  easy('easy', 'Easy', 0.7),
  normal('normal', 'Normal', 1),
  hard('hard', 'Hard', 1.4),
  beast('beast', 'Beast', 1.8);

  const AlarmDifficulty(this.code, this.label, this.multiplier);

  final String code;
  final String label;
  final double multiplier;

  int applyTo(int baseCount) {
    return (baseCount * multiplier).round().clamp(1, 999).toInt();
  }

  static AlarmDifficulty fromCode(String code) {
    return AlarmDifficulty.values.firstWhere(
      (difficulty) => difficulty.code == code,
      orElse: () => AlarmDifficulty.normal,
    );
  }
}

enum AlarmSoundMood {
  calm('calm', 'Calm'),
  loud('loud', 'Loud'),
  nature('nature', 'Nature'),
  extreme('extreme', 'Extreme'),
  random('random', 'Random'),
  custom('custom', 'Custom');

  const AlarmSoundMood(this.code, this.label);

  final String code;
  final String label;

  static AlarmSoundMood fromCode(String code) {
    return AlarmSoundMood.values.firstWhere(
      (mood) => mood.code == code,
      orElse: () => AlarmSoundMood.calm,
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

  String get title => '${kind.label}: $targetCount ${kind.unit}';

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
