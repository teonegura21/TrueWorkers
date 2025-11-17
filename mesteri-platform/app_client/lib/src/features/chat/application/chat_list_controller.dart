import 'package:flutter/foundation.dart';
import 'package:app_client/src/core/services/conversations_api_service.dart';
import 'package:app_client/src/core/models/conversation_models.dart';

class ChatListController extends ChangeNotifier {
  final ConversationsApiService _conversationsApiService;
  List<ConversationSummary> _conversations = [];
  bool _isLoading = false;
  String? _error;

  ChatListController({ConversationsApiService? conversationsApiService})
      : _conversationsApiService = conversationsApiService ?? ConversationsApiService.instance;

  List<ConversationSummary> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _conversationsApiService.listConversations();
    } catch (e, stackTrace) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error fetching conversations: $e\n$stackTrace');
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
}
