import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/services/projects_api_service.dart';
import '../../../../core/models/api_models.dart';

class ProjectsDashboardScreen extends StatefulWidget {
  const ProjectsDashboardScreen({super.key});

  @override
  State<ProjectsDashboardScreen> createState() => _ProjectsDashboardScreenState();
}

class _ProjectsDashboardScreenState extends State<ProjectsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProjectsApiService _projectsService = ProjectsApiService();

  // State management
  List<Project> _activeProjects = [];
  List<Project> _completedProjects = [];
  bool _isLoadingActive = false;
  bool _isLoadingCompleted = false;
  String? _errorActive;
  String? _errorCompleted;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProjects();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects() async {
    await Future.wait([
      _loadActiveProjects(),
      _loadCompletedProjects(),
    ]);
  }

  Future<void> _loadActiveProjects() async {
    setState(() {
      _isLoadingActive = true;
      _errorActive = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final projects = await _projectsService.getProjects(
        status: ProjectStatus.inProgress,
        clientId: currentUser.uid,
      );

      if (mounted) {
        setState(() {
          _activeProjects = projects;
          _isLoadingActive = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorActive = e.toString();
          _isLoadingActive = false;
        });
      }
    }
  }

  Future<void> _loadCompletedProjects() async {
    setState(() {
      _isLoadingCompleted = true;
      _errorCompleted = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final projects = await _projectsService.getProjects(
        status: ProjectStatus.completed,
        clientId: currentUser.uid,
      );

      if (mounted) {
        setState(() {
          _completedProjects = projects;
          _isLoadingCompleted = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorCompleted = e.toString();
          _isLoadingCompleted = false;
        });
      }
    }
  }

  Future<void> _refreshProjects() async {
    await _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proiectele Mele'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProjects,
            tooltip: 'Reîmprospătează',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.work_outline)),
            Tab(text: 'Finalizate', icon: Icon(Icons.check_circle_outline)),
            Tab(text: 'Oferte', icon: Icon(Icons.pending_actions)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveProjects(),
          _buildCompletedProjects(),
          _buildPendingOffers(),
        ],
      ),
    );
  }

  Widget _buildActiveProjects() {
    // Show loading state
    if (_isLoadingActive) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Se încarcă proiectele active...'),
          ],
        ),
      );
    }

    // Show error state
    if (_errorActive != null) {
      return _buildErrorState(
        error: _errorActive!,
        onRetry: _loadActiveProjects,
      );
    }

    // Show empty state
    if (_activeProjects.isEmpty) {
      return _buildEmptyState(
        icon: Icons.work_outline,
        title: 'Niciun proiect activ',
        message: 'Proiectele tale active vor apărea aici',
      );
    }

    // Show projects list
    return RefreshIndicator(
      onRefresh: _loadActiveProjects,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activeProjects.length,
        itemBuilder: (context, index) {
          return _buildProjectCard(_activeProjects[index]);
        },
      ),
    );
  }

  Widget _buildCompletedProjects() {
    // Show loading state
    if (_isLoadingCompleted) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Se încarcă proiectele finalizate...'),
          ],
        ),
      );
    }

    // Show error state
    if (_errorCompleted != null) {
      return _buildErrorState(
        error: _errorCompleted!,
        onRetry: _loadCompletedProjects,
      );
    }

    // Show empty state
    if (_completedProjects.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        title: 'Niciun proiect finalizat',
        message: 'Proiectele finalizate vor apărea aici',
      );
    }

    // Show projects list
    return RefreshIndicator(
      onRefresh: _loadCompletedProjects,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _completedProjects.length,
        itemBuilder: (context, index) {
          return _buildProjectCard(_completedProjects[index]);
        },
      ),
    );
  }

  Widget _buildPendingOffers() {
    // TODO: Implement pending offers view
    return _buildEmptyState(
      icon: Icons.pending_actions,
      title: 'Nicio ofertă primită',
      message: 'Ofertele de la meșteri vor apărea aici',
    );
  }

  Widget _buildProjectCard(Project project) {
    // Calculate progress if milestones exist
    int progress = 0;
    if (project.milestones != null && project.milestones!.isNotEmpty) {
      final completedMilestones = project.milestones!.where((m) => m.status == 'completed').length;
      progress = ((completedMilestones / project.milestones!.length) * 100).round();
    }

    // Calculate days left if endDate exists
    int? daysLeft;
    if (project.endDate != null) {
      daysLeft = project.endDate!.difference(DateTime.now()).inDays;
    }

    // Determine status color and text
    Color statusColor;
    String statusText;
    switch (project.status.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
        statusColor = Colors.orange;
        statusText = 'În desfășurare';
        break;
      case 'completed':
        statusColor = Colors.green;
        statusText = 'Finalizat';
        break;
      case 'onhold':
      case 'on_hold':
        statusColor = Colors.red;
        statusText = 'În așteptare';
        break;
      case 'cancelled':
        statusColor = Colors.grey;
        statusText = 'Anulat';
        break;
      default:
        statusColor = Colors.blue;
        statusText = 'În curs';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to project details
          // Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectDetailsScreen(projectId: project.id)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Craftsman
              if (project.craftsmanName != null)
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      project.craftsmanName!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              if (project.craftsmanName != null) const SizedBox(height: 12),

              // Progress (if milestones exist)
              if (project.milestones != null && project.milestones!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progres',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '$progress%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress / 100,
                        minHeight: 8,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Budget & Deadline
              Row(
                children: [
                  if (project.totalValue != null)
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.attach_money,
                        label: '${project.totalValue!.toStringAsFixed(0)} RON',
                        color: Colors.green,
                      ),
                    ),
                  if (project.totalValue != null && daysLeft != null) const SizedBox(width: 12),
                  if (daysLeft != null)
                    Expanded(
                      child: _buildInfoChip(
                        icon: Icons.calendar_today,
                        label: '$daysLeft zile',
                        color: daysLeft < 3 ? Colors.red : Colors.blue,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to messages
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(projectId: project.id)));
                      },
                      icon: const Icon(Icons.message, size: 16),
                      label: const Text('Mesaj'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to project details
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectDetailsScreen(projectId: project.id)));
                      },
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text('Detalii'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required String error,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[300]),
            const SizedBox(height: 24),
            const Text(
              'Eroare la încărcare',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Încearcă din nou'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
