import 'package:dio/dio.dart';
import '../network/api_client.dart';

class UserService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('Failed to load profile');
    } on DioException catch (e) {
      throw Exception('Error loading profile: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  /// Get current user profile
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    try {
      final response = await _apiClient.get('/users/me');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('Failed to load current user profile');
    } on DioException catch (e) {
      throw Exception('Error loading profile: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
  }

  /// Get craftsman portfolio
  Future<List<dynamic>> getPortfolio(String userId) async {
    try {
      final response = await _apiClient.get('/media/$userId/PORTFOLIO');

      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data as List;
        } else if (response.data is Map && response.data.containsKey('media')) {
          return response.data['media'] as List;
        } else if (response.data is Map && response.data.containsKey('data')) {
          return response.data['data'] as List;
        }
      }

      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No portfolio items yet
      }
      throw Exception('Error loading portfolio: ${e.message}');
    } catch (e) {
      return []; // Return empty on error
    }
  }

  /// Get certificates
  Future<List<dynamic>> getCertificates(String userId) async {
    try {
      final response = await _apiClient.get('/verification/$userId/certificates');

      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data as List;
        } else if (response.data is Map && response.data.containsKey('certificates')) {
          return response.data['certificates'] as List;
        } else if (response.data is Map && response.data.containsKey('data')) {
          return response.data['data'] as List;
        }
      }

      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No certificates yet
      }
      throw Exception('Error loading certificates: ${e.message}');
    } catch (e) {
      return []; // Return empty on error
    }
  }

  /// Update profile
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/users/$userId', data: data);

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      throw Exception('Error updating profile: ${e.message}');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  /// Update current user profile
  Future<void> updateCurrentUserProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.put('/users/me', data: data);

      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    } on DioException catch (e) {
      throw Exception('Error updating profile: ${e.message}');
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }

  /// Upload portfolio image
  Future<Map<String, dynamic>> uploadPortfolioImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        'category': 'PORTFOLIO',
      });

      final response = await _apiClient.post(
        '/media/upload/image',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('Failed to upload image');
    } on DioException catch (e) {
      throw Exception('Error uploading image: ${e.message}');
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final response = await _apiClient.get('/users/$userId/stats');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      return {};
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return {}; // No stats yet
      }
      throw Exception('Error loading stats: ${e.message}');
    } catch (e) {
      return {}; // Return empty on error
    }
  }
}
