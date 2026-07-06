# WakeUp AI кезеңдік жоспары

## 1-кезең. MVP app shell

- Flutter жобасын дайындау.
- Тақырып, навигация, негізгі экрандар.
- Аккаунтқа кіру/тіркелу UI.
- Будильник уақытын және тапсырманы таңдау.

## 2-кезең. Жергілікті сақтау

- Hive box ашу.
- Будильник конфигурациясын сақтау.
- Орындалған тапсырма нәтижелерін сақтау.
- Streak және күнделікті статистика есептеу.

## 3-кезең. Alarm flow

- Таңдалған уақытқа notification жоспарлау.
- Белгіленген уақытта ringing state ашу.
- Ringing screen-де тек `Өшіру` батырмасын қалдыру.
- `Өшіру` басылғанда камера/AI task screen-ге өту.

## 4-кезең. Pose AI ядросы

- MediaPipe Pose-тен келетін 33 landmark үшін adapter дайындау.
- Иық, шынтақ, білек, жамбас, тізе, аяқ нүктелерін оқу.
- Push-up қозғалысын down/up фазалары арқылы санау.
- Дұрыс қайталау саны target-ке жеткенде alarm-ды тоқтату.

## 5-кезең. Camera pipeline

- Алдыңғы камераны ашу.
- Frame stream алу.
- Frame-ді MediaPipe/native adapter-ге жіберу.
- Нәтижені UI counter-ге беру.

## 6-кезең. Firebase

- Firebase Auth арқылы аккаунт.
- Firestore-ға alarm және result sync.
- Offline-first: Hive негізгі store, Firebase cloud mirror.

## 7-кезең. Production alarm

- Android exact alarm және full-screen intent.
- Қатты дыбысты foreground service арқылы басқару.
- iOS notification шектеулеріне сай UX.
- Battery optimization edge case-тері.
