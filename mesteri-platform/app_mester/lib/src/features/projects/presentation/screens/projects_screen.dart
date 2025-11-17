import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';

enum ProjectsView {
  all,
  current,
  completed,
  upcoming,
}

enum ProjectStatus {
  preparation,
  inProgress,
  waitingApproval,
  onHold,
  completed,
  cancelled,
}

class ActiveProject {
  final String id;
  final String clientName;
  final String projectTitle;
  final String description;
  final ProjectStatus status;
  final DateTime startDate;
  final DateTime? completionDate;
  final DateTime? deadline;
  final double totalValue;
  final double paidAmount;
  final List<ProjectMilestone> milestones;
  final int completedTasks;
  final int totalTasks;
  final bool hasIssues;
  final String? lastMessage;

  const ActiveProject({
    required this.id,
    required this.clientName,
    required this.projectTitle,
    required this.description,
    required this.status,
    required this.startDate,
    this.completionDate,
    this.deadline,
    required this.totalValue,
    required this.paidAmount,
    required this.milestones,
    required this.completedTasks,
    required this.totalTasks,
    this.hasIssues = false,
    this.lastMessage,
  });

  double get progress => totalTasks > 0 ? completedTasks / totalTasks : 0.0;
  double get paymentProgress => totalValue > 0 ? paidAmount / totalValue : 0.0;

  int get daysUntilDeadline {
    if (deadline == null) return 0;
    return deadline!.difference(DateTime.now()).inDays;
  }

  bool get isOverdue => daysUntilDeadline < 0 && status != ProjectStatus.completed;
  bool get isNearDeadline => daysUntilDeadline <= 3 && daysUntilDeadline > 0;
}

class ProjectMilestone {
  final String id;
  final String title;
  final String description;
  final double value;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedDate;

  const ProjectMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.value,
    required this.dueDate,
    this.isCompleted = false,
    this.completedDate,
  });

  Color getStatusColor() {
    if (isCompleted) return AppTheme.successColor;
    final now = DateTime.now();
    if (dueDate.isBefore(now)) return AppTheme.errorColor;
    if (dueDate.difference(now).inDays <= 2) return AppTheme.warningColor;
    return AppTheme.primaryColor;
  }
}

