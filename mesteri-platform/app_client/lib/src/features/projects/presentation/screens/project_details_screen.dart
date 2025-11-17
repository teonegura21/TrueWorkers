import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/widgets/trust_badge.dart';
import '../../data/models/project_models.dart';
import '../utils/project_helpers.dart';
import 'package:app_client/src/core/services/projects_api_service.dart' as api_service hide ProjectStatus;
import 'package:app_client/src/core/models/api_models.dart' as api;
import 'package:app_client/src/core/services/comprehensive_service.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;

  const ProjectDetailsScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<ChatMessage> _messages;
  final TextEditingController _messageController = TextEditingController();
  final api_service.ProjectsApiService _projectsService = api_service.ProjectsApiService();
  ActiveProject? _project;
  bool _loading = true;
  String? _error;
  List<api.Payment> _payments = [];
  bool _paymentsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _messages = [];
    _fetchProject();
    _fetchPayments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = _project;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalii Proiect'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: _showProjectOptions,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.onSurfaceSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.info_rounded), text: 'Detalii'),
            Tab(icon: Icon(Icons.timeline_rounded), text: 'Progres'),
            Tab(icon: Icon(Icons.message_rounded), text: 'Mesaje'),
            Tab(icon: Icon(Icons.payment_rounded), text: 'Plată'),
          ],
        ),
      ),
      body: project == null
          ? Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : Text(_error ?? 'Nu s-a putut încărca proiectul'),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProjectOverview(project),
                _buildProgressTab(project),
                _buildMessagesTab(project),
                _buildPaymentsTab(project),
              ],
            ),
      floatingActionButton:
          project != null && project.status != ProjectStatus.completed
          ? FloatingActionButton.extended(
              onPressed: _quickActions,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Acțiuni Rapide'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
    );
  }

  Widget _buildProjectOverview(ActiveProject project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(project),
          const SizedBox(height: 24),
          _buildCraftsmanInfo(project),
          const SizedBox(height: 24),
          _buildProjectSummary(project),
          const SizedBox(height: 24),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(ActiveProject project) {
    final statusColor = ProjectHelpers.getStatusColor(project.status);
    final statusText = ProjectHelpers.getStatusText(project.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              ProjectHelpers.getStatusIcon(project.status),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stare Proiect',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: statusColor, size: 24),
        ],
      ),
    );
  }

  Widget _buildCraftsmanInfo(ActiveProject project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
            child: project.craftsmanPhoto.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      project.craftsmanPhoto,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    project.craftsmanName.isNotEmpty
                        ? project.craftsmanName[0]
                        : '-',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.craftsmanName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: const Color(0xFFfbbc05),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${project.craftsmanRating}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    TrustBadge(type: TrustBadgeType.verified),
                    SizedBox(width: 8),
                    TrustBadge(type: TrustBadgeType.secure),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                onPressed: () => _callCraftsman(project.craftsmanName),
                icon: const Icon(Icons.phone_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.successColor.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.successColor,
                ),
              ),
              IconButton(
                onPressed: () => _tabController.animateTo(2),
                icon: const Icon(Icons.message_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSummary(ActiveProject project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.projectTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 16),
              const SizedBox(width: 8),
              Text(
                project.location,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16),
              const SizedBox(width: 8),
              Text(
                'Început: ${ProjectHelpers.formatShortDate(project.startDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
              ),
              if (project.deadline != null) ...[
                const SizedBox(width: 16),
                Text(
                  'Termen: ${ProjectHelpers.formatShortDate(project.deadline!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acțiuni Rapide',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.edit_rounded,
                label: 'Modificare Cerere',
                onPressed: _modifyProject,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.report_problem_rounded,
                label: 'Raportare Problem',
                onPressed: _reportIssue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.cancel_rounded,
                label: 'Anulare Proiect',
                onPressed: _cancelProject,
                isDestructive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                icon: Icons.thumb_up_alt_rounded,
                label: 'Marchează Finalizat',
                onPressed: _markCompleted,
                isPrimary: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProgressTab(ActiveProject project) {
    return RefreshIndicator(
      onRefresh: _refreshProgress,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallProgress(project),
            const SizedBox(height: 24),
            Text(
              'Etape Proiect (${project.completedMilestones}/${project.milestones.length})',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: project.milestones.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) =>
                  _buildMilestoneCard(project.milestones[index], index + 1),
            ),
            const SizedBox(height: 24),
            _buildProgressTimeline(project),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgress(ActiveProject project) {
    final progress = project.progress * 100;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withValues(alpha: 0.8),
            AppTheme.primaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progres General',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${progress.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${project.completedMilestones} din ${project.milestones.length} etape finalizate',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(ProjectMilestone milestone, int number) {
    final statusColor = ProjectHelpers.getMilestoneStatusColor(milestone);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: milestone.isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: milestone.isCompleted
                  ? statusColor.withValues(alpha: 0.1)
                  : statusColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: milestone.isCompleted
                  ? Icon(Icons.check_rounded, color: statusColor, size: 16)
                  : Text(
                      '$number',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: AppTheme.onSurfaceSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Termen: ${ProjectHelpers.formatShortDate(milestone.dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ProjectHelpers.isMilestoneOverdue(milestone)
                            ? AppTheme.errorColor
                            : ProjectHelpers.isMilestoneDueSoon(milestone)
                            ? AppTheme.warningColor
                            : AppTheme.onSurfaceSecondary,
                        fontWeight:
                            ProjectHelpers.isMilestoneOverdue(milestone) ||
                                ProjectHelpers.isMilestoneDueSoon(milestone)
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        ProjectHelpers.getMilestoneStatusText(milestone),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      ProjectHelpers.formatCurrencyShort(milestone.value),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
                if (!milestone.isCompleted && milestone.progress > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      height: 4,
                      child: LinearProgressIndicator(
                        value: milestone.progress / 100,
                        backgroundColor: AppTheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTimeline(ActiveProject project) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cronologie Proiect',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TimelineStep(
                title: 'Început',
                subtitle: ProjectHelpers.formatShortDate(project.startDate),
                isCompleted: true,
                isFirst: true,
              ),
              const Expanded(
                child: Divider(color: AppTheme.primaryColor, thickness: 2),
              ),
              _TimelineStep(
                title: 'În curs',
                subtitle: '${(project.progress * 100).toStringAsFixed(0)}%',
                isCompleted: true,
                isActive: true,
              ),
              const Expanded(
                child: Divider(color: AppTheme.outlineColor, thickness: 2),
              ),
              _TimelineStep(
                title: 'Finalizare',
                subtitle: project.deadline != null
                    ? ProjectHelpers.formatShortDate(project.deadline!)
                    : 'TBD',
                isCompleted: project.status == ProjectStatus.completed,
                isLast: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesTab(ActiveProject project) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.outlineColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.message_rounded, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                '${_messages.length} mesaj(e)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _callCraftsman(project.craftsmanName),
                icon: const Icon(Icons.phone_rounded),
                tooltip: 'Sună',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) =>
                _buildMessageBubble(_messages.reversed.toList()[index]),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 8 + MediaQuery.of(context).padding.bottom,
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
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Scrie mesaj...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isFromClient = message.type == MessageType.clientToCraftsman;
    final color = isFromClient
        ? AppTheme.primaryColor
        : AppTheme.surfaceVariant;
    final textColor = isFromClient ? Colors.white : AppTheme.onSurfaceColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      alignment: isFromClient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isFromClient
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isFromClient
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isFromClient
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              ProjectHelpers.formatMessageTime(message.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsTab(ActiveProject project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPaymentSummary(project),
          const SizedBox(height: 24),
          _buildPaymentHistory(),
          const SizedBox(height: 24),
          _buildUpcomingPayments(project),
          const SizedBox(height: 24),
          _buildTrustGuarantee(),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(ActiveProject project) {
    final total = project.totalValue;
    final paid = _payments
        .where(
          (p) =>
              (p.status.toLowerCase() == 'completed') ||
              (p.status.toLowerCase() == 'paid'),
        )
        .fold<double>(0.0, (a, b) => a + b.amount);
    final pending = (total - paid).clamp(0.0, total);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.successColor.withValues(alpha: 0.8),
            AppTheme.successColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rezumat Plăți',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Proiect',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Text(
                ProjectHelpers.formatCurrency(total),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Plătit până acum',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Text(
                ProjectHelpers.formatCurrency(paid),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sold de plătit',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              Text(
                ProjectHelpers.formatCurrency(pending),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: total > 0 ? (paid / total).clamp(0.0, 1.0) : 0.0,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            '${(total > 0 ? (paid / total * 100) : 0).toStringAsFixed(0)}% plătit',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    if (_paymentsLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Istoric Plăți',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (_payments.isEmpty)
          _buildEmptyState('Nu există plăți înregistrate')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _payments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final pay = _payments[index];
              final isCompleted =
                  pay.status.toLowerCase() == 'completed' ||
                  pay.status.toLowerCase() == 'paid';
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.payment_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pay.description ?? 'Plată proiect',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ProjectHelpers.formatShortDate(pay.processedAt),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.onSurfaceSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+${pay.amount.toStringAsFixed(0)} lei',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: isCompleted
                            ? AppTheme.successColor
                            : AppTheme.warningColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _tabController.animateTo(3),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Vezi toate tranzacțiile'),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingPayments(ActiveProject project) {
    final pendingMilestone = project.milestones.firstWhere(
      (m) => !m.isCompleted,
      orElse: () => project.milestones.last,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Următoarea Plată',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.outlineColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pendingMilestone.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Termen: ${ProjectHelpers.formatShortDate(pendingMilestone.dueDate)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Valoare etapă', style: TextStyle(fontSize: 16)),
                  Text(
                    ProjectHelpers.formatCurrency(pendingMilestone.value),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _processPaymentForMilestone(pendingMilestone),
                  icon: const Icon(Icons.payment_rounded),
                  label: const Text('Plătește Acum'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrustGuarantee() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_rounded,
            color: AppTheme.primaryColor,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Garanția Mesteri',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Plățile sunt securizate și eliberate doar la finalizarea etapei.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 48,
              color: AppTheme.onSurfaceSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Action handlers
  void _showProjectOptions() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Opțiuni proiect în curând.')));
  }

  void _quickActions() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Acțiuni rapide în curând.')));
  }

  void _modifyProject() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcționalitate modificare în curând.')),
    );
  }

  void _reportIssue() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcționalitate raportare în curând.')),
    );
  }

  void _cancelProject() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcționalitate anulare în curând.')),
    );
  }

  void _markCompleted() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcționalitate finalizare în curând.')),
    );
  }

  Future<void> _refreshProgress() async {
    await Future.delayed(const Duration(seconds: 1));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Progres actualizat.')));
  }

  void _callCraftsman(String name) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Se sună $name...')));
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (ProjectHelpers.isValidMessage(content)) {
      final newMessage = ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        type: MessageType.clientToCraftsman,
        timestamp: DateTime.now(),
      );
      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
      });
    }
  }

  Future<void> _fetchProject() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final proj = await _projectsService.getProjectById(widget.projectId);
      final ms = await _projectsService.getProjectMilestones(widget.projectId);
      setState(() {
        _project = _mapToActiveProject(proj, ms);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _fetchPayments() async {
    setState(() => _paymentsLoading = true);
    try {
      final payments = await _projectsService.getProjectPayments(
        widget.projectId,
      );
      setState(() {
        _payments = payments;
        _paymentsLoading = false;
      });
    } catch (e) {
      setState(() => _paymentsLoading = false);
      // Non-blocking error; summary will still show defaults
    }
  }

  Future<void> _processPaymentForMilestone(ProjectMilestone milestone) async {
    try {
      final amount = milestone.value;
      await mesteriService.processPayment(
        projectId: widget.projectId,
        amount: amount,
        milestoneId: milestone.id,
        description: 'Plată pentru ${milestone.title}',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plata a fost procesată pentru: ${milestone.title}'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      await _fetchPayments();
      await _fetchProject();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la procesarea plății: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  ActiveProject _mapToActiveProject(api.Project p, List<api.Milestone> ms) {
    final status = () {
      final s = p.status.toLowerCase();
      if (s.contains('completed')) return ProjectStatus.completed;
      if (s.contains('progress')) return ProjectStatus.inProgress;
      if (s.contains('cancel')) return ProjectStatus.cancelled;
      return ProjectStatus.pending;
    }();

    final milestones = ms.map((m) {
      final completed = m.status.toLowerCase() == 'completed';
      final inProg =
          m.status.toLowerCase() == 'inprogress' ||
          m.status.toLowerCase() == 'in_progress';
      final progress = completed ? 100 : (inProg ? 50 : 0);
      return ProjectMilestone(
        id: m.id,
        title: m.title,
        description: m.description,
        progress: progress,
        dueDate: m.dueDate,
        isCompleted: completed,
        value: m.amount,
        status: m.status,
      );
    }).toList();

    final completedCount = milestones.where((m) => m.isCompleted).length;

    return ActiveProject(
      id: p.id,
      jobId: '',
      craftsmanId: p.craftsmanId ?? '',
      craftsmanName: p.craftsmanName ?? 'Necunoscut',
      craftsmanPhoto: '',
      craftsmanRating: 0.0,
      status: status,
      projectTitle: p.title,
      description: p.description,
      milestones: milestones,
      completedMilestones: completedCount,
      messages: const [],
      totalValue: p.budget,
      paidAmount: 0,
      startDate: p.createdAt,
      completionDate: p.updatedAt,
      deadline: milestones.isNotEmpty
          ? milestones
                .map((m) => m.dueDate)
                .reduce((a, b) => a.isAfter(b) ? a : b)
          : null,
      location: p.location,
      cancellationReason: null,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive
        ? AppTheme.errorColor
        : (isPrimary ? AppTheme.primaryColor : AppTheme.onSurfaceSecondary);
    final backgroundColor = color.withValues(alpha: 0.1);

    return SizedBox(
      height: 80,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
  final bool isFirst;
  final bool isLast;

  const _TimelineStep({
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.isActive = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCompleted ? AppTheme.primaryColor : AppTheme.outlineColor;
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.white : color,
            border: Border.all(color: color, width: 2),
          ),
          child: isActive
              ? Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
        ),
      ],
    );
  }
}
