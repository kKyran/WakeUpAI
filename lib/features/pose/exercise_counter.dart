import '../../models/exercise_template.dart';
import '../../services/angle_calculator.dart';
import 'pose_models.dart';

enum ExercisePhase { up, down, open, closed }

class RepCounterUpdate {
  const RepCounterUpdate({
    required this.count,
    required this.phase,
    required this.isComplete,
    required this.feedback,
    this.countedRep = false,
  });

  final int count;
  final ExercisePhase phase;
  final bool isComplete;
  final String feedback;
  final bool countedRep;
}

abstract class ExerciseCounter {
  int get count;

  RepCounterUpdate processFrame(PoseFrame frame);
}

class PersonalizedPushUpCounter implements ExerciseCounter {
  PersonalizedPushUpCounter({
    required this.target,
    required this.template,
  });

  final int target;
  final ExerciseTemplate template;

  int _count = 0;
  ExercisePhase _phase = ExercisePhase.up;

  @override
  int get count => _count;

  @override
  RepCounterUpdate processFrame(PoseFrame frame) {
    final elbowAngle = (AngleCalculator.getElbowAngle(frame, true) +
            AngleCalculator.getElbowAngle(frame, false)) /
        2;
    final backAngle = AngleCalculator.getBackAngle(frame);

    if ((backAngle - template.maxAngles.back).abs() > 15) {
      return _update('Арқаны түзу ұста');
    }

    var feedback = 'Төмен түс';
    var counted = false;
    final downThreshold = template.minAngles.elbow + 5;
    final upThreshold = template.maxAngles.elbow - 10;

    if (_phase == ExercisePhase.up && elbowAngle <= downThreshold) {
      _phase = ExercisePhase.down;
      feedback = 'Жақсы, енді көтеріл';
    } else if (_phase == ExercisePhase.down && elbowAngle >= upThreshold) {
      _count += 1;
      counted = true;
      _phase = ExercisePhase.up;
      feedback = 'Дұрыс қайталау';
    } else if (_phase == ExercisePhase.down) {
      feedback = 'Қолды толық жаз';
    }

    return _update(feedback, countedRep: counted);
  }

  RepCounterUpdate _update(String feedback, {bool countedRep = false}) {
    return RepCounterUpdate(
      count: _count,
      phase: _phase,
      isComplete: _count >= target,
      feedback: feedback,
      countedRep: countedRep,
    );
  }
}

class PushUpCounter implements ExerciseCounter {
  PushUpCounter({required this.target});

  final int target;
  int _count = 0;
  ExercisePhase _phase = ExercisePhase.up;

  @override
  int get count => _count;

  @override
  RepCounterUpdate processFrame(PoseFrame frame) {
    final elbowAngle = (AngleCalculator.getElbowAngle(frame, true) +
            AngleCalculator.getElbowAngle(frame, false)) /
        2;
    var feedback = 'Төмен түс';
    var counted = false;

    if (_phase == ExercisePhase.up && elbowAngle <= 95) {
      _phase = ExercisePhase.down;
      feedback = 'Жақсы, енді көтеріл';
    } else if (_phase == ExercisePhase.down && elbowAngle >= 155) {
      _count += 1;
      counted = true;
      _phase = ExercisePhase.up;
      feedback = 'Дұрыс қайталау';
    } else if (_phase == ExercisePhase.down) {
      feedback = 'Қолды толық жаз';
    }

    return RepCounterUpdate(
      count: _count,
      phase: _phase,
      isComplete: _count >= target,
      feedback: feedback,
      countedRep: counted,
    );
  }
}

class SquatCounter implements ExerciseCounter {
  SquatCounter({required this.target});

  final int target;
  int _count = 0;
  ExercisePhase _phase = ExercisePhase.up;

  @override
  int get count => _count;

  @override
  RepCounterUpdate processFrame(PoseFrame frame) {
    final hip = frame[PosePointType.leftHip];
    final knee = frame[PosePointType.leftKnee];
    final ankle = frame[PosePointType.leftAnkle];
    if (hip == null || knee == null || ankle == null) {
      return RepCounterUpdate(
        count: _count,
        phase: _phase,
        isComplete: false,
        feedback: 'Аяқ толық көрінбейді',
      );
    }

    final angle = AngleCalculator.calculateAngle(hip, knee, ankle);
    var feedback = 'Төмен отыр';
    var counted = false;
    if (_phase == ExercisePhase.up && angle <= 100) {
      _phase = ExercisePhase.down;
      feedback = 'Төмен нүкте алынды';
    } else if (_phase == ExercisePhase.down && angle >= 160) {
      _count += 1;
      counted = true;
      _phase = ExercisePhase.up;
      feedback = 'Жарайсың';
    } else if (_phase == ExercisePhase.down) {
      feedback = 'Толық тұр';
    }

    return RepCounterUpdate(
      count: _count,
      phase: _phase,
      isComplete: _count >= target,
      feedback: feedback,
      countedRep: counted,
    );
  }
}

class JumpingJackCounter implements ExerciseCounter {
  JumpingJackCounter({required this.target});

  final int target;
  int _count = 0;
  ExercisePhase _phase = ExercisePhase.closed;

  @override
  int get count => _count;

  @override
  RepCounterUpdate processFrame(PoseFrame frame) {
    final leftWrist = frame[PosePointType.leftWrist];
    final rightWrist = frame[PosePointType.rightWrist];
    final leftShoulder = frame[PosePointType.leftShoulder];
    final rightShoulder = frame[PosePointType.rightShoulder];

    if (leftWrist == null ||
        rightWrist == null ||
        leftShoulder == null ||
        rightShoulder == null) {
      return RepCounterUpdate(
        count: _count,
        phase: _phase,
        isComplete: false,
        feedback: 'Қол толық көрінбейді',
      );
    }

    final handsUp =
        leftWrist.y < leftShoulder.y && rightWrist.y < rightShoulder.y;
    var feedback = 'Қолды жоғары көтер';
    var counted = false;

    if (_phase == ExercisePhase.closed && handsUp) {
      _phase = ExercisePhase.open;
      feedback = 'Енді қолды түсір';
    } else if (_phase == ExercisePhase.open && !handsUp) {
      _count += 1;
      counted = true;
      _phase = ExercisePhase.closed;
      feedback = 'Дұрыс секіру';
    }

    return RepCounterUpdate(
      count: _count,
      phase: _phase,
      isComplete: _count >= target,
      feedback: feedback,
      countedRep: counted,
    );
  }
}
