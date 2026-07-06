# Mobile-only нұсқа

WakeUp AI web-сайт емес. Қолданба Android және iPhone телефондарына орнатылатын native mobile app ретінде жасалады.

## Root project-ті дайындау

Root project дайын. `D:\WakeUp AI` ішінде тексеру үшін орындаңыз:

```powershell
flutter pub get
flutter analyze
flutter test
```

`flutter_application_1/` папкасы негізгі project емес. Негізгі project root-тағы `lib/`, `pubspec.yaml`, `android/`, `ios/` арқылы жүреді.

## Android Studio арқылы іске қосу

1. Android Studio ашыңыз.
2. `File` -> `Open` арқылы `D:\WakeUp AI` папкасын таңдаңыз.
3. `Tools` -> `Device Manager` ашыңыз.
4. `Create Device` -> `Pixel 7` немесе `Pixel 6` таңдаңыз.
5. `API 35` немесе `API 34 x86_64` system image таңдаңыз.
6. Image жоқ болса, `Download` басып орнатыңыз.
7. Emulator-ды Play батырмасымен іске қосыңыз.
8. Android Studio device dropdown ішінен emulator таңдаңыз.
9. `lib/main.dart` файлын Run етіңіз.

## Emulator SDK қатесі

Егер emulator мынадай қате берсе:

```text
FATAL | Cannot find AVD system path. Please define ANDROID_SDK_ROOT
```

Windows-та SDK path мәнін нақты SDK тұрған жерге қойыңыз. Мысалы, SDK-ны D дискіге көшірсеңіз және ол `D:\Android\Sdk` ішінде тұрса:

```powershell
[Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", "D:\Android\Sdk", "User")
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "D:\Android\Sdk", "User")
```

PowerShell және Android Studio-ны толық жауып, қайта ашыңыз. Содан кейін Android Studio ішінде `Settings` -> `Languages & Frameworks` -> `Android SDK` бөлігінде SDK Location:

```text
D:\Android\Sdk
```

болуы керек.

SDK path ретінде ішінде `platform-tools`, `emulator`, `system-images`, `cmdline-tools` папкалары бар нақты папканы таңдаңыз.

Flutter-ге де D-дегі Android SDK-ны көрсетіңіз:

```powershell
flutter config --android-sdk D:\Android\Sdk
flutter doctor -v
```

AVD бар-жоғын тексеріңіз:

```powershell
& "D:\Android\Sdk\emulator\emulator.exe" -list-avds
flutter emulators
```

Егер AVD шықпаса, SDK бар, бірақ emulator құрылғысы әлі жасалмаған. Android Studio `Device Manager` арқылы жаңа AVD жасаңыз.

Егер `flutter doctor -v` Android toolchain-ді дұрыс көрсетіп, бірақ `flutter emulators`:

```text
No emulators available.
```

деп тұрса, Android Studio ішінде міндетті түрде жаңа virtual device құру керек. Бұл Flutter қатесі емес, AVD жоқ деген сөз.

## AVD үшін C дискіде орын жетпесе

Егер мынадай қате шықса:

```text
Not enough space to create userdata partition.
Available: ... at C:\Users\kyran\.android\avd\...\Pixel_7.avd, need 12288.00 MB.
```

SDK D дискіде тұрса да, emulator data әлі C дискідегі `.android\avd` ішіне жасалып жатыр. AVD storage-ті D дискіге ауыстырыңыз:

```powershell
New-Item -ItemType Directory -Force D:\Android\avd
[Environment]::SetEnvironmentVariable("ANDROID_AVD_HOME", "D:\Android\avd", "User")
```

PowerShell және Android Studio-ны толық жауып, қайта ашыңыз. Содан кейін `Device Manager` ішінен ескі `Pixel_7` AVD-ны өшіріп, жаңасын жасаңыз.

Қосымша жеңілдету: emulator жасағанда `Show Advanced Settings` ашып, `Internal Storage` мәнін `4096 MB` немесе `6144 MB` етіп азайтуға болады.

Егер `google_apis_ps16k` system image invalid болып тұрса, `Device Manager` ішінде `Pixel_6` AVD-ны өшіріп, жаңа emulator жасаңыз. System image ретінде `API 35` немесе `API 34` ішінен қалыпты `Google APIs x86_64` image таңдаңыз.

## Android телефонға орнату

1. Телефонда Developer options және USB debugging қосылады.
2. Телефон USB арқылы компьютерге қосылады.
3. Құрылғы көрінетінін тексеру:

```powershell
flutter devices
```

4. App орнату және іске қосу:

```powershell
flutter run -d <android-device-id>
```

Release APK жинау:

```powershell
flutter build apk --release
```

APK файлы `build/app/outputs/flutter-apk/app-release.apk` ішінде болады.

## iPhone-ға орнату

iPhone build үшін Mac және Xcode керек.

```bash
flutter pub get
flutter devices
flutter run -d <ios-device-id>
```

Release/TestFlight үшін:

```bash
flutter build ipa
```

Apple Developer signing, Bundle Identifier және provisioning profile Xcode арқылы бапталады.
