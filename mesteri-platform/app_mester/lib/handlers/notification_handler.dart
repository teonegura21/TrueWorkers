import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationHandler {
  static void handleNotificationTap(
    BuildContext context,
    RemoteMessage message,
  ) {
    final type = message.data['type'] as String?;
    final id = message.data['id'] as String?;
    final projectId = message.data['projectId'] as String?;
    
    print('Handling notification: $type with id: $id, project: $projectId');
    
    switch (type) {
      case 'NEW_JOB':
        // Navigate to new jobs screen
        context.go('/jobs');
        break;
      case 'OFFER_ACCEPTED':
        // Navigate to MyOffersScreen - your offer was accepted!
        if (id != null) {
          context.go('/offers/$id');
        }
        break;
      case 'CONTRACT_SIGNED':
        // Navigate to ContractReviewScreen with contractId
        if (id != null) {
          context.go('/contracts/$id');
        }
        break;
      case 'PAYMENT_RECEIVED':
        // Navigate to WalletScreen
        context.go('/wallet');
        break;
      case 'NEW_MESSAGE':
        // Navigate to ChatConversationScreen with conversationId or projectId
        if (projectId != null) {
          context.go('/chat/$projectId');
        } else if (id != null) {
          context.go('/chat/$id');
        }
        break;
      case 'NEW_REVIEW':
        // Navigate to ReviewScreen
        if (id != null) {
          context.go('/reviews/$id');
        }
        break;
      case 'PROJECT_COMPLETED':
        // Navigate to project details
        if (projectId != null) {
          context.go('/projects/$projectId');
        }
        break;
      default:
        print('Unknown notification type: $type');
        // Navigate to default screen
        context.go('/dashboard');
    }
  }
}