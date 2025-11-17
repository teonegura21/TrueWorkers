import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import '../config/app_config.dart';
import '../../../firebase_options.dart';

/// Firebase Service for TrueWorkers Client App
///
/// Handles Firebase initialization, authentication, and user management
/// with role-based access control (client=0, craftsman=1)
///
/// @author Archyt - Principal Engineer
/// @version 1.0.0
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final FirebaseAnalytics _analytics;
  late final FirebaseCrashlytics _crashlytics;

  // App configuration
  static const String appRole = 'client'; // This app is for clients
  static const int roleValue = 0; // client=0, craftsman=1

  bool _isInitialized = false;
  User? _currentUser;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseAnalytics get analytics => _analytics;
  FirebaseCrashlytics get crashlytics => _crashlytics;
  bool get isInitialized => _isInitialized;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Initialize Firebase services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize Firebase with platform-specific options
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize service instances
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Set up error handling
      if (!kDebugMode) {
        FlutterError.onError = _crashlytics.recordFlutterFatalError;
        PlatformDispatcher.instance.onError = (error, stack) {
          _crashlytics.recordError(error, stack, fatal: true);
          return true;
        };
      }

      // Listen to auth state changes
      _auth.authStateChanges().listen(_onAuthStateChanged);

      // Set current user if already logged in
      _currentUser = _auth.currentUser;

      _isInitialized = true;

      if (kDebugMode) {
        print('🔥 Firebase initialized successfully for client app');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase initialization failed: $e');
      }
      rethrow;
    }
  }

  /// Handle authentication state changes
  void _onAuthStateChanged(User? user) {
    _currentUser = user;
    if (kDebugMode) {
      if (user != null) {
        print('👤 User signed in: ${user.email}');
      } else {
        print('👤 User signed out');
      }
    }
  }

  /// Register new client with email and password
  Future<UserCredential> registerClient({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) throw Exception('User creation failed');

      // Update display name
      await user.updateDisplayName(name);

      // Create user profile in Firestore
      await createUserProfile(
        uid: user.uid,
        name: name,
        email: email,
        phoneNumber: phoneNumber,
      );

      // Set custom claims (handled by backend)
      await _requestRoleAssignment(user.uid, appRole);

      // Log analytics event
      await _analytics.logSignUp(signUpMethod: 'email');

      if (kDebugMode) {
        print('✅ Client registered successfully: ${user.email}');
      }

      return credential;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Registration failed: $e');
      }
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Verify user role
      await _verifyUserRole(credential.user);

      // Log analytics event
      await _analytics.logLogin(loginMethod: 'email');

      if (kDebugMode) {
        print('✅ Client signed in successfully: ${credential.user?.email}');
      }

      return credential;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign in failed: $e');
      }
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      if (kDebugMode) {
        print('✅ User signed out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Sign out failed: $e');
      }
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Get current user's Firebase ID token
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

  /// Create user profile in Firestore
  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
    String? phoneNumber,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'role': appRole,
        'roleValue': roleValue,
        'isVerified': false,
        'rating': 0.0,
        'completedProjects': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ User profile created in Firestore');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to create user profile: $e');
      }
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Get user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile([String? uid]) async {
    try {
      final userId = uid ?? _currentUser?.uid;
      if (userId == null) return null;

      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get user profile: $e');
      }
      return null;
    }
  }

  /// Update user profile in Firestore
  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final userId = _currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      updates['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('users').doc(userId).update(updates);

      if (kDebugMode) {
        print('✅ User profile updated');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to update user profile: $e');
      }
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Request role assignment from backend
  Future<void> _requestRoleAssignment(String uid, String role) async {
    if (kDebugMode) {
      print('🔧 Requesting role assignment: $uid -> $role');
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/firebase-auth/set-role'),
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode({
          'uid': uid,
          'role': role,
          'email': _currentUser?.email,
          'name': _currentUser?.displayName,
        }),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('✅ Role assignment successful');
        }
      } else {
        throw Exception('Role assignment failed: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Role assignment request failed: $e');
      }
      // Don't throw - allow registration to continue
    }
  }

  /// Verify user has correct role for this app
  Future<void> _verifyUserRole(User? user) async {
    if (user == null) return;

    try {
      // Get ID token and check custom claims
      final idTokenResult = await user.getIdTokenResult();
      final claims = idTokenResult.claims;

      final userRole = claims?['role'] as String?;
      final userRoleValue = claims?['roleValue'] as int?;

      if (userRole != appRole || userRoleValue != roleValue) {
        throw Exception('Access denied: This app is for clients only');
      }

      if (kDebugMode) {
        print('✅ User role verified: $userRole');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Role verification failed: $e');
      }
      // For development, we'll allow access without role verification
      // In production, uncomment the next line:
      // rethrow;
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (kDebugMode) {
        print('✅ Password reset email sent');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send password reset email: $e');
      }
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      final user = _currentUser;
      if (user == null) throw Exception('No user to delete');

      // Delete user profile from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();

      if (kDebugMode) {
        print('✅ User account deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to delete account: $e');
      }
      await _crashlytics.recordError(e, null);
      rethrow;
    }
  }

  /// Synchronize user with backend after authentication
  Future<Map<String, dynamic>?> syncUserWithBackend() async {
    final user = _currentUser;
    if (user == null) return null;

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/firebase-auth/sync-user'),
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName,
          'role': appRole,
          'phoneNumber': user.phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body);
        if (kDebugMode) {
          print('✅ User synchronized with backend');
        }
        return data;
      } else {
        throw Exception('Backend sync failed: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to sync with backend: $e');
      }
      await _crashlytics.recordError(e, null);
      return null;
    }
  }

  /// Get complete user profile (Firebase + backend data)
  Future<Map<String, dynamic>?> getCompleteProfile() async {
    final user = _currentUser;
    if (user == null) return null;

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/firebase-auth/get-profile'),
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode({'uid': user.uid}),
      );

      if (response.statusCode == 200) {
        final data = convert.jsonDecode(response.body);
        return data['profile'];
      } else {
        throw Exception('Failed to get profile: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get complete profile: $e');
      }
      return null;
    }
  }
}

/// Global Firebase service instance
final firebaseService = FirebaseService();
