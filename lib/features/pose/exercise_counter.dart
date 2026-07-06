import 'dart:math' as math;

import 'pose_models.dart';

import 'dart:math' as math;
import '../../models/exercise_template.dart';
import '../../services/angle_calculator.dart';
import 'pose_models.dart';

enum ExercisePhase { up, down }

class RepCounterUpdate {
  const RepCounterUpdate({
    required this.count,
    required this.phase,
    required this.isComplete,
    required this.feedback,
  });

  final int count;
  final ExercisePhase phase;
  final bool isComplete;
  final String feedback;
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
                        AngleCalculator.getElbowAngle(frame, false)) / 2;
    final backAngle = AngleCalculator.getBackAngle(frame);

    if ((backAngle - template.maxAngles.back).abs() > 15) {
      return _update('Арқаны түзу ұстаңыз');
    }

    var feedback = 'Түсіңіз';
    final downThreshold = template.minAngles.elbow + 5;
    final upThreshold = template.maxAngles.elbow - 10;

    if (_phase == ExercisePhase.up && elbowAngle <= downThreshold) {
      _phase = ExercisePhase.down;
      feedback = 'Төмен түстіңіз';
    } else if (_phase == ExercisePhase.down && elbowAngle >= upThreshold) {
      _count += 1;
      _phase = ExercisePhase.up;
      feedback = 'Жарайсың!';
    } else if (_phase == ExercisePhase.down) {
      feedback = 'Көтеріліңіз';
    }

    return RepCounterUpdate(
      count: _count,
      phase: _phase,
      isComplete: _count >= target,
      feedback: feedback,
    );
  }

  RepCounterUpdate _update(String feedback) {
    return RepCounterUpdate(
      count: _count,
      phase: _phase,
      isComplete: _count >= target,
      feedback: feedback,
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
    final elbowAngle = (AngleCalculator.getElbowAngle(frame, true) + AngleCalculator.getElbowAngle(frame, false)) / 2;
    var feedback = 'Түсіңіз';
    if (_phase == ExercisePhase.up && elbowAngle <= 90) {
      _phase = ExercisePhase.down;
    } else if (_phase == ExercisePhase.down && elbowAngle >= 160) {
      _count++;
      _phase = ExercisePhase.up;
    }
    return RepCounterUpdate(count: _count, phase: _phase, isComplete: _count >= target, feedback: feedback);
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
    if (hip == null || knee == null || ankle == null) return RepCounterUpdate(count: _count, phase: _phase, isComplete: false, feedback: 'Аяқ көрінбейді');
    
    final angle = AngleCalculator.calculateAngle(hip, knee, ankle);
    if (_phase == ExercisePhase.up && angle <= 100) {
      _phase = ExercisePhase.down;
    } else if (_phase == ExercisePhase.down && angle >= 160) {
      _count++;
      _phase = ExercisePhase.up;
    }
    return RepCounterUpdate(count: _count, phase: _phase, isComplete: _count >= target, feedback: 'Жалғастырыңыз');
  }
}
