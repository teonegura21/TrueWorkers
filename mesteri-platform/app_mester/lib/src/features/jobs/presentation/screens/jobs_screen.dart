import 'package:flutter/material.dart';
import '../../../../core/services/jobs_service.dart';
import '../../../../core/theme/app_theme.dart';
import 'job_details_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final JobsService _jobsService = JobsService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _jobs = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedCategory;

  final List<Map<String, String>> _categories = [
    {'value': 'TOATE', 'label': 'Toate categoriile'},
    {'value': 'ELECTRIK', 'label': 'Electricieni'},
    {'value': 'INSTALATII_SANITARE', 'label': 'Instalații sanitare'},
    {'value': 'CONSTRUCTII', 'label': 'Construcții'},
    {'value': 'ZUGRAVIT_VOPSIT', 'label': 'Zugravit & vopsit'},
    {'value': 'PARCHET_FINISAJE', 'label': 'Parchet & finisaje'},
    {'value': 'AMENAJARI_INTERIOARE', 'label': 'Amenajări interioare'},
    {'value': 'TAMPLAR_STICLA', 'label': 'Tâmplărie & sticlă'},
    {'value': 'REPARAT_CLIMATIZARE', 'label': 'Reparații climatizare'},
    {'value': 'CURATENIE', 'label': 'Curățenie'},
    {'value': 'ALTELE', 'label': 'Altele'},
  ];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final category = _selectedCategory == 'TOATE' ? null : _selectedCategory;
      final jobs = await _jobsService.getAvailableJobs(
        category: category,
        status: 'ACTIVE',
      );

      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _searchJobs(String query) async {
    if (query.isEmpty) {
      _loadJobs();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jobs = await _jobsService.searchJobs(query);
      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proiecte disponibile'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Caută proiecte...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadJobs();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onSubmitted: _searchJobs,
                ),
                const SizedBox(height: 12),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory == cat['value'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(cat['label']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = selected ? cat['value'] : null;
                            });
                            _loadJobs();
                          },
                          selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                          checkmarkColor: AppTheme.primaryColor,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Jobs List
          Expanded(
            child: _buildJobsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadJobs,
              child: const Text('Încearcă din nou'),
            ),
          ],
        ),
      );
    }

    if (_jobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nu există proiecte disponibile',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _jobs.length,
        itemBuilder: (context, index) {
          final job = _jobs[index];
          return _buildJobCard(job);
        },
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final budgetMin = job['budgetMin'] ?? 0;
    final budgetMax = job['budgetMax'] ?? 0;
    final offersCount = (job['offers'] as List?)?.length ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToJobDetails(job),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(job['category']),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getCategoryLabel(job['category']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildUrgencyBadge(job['urgency']),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                job['title'] ?? 'Fără titlu',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                job['description'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),

              // Location & Budget
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job['location'] ?? job['city'] ?? 'Necunoscut',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.attach_money, size: 16, color: AppTheme.primaryColor),
                  Text(
                    '$budgetMin - $budgetMax RON',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '$offersCount oferte',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _navigateToJobDetails(job),
                    icon: const Icon(Icons.send),
                    label: const Text('Trimite ofertă'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUrgencyBadge(String? urgency) {
    Color color;
    IconData icon;
    String label;

    switch (urgency) {
      case 'HIGH':
        color = Colors.red;
        icon = Icons.priority_high;
        label = 'URGENT';
        break;
      case 'MEDIUM':
        color = Colors.orange;
        icon = Icons.schedule;
        label = 'MEDIU';
        break;
      default:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        label = 'SCĂZUT';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'ELECTRIK':
        return Colors.yellow.shade700;
      case 'INSTALATII_SANITARE':
        return Colors.blue;
      case 'CONSTRUCTII':
        return Colors.brown;
      case 'ZUGRAVIT_VOPSIT':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getCategoryLabel(String? category) {
    final cat = _categories.firstWhere(
      (c) => c['value'] == category,
      orElse: () => {'label': 'Altele'},
    );
    return cat['label']!;
  }

  void _navigateToJobDetails(Map<String, dynamic> job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobDetailsScreen(jobId: job['id']),
      ),
    ).then((_) => _loadJobs()); // Refresh after returning
  }
}
