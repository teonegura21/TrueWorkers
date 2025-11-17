import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data (tokens, credentials)
/// Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences
/// - Web: localStorage (with encryption)
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // Keys
  static const String _keyFirebaseToken = 'firebase_token';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserId = 'user_id';
  static const String _keyRememberMe = 'remember_me';
  static const String _keyLastLoginTime = 'last_login_time';

  // === AUTH TOKEN MANAGEMENT ===

  /// Save Firebase auth token securely
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyFirebaseToken, value: token);
    await _storage.write(
      key: _keyLastLoginTime,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Get saved auth token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyFirebaseToken);
  }

  /// Delete auth token (logout)
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: _keyFirebaseToken);
  }

  // === USER CREDENTIALS ===

  /// Save user email (only if remember me is enabled)
  Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _keyUserEmail, value: email);
  }

  /// Get saved user email
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  /// Get saved user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  // === REMEMBER ME ===

  /// Set remember me preference
  Future<void> setRememberMe(bool remember) async {
    await _storage.write(
      key: _keyRememberMe,
      value: remember.toString(),
    );
  }

  /// Check if remember me is enabled
  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: _keyRememberMe);
    return value == 'true';
  }

  // === SESSION VALIDATION ===

  /// Check if session is still valid (within 30 days)
  Future<bool> isSessionValid() async {
    final lastLoginStr = await _storage.read(key: _keyLastLoginTime);
    if (lastLoginStr == null) return false;

    final lastLogin = DateTime.tryParse(lastLoginStr);
    if (lastLogin == null) return false;

    final daysSinceLogin = DateTime.now().difference(lastLogin).inDays;
    return daysSinceLogin < 30; // Session valid for 30 days
  }

  // === CLEAR ALL DATA ===

  /// Clear all stored credentials (complete logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Clear only auth data (keep preferences)
  Future<void> clearAuthData() async {
    await _storage.delete(key: _keyFirebaseToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyLastLoginTime);
  }
}
