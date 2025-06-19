import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/auth/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final _auth = FirebaseAuth.instance;

  AuthNotifier() : super(const InitialAuthState()) {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        state = AuthenticatedState(user);
      } else {
        state = const UnauthenticatedState();
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      state = const LoadingAuthState();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      state = ErrorAuthState(e.message ?? 'An error occurred');
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      state = const LoadingAuthState();
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      state = ErrorAuthState(e.message ?? 'An error occurred');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
