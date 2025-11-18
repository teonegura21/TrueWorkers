import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/project_card.dart';
import 'package:app_client/src/core/services/projects_api_service.dart';
import 'package:app_client/src/core/models/api_models.dart' as api;
import 'package:app_client/src/core/errors/error_type.dart';
import 'package:app_client/src/core/widgets/error_view.dart';
import 'package:app_client/src/core/widgets/skeleton_loading.dart';
import 'package:app_client/src/core/utils/accessibility_utils.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _activeProjectsCount = 0;
  final ProjectsApiService _projectsService = ProjectsApiService();
  List<Map<String, dynamic>> _activeProjects = [];
  List<Map<String, dynamic>> _completedProjects = [];
  bool _loading = true;
  AppError? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proiectele Mele'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppTheme.surfaceColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.onSurfaceSecondary,
              tabs: const [
                Tab(text: 'Active'),
                Tab(text: 'Finalizate'),
                Tab(text: 'Contestații'),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        children: [
          // Overview Cards
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: Row(
              children: [
                // Active Projects Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _activeProjectsCount.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          'În lucru',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Completed Projects Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _completedProjects.length.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                        Text(
                          'Finalizate',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Total Value Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${(_calculateTotalValue() ~/ 1000)}K',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        Text(
                          'RON',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Projects List
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Projects
                _buildTabContent(_activeProjects, 'Active'),
                // Completed Projects
                _buildTabContent(_completedProjects, 'Finalizate'),
                // Disputed Projects (placeholder)
                _buildEmptyState('Contestații'),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vei putea contacta meșterii prin mesaj'),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        tooltip: 'Contactează meșter',
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildTabContent(List<Map<String, dynamic>> projects, String tabTitle) {
    // Show error state with retry option
    if (_error != null && !_loading) {
      return ErrorView(
        error: _error!,
        onRetry: _error!.canRetry ? _fetchProjects : null,
      );
    }

    // Show skeleton loading
    if (_loading) {
      return _buildLoadingState();
    }

    // Show project list or empty state
    return _buildProjectsList(projects, tabTitle);
  }

  Widget _buildLoadingState() {
    return Semantics(
      label: 'Se încarcă proiectele',
      child: ListView.builder(
        padding: EdgeInsets.all(AppSpacing.lg),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: AppSpacing.lg),
            child: const ProjectCardSkeleton(),
          );
        },
      ),
    );
  }

  Widget _buildProjectsList(List<Map<String, dynamic>> projects, String tabTitle) {
    if (projects.isEmpty) {
      return _buildEmptyState(tabTitle);
    }

    return Semantics(
      label: '$tabTitle, ${projects.length} proiecte',
      child: RefreshIndicator(
        onRefresh: _fetchProjects,
        child: ListView.builder(
          padding: EdgeInsets.all(AppSpacing.lg),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return AccessibilityUtils.ensureTouchTarget(
              onTap: () {
                context.announce('Ai selectat proiectul: ${project['job']?['title'] ?? 'Fără titlu'}');
                _onProjectTap(context, project);
              },
              child: ProjectCard(
                project: project,
                onTap: () => _onProjectTap(context, project),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String type) {
    IconData icon;
    String title;
    String subtitle;

    switch (type) {
      case 'Active':
        icon = Icons.hourglass_empty;
        title = 'Nici un proiect activ';
        subtitle = 'Proiectele active vor apărea aici';
        break;
      case 'Finalizate':
        icon = Icons.check_circle_outline;
        title = 'Nici un proiect finalizat';
        subtitle = 'Proiectele finalizate vor apărea aici';
        break;
      case 'Contestații':
        icon = Icons.warning_amber_rounded;
        title = 'Nici o contestație activă';
        subtitle = 'Orice dispute vor fi rezolvate aici';
        break;
      default:
        icon = Icons.list_alt;
        title = 'Empty';
        subtitle = '';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppTheme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.onSurfaceSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _onProjectTap(BuildContext context, Map<String, dynamic> project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ProjectDetailsSheet(project: project),
    );
  }

  double _calculateTotalValue() {
    final activeValue = _activeProjects
        .map((p) => (p['agreedPrice'] as num?)?.toDouble() ?? 0.0)
        .fold<double>(0.0, (a, b) => a + b);

    final completedValue = _completedProjects
        .map((p) => (p['agreedPrice'] as num?)?.toDouble() ?? 0.0)
        .fold<double>(0.0, (a, b) => a + b);

    return (activeValue + completedValue).toDouble();
  }

  Future<void> _fetchProjects() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final projects = await _projectsService.getProjects(limit: 100);
      if (!mounted) return;

      final mapped = projects.map(_projectToCardMap).toList();
      final active = mapped
          .where((p) => (p['status'] as String) == 'ACTIVE')
          .toList();
      final completed = mapped
          .where((p) => (p['status'] as String) == 'COMPLETED')
          .toList();

      setState(() {
        _activeProjects = active;
        _completedProjects = completed;
        _activeProjectsCount = active.length;
        _loading = false;
        _error = null;
      });

      // Announce success to screen readers
      if (mounted) {
        context.announce('Proiecte încărcate cu succes: ${active.length} active, ${completed.length} finalizate');
      }
    } catch (e) {
      if (!mounted) return;

      final appError = AppError.fromException(e);
      setState(() {
        _loading = false;
        _error = appError;
      });

      // Announce error to screen readers
      if (mounted) {
        context.announce('Eroare la încărcarea proiectelor');
      }
    }
  }

  Map<String, dynamic> _projectToCardMap(api.Project p) {
    String statusStr = (p.status).toLowerCase();
    final status = statusStr.contains('completed') ? 'COMPLETED' : 'ACTIVE';
    return {
      'id': p.id,
      'status': status,
      'progress': status == 'COMPLETED' ? 1.0 : 0.0,
      'agreedPrice': p.budget,
      'startDate': p.createdAt,
      'endDate': status == 'COMPLETED' ? p.updatedAt : null,
      'job': {'title': p.title},
      'craftsman': {'name': p.craftsmanName ?? 'Necunoscut', 'rating': 0.0},
    };
  }
}

// Project Details Bottom Sheet
class _ProjectDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> project;

  const _ProjectDetailsSheet({required this.project});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  project['job']?['title'] ?? 'Project Title',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Project Info
          _buildInfoRow('Meșter', project['craftsman']?['name'] ?? ''),
          _buildInfoRow('Preț acordat', '${project['agreedPrice']} RON'),

          if (project['startDate'] != null)
            _buildInfoRow('Început', _formatDate(project['startDate'])),

          if (project['endDate'] != null)
            _buildInfoRow('Finalizat', _formatDate(project['endDate'])),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Contact craftsman action
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Funcție chat în curs de implementare'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('Trimite mesaj'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // View milestones/next steps
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Funcție milestones în curs de implementare',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.list_alt),
                  label: const Text('Vezi etape'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Additional actions based on project status
          if (project['status'] == 'ACTIVE')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCompleteOptions(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Marchează ca finalizat'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.onSurfaceSecondary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.onSurfaceColor,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date is DateTime) {
      return '${date.day}.${date.month}.${date.year}';
    }
    return date?.toString() ?? '';
  }

  void _showCompleteOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizează proiect?'),
        content: const Text(
          'Ești sigur că vrei să marchezi acest proiect ca finalizat? '
          'Rezultatul va afecta rating-ul meșterului.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Anulează'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Finalizează'),
          ),
        ],
      ),
    );
  }
}
