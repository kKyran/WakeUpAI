import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app.dart';
import 'services/alarm_repository.dart';
import 'services/alarm_scheduler.dart';
import 'services/localization_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final localization = LocalizationService();
  await localization.init();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  final repository = await HiveAlarmRepository.open();
  final scheduler = AlarmScheduler();

  runApp(
    ListenableBuilder(
      listenable: localization,
      builder: (context, _) => WakeUpApp(
        repository: repository,
        scheduler: scheduler,
        locale: localization.currentLocale,
      ),
    ),
  );
}
