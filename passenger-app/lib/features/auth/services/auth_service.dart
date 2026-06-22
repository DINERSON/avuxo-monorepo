import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<void> saveLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    final user = _auth.currentUser;

    await prefs.setBool('is_logged_in', user != null);
    await prefs.setString('uid', user?.uid ?? '');
  }

  static Future<void> clearLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('uid');
  }

  static Future<bool> hasSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final localSession = prefs.getBool('is_logged_in') ?? false;
    final firebaseUser = _auth.currentUser;

    return localSession && firebaseUser != null;
  }

  static Future<void> savePendingName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('pending_user_name', name.trim());
  }

  static Future<String?> getPendingName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('pending_user_name');
  }

  static Future<void> clearPendingName() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_user_name');
  }

  static String normalizeBrazilPhone(String input) {
    final numbers = input.replaceAll(RegExp(r'[^0-9]'), '');

    if (numbers.startsWith('55') && numbers.length >= 12) {
      return '+$numbers';
    }

    if (numbers.length == 10 || numbers.length == 11) {
      return '+55$numbers';
    }

    return input.trim();
  }

  static Future<void> sendPhoneOtp({
    required String phone,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    final normalizedPhone = normalizeBrazilPhone(phone);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: normalizedPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _finishPhoneCredential(credential);
            await saveLoginSession();
          } catch (_) {}
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Erro ao enviar SMS.');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? e.code);
    } catch (_) {
      onError('Erro ao enviar código. Tente novamente.');
    }
  }

  static Future<void> verifyOtp({
    required String verificationId,
    required String smsCode,
    required String phone,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode.trim(),
    );

    await _finishPhoneCredential(credential);
    await saveLoginSession();
  }

  static Future<void> _finishPhoneCredential(
    PhoneAuthCredential credential,
  ) async {
    final current = _auth.currentUser;

    if (current != null) {
      try {
        await current.linkWithCredential(credential);
        await current.reload();
        return;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'provider-already-linked') {
          return;
        }

        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use') {
          await _auth.signInWithCredential(credential);
          return;
        }

        rethrow;
      }
    }

    await _auth.signInWithCredential(credential);
  }

  static Future<UserCredential> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn();
    final account = await googleSignIn.signIn();

    if (account == null) {
      throw Exception('Login cancelado.');
    }

    final googleAuth = await account.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);

    await saveLoginSession();

    return result;
  }

  static Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String name,
  }) async {
    await savePendingName(name);

    final result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await result.user?.updateDisplayName(name.trim());
    await result.user?.reload();

    return result;
  }

  static Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    await result.user?.reload();

    return result;
  }

  static Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}

    await _auth.signOut();
    await clearLoginSession();
    await clearPendingName();
  }
}