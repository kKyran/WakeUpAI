import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import '../../models/exercise_task.dart';
import '../../services/wake_flow_controller.dart';
import 'exercise_counter.dart';
import 'pose_models.dart';

class PoseTaskScreen extends StatefulWidget {
  const PoseTaskScreen({
    required this.controller,
    required this.task,
    super.key,
  });

  final WakeFlowController controller;
  final ExerciseTask task;

  @override
  State<PoseTaskScreen> createState() => _PoseTaskScreenState();
}

class _PoseTaskScreenState extends State<PoseTaskScreen> {
  CameraController? _camera;
  PoseDetector? _poseDetector;
  Future<void>? _cameraFuture;

  CustomPaint? _customPaint;

  ExerciseCounter? _counter;
  Timer? _manualTimer;
  final _mathAnswerController = TextEditingController();
  var _manualProgress = 0;
  var _mathA = 8;
  var _mathB = 7;
  var _feedback = 'Камера қосылуда...';
  var _isBusy = false;
  var _completing = false;

  @override
  void initState() {
    super.initState();
    if (widget.task.kind.usesPose) {
      _counter = _createCounter();
      _poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream,
        ),
      );
      _cameraFuture = _initializeCamera();
    } else {
      _feedback = widget.task.kind.instruction;
      _manualProgress = widget.task.kind == ExerciseKind.plank
          ? widget.task.targetCount
          : 0;
    }
  }

  ExerciseCounter _createCounter() {
    switch (widget.task.kind) {
      case ExerciseKind.squats:
        return SquatCounter(target: widget.task.targetCount);
      case ExerciseKind.jumpingJacks:
        return JumpingJackCounter(target: widget.task.targetCount);
      case ExerciseKind.pushUps:
      case ExerciseKind.plank:
      case ExerciseKind.water:
      case ExerciseKind.mathPuzzle:
      case ExerciseKind.qrScan:
        return PushUpCounter(target: widget.task.targetCount);
    }
  }

  @override
  void dispose() {
    _camera?.stopImageStream();
    _camera?.dispose();
    _poseDetector?.close();
    _manualTimer?.cancel();
    _mathAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (!widget.task.kind.usesPose) {
      return _buildManualChallenge(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.kind.label),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          FutureBuilder<void>(
            future: _cameraFuture,
            builder: (context, snapshot) {
              final camera = _camera;
              final ready = camera != null && camera.value.isInitialized;

              if (!ready) {
                return AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                );
              }

              return AspectRatio(
                aspectRatio: 3 / 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(camera),
                      if (_customPaint != null) _customPaint!,
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Text(
                    '${_counter?.count ?? 0}/${widget.task.targetCount}',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: scheme.primary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: ((_counter?.count ?? 0) / widget.task.targetCount)
                          .clamp(0.0, 1.0)
                          .toDouble(),
                      minHeight: 12,
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _feedback,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();

      if (!mounted) return;

      controller.startImageStream(_processCameraImage);
      setState(() => _camera = controller);
    } catch (e) {
      if (mounted) {
        setState(() => _feedback = 'Камера қатесі: $e');
      }
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_isBusy || _completing) return;
    _isBusy = true;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) {
        _isBusy = false;
        return;
      }

      final poses = await _poseDetector!.processImage(inputImage);
      
      if (mounted) {
        setState(() {
          _customPaint = CustomPaint(
            painter: PosePainter(
              poses,
              inputImage.metadata!.size,
              inputImage.metadata!.rotation,
            ),
          );
          
          if (poses.isEmpty) {
            _feedback = 'Адам көрінбейді';
          } else {
            final pose = poses.first;
            final frame = _poseFrameFromMLKit(pose);
            final update = _counter!.processFrame(frame);
            _feedback = update.feedback;
            widget.controller.updateTaskProgress(update.count);

            if (update.isComplete && !_completing) {
              _completing = true;
              widget.controller.completeTask(update.count);
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Pose detection error: $e');
    } finally {
      _isBusy = false;
    }
  }

  Widget _buildManualChallenge(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final kind = widget.task.kind;
    final progress = kind == ExerciseKind.plank
        ? widget.task.targetCount - _manualProgress
        : _manualProgress;

    return Scaffold(
      appBar: AppBar(
        title: Text(kind.label),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: <Widget>[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: <Widget>[
                  Icon(_manualIcon(kind), size: 64, color: scheme.primary),
                  const SizedBox(height: 14),
                  Text(
                    kind.label,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kind.instruction,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  if (kind == ExerciseKind.plank) ...<Widget>[
                    Text(
                      '$_manualProgress сек',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: scheme.primary,
                          ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: (progress / widget.task.targetCount)
                          .clamp(0.0, 1.0)
                          .toDouble(),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _manualTimer == null ? _startPlank : null,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Планканы бастау'),
                    ),
                  ] else if (kind == ExerciseKind.mathPuzzle) ...<Widget>[
                    Text(
                      '$_mathA + $_mathB = ?',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _mathAnswerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Жауап',
                        prefixIcon: Icon(Icons.calculate_rounded),
                      ),
                      onSubmitted: (_) => _checkMath(),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _checkMath,
                      icon: const Icon(Icons.check_rounded),
                      label: Text('Тексеру ($_manualProgress/${widget.task.targetCount})'),
                    ),
                  ] else if (kind == ExerciseKind.qrScan) ...<Widget>[
                    FilledButton.icon(
                      onPressed: _completeManual,
                      icon: const Icon(Icons.qr_code_scanner_rounded),
                      label: const Text('QR сканерленді'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'MVP: нақты QR scanner келесі native кезеңде қосылады.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  ] else ...<Widget>[
                    FilledButton.icon(
                      onPressed: _completeManual,
                      icon: const Icon(Icons.local_drink_rounded),
                      label: const Text('Орындадым'),
                    ),
                  ],
                  if (widget.controller.currentAlarm?.emergencyModeEnabled ??
                      true) ...<Widget>[
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: () => _completeManual(emergencyUsed: true),
                      icon: const Icon(Icons.emergency_rounded),
                      label: const Text('Emergency backup'),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    _feedback,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _manualIcon(ExerciseKind kind) {
    return switch (kind) {
      ExerciseKind.plank => Icons.timer_rounded,
      ExerciseKind.water => Icons.local_drink_rounded,
      ExerciseKind.mathPuzzle => Icons.calculate_rounded,
      ExerciseKind.qrScan => Icons.qr_code_scanner_rounded,
      ExerciseKind.pushUps => Icons.fitness_center_rounded,
      ExerciseKind.squats => Icons.fitness_center_rounded,
      ExerciseKind.jumpingJacks => Icons.fitness_center_rounded,
    };
  }

  void _startPlank() {
    if (_manualTimer != null) {
      return;
    }

    _manualTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _manualProgress -= 1;
        _feedback = 'Тыныс ал, денені түзу ұста';
      });
      if (_manualProgress <= 0) {
        timer.cancel();
        _completeManual();
      }
    });
  }

  void _checkMath() {
    final answer = int.tryParse(_mathAnswerController.text.trim());
    if (answer != _mathA + _mathB) {
      setState(() => _feedback = 'Қате жауап, қайта көр');
      return;
    }

    _mathAnswerController.clear();
    setState(() {
      _manualProgress += 1;
      _mathA += 3;
      _mathB += 4;
      _feedback = 'Дұрыс, тағы бір есеп';
    });

    if (_manualProgress >= widget.task.targetCount) {
      _completeManual();
    }
  }

  Future<void> _completeManual({bool emergencyUsed = false}) async {
    if (_completing) {
      return;
    }
    _completing = true;
    _manualTimer?.cancel();
    final completed = widget.task.kind == ExerciseKind.plank
        ? widget.task.targetCount
        : widget.task.targetCount;
    await widget.controller.completeTask(
      completed,
      emergencyUsed: emergencyUsed,
    );
  }

  PoseFrame _poseFrameFromMLKit(Pose pose) {
    final points = <PosePointType, PosePoint>{};

    void addPoint(PoseLandmarkType type, PosePointType target) {
      final landmark = pose.landmarks[type];
      if (landmark != null) {
        points[target] = PosePoint(
          x: landmark.x,
          y: landmark.y,
          visibility: landmark.likelihood,
        );
      }
    }

    addPoint(PoseLandmarkType.leftShoulder, PosePointType.leftShoulder);
    addPoint(PoseLandmarkType.rightShoulder, PosePointType.rightShoulder);
    addPoint(PoseLandmarkType.leftElbow, PosePointType.leftElbow);
    addPoint(PoseLandmarkType.rightElbow, PosePointType.rightElbow);
    addPoint(PoseLandmarkType.leftWrist, PosePointType.leftWrist);
    addPoint(PoseLandmarkType.rightWrist, PosePointType.rightWrist);
    addPoint(PoseLandmarkType.leftHip, PosePointType.leftHip);
    addPoint(PoseLandmarkType.rightHip, PosePointType.rightHip);
    addPoint(PoseLandmarkType.leftKnee, PosePointType.leftKnee);
    addPoint(PoseLandmarkType.rightKnee, PosePointType.rightKnee);
    addPoint(PoseLandmarkType.leftAnkle, PosePointType.leftAnkle);
    addPoint(PoseLandmarkType.rightAnkle, PosePointType.rightAnkle);

    return PoseFrame(points);
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = _camera?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }
}

class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.imageSize, this.rotation);

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.green;

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.red;

    for (final pose in poses) {
      // Барлық нүктелерді сызу
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
          Offset(
            _translateX(landmark.x, rotation, size, imageSize),
            _translateY(landmark.y, rotation, size, imageSize),
          ),
          4,
          dotPaint,
        );
      });

      void paintLine(PoseLandmarkType type1, PoseLandmarkType type2) {
        final p1 = pose.landmarks[type1];
        final p2 = pose.landmarks[type2];
        if (p1 != null && p2 != null) {
          canvas.drawLine(
            Offset(
              _translateX(p1.x, rotation, size, imageSize),
              _translateY(p1.y, rotation, size, imageSize),
            ),
            Offset(
              _translateX(p2.x, rotation, size, imageSize),
              _translateY(p2.y, rotation, size, imageSize),
            ),
            paint,
          );
        }
      }

      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    }
  }

  double _translateX(double x, InputImageRotation rotation, Size size, Size imageSize) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        return x * size.width / imageSize.height;
      case InputImageRotation.rotation270deg:
        return size.width - x * size.width / imageSize.height;
      default:
        return x * size.width / imageSize.width;
    }
  }

  double _translateY(double y, InputImageRotation rotation, Size size, Size imageSize) {
    switch (rotation) {
      case InputImageRotation.rotation90deg:
      case InputImageRotation.rotation270deg:
        return y * size.height / imageSize.width;
      default:
        return y * size.height / imageSize.height;
    }
  }

  @override
  bool shouldRepaint(PosePainter oldDelegate) {
    return oldDelegate.poses != poses;
  }
}
