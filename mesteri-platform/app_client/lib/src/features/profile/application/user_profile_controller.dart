import 'package:flutter/foundation.dart';
import 'package:app_client/src/core/services/comprehensive_service.dart';
import 'package:app_client/src/core/network/api_client.dart';

class UserProfileController extends ChangeNotifier {
  final MesteriService _mesteriService;
  UserProfile? _userProfile;
  bool _isLoading = false;
  String? _error;

  UserProfileController({MesteriService? mesteriService})
      : _mesteriService = mesteriService ?? MesteriService();

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userProfile = await _mesteriService.getUserProfile(userId);
    } catch (e, stackTrace) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching user profile: $e\n$stackTrace');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _userProfile = await _mesteriService.updateUserProfile(userId, updates);
    } catch (e, stackTrace) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error updating user profile: $e\n$stackTrace');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await ApiClient.setAuthTokenPersist(null);
    await ApiClient.setRefreshTokenPersist(null);
    _userProfile = null;
    _isLoading = false;
    notifyListeners();
  }
}
