import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Header with Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project['job']?['title'] ?? 'Project Title',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(project['status'] ?? 'ACTIVE'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(project['status'] ?? 'ACTIVE'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Craftsman info
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: AppTheme.onSurfaceSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project['craftsman']?['name'] ?? 'Craftsman Name',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '${project['agreedPrice'] ?? 0} RON',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Progress Indicator
              _buildProgressSection(),

              const SizedBox(height: 8),

              // Deadline/Remaining time
              if (project['deadline'] != null)
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: AppTheme.onSurfaceTertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Due: ${_formatDeadline(project['deadline'])}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceTertiary,
                      ),
                    ),
                  ],
                ),

              // Escrow protection
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.security, size: 14, color: AppTheme.successColor),
                    const SizedBox(width: 6),
                    Text(
                      'Plată garantată escrowed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final progress = (project['progress'] ?? 0.0).toDouble();
    final progressText = '${(progress * 100).round()}%';

    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.timeline, size: 16, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(
              'Progress',
              style: TextStyle(
                color: AppTheme.onSurfaceSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              progressText,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return AppTheme.primaryColor;
      case 'COMPLETED':
        return AppTheme.successColor;
      case 'CANCELLED':
        return AppTheme.errorColor;
      case 'DISPUTED':
        return AppTheme.warningColor;
      default:
        return AppTheme.onSurfaceSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return 'În lucru';
      case 'COMPLETED':
        return 'Finalizat';
      case 'CANCELLED':
        return 'Anulat';
      case 'DISPUTED':
        return 'Contestație';
      default:
        return status;
    }
  }

  String _formatDeadline(dynamic deadline) {
    if (deadline == null) return '';

    try {
      final date = DateTime.parse(deadline.toString());
      final now = DateTime.now();
      final diff = date.difference(now).inDays;

      if (diff < 0) {
        return '${diff.abs()} zile depășite';
      } else if (diff == 0) {
        return 'astăzi';
      } else if (diff == 1) {
        return 'mâine';
      } else {
        return 'în $diff zile';
      }
    } catch (e) {
      return deadline.toString();
    }
  }
}

