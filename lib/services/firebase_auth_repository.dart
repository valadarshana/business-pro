import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  Future<void>? _googleInitialization;

  @override
  Stream<AuthUser?> get authStateChanges => _auth.authStateChanges().map(
    (user) => user == null ? null : _toAuthUser(user),
  );

  @override
  Future<AuthUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase Authentication returned no signed-in user.');
    }
    return _completeSignIn(user);
  }

  @override
  Future<AuthUser> registerWithEmail({
    required String name,
    required String businessName,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase Authentication returned no created user.');
    }

    try {
      await user.updateDisplayName(name.trim());
      return await _completeSignIn(
        user,
        profileName: name.trim(),
        businessName: businessName.trim(),
      );
    } on Exception catch (error, stackTrace) {
      if (_auth.currentUser?.uid == user.uid) {
        try {
          await _auth.signOut();
        } on Exception catch (signOutError) {
          throw StateError(
            'Registration failed ($error) and Firebase sign-out cleanup '
            'also failed ($signOutError).',
          );
        }
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = firebase_auth.GoogleAuthProvider();
      provider.addScope('email');
      final credential = await _auth.signInWithPopup(provider);
      final user = credential.user;
      if (user == null) {
        throw StateError('Google sign-in returned no authenticated user.');
      }
      return _completeSignIn(user);
    }

    const clientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
    const serverClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    final platformClientId =
        defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS
        ? clientId
        : '';
    _googleInitialization ??= _googleSignIn.initialize(
      clientId: platformClientId.isEmpty ? null : platformClientId,
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
    await _googleInitialization;
    if (!_googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError(
        'This platform does not support the Google sign-in flow used by this app.',
      );
    }

    final googleUser = await _googleSignIn.authenticate();
    final idToken = googleUser.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw StateError(
        'Google did not return an ID token. Check the OAuth client configuration.',
      );
    }

    final googleCredential = firebase_auth.GoogleAuthProvider.credential(
      idToken: idToken,
    );
    final credential = await _auth.signInWithCredential(googleCredential);
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase Authentication returned no signed-in user.');
    }
    return _completeSignIn(user);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb) await _googleSignIn.signOut();
  }

  AuthUser _toAuthUser(firebase_auth.User user) => AuthUser(
    id: user.uid,
    email: user.email ?? '',
    name: user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email?.split('@').first ?? 'Business owner',
    photoUrl: user.photoURL,
  );

  Future<AuthUser> _completeSignIn(
    firebase_auth.User user, {
    String? profileName,
    String? businessName,
  }) async {
    try {
      await _ensureUserProfile(
        user,
        name: profileName,
        businessName: businessName,
      );
    } on firebase_core.FirebaseException catch (error, stackTrace) {
      try {
        await _auth.signOut();
      } on Exception catch (signOutError) {
        throw StateError(
          'Could not save the user profile (${error.message ?? error.code}) '
          'or roll back the sign-in ($signOutError).',
        );
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
    return _toAuthUser(user);
  }

  Future<void> _ensureUserProfile(
    firebase_auth.User user, {
    String? name,
    String? businessName,
  }) async {
    final profile = _firestore.collection('users').doc(user.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(profile);
      final now = FieldValue.serverTimestamp();
      if (!snapshot.exists) {
        transaction.set(profile, {
          'uid': user.uid,
          'name':
              name ?? user.displayName ?? user.email?.split('@').first ?? '',
          'email': user.email ?? '',
          'businessName': businessName ?? '',
          'phone': user.phoneNumber ?? '',
          'profileImage': user.photoURL ?? '',
          'isActive': true,
          'createdAt': now,
          'updatedAt': now,
        });
      } else {
        final updates = <String, Object?>{
          'email': user.email ?? '',
          'updatedAt': now,
        };
        if (name != null) updates['name'] = name;
        if (businessName != null) updates['businessName'] = businessName;
        transaction.set(profile, updates, SetOptions(merge: true));
      }
    });
  }
}
