import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';
import '../network/api_client.dart';
import 'secure_storage_service.dart';

/// Enhanced Authentication Provider with caching and persistent login
///
/// Features:
/// - Automatic login with Firebase Auth persistence
/// - Remember me functionality
/// - User profile caching
/// - Token management
class AuthProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = firebaseService;
  final SecureStorageService _secureStorage = SecureStorageService();

  User? _currentUser;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;
  bool _rememberMe = true;

  // Getters
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get rememberMe => _rememberMe;

  String? get userId => _currentUser?.uid;
  String? get userEmail => _currentUser?.email;
  String? get userName =>
      _userProfile?['fullName'] ?? _currentUser?.displayName;
  String? get userRole => _userProfile?['role'];

  AuthProvider() {
    _initialize();
  }

  /// Initialize authentication state
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize Firebase service
      await _firebaseService.initialize();

      // Initialize API client auth token
      await ApiClient.initAuthToken();

      // Load remember me preference
      final prefs = await SharedPreferences.getInstance();
      _rememberMe = prefs.getBool('remember_me') ?? true;

      // Listen to auth state changes
      FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);

      // Check current user
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser != null) {
        await _loadUserProfile();
        await _updateAuthToken();
      }
    } catch (e) {
      _errorMessage = 'Initialization failed: $e';
      debugPrint('❌ Auth initialization error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Handle authentication state changes
  Future<void> _onAuthStateChanged(User? user) async {
    _currentUser = user;

    if (user != null) {
      await _loadUserProfile();
      await _updateAuthToken();
    } else {
      _userProfile = null;
      await _clearAuthToken();
    }

    notifyListeners();
  }

  /// Load user profile from backend
  Future<void> _loadUserProfile() async {
    try {
      final response = await _firebaseService.syncUserWithBackend();
      if (response != null) {
        _userProfile = response['user'];

        // Cache profile locally
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('user_profile', response.toString());
      }
    } catch (e) {
      debugPrint('❌ Failed to load user profile: $e');
    }
  }

  /// Update auth token in API client
  Future<void> _updateAuthToken() async {
    try {
      final token = await _currentUser?.getIdToken();
      if (token != null) {
        await ApiClient.setAuthTokenPersist(token);
        await _secureStorage.saveAuthToken(token);
      }
    } catch (e) {
      debugPrint('❌ Failed to update auth token: $e');
    }
  }

  /// Clear auth token
  Future<void> _clearAuthToken() async {
    await ApiClient.setAuthTokenPersist(null);
    await ApiClient.setRefreshTokenPersist(null);
    await _secureStorage.clearAuthData();
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rememberMe = rememberMe;

      // Save remember me preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', rememberMe);

      // Sign in with Firebase
      final credential = await _firebaseService.signInWithEmail(
        email: email,
        password: password,
      );

      _currentUser = credential.user;

      if (_currentUser != null) {
        await _loadUserProfile();
        await _updateAuthToken();

        // Save email and session if remember me is enabled
        if (rememberMe) {
          await _secureStorage.saveUserEmail(email);
          await _secureStorage.saveUserId(_currentUser!.uid);
          await _secureStorage.setRememberMe(true);
        } else {
          await _secureStorage.setRememberMe(false);
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Register with Firebase
      final credential = await _firebaseService.registerClient(
        email: email,
        password: password,
        name: name,
        phoneNumber: phone,
      );

      _currentUser = credential.user;

      if (_currentUser != null) {
        await _loadUserProfile();
        await _updateAuthToken();
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firebaseService.signOut();
      await _clearAuthToken();

      _currentUser = null;
      _userProfile = null;

      // Clear cached data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_profile');
    } catch (e) {
      _errorMessage = 'Sign out failed: $e';
      debugPrint('❌ Sign out error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firebaseService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _parseFirebaseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get saved email for auto-fill
  Future<String?> getSavedEmail() async {
    try {
      return await _secureStorage.getUserEmail();
    } catch (e) {
      return null;
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    await _loadUserProfile();
    notifyListeners();
  }

  /// Refresh auth token
  Future<void> refreshToken() async {
    await _updateAuthToken();
  }

  /// Parse Firebase error messages
  String _parseFirebaseError(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('user-not-found')) {
      return 'Nu există cont cu acest email';
    } else if (message.contains('wrong-password')) {
      return 'Parolă incorectă';
    } else if (message.contains('email-already-in-use')) {
      return 'Email-ul este deja înregistrat';
    } else if (message.contains('weak-password')) {
      return 'Parola este prea slabă';
    } else if (message.contains('invalid-email')) {
      return 'Email invalid';
    } else if (message.contains('network')) {
      return 'Eroare de conexiune. Verifică internetul';
    } else {
      return 'A apărut o eroare. Te rugăm să încerci din nou';
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
