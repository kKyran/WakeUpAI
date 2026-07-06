# Native setup

Бұл файл Android және iOS native баптаулары үшін керек.

Жоба телефонға арналған. Web, Chrome, Edge, Windows desktop target-тері қажет емес.

## Android

`android/app/src/main/AndroidManifest.xml` ішіне permissions қосылды:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
```

Alarm notification басқанда app-ты ашу үшін main activity-де launch mode және exported мәндерін Flutter шаблонына сай қалдырып, full-screen notification behavior-ын тексеру керек.

Production alarm үшін бөлек Android foreground service керек болады. Қазіргі MVP foreground app және local notification scheduling қабатын дайындайды.

## iOS

`ios/Runner/Info.plist` ішіне camera permission қосылды:

```xml
<key>NSCameraUsageDescription</key>
<string>WakeUp AI жаттығуды тексеру үшін камераны қолданады.</string>
```

iOS-та будильник секілді ұзақ дыбыс пен background execution қатты шектеледі. Сондықтан production UX local notification арқылы app ашып, task screen-ге жеткізуге бейімделеді.

## Firebase

```powershell
dart pub global activate flutterfire_cli
flutterfire configure
```

Содан кейін `lib/main.dart` ішінде:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

және `firebase_options.dart` import қосылады. Auth экранының қазіргі local mock логикасын `FirebaseAuth` adapter-іне ауыстыру келесі кезеңге жатады.

## MediaPipe Pose

Flutter жағы қазір `PoseFrame` және `PushUpCounter` арқылы AI нәтижесін қабылдауға дайын. Native MediaPipe adapter мына форматта frame беруі керек:

- left/right shoulder
- left/right elbow
- left/right wrist
- left/right hip
- left/right knee
- left/right ankle

Әр frame `PoseFrame` ретінде `PushUpCounter.processFrame(...)` әдісіне жіберіледі.
