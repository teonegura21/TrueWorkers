import 'package:flutter/material.dart';
import '../../data/models/project_models.dart';

/// Helper class for project formatting and status logic
class ProjectHelpers {
  /// Get status color based on project status
  static Color getStatusColor(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.inProgress => const Color(0xFF007BFF),
      ProjectStatus.completed => const Color(0xFF28a745),
      ProjectStatus.review => const Color(0xFF17a2b8),
      ProjectStatus.pending ||
      ProjectStatus.accepted => const Color(0xFFffc107),
      ProjectStatus.disputed ||
      ProjectStatus.cancelled => const Color(0xFFdc3545),
    };
  }

  /// Get status text in Romanian based on project status
  static String getStatusText(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.pending => 'Așteaptă acceptare',
      ProjectStatus.accepted => 'Acceptat',
      ProjectStatus.inProgress => 'În desfășurare',
      ProjectStatus.review => 'În revizuire',
      ProjectStatus.completed => 'Finalizat',
      ProjectStatus.disputed => 'Dispută deschisă',
      ProjectStatus.cancelled => 'Anulat',
    };
  }

  /// Get status icon based on project status
  static IconData getStatusIcon(ProjectStatus status) {
    return switch (status) {
      ProjectStatus.inProgress => Icons.construction_rounded,
      ProjectStatus.completed => Icons.check_circle_rounded,
      ProjectStatus.review => Icons.rate_review_rounded,
      ProjectStatus.pending ||
      ProjectStatus.accepted => Icons.hourglass_top_rounded,
      ProjectStatus.disputed => Icons.report_problem_rounded,
      ProjectStatus.cancelled => Icons.cancel_rounded,
    };
  }

  /// Format date in short Romanian format (DD/MM/YYYY)
  static String formatShortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Format message timestamp in relative time
  static String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  /// Format currency value with lei symbol
  static String formatCurrency(double amount) {
    return '${amount.toStringAsFixed(2)} lei';
  }

  /// Format currency value without decimal places for display
  static String formatCurrencyShort(double amount) {
    return '${amount.toStringAsFixed(0)} lei';
  }

  /// Check if milestone is overdue
  static bool isMilestoneOverdue(ProjectMilestone milestone) {
    return milestone.dueDate.isBefore(DateTime.now()) && !milestone.isCompleted;
  }

  /// Check if milestone is due soon (within 2 days)
  static bool isMilestoneDueSoon(ProjectMilestone milestone) {
    if (milestone.isCompleted) return false;
    final daysUntilDue = milestone.dueDate.difference(DateTime.now()).inDays;
    return daysUntilDue <= 2 && daysUntilDue >= 0;
  }

  /// Get milestone status color
  static Color getMilestoneStatusColor(ProjectMilestone milestone) {
    if (milestone.isCompleted) {
      return const Color(0xFF28a745); // success
    } else if (isMilestoneOverdue(milestone)) {
      return const Color(0xFFdc3545); // error
    } else if (isMilestoneDueSoon(milestone)) {
      return const Color(0xFFffc107); // warning
    } else {
      return const Color(0xFF007BFF); // primary
    }
  }

  /// Get milestone status text
  static String getMilestoneStatusText(ProjectMilestone milestone) {
    if (milestone.isCompleted) {
      return 'Finalizat';
    } else if (milestone.progress > 0) {
      return '${milestone.progress}%';
    } else {
      return 'În așteptare';
    }
  }

  /// Calculate pending payment amount
  static double getPendingPaymentAmount(ActiveProject project) {
    return project.totalValue - project.paidAmount;
  }

  /// Check if project has unread messages
  static bool hasUnreadMessages(ActiveProject project) {
    return project.messages.any((message) => !message.isRead);
  }

  /// Get unread messages count
  static int getUnreadMessagesCount(ActiveProject project) {
    return project.messages.where((message) => !message.isRead).length;
  }

  /// Check if project can be cancelled
  static bool canCancelProject(ProjectStatus status) {
    return status != ProjectStatus.completed &&
        status != ProjectStatus.cancelled;
  }

  /// Check if project can be marked as completed
  static bool canMarkAsCompleted(ActiveProject project) {
    // Can be marked as completed if at least 80% of milestones are complete
    return project.progress >= 0.8 && project.status != ProjectStatus.completed;
  }

  /// Validate message content
  static bool isValidMessage(String content) {
    return content.trim().isNotEmpty && content.trim().length <= 1000;
  }
}
