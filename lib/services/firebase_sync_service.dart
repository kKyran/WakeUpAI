import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/session_result.dart';
import '../models/wake_alarm.dart';

class FirebaseSyncService {
  FirebaseSyncService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> saveAlarm(WakeAlarm alarm) {
    return _userDoc(alarm.userId)
        .collection('alarms')
        .doc(alarm.id)
        .set(alarm.toJson(), SetOptions(merge: true));
  }

  Future<void> saveResult(String userId, WakeSessionResult result) {
    return _userDoc(userId)
        .collection('results')
        .doc(result.id)
        .set(result.toJson(), SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return _firestore.collection('users').doc(userId);
  }
}
