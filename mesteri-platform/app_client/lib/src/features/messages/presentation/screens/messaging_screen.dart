import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/models/conversation_models.dart';
import '../../../../core/services/conversations_api_service.dart';
import '../../../../core/services/storage_api_service.dart';
import '../../../../core/theme/app_theme.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen>
    with SingleTickerProviderStateMixin {
  final _conversationsApi = ConversationsApiService.instance;
  final _storageApi = StorageApiService.instance;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  late final TabController _tabController;

  bool _isLoadingList = true;
  bool _isLoadingThread = false;
  bool _isSending = false;
  String? _errorMessage;

  List<ConversationSummary> _allConversations = [];
  List<ConversationSummary> _visibleConversations = [];
  ConversationSummary? _selectedConversation;
  ConversationThread? _currentThread;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(_handleTabSelection);
    _loadConversations();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _isLoadingList = true;
      _errorMessage = null;
    });
    try {
      final conversations = await _conversationsApi.listConversations();
      _allConversations = conversations;
      _applyFilters();
      if (_visibleConversations.isNotEmpty) {
        await _selectConversation(_visibleConversations.first, loadThread: true);
      } else {
        setState(() {
          _selectedConversation = null;
          _currentThread = null;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Nu am putut încarca conversa?iile.';
      });
    } finally {
      setState(() {
        _isLoadingList = false;
      });
    }
  }

  void _applyFilters() {
    final tabIndex = _tabController.index;
    final query = _searchController.text.trim().toLowerCase();

    Iterable<ConversationSummary> filtered = _allConversations;
    if (tabIndex == 0) {
      filtered = filtered.where((conversation) => conversation.isActive);
    }

    if (query.isNotEmpty) {
      filtered = filtered.where((conversation) {
        final titleMatch = conversation.title.toLowerCase().contains(query);
        final participantMatch = conversation.participants.any(
          (participant) => participant.name.toLowerCase().contains(query),
        );
        return titleMatch || participantMatch;
      });
    }

    final sorted = filtered.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    setState(() {
      _visibleConversations = sorted;
      if (_selectedConversation != null && !_visibleConversations.any((c) => c.id == _selectedConversation!.id)) {
        _selectedConversation = _visibleConversations.isNotEmpty ? _visibleConversations.first : null;
      }
    });
  }

  Future<void> _selectConversation(ConversationSummary conversation, {bool loadThread = true}) async {
    setState(() {
      _selectedConversation = conversation;
      _currentThread = null;
      _isLoadingThread = loadThread;
    });

    if (loadThread) {
      try {
        final thread = await _conversationsApi.fetchConversation(conversation.id);
        _currentThread = thread;
        _selectedConversation = thread.summary;
        _updateSummary(thread.summary);
        await _conversationsApi.markConversationRead(conversation.id);
        _updateUnreadCount(conversation.id, 0);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nu am putut încarca mesajele.')), 
        );
      } finally {
        setState(() {
          _isLoadingThread = false;
        });
      }
    }
  }

  Future<void> _handleSendMessage() async {
    final summary = _selectedConversation;
    final thread = _currentThread;
    if (summary == null || thread == null) return;

    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      final message = await _conversationsApi.sendMessage(
        conversationId: summary.id,
        body: text,
      );
      _messageController.clear();

      final updatedMessages = List<ConversationMessage>.from(thread.messages)..add(message);
      final updatedSummary = summary.copyWith(
        lastMessage: message,
        unreadCount: 0,
        updatedAt: message.sentAt,
      );

      setState(() {
        _currentThread = thread.copyWith(
          messages: updatedMessages,
          total: thread.total + 1,
          summary: updatedSummary,
        );
        _selectedConversation = updatedSummary;
      });

      _updateSummary(updatedSummary);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trimiterea mesajului a e?uat. Încearca din nou.')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Future<void> _refreshConversations() async {
    await _loadConversations();
  }

  void _handleSearchChanged(String value) {
    _applyFilters();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) return;
    _applyFilters();
  }

  void _updateSummary(ConversationSummary summary) {
    final index = _allConversations.indexWhere((c) => c.id == summary.id);
    if (index >= 0) {
      _allConversations[index] = summary;
    } else {
      _allConversations.insert(0, summary);
    }
    _applyFilters();
  }

  void _updateUnreadCount(String conversationId, int unreadCount) {
    final index = _allConversations.indexWhere((conversation) => conversation.id == conversationId);
    if (index >= 0) {
      final summary = _allConversations[index];
      _allConversations[index] = summary.copyWith(unreadCount: unreadCount);
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesaje'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.onSurfaceSecondary,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Toate'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  flex: 3,
                  child: _buildConversationList(),
                ),
                const VerticalDivider(width: 1),
                Flexible(
                  flex: 5,
                  child: _buildConversationView(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _handleSearchChanged,
        decoration: InputDecoration(
          hintText: 'Cauta dupa proiect sau participant...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppTheme.surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildConversationList() {
    if (_isLoadingList) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_visibleConversations.isEmpty) {
      return const Center(child: Text('Nu exista conversa?ii disponibile.'));
    }

    return RefreshIndicator(
      onRefresh: _refreshConversations,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: _visibleConversations.length,
        itemBuilder: (context, index) {
          final conversation = _visibleConversations[index];
          final isSelected = _selectedConversation?.id == conversation.id;
          final lastMessage = conversation.lastMessage?.body ?? '—';
          final subtitle = conversation.project != null
              ? conversation.project!['title'] ?? ''
              : conversation.participants
                  .where((p) => p.id != _selectedConversation?.participants.first.id)
                  .map((p) => p.name)
                  .join(', ');

          return Card(
            color: isSelected ? AppTheme.primaryUltraLowOpacity : null,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              onTap: () => _selectConversation(conversation),
              title: Text(conversation.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('dd.MM, HH:mm').format(conversation.updatedAt),
                      style: const TextStyle(fontSize: 11, color: AppTheme.onSurfaceSecondary)),
                  if (conversation.unreadCount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        conversation.unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildConversationView() {
    if (_isLoadingThread) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = _selectedConversation;
    final thread = _currentThread;

    if (summary == null || thread == null) {
      return const Center(
        child: Text('Selecteaza o conversa?ie pentru a vedea mesajele.'),
      );
    }

    return Column(
      children: [
        _buildConversationHeader(summary),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: thread.messages.length,
            itemBuilder: (context, index) {
              final message = thread.messages[index];
              final isOwn = message.sender == null || summary.participants.any(
                    (participant) => participant.id == message.sender?.id && participant.role == 'CLIENT',
                  );
              return Align(
                alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(
                    color: isOwn ? AppTheme.primaryColor : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.body != null && message.body!.isNotEmpty)
                        Text(
                          message.body!,
                          style: TextStyle(
                            color: isOwn ? Colors.white : AppTheme.onSurfaceColor,
                          ),
                        ),
                      if (message.attachments.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: message.attachments
                                .map(
                                  (attachment) => Chip(
                                    label: Text(attachment.objectPath.split('/').last),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      Text(
                        DateFormat('HH:mm').format(message.sentAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isOwn ? Colors.white70 : AppTheme.onSurfaceSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 1),
        _buildComposer(),
      ],
    );
  }

  Widget _buildConversationHeader(ConversationSummary summary) {
    final title = summary.title;
    final subtitle = summary.project?['title'] ?? summary.participants.map((p) => p.name).join(', ');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      subtitle: Text(subtitle ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.more_vert_rounded),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Op?iunile de conversa?ie vor fi disponibile curând.')),
          );
        },
      ),
    );
  }

  Widget _buildComposer() {
    final canSend = !_isSending && _selectedConversation != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: canSend,
              minLines: 1,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Scrie un mesaj...',
                filled: true,
                fillColor: AppTheme.surfaceColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.photo_outlined),
            color: AppTheme.primaryColor,
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Încarcarea de fi?iere va fi disponibila curând.')),
            ),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: canSend ? _handleSendMessage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: _isSending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Trimite'),
          ),
        ],
      ),
    );
  }
}

