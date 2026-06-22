import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instance;
});

class FirebaseService {
  FirebaseService._();

  static FirebaseAuth get auth => FirebaseAuth.instance;

  static FirebaseMessaging get messaging =>
      FirebaseMessaging.instance;

  static FirebaseDatabase get database =>
      FirebaseDatabase.instance;

  static Future<String?> getFcmToken() async {
    try {
      return await messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  static Future<void> deleteFcmToken() async {
    try {
      await messaging.deleteToken();
    } catch (_) {}
  }

  static Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (_) {}
  }

  static User? get currentUser => auth.currentUser;

  static bool get isLogged =>
      auth.currentUser != null;
}