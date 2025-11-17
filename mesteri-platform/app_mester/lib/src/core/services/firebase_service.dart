import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late final FirebaseAuth _auth;
  bool _isInitialized = false;
  User? _currentUser;

  FirebaseAuth get auth => _auth;
  bool get isInitialized => _isInitialized;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      _auth = FirebaseAuth.instance;
      _auth.authStateChanges().listen(_onAuthStateChanged);
      _currentUser = _auth.currentUser;
      _isInitialized = true;

      if (kDebugMode) {
        print('🔥 Firebase initialized for craftsman app');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase initialization failed: $e');
      }
      rethrow;
    }
  }

  void _onAuthStateChanged(User? user) {
    _currentUser = user;
  }

  Future<String?> getIdToken({bool forceRefresh = false}) async {
    final user = _currentUser;
    if (user == null) return null;

    try {
      return await user.getIdToken(forceRefresh);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get ID token: $e');
      }
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out failed: $e');
      }
      rethrow;
    }
  }
}

final firebaseService = FirebaseService();
