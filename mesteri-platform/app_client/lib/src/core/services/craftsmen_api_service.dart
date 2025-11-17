import 'package:dio/dio.dart';
import '../network/api_client.dart';

/// Service for craftsmen-related API calls
class CraftsmenApiService {
  final ApiClient _apiClient = ApiClient.instance;
  
  /// Search for craftsmen with filters
  Future<Map<String, dynamic>> searchCraftsmen({
    String? query,
    List<String>? specialties,
    String? city,
    String? county,
    double? minRating,
    bool? isVerified,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        if (query != null && query.isNotEmpty) 'query': query,
        if (specialties != null && specialties.isNotEmpty) 'specialties': specialties.join(','),
        if (city != null && city.isNotEmpty) 'city': city,
        if (county != null && county.isNotEmpty) 'county': county,
        if (minRating != null) 'minRating': minRating,
        if (isVerified != null) 'isVerified': isVerified,
        'page': page,
        'limit': limit,
      };
      
      final response = await _apiClient.get(
        '/api/users/craftsmen',
        queryParameters: queryParams,
      );
      
      return {
        'craftsmen': response.data['craftsmen'] ?? [],
        'total': response.data['total'] ?? 0,
        'page': response.data['page'] ?? 1,
        'totalPages': response.data['totalPages'] ?? 1,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get craftsman profile by ID
  Future<Map<String, dynamic>> getCraftsmanProfile(String craftsmanId) async {
    try {
      final response = await _apiClient.get('/api/users/craftsmen/$craftsmanId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get craftsman reviews
  Future<Map<String, dynamic>> getCraftsmanReviews(
    String craftsmanId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/reviews/craftsman/$craftsmanId',
        queryParameters: {'page': page, 'limit': limit},
      );
      
      return {
        'reviews': response.data['reviews'] ?? [],
        'total': response.data['total'] ?? 0,
        'averageRating': response.data['averageRating'] ?? 0.0,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get craftsman projects/portfolio
  Future<List<dynamic>> getCraftsmanPortfolio(String craftsmanId) async {
    try {
      final response = await _apiClient.get('/api/projects/craftsman/$craftsmanId');
      return response.data['projects'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get featured/top craftsmen
  Future<List<dynamic>> getFeaturedCraftsmen({int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/api/users/craftsmen/featured',
        queryParameters: {'limit': limit},
      );
      return response.data['craftsmen'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get craftsmen by specialty
  Future<List<dynamic>> getCraftsmenBySpecialty(
    String specialty, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/users/craftsmen',
        queryParameters: {
          'specialties': specialty,
          'page': page,
          'limit': limit,
        },
      );
      return response.data['craftsmen'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get nearby craftsmen
  Future<List<dynamic>> getNearbyCraftsmen({
    required String city,
    String? specialty,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'city': city,
        if (specialty != null) 'specialties': specialty,
        'limit': limit,
      };
      
      final response = await _apiClient.get(
        '/api/users/craftsmen',
        queryParameters: queryParams,
      );
      return response.data['craftsmen'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  Exception _handleError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = e.response!.data['message'] ?? 'An error occurred';
      
      return Exception('Error $statusCode: $message');
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}
