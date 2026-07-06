import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup_ai/models/wake_alarm.dart';

void main() {
  test('next alarm occurrence moves to tomorrow when time already passed', () {
    const alarmTime = AlarmClockTime(hour: 7, minute: 30);
    final base = DateTime(2026, 6, 30, 8);

    final next = alarmTime.nextOccurrence(base);

    expect(next, DateTime(2026, 7, 1, 7, 30));
  });

  test('next alarm occurrence stays today when time is still ahead', () {
    const alarmTime = AlarmClockTime(hour: 7, minute: 30);
    final base = DateTime(2026, 6, 30, 6);

    final next = alarmTime.nextOccurrence(base);

    expect(next, DateTime(2026, 6, 30, 7, 30));
  });
}
