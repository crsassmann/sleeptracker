import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SleepService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Future<String> startSession({String? soundId}) async {
    final userId = _auth.currentUser!.uid;
    final ref = await _db.collection('sleepSessions').add({
      'userId': userId,
      'startTime': FieldValue.serverTimestamp(),
      'endTime': null,
      'soundId': soundId,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> stopSession(String sessionId) async {
    await _db.collection('sleepSessions').doc(sessionId).update({
      'endTime': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> mySessions() {
    final userId = _auth.currentUser!.uid;
    return _db
        .collection('sleepSessions')
        .where('userId', isEqualTo: userId)
        .orderBy('startTime', descending: true)
        .limit(50)
        .snapshots();
  }
}