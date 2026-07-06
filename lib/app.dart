import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/auth_screen.dart';
import 'features/home/home_screen.dart';
import 'services/alarm_repository.dart';
import 'services/alarm_scheduler.dart';
import 'services/wake_flow_controller.dart';

class WakeUpApp extends StatefulWidget {
  const WakeUpApp({
    required this.repository,
    required this.scheduler,
    super.key,
  });

  final AlarmRepository repository;
  final AlarmScheduler scheduler;

  @override
  State<WakeUpApp> createState() => _WakeUpAppState();
}

class _WakeUpAppState extends State<WakeUpApp> {
  late final WakeFlowController controller;
  var _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    controller = WakeFlowController(
      repository: widget.repository,
      scheduler: widget.scheduler,
    )..bootstrap();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WakeUp AI',
      theme: WakeUpTheme.light(),
      darkTheme: WakeUpTheme.dark(),
      themeMode: _themeMode,
      home: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (!controller.isReady) {
            return const _SplashScreen();
          }

          if (!controller.isAuthenticated) {
            return AuthScreen(
              controller: controller,
              isDarkMode: _themeMode == ThemeMode.dark,
              onToggleTheme: _toggleTheme,
            );
          }

          return HomeScreen(
            controller: controller,
            isDarkMode: _themeMode == ThemeMode.dark,
            onToggleTheme: _toggleTheme,
          );
        },
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
