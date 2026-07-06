import 'dart:math' as math;
import '../features/pose/pose_models.dart';

class AngleCalculator {
  static double calculateAngle(PosePoint a, PosePoint b, PosePoint c) {
    final abx = a.x - b.x;
    final aby = a.y - b.y;
    final cbx = c.x - b.x;
    final cby = c.y - b.y;
    
    final dotProduct = abx * cbx + aby * cby;
    final abLength = math.sqrt(abx * abx + aby * aby);
    final cbLength = math.sqrt(cbx * cbx + cby * cby);
    
    if (abLength == 0 || cbLength == 0) return 0;
    
    final cosine = (dotProduct / (abLength * cbLength)).clamp(-1.0, 1.0);
    return math.acos(cosine) * 180 / math.pi;
  }

  static double getElbowAngle(PoseFrame frame, bool isLeft) {
    final shoulder = frame[isLeft ? PosePointType.leftShoulder : PosePointType.rightShoulder];
    final elbow = frame[isLeft ? PosePointType.leftElbow : PosePointType.rightElbow];
    final wrist = frame[isLeft ? PosePointType.leftWrist : PosePointType.rightWrist];
    
    if (shoulder == null || elbow == null || wrist == null) return 180;
    return calculateAngle(shoulder, elbow, wrist);
  }

  static double getBackAngle(PoseFrame frame) {
    final shoulder = frame[PosePointType.leftShoulder];
    final hip = frame[PosePointType.leftHip];
    final knee = frame[PosePointType.leftKnee];
    
    if (shoulder == null || hip == null || knee == null) return 180;
    return calculateAngle(shoulder, hip, knee);
  }
}
