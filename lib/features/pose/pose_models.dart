enum PosePointType {
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
}

class PosePoint {
  const PosePoint({
    required this.x,
    required this.y,
    this.visibility = 1,
  });

  final double x;
  final double y;
  final double visibility;
}

class PoseFrame {
  const PoseFrame(this.points);

  final Map<PosePointType, PosePoint> points;

  PosePoint? operator [](PosePointType type) => points[type];
}

class PoseFrameSamples {
  const PoseFrameSamples._();

  static PoseFrame pushUpUp() {
    return const PoseFrame(
      <PosePointType, PosePoint>{
        PosePointType.leftShoulder: PosePoint(x: 0.38, y: 0.35),
        PosePointType.leftElbow: PosePoint(x: 0.42, y: 0.52),
        PosePointType.leftWrist: PosePoint(x: 0.46, y: 0.69),
        PosePointType.leftHip: PosePoint(x: 0.58, y: 0.39),
        PosePointType.leftKnee: PosePoint(x: 0.72, y: 0.43),
        PosePointType.leftAnkle: PosePoint(x: 0.86, y: 0.47),
        PosePointType.rightShoulder: PosePoint(x: 0.38, y: 0.43),
        PosePointType.rightElbow: PosePoint(x: 0.42, y: 0.60),
        PosePointType.rightWrist: PosePoint(x: 0.46, y: 0.77),
        PosePointType.rightHip: PosePoint(x: 0.58, y: 0.47),
        PosePointType.rightKnee: PosePoint(x: 0.72, y: 0.51),
        PosePointType.rightAnkle: PosePoint(x: 0.86, y: 0.55),
      },
    );
  }

  static PoseFrame pushUpDown() {
    return const PoseFrame(
      <PosePointType, PosePoint>{
        PosePointType.leftShoulder: PosePoint(x: 0.42, y: 0.45),
        PosePointType.leftElbow: PosePoint(x: 0.50, y: 0.55),
        PosePointType.leftWrist: PosePoint(x: 0.58, y: 0.45),
        PosePointType.leftHip: PosePoint(x: 0.60, y: 0.49),
        PosePointType.leftKnee: PosePoint(x: 0.74, y: 0.52),
        PosePointType.leftAnkle: PosePoint(x: 0.88, y: 0.55),
        PosePointType.rightShoulder: PosePoint(x: 0.42, y: 0.53),
        PosePointType.rightElbow: PosePoint(x: 0.50, y: 0.63),
        PosePointType.rightWrist: PosePoint(x: 0.58, y: 0.53),
        PosePointType.rightHip: PosePoint(x: 0.60, y: 0.57),
        PosePointType.rightKnee: PosePoint(x: 0.74, y: 0.60),
        PosePointType.rightAnkle: PosePoint(x: 0.88, y: 0.63),
      },
    );
  }
}
