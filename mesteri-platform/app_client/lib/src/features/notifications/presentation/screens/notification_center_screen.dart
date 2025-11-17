import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:app_client/src/core/services/comprehensive_service.dart';

// Notification data structures
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final bool isPriority;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final String? senderName;
  final String? senderId;
  final String? projectId;
  final String? projectName;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.isPriority = false,
    this.actionUrl,
    this.metadata,
    this.senderName,
    this.senderId,
    this.projectId,
    this.projectName,
  });

  bool get isRecent => DateTime.now().difference(timestamp).inDays <= 1;
  bool get isToday => DateTime.now().day == timestamp.day;

  Color getTypeColor() {
    switch (type) {
      case NotificationType.message:
        return AppTheme.primaryColor;
      case NotificationType.project:
        return AppTheme.successColor;
      case NotificationType.payment:
        return AppTheme.primaryColor;
      case NotificationType.review:
        return AppTheme.warningColor;
      case NotificationType.system:
        return AppTheme.onSurfaceSecondary;
      case NotificationType.emergency:
        return AppTheme.errorColor;
    }
  }

  IconData getTypeIcon() {
    switch (type) {
      case NotificationType.message:
        return Icons.message_rounded;
      case NotificationType.project:
        return Icons.build_rounded;
      case NotificationType.payment:
        return Icons.payment_rounded;
      case NotificationType.review:
        return Icons.star_rounded;
      case NotificationType.system:
        return Icons.info_rounded;
      case NotificationType.emergency:
        return Icons.warning_rounded;
    }
  }

  factory NotificationItem.fromApi(Map<String, dynamic> json) {
    final typeStr = (json['type'] ?? 'system').toString().toLowerCase();
    final type = () {
      switch (typeStr) {
        case 'message':
          return NotificationType.message;
        case 'project':
          return NotificationType.project;
        case 'payment':
          return NotificationType.payment;
        case 'review':
          return NotificationType.review;
        case 'emergency':
          return NotificationType.emergency;
        case 'system':
        default:
          return NotificationType.system;
      }
    }();

    return NotificationItem(
      id: json['id'] ?? '',
      type: type,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      isPriority: json['isPriority'] ?? false,
      actionUrl: json['actionUrl'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      senderName: json['senderName'],
      senderId: json['senderId'],
      projectId: json['projectId'],
      projectName: json['projectName'],
    );
  }
}

