import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/session_result.dart';
import '../models/wake_alarm.dart';

abstract class AlarmRepository {
  Future<WakeAlarm?> getCurrentAlarm();

  Future<void> saveAlarm(WakeAlarm alarm);

  Future<void> clearAlarm();

  Future<List<WakeSessionResult>> fetchResults();

  Future<void> addResult(WakeSessionResult result);
}

class HiveAlarmRepository implements AlarmRepository {
  HiveAlarmRepository._(this._box);

  static const _boxName = 'wake_up_ai';
  static const _alarmKey = 'current_alarm';
  static const _resultsKey = 'results';

  final Box<String> _box;

  static Future<HiveAlarmRepository> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox<String>(_boxName);
    return HiveAlarmRepository._(box);
  }

  @override
  Future<WakeAlarm?> getCurrentAlarm() async {
    final raw = _box.get(_alarmKey);
    if (raw == null) {
      return null;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return WakeAlarm.fromJson(decoded);
  }

  @override
  Future<void> saveAlarm(WakeAlarm alarm) {
    return _box.put(_alarmKey, jsonEncode(alarm.toJson()));
  }

  @override
  Future<void> clearAlarm() {
    return _box.delete(_alarmKey);
  }

  @override
  Future<List<WakeSessionResult>> fetchResults() async {
    final raw = _box.get(_resultsKey);
    if (raw == null) {
      return <WakeSessionResult>[];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    final results = decoded
        .map(
          (item) => WakeSessionResult.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return results;
  }

  @override
  Future<void> addResult(WakeSessionResult result) async {
    final results = await fetchResults();
    results.insert(0, result);
    await _box.put(
      _resultsKey,
      jsonEncode(results.map((item) => item.toJson()).toList()),
    );
  }
}
