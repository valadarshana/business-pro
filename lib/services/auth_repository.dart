import '../models/auth_user.dart';

abstract interface class AuthRepository {
  Stream<AuthUser?> get authStateChanges;

  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthUser> registerWithEmail({
    required String name,
    required String businessName,
    required String email,
    required String password,
  });

  Future<AuthUser> signInWithGoogle();

  Future<void> signOut();
}
