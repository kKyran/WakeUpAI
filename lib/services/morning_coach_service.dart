import '../models/exercise_task.dart';
import '../models/session_result.dart';
import '../models/wake_alarm.dart';

class CoachAchievement {
  const CoachAchievement({
    required this.code,
    required this.title,
    required this.description,
  });

  final String code;
  final String title;
  final String description;
}

class MorningCoachService {
  const MorningCoachService._();

  static List<CoachAchievement> achievementsFor(
    List<WakeSessionResult> results,
  ) {
    final achievements = <CoachAchievement>[];
    final summary = StatsSummary.fromResults(results);

    if (results.isNotEmpty) {
      achievements.add(
        const CoachAchievement(
          code: 'first_wake_win',
          title: 'First Wake Win',
          description: 'Алғашқы таңғы тапсырма орындалды',
        ),
      );
    }
    if (summary.currentStreak >= 3) {
      achievements.add(
        const CoachAchievement(
          code: 'three_day_streak',
          title: '3 күн streak',
          description: 'Үш күн қатарынан ояндың',
        ),
      );
    }
    if (summary.currentStreak >= 7) {
      achievements.add(
        const CoachAchievement(
          code: 'no_snooze_week',
          title: 'No Snooze Week',
          description: 'Бір апта тәртіп сақталды',
        ),
      );
    }
    if (results.any((result) => result.durationSeconds <= 60)) {
      achievements.add(
        const CoachAchievement(
          code: 'speed_runner',
          title: 'Speed Runner',
          description: 'Тапсырма 60 секунд ішінде аяқталды',
        ),
      );
    }
    if (results.any((result) => result.difficultyCode == 'beast')) {
      achievements.add(
        const CoachAchievement(
          code: 'beast_mode',
          title: 'Beast Mode',
          description: 'Ең қиын режим орындалды',
        ),
      );
    }

    return achievements;
  }

  static List<String> achievementCodesForResults(
    List<WakeSessionResult> allResults,
  ) {
    return achievementsFor(allResults).map((item) => item.code).toList();
  }

  static List<String> smartInsights(
    WakeAlarm? alarm,
    List<WakeSessionResult> results,
  ) {
    final insights = <String>[];
    final summary = StatsSummary.fromResults(results);

    if (alarm == null) {
      return <String>[
        'Алдымен будильник уақытын және таңғы миссияны таңда',
        'Easy режимімен бастап, кейін Hard немесе Beast режиміне өт',
      ];
    }

    if (summary.currentStreak >= 3) {
      insights.add('Streak жақсы жүріп жатыр: бүгін бұзба');
    } else {
      insights.add('3 күндік streak мақсат қойсаң, әдет тез қалыптасады');
    }

    if (summary.averageDurationSeconds > 0 &&
        summary.averageDurationSeconds <= 60) {
      insights.add('Сен тапсырманы тез орындайсың, Hard режимін байқап көр');
    } else if (summary.averageDurationSeconds > 120) {
      insights.add('Таңертең ауыр болса, Easy режим немесе ертерек ұйқы көмектеседі');
    }

    if (alarm.task.kind == ExerciseKind.pushUps &&
        alarm.difficulty == AlarmDifficulty.beast) {
      insights.add('Beast push-up режимі күшті, камераны алдын ала қой');
    }

    insights.add('${alarm.sleepLabel}-де ұйықтасаң, ${alarm.time.label} ояну жеңілдейді');

    return insights.take(3).toList();
  }

  static String morningSummaryTitle(WakeSessionResult result) {
    if (result.emergencyUsed) {
      return 'Backup арқылы ояндың';
    }
    if (result.durationSeconds <= 45) {
      return 'Өте жылдам ояндың';
    }
    if (result.durationSeconds <= 90) {
      return 'Жақсы таңғы старт';
    }
    return 'Тапсырма орындалды';
  }

  static List<String> morningSummaryLines(WakeSessionResult result) {
    return <String>[
      '${result.repsCompleted}/${result.targetReps} орындалды',
      '${result.durationSeconds} секундта аяқталды',
      result.emergencyUsed ? 'Emergency backup қолданылды' : 'Негізгі миссиямен өшті',
    ];
  }
}
