
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationHandler {
  static void handleNotificationTap(
    BuildContext context,
    RemoteMessage? message,
  ) {
    if (message == null) {
      print('Received null message');
      return;
    }
    
    final type = message.data['type'] as String?;
    final id = message.data['id'] as String?;
    final projectId = message.data['projectId'] as String?;
    
    print('Handling notification: $type with id: $id, project: $projectId');
    
    switch (type) {
      case 'NEW_JOB':
        // Navigate to JobDetailsScreen with jobId
        if (id != null) {
          context.push('/job-details/$id');
        }
        break;
      case 'OFFER_ACCEPTED':
        // Navigate to MyOffersScreen
        context.push('/my-offers');
        break;
      case 'CONTRACT_SIGNED':
        // Navigate to ContractReviewScreen with contractId
        if (id != null) {
          context.push('/contracts/$id');
        }
        break;
      case 'PAYMENT_RECEIVED':
        // Navigate to WalletScreen
        context.push('/wallet');
        break;
      case 'NEW_MESSAGE':
        // Navigate to ChatConversationScreen with conversationId or projectId
        if (projectId != null) {
          context.push('/chat/$projectId');
        } else if (id != null) {
          context.push('/chat/$id');
        }
        break;
      case 'NEW_REVIEW':
        // Navigate to ReviewScreen
        if (id != null) {
          context.push('/reviews/$id');
        }
        break;
      case 'PROJECT_COMPLETED':
        // Navigate to project details
        if (projectId != null) {
          context.push('/projects/$projectId');
        }
        break;
      default:
        print('Unknown notification type: $type');
        // Navigate to default screen
        context.push('/home');
    }
  }
}