// Mock data for development
final List<ActiveProject> mockProjects = [
  ActiveProject(
    id: '1',
    clientName: 'Maria Popescu',
    projectTitle: 'Reparație robinet și instalații',
    description: 'Se repară robineții defecte, se schimbă câteva conducte. Inclusiv testarea sistemului.',
    status: ProjectStatus.inProgress,
    startDate: DateTime.now().subtract(const Duration(days: 5)),
    deadline: DateTime.now().add(const Duration(days: 2)),
    totalValue: 450.0,
    paidAmount: 150.0,
    completedTasks: 2,
    totalTasks: 6,
    hasIssues: true,
    lastMessage: 'Materialele ajung mâine dimineața',
    milestones: [
      ProjectMilestone(
        id: '1',
        title: 'Demontare robinete vechi',
        description: 'Se demontează sistemele existente',
        value: 50.0,
        dueDate: DateTime.now().subtract(const Duration(days: 3)),
        isCompleted: true,
        completedDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      ProjectMilestone(
        id: '2',
        title: 'Montare robinete noi',
        description: 'Instalare și verificare',
        value: 100.0,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
      ),
    ],
  ),

  ActiveProject(
    id: '2',
    clientName: 'Ion Dumitrescu',
    projectTitle: 'Montaj ușă metalică 80x210cm',
    description: 'Ușă de intrare complet echipată cu panou securizat și accesorii',
    status: ProjectStatus.preparation,
    startDate: DateTime.now().subtract(const Duration(days: 1)),
    deadline: DateTime.now().add(const Duration(days: 10)),
    totalValue: 320.0,
    paidAmount: 100.0,
    completedTasks: 1,
    totalTasks: 4,
    lastMessage: 'Clientul dorște ușă mai întunecată',
    milestones: [
      ProjectMilestone(
        id: '3',
        title: 'Pregătire loc de montaj',
        description: 'Demolarea ramei vechi',
        value: 80.0,
        dueDate: DateTime.now().add(const Duration(days: 2)),
        isCompleted: false,
      ),
    ],
  ),

  ActiveProject(
    id: '3',
    clientName: 'Sofia Andrei',
    projectTitle: 'Montaj blat bucătărie',
    description: 'Montaj complet cu electrocasnice integrate și sistem de ventilație',
    status: ProjectStatus.completed,
    startDate: DateTime.now().subtract(const Duration(days: 14)),
    completionDate: DateTime.now().subtract(const Duration(days: 2)),
    deadline: DateTime.now().subtract(const Duration(days: 5)),
    totalValue: 1800.0,
    paidAmount: 1800.0,
    completedTasks: 8,
    totalTasks: 8,
    milestones: [],
  ),
];

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  ProjectsView _selectedView = ProjectsView.all;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      switch (_tabController.index) {
        case 0:
          _selectedView = ProjectsView.all;
          break;
        case 1:
          _selectedView = ProjectsView.current;
          break;
        case 2:
          _selectedView = ProjectsView.upcoming;
          break;
        case 3:
          _selectedView = ProjectsView.completed;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = getProjectsSummary();
    final filteredProjects = getFilteredProjects(mockProjects);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proiectele Mele'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.onSurfaceSecondary,
          tabs: [
            Tab(text: 'Toate (${summary.total})'),
            Tab(text: 'Active (${summary.active})'),
            Tab(text: 'Așteptare (${summary.upcoming})'),
            Tab(text: 'Completate (${summary.completed})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick stats summary
          _buildStatsSummary(),

          // Projects list
          Expanded(
            child: filteredProjects.isEmpty
                ? _buildEmptyState()
                : _buildProjectsList(filteredProjects),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildStatsSummary() {
    final summary = getProjectsSummary();
    final averageCompletion = mockProjects.isNotEmpty
        ? mockProjects.map((p) => p.progress).reduce((a, b) => a + b) /
          mockProjects.length
        : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.surfaceVariant,
      child: Row(
        children: [
          // Completion rate
          Expanded(
            child: _buildStatItem(
              'Progres\nMediu',
              '${(averageCompletion * 100).toStringAsFixed(0)}%',
              AppTheme.successColor,
            ),
          ),

          Container(width: 1, height: 40, color: AppTheme.outlineColor),

          // Active projects
          Expanded(
            child: _buildStatItem(
              'Proiecte\nActive',
              summary.active.toString(),
              AppTheme.primaryColor,
            ),
          ),

          Container(width: 1, height: 40, color: AppTheme.outlineColor),

          // Total earnings
          Expanded(
            child: _buildStatItem(
              'Total\nVenit',
              '${mockProjects.where((p) => p.status == ProjectStatus.completed).fold(0.0, (sum, p) => sum + p.totalValue).toStringAsFixed(0)}${AppConfig.currencySymbol}',
              AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.onSurfaceSecondary,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProjectsList(List<ActiveProject> projects) {
    return RefreshIndicator(
      onRefresh: _refreshProjects,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          return _buildProjectCard(project);
        },
      ),
    );
  }

  Widget _buildProjectCard(ActiveProject project) {
    return GestureDetector(
      onTap: () => _showProjectDetails(project),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: project.isOverdue ? AppTheme.errorColor.withValues(alpha: 0.3) :
                   AppTheme.outlineColor.withValues(alpha: 0.3),
            width: project.isOverdue ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and status
              Row(
                children: [
                  // Status badges
                  project.isOverdue
                      ? _buildBadge('ÎNTÂRZIERE', AppTheme.errorColor)
                      : project.isNearDeadline
                          ? _buildBadge('URGENT', AppTheme.warningColor)
                          : project.status == ProjectStatus.completed
                              ? _buildBadge('COMPLETAT', AppTheme.successColor)
                              : _buildBadge(_getStatusText(project.status), AppTheme.primaryColor),

                  const Spacer(),

                  Text(
                    '${project.totalValue.toStringAsFixed(0)} ${AppConfig.currencySymbol}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Project title
              Text(
                project.projectTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Client info
              Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 14,
                    color: AppTheme.onSurfaceSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      project.clientName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ),

                  // Progress indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: project.progress >= 0.8
                          ? AppTheme.successColor.withValues(alpha: 0.1)
                          : project.progress >= 0.5
                              ? AppTheme.warningColor.withValues(alpha: 0.1)
                              : AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(project.progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: project.progress >= 0.8
                            ? AppTheme.successColor
                            : project.progress >= 0.5
                                ? AppTheme.warningColor
                                : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress bar
              LinearProgressIndicator(
                value: project.progress,
                backgroundColor: AppTheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  project.progress >= 0.8
                      ? AppTheme.successColor
                      : project.progress >= 0.5
                          ? AppTheme.warningColor
                          : AppTheme.primaryColor,
                ),
              ),

              const SizedBox(height: 4),

              // Tasks info
              Text(
                '${project.completedTasks} din ${project.totalTasks} sarcini • ${project.milestones.length} milestone-uri',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
              ),

              const SizedBox(height: 8),

              // Deadline and payment info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: project.deadline != null
                        ? Row(
                            children: [
                              Icon(
                                project.isOverdue
                                    ? Icons.warning_rounded
                                    : project.isNearDeadline
                                        ? Icons.schedule_rounded
                                        : Icons.calendar_today_rounded,
                                size: 14,
                                color: project.isOverdue
                                    ? AppTheme.errorColor
                                    : project.isNearDeadline
                                        ? AppTheme.warningColor
                                        : AppTheme.onSurfaceSecondary,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  project.isOverdue
                                      ? 'Termen depășit'
                                      : '${project.daysUntilDeadline} zile răm.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: project.isOverdue
                                        ? AppTheme.errorColor
                                        : project.isNearDeadline
                                            ? AppTheme.warningColor
                                            : AppTheme.onSurfaceSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ),

                  // Payment status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: project.paymentProgress >= 1.0
                          ? AppTheme.successColor.withValues(alpha: 0.1)
                          : project.paymentProgress > 0
                              ? AppTheme.warningColor.withValues(alpha: 0.1)
                              : AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      project.paymentProgress >= 1.0
                          ? 'Plătit'
                          : '${(project.paymentProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: project.paymentProgress >= 1.0
                            ? AppTheme.successColor
                            : project.paymentProgress > 0
                                ? AppTheme.warningColor
                                : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              // Last message (if any)
              if (project.lastMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.message_rounded,
                        size: 14,
                        color: AppTheme.onSurfaceSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          project.lastMessage!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String title, description;

    switch (_selectedView) {
      case ProjectsView.all:
        title = 'Niciun proiect';
        description = 'Când oferte sunt acceptate, vei vedea proiectele aici.';
        break;
      case ProjectsView.current:
        title = 'Niciun proiect activ';
        description = 'Proiectele active apar aici când ofertele sunt acceptate.';
        break;
      case ProjectsView.upcoming:
        title = 'Niciun proiect în așteptare';
        description = 'Proiectele programate pentru viitor apar aici.';
        break;
      case ProjectsView.completed:
        title = 'Niciun proiect completat';
        description = 'Proiectele finalizate vor apărea aici când sunt completate.';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_circle_rounded,
              size: 64,
              color: AppTheme.onSurfaceSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _navigateToOffers(),
              icon: const Icon(Icons.assignment_rounded),
              label: const Text('Vezi Ofertele'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _addMilestone,
      icon: const Icon(Icons.add_circle_rounded),
      label: const Text('Adaugă Milestone'),
      backgroundColor: AppTheme.primaryColor,
      foregroundColor: Colors.white,
    );
  }

  // Helper methods
  ProjectsSummary getProjectsSummary() {
    int active = 0, completed = 0, upcoming = 0;
    for (final project in mockProjects) {
      switch (project.status) {
        case ProjectStatus.inProgress:
        case ProjectStatus.waitingApproval:
        case ProjectStatus.onHold:
        case ProjectStatus.preparation:
          active++;
          break;
        case ProjectStatus.completed:
          completed++;
          break;
        default:
          upcoming++;
          break;
      }
    }
    return ProjectsSummary(
      active: active,
      completed: completed,
      upcoming: upcoming,
      total: mockProjects.length,
    );
  }

  List<ActiveProject> getFilteredProjects(List<ActiveProject> projects) {
    switch (_selectedView) {
      case ProjectsView.all:
        return projects;
      case ProjectsView.current:
        return projects.where((p) =>
          [ProjectStatus.preparation, ProjectStatus.inProgress, ProjectStatus.waitingApproval, ProjectStatus.onHold]
            .contains(p.status)
        ).toList();
      case ProjectsView.upcoming:
        return projects.where((p) => false).toList(); // TODO: Implement upcoming filter
      case ProjectsView.completed:
        return projects.where((p) => p.status == ProjectStatus.completed).toList();
      default:
        return projects;
    }
  }

  String _getStatusText(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.preparation:
        return 'PREGĂTIRE';
      case ProjectStatus.inProgress:
        return 'ÎN EXECUȚIE';
      case ProjectStatus.waitingApproval:
        return 'ASP APTROBARE';
      case ProjectStatus.onHold:
        return 'SUS PENDED';
      case ProjectStatus.completed:
        return 'COMPLETAT';
      case ProjectStatus.cancelled:
        return 'ANULAT';
    }
  }

  // Action handlers
  void _showProjectDetails(ActiveProject project) {
    // TODO: Navigate to project details screen
  }

  void _navigateToOffers() {
    // TODO: Navigate to offers screen
  }

  void _addMilestone() {
    // TODO: Show dialog to add new milestone
  }

  Future<void> _refreshProjects() async {
    // TODO: Implement refresh logic
    await Future.delayed(const Duration(seconds: 2));
    setState(() {});
  }
}

class ProjectsSummary {
  final int active;
  final int upcoming;
  final int completed;
  final int total;

  const ProjectsSummary({
    required this.active,
    required this.upcoming,
    required this.completed,
    required this.total,
  });
}
