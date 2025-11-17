import 'package:dio/dio.dart';
import '../models/inspiration_post.dart';
import '../../../core/network/api_client.dart';

class InspirationService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get inspiration feed (TikTok-style)
  Future<List<InspirationPost>> getFeed({
    int page = 1,
    int limit = 20,
    String? userId,
  }) async {
    try {
      final response = await _apiClient.get(
        '/inspiration/feed',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (userId != null) 'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle different response structures
        List<dynamic> postsData;
        if (data is List) {
          postsData = data;
        } else if (data is Map && data.containsKey('posts')) {
          postsData = data['posts'] as List;
        } else if (data is Map && data.containsKey('data')) {
          postsData = data['data'] as List;
        } else {
          throw Exception('Unexpected response format from server');
        }

        final posts = postsData
            .map((json) => InspirationPost.fromJson(json as Map<String, dynamic>))
            .toList();
        return posts;
      }

      throw Exception('Failed to load inspiration feed: ${response.statusCode}');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No posts available yet
      }
      throw Exception('Failed to load inspiration feed: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching inspiration feed: $e');
    }
  }

  /// Get posts by craftsman
  Future<List<InspirationPost>> getPostsByCraftsman(String craftsmanId) async {
    try {
      final response = await _apiClient.get(
        '/inspiration',
        queryParameters: {
          'craftsmanId': craftsmanId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        List<dynamic> postsData;
        if (data is List) {
          postsData = data;
        } else if (data is Map && data.containsKey('posts')) {
          postsData = data['posts'] as List;
        } else if (data is Map && data.containsKey('data')) {
          postsData = data['data'] as List;
        } else {
          return [];
        }

        final posts = postsData
            .map((json) => InspirationPost.fromJson(json as Map<String, dynamic>))
            .toList();
        return posts;
      }

      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No posts for this craftsman
      }
      throw Exception('Failed to load craftsman posts: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching craftsman posts: $e');
    }
  }

  /// Like a post
  Future<bool> likePost(String postId) async {
    try {
      final response = await _apiClient.post('/inspiration/$postId/like');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('Error liking post: ${e.message}');
      return false;
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  /// Share a post
  Future<bool> sharePost(String postId) async {
    try {
      final response = await _apiClient.post('/inspiration/$postId/share');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      print('Error sharing post: ${e.message}');
      return false;
    } catch (e) {
      print('Error sharing post: $e');
      return false;
    }
  }

  /// Increment view count
  Future<void> incrementViews(String postId) async {
    try {
      await _apiClient.post('/inspiration/$postId/view');
    } catch (e) {
      // Silently fail for view tracking
      print('Failed to track view: $e');
    }
  }

  /// Get post by ID
  Future<InspirationPost?> getPost(String postId) async {
    try {
      final response = await _apiClient.get('/inspiration/$postId');

      if (response.statusCode == 200) {
        return InspirationPost.fromJson(response.data as Map<String, dynamic>);
      }

      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to load post: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching post: $e');
    }
  }
}
