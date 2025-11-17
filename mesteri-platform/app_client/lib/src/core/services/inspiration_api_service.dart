import 'package:dio/dio.dart';
import '../network/api_client.dart';

/// Service for Inspiration Feed API calls
/// Manages the TikTok-style content feed showcasing craftsmen work
class InspirationApiService {
  final ApiClient _apiClient = ApiClient.instance;
  
  /// Get inspiration feed posts (TikTok-style)
  Future<Map<String, dynamic>> getFeedPosts({
    int page = 1,
    int limit = 10,
    String? category,
    String? city,
    List<String>? skills,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (category != null && category.isNotEmpty) 'category': category,
        if (city != null && city.isNotEmpty) 'city': city,
        if (skills != null && skills.isNotEmpty) 'skills': skills.join(','),
      };
      
      final response = await _apiClient.get(
        '/api/inspiration/feed',
        queryParameters: queryParams,
      );
      
      return {
        'posts': response.data['posts'] ?? [],
        'total': response.data['total'] ?? 0,
        'page': response.data['page'] ?? 1,
        'hasMore': response.data['hasMore'] ?? false,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get a single inspiration post by ID
  Future<Map<String, dynamic>> getPost(String postId) async {
    try {
      final response = await _apiClient.get('/api/inspiration/posts/$postId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get posts by craftsman
  Future<List<dynamic>> getCraftsmanPosts(
    String craftsmanId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/inspiration/craftsman/$craftsmanId',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data['posts'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Like a post
  Future<Map<String, dynamic>> likePost(String postId) async {
    try {
      final response = await _apiClient.post('/api/inspiration/posts/$postId/like');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Unlike a post
  Future<Map<String, dynamic>> unlikePost(String postId) async {
    try {
      final response = await _apiClient.delete('/api/inspiration/posts/$postId/like');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Increment view count
  Future<void> incrementViews(String postId) async {
    try {
      await _apiClient.post('/api/inspiration/posts/$postId/view');
    } on DioException catch (e) {
      // Silently fail for view tracking
      print('Failed to track view: $e');
    }
  }
  
  /// Share a post (increment share count)
  Future<void> sharePost(String postId) async {
    try {
      await _apiClient.post('/api/inspiration/posts/$postId/share');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get trending posts
  Future<List<dynamic>> getTrendingPosts({int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        '/api/inspiration/trending',
        queryParameters: {'limit': limit},
      );
      return response.data['posts'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get posts by category
  Future<Map<String, dynamic>> getPostsByCategory(
    String category, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/inspiration/category/$category',
        queryParameters: {'page': page, 'limit': limit},
      );
      
      return {
        'posts': response.data['posts'] ?? [],
        'total': response.data['total'] ?? 0,
        'hasMore': response.data['hasMore'] ?? false,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Search inspiration posts
  Future<Map<String, dynamic>> searchPosts({
    required String query,
    String? category,
    String? city,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'query': query,
        if (category != null && category.isNotEmpty) 'category': category,
        if (city != null && city.isNotEmpty) 'city': city,
        'page': page,
        'limit': limit,
      };
      
      final response = await _apiClient.get(
        '/api/inspiration/search',
        queryParameters: queryParams,
      );
      
      return {
        'posts': response.data['posts'] ?? [],
        'total': response.data['total'] ?? 0,
        'hasMore': response.data['hasMore'] ?? false,
      };
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
