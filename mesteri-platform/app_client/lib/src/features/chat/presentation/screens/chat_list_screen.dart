import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';
import 'package:app_client/src/features/chat/presentation/screens/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Mock chat data
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'Ion Popescu',
      'avatar': 'assets/images/avatar1.png',
      'lastMessage': 'Am trimis oferta pentru reparații sanitare',
      'timestamp': '14:30',
      'unreadCount': 2,
      'isOnline': true,
      'jobTitle': 'Reparații instalații sanitare',
    },
    {
      'id': '2',
      'name': 'Vasile Ionescu',
      'avatar': 'assets/images/avatar2.png',
      'lastMessage': 'Da, pot veni mâine pentru inspecție',
      'timestamp': '12:15',
      'unreadCount': 0,
      'isOnline': false,
      'jobTitle': 'Montaj parchet living',
    },
    {
      'id': '3',
      'name': 'Gheorghe Marinescu',
      'avatar': 'assets/images/avatar3.png',
      'lastMessage': 'Aștept detalii despre materialele necesare',
      'timestamp': 'Ieri',
      'unreadCount': 1,
      'isOnline': true,
      'jobTitle': 'Zugrăveli apartament 3 camere',
    },
    {
      'id': '4',
      'name': 'Mihai Alexandru',
      'avatar': 'assets/images/avatar4.png',
      'lastMessage': 'Bugetul este perfect pentru proiectul meu',
      'timestamp': 'Ieri',
      'unreadCount': 0,
      'isOnline': false,
      'jobTitle': 'Termoizolație fațadă',
    },
    {
      'id': '5',
      'name': 'Andrei Popa',
      'avatar': 'assets/images/avatar5.png',
      'lastMessage': 'Vă mulțumesc pentru răspuns!',
      'timestamp': '12/12/2024',
      'unreadCount': 0,
      'isOnline': false,
      'jobTitle': 'Reparații acoperiș',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mesaje'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return _buildChatItem(chat);
        },
      ),
    );
  }

  Widget _buildChatItem(Map<String, dynamic> chat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              child: Icon(
                Icons.person,
                size: 25,
                color: AppTheme.primaryColor,
              ),
            ),
            if (chat['isOnline'] as bool)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.successColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              chat['timestamp'] as String,
              style: TextStyle(
                color: AppTheme.onSurfaceSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chat['jobTitle'] as String,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              chat['lastMessage'] as String,
              style: TextStyle(
                color: AppTheme.onSurfaceSecondary,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: chat['unreadCount'] > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  chat['unreadCount'].toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            : null,
        onTap: () {
          // Navigate to chat detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ChatScreen(),
            ),
          );
        },
      ),
    );
  }
}

