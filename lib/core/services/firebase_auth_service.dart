import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/user.dart' as app_models;
import 'api_service.dart';
import 'storage_service.dart';
import 'auth_service.dart';
import '../constants/app_constants.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final ApiService _apiService = ApiService();
  final StorageService _storage = StorageService();
  final AuthService _authService = AuthService();

  /// Get current Firebase user
  User? get currentFirebaseUser => _auth.currentUser;

  /// Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Signed in with email: ${credential.user?.email}');
      return credential;
    } catch (e) {
      debugPrint('❌ Error signing in with email: $e');
      rethrow;
    }
  }

  /// Create user with email and password
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Created user with email: ${credential.user?.email}');
      return credential;
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      rethrow;
    }
  }

  /// Sign in with Google
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('✅ Signed in with Google: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      debugPrint('❌ Error signing in with Google: $e');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      debugPrint('✅ Signed out successfully');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
      rethrow;
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }
      await user.sendEmailVerification();
      debugPrint('✅ Email verification sent');
    } catch (e) {
      debugPrint('❌ Error sending email verification: $e');
      rethrow;
    }
  }

  /// Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  /// Get user ID token (for backend authentication)
  Future<String?> getIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;
      return await user.getIdToken();
    } catch (e) {
      debugPrint('❌ Error getting ID token: $e');
      return null;
    }
  }

  /// Link Firebase account with backend user
  /// This should be called after Firebase sign in to sync with backend
  Future<app_models.User> linkWithBackend({
    required String firebaseUid,
    String? email,
    String? fullName,
    String? phone,
  }) async {
    try {
      // Call backend API to create/link user
      final response = await _apiService.post(
        '/auth/firebase-link',
        data: {
          'firebaseUid': firebaseUid,
          'email': email,
          'fullName': fullName,
          'phone': phone,
        },
      );

      final data = response.data;
      if (data is Map && data.containsKey('data')) {
        final userJson = data['data'] as Map<String, dynamic>;
        final token = data['token'] as String?;

        // Save token if provided
        if (token != null) {
          await _storage.setSecureString(AppConstants.keyToken, token);
        }

        // Save user data to AuthService (similar to login/register)
        final user = app_models.User.fromJson(userJson);
        await _storage.setString(
          AppConstants.keyUser,
          jsonEncode(userJson),
        );
        
        // Update AuthService current user
        _authService.setCurrentUser(user);

        return user;
      }
      throw Exception('Invalid response format');
    } catch (e) {
      debugPrint('❌ Error linking with backend: $e');
      rethrow;
    }
  }

  /// Sign in with Google and link with backend
  Future<app_models.User> signInWithGoogleAndLink() async {
    try {
      // 1. Sign in with Google (Firebase)
      final credential = await signInWithGoogle();
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Firebase user is null');
      }

      // 2. Link with backend
      return await linkWithBackend(
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email,
        fullName: firebaseUser.displayName,
        phone: firebaseUser.phoneNumber,
      );
    } catch (e) {
      debugPrint('❌ Error in signInWithGoogleAndLink: $e');
      rethrow;
    }
  }
}

