import 'package:dio/dio.dart';
import '../network/api_client.dart';

/// Service for messaging-related API calls
class MessagingApiService {
  final ApiClient _apiClient = ApiClient.instance;
  
  /// Get conversations list
  Future<List<dynamic>> getConversations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/conversations',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data['conversations'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get conversation by ID
  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    try {
      final response = await _apiClient.get('/api/conversations/$conversationId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get messages for a conversation/project
  Future<Map<String, dynamic>> getMessages(
    String projectId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/messages/project/$projectId',
        queryParameters: {'page': page, 'limit': limit},
      );
      
      return {
        'messages': response.data['messages'] ?? [],
        'total': response.data['total'] ?? 0,
        'hasMore': response.data['hasMore'] ?? false,
      };
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Send a message (REST fallback if WebSocket fails)
  Future<Map<String, dynamic>> sendMessage({
    required String projectId,
    required String receiverId,
    required String content,
    String? messageType,
    List<dynamic>? attachments,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/messages',
        data: {
          'projectId': projectId,
          'receiverId': receiverId,
          'content': content,
          if (messageType != null) 'messageType': messageType,
          if (attachments != null) 'attachments': attachments,
          if (metadata != null) 'metadata': metadata,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Mark messages as read
  Future<void> markAsRead(String projectId) async {
    try {
      await _apiClient.put('/api/messages/project/$projectId/read');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get unread message count
  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get('/api/messages/unread/count');
      return response.data['count'] ?? 0;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Create a new conversation
  Future<Map<String, dynamic>> createConversation({
    required String projectId,
    String? title,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/conversations',
        data: {
          'projectId': projectId,
          if (title != null) 'title': title,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      await _apiClient.delete('/api/messages/$messageId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Upload attachment
  Future<Map<String, dynamic>> uploadAttachment(
    String filePath,
    String fileName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      
      final response = await _apiClient.post(
        '/api/storage/upload',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  /// Get conversation for a specific project
  Future<Map<String, dynamic>?> getProjectConversation(String projectId) async {
    try {
      final response = await _apiClient.get('/api/conversations/project/$projectId');
      return response.data;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null; // No conversation exists yet
      }
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
