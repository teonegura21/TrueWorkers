import '../models/conversation_models.dart';
import '../network/api_client.dart';

class ConversationsApiService {
  ConversationsApiService._();

  static final ConversationsApiService instance = ConversationsApiService._();
  final ApiClient _client = ApiClient.instance;

  Future<List<ConversationSummary>> listConversations() async {
    final response = await _client.get('/conversations');
    final data = response.data;
    if (data is List) {
      return data
          .map(
            (item) =>
                ConversationSummary.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    }
    return const [];
  }

  Future<ConversationSummary> ensureProjectConversation(
    String projectId,
  ) async {
    final response = await _client.post(
      '/conversations/projects/$projectId/ensure',
    );
    return ConversationSummary.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ConversationThread> fetchConversation(
    String conversationId, {
    int? skip,
    int? take,
  }) async {
    final response = await _client.get(
      '/conversations/$conversationId/messages',
      queryParameters: {
        if (skip != null) 'skip': skip.toString(),
        if (take != null) 'take': take.toString(),
      },
    );
    return ConversationThread.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ConversationMessage> sendMessage({
    required String conversationId,
    String? body,
    List<String>? attachmentIds,
    String kind = 'TEXT',
  }) async {
    final response = await _client.post(
      '/conversations/messages',
      data: {
        'conversationId': conversationId,
        if (body != null) 'body': body,
        'kind': kind,
        if (attachmentIds != null && attachmentIds.isNotEmpty)
          'attachmentIds': attachmentIds,
      },
    );
    return ConversationMessage.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> markConversationRead(
    String conversationId, {
    String? messageId,
  }) async {
    await _client.post(
      '/conversations/$conversationId/read',
      data: {if (messageId != null) 'messageId': messageId},
    );
  }

  Future<int> fetchUnreadCount(String conversationId) async {
    final response = await _client.get(
      '/conversations/$conversationId/unread-count',
    );
    final data = response.data as Map<String, dynamic>?;
    return (data?['count'] as num?)?.toInt() ?? 0;
  }
}
