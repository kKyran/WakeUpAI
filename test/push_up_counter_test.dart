import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup_ai/features/pose/exercise_counter.dart';
import 'package:wakeup_ai/features/pose/pose_models.dart';

void main() {
  test('counts one push-up after down then up frames', () {
    final counter = PushUpCounter(target: 15);

    counter.processFrame(PoseFrameSamples.pushUpUp());
    counter.processFrame(PoseFrameSamples.pushUpDown());
    final update = counter.processFrame(PoseFrameSamples.pushUpUp());

    expect(update.countedRep, isTrue);
    expect(update.count, 1);
    expect(update.isComplete, isFalse);
  });

  test('does not count repeated up frames', () {
    final counter = PushUpCounter(target: 15);

    counter.processFrame(PoseFrameSamples.pushUpUp());
    final update = counter.processFrame(PoseFrameSamples.pushUpUp());

    expect(update.countedRep, isFalse);
    expect(update.count, 0);
  });
}
