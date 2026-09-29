import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Locale _currentLocale = const Locale('kk');
  Locale get currentLocale => _currentLocale;

  static const List<Locale> supportedLocales = [
    Locale('kk'),
    Locale('ru'),
    Locale('en'),
    Locale('tr'),
    Locale('ar'),
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'kk';
    _currentLocale = Locale(langCode);
    notifyListeners();
  }

  Future<void> changeLanguage(String langCode) async {
    _currentLocale = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);
    notifyListeners();
  }

  static String translate(BuildContext context, String key) {
    final langCode = _instance.currentLocale.languageCode;
    return _translations[langCode]?[key] ?? _translations['en']?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _translations = {
    'kk': {
      'app_title': 'WakeUp AI',
      'tab_today': 'Бүгін',
      'tab_alarms': 'Оятқыштар',
      'tab_stats': 'Статистика',
      'tab_profile': 'Профиль',
      'save': 'Сақтау',
      'height': 'Бойы',
      'weight': 'Салмағы',
      'age': 'Жасы',
      'gender': 'Жынысы',
      'male': 'Еркек',
      'female': 'Әйел',
      'language': 'Тіл',
      'start_calibration': 'AI Калибрлеуді бастау',
      'logout': 'Шығу',
    },
    'ru': {
      'app_title': 'WakeUp AI',
      'tab_today': 'Сегодня',
      'tab_alarms': 'Будильники',
      'tab_stats': 'Статистика',
      'tab_profile': 'Профиль',
      'save': 'Сохранить',
      'height': 'Рост',
      'weight': 'Вес',
      'age': 'Возраст',
      'gender': 'Пол',
      'male': 'Мужской',
      'female': 'Женский',
      'language': 'Язык',
      'start_calibration': 'Начать AI Калибровку',
      'logout': 'Выйти',
    },
    'en': {
      'app_title': 'WakeUp AI',
      'tab_today': 'Today',
      'tab_alarms': 'Alarms',
      'tab_stats': 'Statistics',
      'tab_profile': 'Profile',
      'save': 'Save',
      'height': 'Height',
      'weight': 'Weight',
      'age': 'Age',
      'gender': 'Gender',
      'male': 'Male',
      'female': 'Female',
      'language': 'Language',
      'start_calibration': 'Start AI Calibration',
      'logout': 'Logout',
    },
    'tr': {
      'app_title': 'WakeUp AI',
      'tab_today': 'Bugün',
      'tab_alarms': 'Alarmlar',
      'tab_stats': 'İstatistikler',
      'tab_profile': 'Profil',
      'save': 'Kaydet',
      'height': 'Boy',
      'weight': 'Kilo',
      'age': 'Yaş',
      'gender': 'Cinsiyet',
      'male': 'Erkek',
      'female': 'Kadın',
      'language': 'Dil',
      'start_calibration': 'AI Kalibrasyonu Başlat',
      'logout': 'Çıkış Yap',
    },
    'ar': {
      'app_title': 'WakeUp AI',
      'tab_today': 'اليوم',
      'tab_alarms': 'المنبهات',
      'tab_stats': 'الإحصائيات',
      'tab_profile': 'الملف الشخصي',
      'save': 'حفظ',
      'height': 'الطول',
      'weight': 'الوزن',
      'age': 'العمر',
      'gender': 'الجنس',
      'male': 'ذكر',
      'female': 'أنثى',
      'language': 'اللغة',
      'start_calibration': 'بدء معايرة الذكاء الاصطناعي',
      'logout': 'تسجيل الخروج',
    },
  };
}
