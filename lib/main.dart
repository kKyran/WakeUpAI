import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'services/alarm_repository.dart';
import 'services/alarm_scheduler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  final repository = await HiveAlarmRepository.open();
  final scheduler = AlarmScheduler();

  runApp(
    WakeUpApp(
      repository: repository,
      scheduler: scheduler,
    ),
  );
}