enum NotificationType { message, project, payment, review, system, emergency }

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<NotificationItem> notifications = [];
  final Map<String, bool> selectedNotifications = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => !n.isRead).length;
    final recentNotifications = notifications.where((n) => n.isRecent).toList();
    final unreadNotifications = notifications.where((n) => !n.isRead).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notificări'),
            const SizedBox(width: 8),
            if (unreadCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.onSurfaceSecondary,
          tabs: [
            const Tab(icon: Icon(Icons.notifications_rounded), text: 'Toate'),
            Tab(
              icon: const Icon(Icons.circle),
              text: 'Noi (${unreadNotifications.length})',
            ),
            const Tab(icon: Icon(Icons.history_rounded), text: 'Recente'),
            const Tab(icon: Icon(Icons.settings_rounded), text: 'Setări'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllNotificationsTab(notifications),
          _buildUnreadTab(unreadNotifications),
          _buildRecentTab(recentNotifications),
          _buildSettingsTab(),
        ],
      ),

      floatingActionButton: selectedNotifications.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _bulkMarkAsRead(),
              icon: const Icon(Icons.done_all_rounded),
              label: const Text('Marchează toate'),
              backgroundColor: AppTheme.successColor,
            )
          : null,

      bottomNavigationBar:
          notifications.isNotEmpty && selectedNotifications.isNotEmpty
          ? Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: 12 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                border: Border(
                  top: BorderSide(
                    color: AppTheme.outlineColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${selectedNotifications.length} selectate',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        selectedNotifications.clear();
                      });
                    },
                    child: Text(
                      'Deselectează',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _bulkDelete(),
                    icon: const Icon(Icons.delete_rounded),
                    label: const Text('Șterge'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildAllNotificationsTab(List<NotificationItem> notifications) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Eroare: $_error'));
    }
    if (notifications.isEmpty) {
      return _buildEmptyState('Nu există notificări');
    }

    return RefreshIndicator(
      onRefresh: _fetchNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) =>
            _buildNotificationCard(notifications[index]),
      ),
    );
  }

  Widget _buildUnreadTab(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState('Nu aveți notificări necitite');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) =>
          _buildNotificationCard(notifications[index]),
    );
  }

  Widget _buildRecentTab(List<NotificationItem> notifications) {
    if (notifications.isEmpty) {
      return _buildEmptyState('Nu există notificări recente');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) =>
          _buildNotificationCard(notifications[index], allowSelection: false),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preferințe Notificări',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // Notification Types
          Text(
            'Tipuri de notificări',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          _buildNotificationTypeSetting(
            'Mesaje noi',
            'Primești afaceri când ai mesaje noi',
          ),
          _buildNotificationTypeSetting(
            'Actualizări proiecte',
            'Înștiintează despre modificări ale proiectelor',
          ),
          _buildNotificationTypeSetting(
            'Plăți procesate',
            'Confirmări de plăți și avansuri',
          ),
          _buildNotificationTypeSetting(
            'Recenzii primite',
            'Foartă bună pentru opinie publică',
          ),
          _buildNotificationTypeSetting(
            'Urgențe și suport',
            'Pe asigurări pentru problemări sau urgențe',
          ),

          const SizedBox(height: 32),

          // Notification Methods
          Text(
            'Metode de notificare',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          _buildNotificationMethodSetting(
            'Campanță în-app',
            'Campanță în aplicație pentru toate notificările',
          ),
          _buildNotificationMethodSetting(
            'Notificări push',
            'Șanse pentru mobil pentru notificări importante',
          ),
          _buildNotificationMethodSetting(
            'Notificări email',
            'Email pentru notificări importante',
          ),

          const SizedBox(height: 32),

          // Quiet Hours
          Text(
            'Ore liniștină',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Activare ore liniștite'),
            subtitle: const Text('Nu primi notificări între 22:00-08:00'),
            value: true,
            onChanged: (value) {},
            activeThumbColor: AppTheme.primaryColor,
          ),

          const SizedBox(height: 32),

          Center(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save_rounded),
              label: const Text(' salvează schimbările'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: AppTheme.onSurfaceSecondary,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'O să vă informăm când apar noutăți!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationItem notification, {
    bool allowSelection = true,
  }) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_rounded, color: AppTheme.errorColor),
      ),
      onDismissed: (direction) => _deleteNotification(notification.id),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification),
        onLongPress: allowSelection
            ? () => _toggleNotificationSelection(notification)
            : null,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selectedNotifications.containsKey(notification.id)
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : notification.isRead
                ? AppTheme.surfaceColor
                : AppTheme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selectedNotifications.containsKey(notification.id)
                  ? AppTheme.primaryColor
                  : notification.isPriority
                  ? AppTheme.primaryColor.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notification.getTypeColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  notification.getTypeIcon(),
                  color: notification.getTypeColor(),
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Notification Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title and timestamp
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: notification.isRead
                                      ? FontWeight.w500
                                      : FontWeight.w600,
                                  color: notification.isRead
                                      ? AppTheme.onSurfaceSecondary
                                      : AppTheme.onSurfaceColor,
                                ),
                          ),
                        ),

                        if (notification.isPriority) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Prioritar',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Message
                    Text(
                      notification.message,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Footer with timestamp and project info
                    Row(
                      children: [
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.onSurfaceSecondary,
                                fontSize: 11,
                              ),
                        ),

                        if (notification.projectName != null) ...[
                          Expanded(
                            child: Text(
                              ' • ${notification.projectName}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (!notification.isRead) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2196F3), // Blue
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  if (selectedNotifications.containsKey(notification.id)) ...[
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ] else if (notification.isRead) ...[
                    Icon(
                      Icons.done_rounded,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTypeSetting(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: true,
            onChanged: (value) {},
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationMethodSetting(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),

          Switch(
            value: true,
            onChanged: (value) {},
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  // Utility methods
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'ieri';
    } else if (difference.inDays < 7) {
      final weekdays = [
        'Luni',
        'Marți',
        'Miercuri',
        'Joi',
        'Vineri',
        'Sâmbătă',
        'Duminică',
      ];
      return weekdays[timestamp.weekday - 1];
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year.toString().substring(2)}';
    }
  }

  void _toggleNotificationSelection(NotificationItem notification) {
    setState(() {
      if (selectedNotifications.containsKey(notification.id)) {
        selectedNotifications.remove(notification.id);
      } else {
        selectedNotifications[notification.id] = true;
      }
    });
  }

  void _handleNotificationTap(NotificationItem notification) {
    if (selectedNotifications.isNotEmpty) {
      _toggleNotificationSelection(notification);
      return;
    }

    // Mark as read (API) and navigate to relevant screen
    if (!notification.isRead) {
      mesteriService.markNotificationRead(notification.id).catchError((_) {});
      setState(() {
        final index = notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          notifications[index] = NotificationItem(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            timestamp: notification.timestamp,
            isRead: true,
            isPriority: notification.isPriority,
            actionUrl: notification.actionUrl,
            metadata: notification.metadata,
            senderName: notification.senderName,
            senderId: notification.senderId,
            projectId: notification.projectId,
            projectName: notification.projectName,
          );
        }
      });
    }

    _navigateToNotificationAction(notification);
  }

  void _navigateToNotificationAction(NotificationItem notification) {
    switch (notification.type) {
      case NotificationType.message:
        // Navigate to messaging screen with specific conversation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deschidere conversație cu ${notification.senderName}',
            ),
          ),
        );
        break;
      case NotificationType.project:
        // Navigate to project details
        if (notification.projectId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deschidere proiect: ${notification.projectName}'),
            ),
          );
        }
        break;
      case NotificationType.payment:
        // Navigate to payments screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deschidere secțiunea plăți')),
        );
        break;
      case NotificationType.review:
        // Navigate to review management
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deschidere recenzii')));
        break;
      case NotificationType.system:
      case NotificationType.emergency:
        // Show details dialog
        _showNotificationDetails(notification);
        break;
    }
  }

  void _showNotificationDetails(NotificationItem notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: Text(notification.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Închide'),
          ),
        ],
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    setState(() {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications.removeAt(index);
      }
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notificare ștearsă')));
  }

  void _bulkDelete() {
    final notificationIds = selectedNotifications.keys.toList();
    setState(() {
      notifications.removeWhere((n) => notificationIds.contains(n.id));
      selectedNotifications.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${notificationIds.length} notificări șterse')),
    );
  }

  void _bulkMarkAsRead() {
    final notificationIds = selectedNotifications.keys.toList();
    () async {
      try {
        for (final id in notificationIds) {
          await mesteriService.markNotificationRead(id);
        }
        setState(() {
          for (int i = 0; i < notifications.length; i++) {
            if (notificationIds.contains(notifications[i].id)) {
              notifications[i] = NotificationItem(
                id: notifications[i].id,
                type: notifications[i].type,
                title: notifications[i].title,
                message: notifications[i].message,
                timestamp: notifications[i].timestamp,
                isRead: true,
                isPriority: notifications[i].isPriority,
                actionUrl: notifications[i].actionUrl,
                metadata: notifications[i].metadata,
                senderName: notifications[i].senderName,
                senderId: notifications[i].senderId,
                projectId: notifications[i].projectId,
                projectName: notifications[i].projectName,
              );
            }
          }
          selectedNotifications.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${notificationIds.length} notificări marcate ca citite',
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare la marcarea notificărilor: $e')),
        );
      }
    }();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final list = await mesteriService.getNotifications(
        unreadOnly: false,
        limit: 100,
      );
      final items = list.map((e) => NotificationItem.fromApi(e)).toList();
      setState(() {
        notifications = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }
}
