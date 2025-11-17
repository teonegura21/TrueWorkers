import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';
import 'package:app_client/src/core/services/comprehensive_service.dart';
// For Project and Milestone models

class ProjectsListScreen extends StatefulWidget {
  const ProjectsListScreen({super.key});

  @override
  State<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends State<ProjectsListScreen> {
  List<PlatformProject> _projects = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // TODO: Replace 'user_id_placeholder' with actual authenticated user ID
      final fetchedProjects = await mesteriService.getProjects(userId: 'user_id_placeholder');
      setState(() {
        _projects = fetchedProjects.map((json) => PlatformProject.fromJson(json)).toList();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proiectele Mele'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Eroare la încărcarea proiectelor: $_error'),
                      ElevatedButton(
                        onPressed: _fetchProjects,
                        child: const Text('Reîncercă'),
                      ),
                    ],
                  ),
                )
              : _projects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Nu ai niciun proiect activ.'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Navigate to create new job/project screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Navigare către creare job/proiect'),
                                ),
                              );
                            },
                            child: const Text('Creează un Proiect Nou'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _projects.length,
                      itemBuilder: (context, index) {
                        final project = _projects[index];
                        return _buildProjectCard(project);
                      },
                    ),
    );
  }

  Widget _buildProjectCard(PlatformProject project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              project.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppTheme.onSurfaceSecondary),
                const SizedBox(width: 4),
                Text(
                  project.location,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, size: 16, color: AppTheme.onSurfaceSecondary),
                const SizedBox(width: 4),
                Text(
                  '${project.budget.toStringAsFixed(2)} RON',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusChip(project.status),
            const SizedBox(height: 16),
            _buildMilestoneSummary(project.milestones),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'inProgress':
        color = AppTheme.warningColor;
        text = 'În Desfășurare';
        break;
      case 'completed':
        color = AppTheme.successColor;
        text = 'Finalizat';
        break;
      case 'pending':
        color = AppTheme.primaryColor;
        text = 'În Așteptare';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    return Chip(
      label: Text(text),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildMilestoneSummary(List<Map<String, dynamic>> milestones) {
    if (milestones.isEmpty) {
      return const SizedBox.shrink();
    }

    final completedMilestones = milestones.where((m) => m['status'] == 'completed').length;
    final totalMilestones = milestones.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progres Milestones',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: totalMilestones > 0 ? completedMilestones / totalMilestones : 0,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          '$completedMilestones din $totalMilestones milestones finalizate',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
        ),
      ],
    );
  }
}
