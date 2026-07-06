# WakeUp AI

WakeUp AI - будильникті жай ғана сөндірмей, таңдалған жаттығуды AI арқылы орындауды талап ететін Flutter қолданба.

## Қазіргі күйі

Бұл репозиторийде мобильді Flutter project scaffold дайын:

- аккаунтқа кіру/тіркелу экранының MVP-нұсқасы;
- будильник уақытын және тапсырманы таңдау;
- Hive арқылы жергілікті сақтау;
- local notification жоспарлау қабаты;
- ringing screen: тек `Өшіру` әрекеті;
- камера ашылатын тапсырма экраны;
- push-up санауға арналған pose landmark алгоритмі;
- күнделікті нәтиже, статистика және streak есептеу;
- Firebase sync service үшін бастапқы adapter.
- Android және iOS platform папкалары.
- Android/iOS камера және notification permissions бастапқы баптауы.

Жоба мобильді қолданба ретінде жасалады: Android және iPhone. Web/Chrome/Windows нұсқалары бұл MVP-ға кірмейді.

## Android Studio арқылы іске қосу

1. Android Studio ашыңыз.
2. `File` -> `Open` арқылы `D:\WakeUp AI` root папкасын таңдаңыз.
3. `flutter_application_1/` папкасын ашпаңыз, ол негізгі project емес.
4. `Tools` -> `Device Manager` арқылы Android emulator жасаңыз немесе нақты телефон қосыңыз.
5. Device dropdown ішінен Android device таңдаңыз.
6. `lib/main.dart` файлын Run етіңіз.

PowerShell арқылы тексеру:

```powershell
flutter pub get
flutter analyze
flutter test
flutter devices
flutter run -d <android-device-id>
```

iPhone үшін Mac және Xcode қажет:

```bash
flutter devices
flutter run -d <ios-device-id>
```

## Телефонға орнату

Android debug орнату:

```powershell
flutter run -d <android-device-id>
```

Android release APK:

```powershell
flutter build apk --release
```

iPhone-ға орнату Mac/Xcode арқылы жасалады:

```bash
flutter build ipa
```

## Келесі native баптаулар

Қосылған Android permissions:

- `android.permission.CAMERA`
- `android.permission.POST_NOTIFICATIONS`
- `android.permission.SCHEDULE_EXACT_ALARM`
- `android.permission.USE_FULL_SCREEN_INTENT`
- `android.permission.WAKE_LOCK`

Қосылған iOS permission:

- `NSCameraUsageDescription`

Келесі production қадамдар:

- Android foreground/full-screen alarm behavior-ын толық тексеру.
- iOS notification permission және background execution шектеулеріне сай UX.
- Firebase Auth және Firestore sync-ті production режимге қосу.

Firebase:

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Содан кейін `Firebase.initializeApp(...)` қосып, auth және Firestore adapter-ін production режимге ауыстыру керек.
