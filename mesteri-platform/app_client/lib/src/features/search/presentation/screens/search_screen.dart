import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';
import 'package:app_client/src/core/models/job_models.dart';
import 'package:app_client/src/core/services/jobs_api_service.dart';
import 'package:app_client/src/features/common/widgets/trust_badge.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final JobsApiService _jobsService = JobsApiService();
  List<Job> _filteredJobs = [];
  List<Job> _allJobs = [];
  bool _trustOnly = false;
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'Toate Categorii';
  String _selectedCity = 'Toate orașele';

  final List<String> _categories = [
    'Toate Categorii',
    'Electrik',
    'Plumbărie',
    'Zugrăveli',
    'Montaj Mobilier',
    'Construcții',
    'Izolații',
    'Instalații Termice',
    'Instalări Sanitare',
    'Reparații Acasă',
  ];

  final List<String> _cities = [
    'Toate orașele',
    'București',
    'Cluj-Napoca',
    'Timișoara',
    'Iași',
    'Constanța',
    'Brașov',
    'Galați',
  ];

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterJobs() {
    List<Job> filtered = List.from(_allJobs);

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (job) =>
                job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                job.description.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    // Filter by category
    if (_selectedCategory != 'Toate Categorii') {
      filtered = filtered
          .where((job) => job.category == _selectedCategory)
          .toList();
    }

    // Filter by city
    if (_selectedCity != 'Toate orașele') {
      filtered = filtered
          .where(
            (job) => job.location.toLowerCase().contains(
              _selectedCity.toLowerCase(),
            ),
          )
          .toList();
    }

    // Filter by trust (verified only)
    if (_trustOnly) {
      filtered = filtered
          .where(
            (job) => job.craftsmenAvailable.any(
              (craftsman) =>
                  craftsman.trustBadges.contains('Verified') ||
                  craftsman.trustBadges.contains('Premium'),
            ),
          )
          .toList();
    }

    setState(() {
      _filteredJobs = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caută Lucrări'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Caută lucrări sau category...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchQuery = '';
                              _filterJobs();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.outlineColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    filled: true,
                    fillColor: AppTheme.surfaceVariant,
                  ),
                  onSubmitted: (value) {
                    _searchQuery = value;
                    _filterJobs();
                  },
                  onChanged: (value) {
                    _searchQuery = value;
                    _filterJobs();
                  },
                ),

                const SizedBox(height: 16),

                // Filters Row
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: _selectedCategory,
                        items: _categories,
                        hint: 'Category',
                        icon: Icons.work_outline,
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                          _filterJobs();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        value: _selectedCity,
                        items: _cities,
                        hint: 'Oraș',
                        icon: Icons.location_on,
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value!;
                          });
                          _filterJobs();
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Trust Filter & Reset
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 0,
                        color: _trustOnly
                            ? AppTheme.primaryColor.withValues(alpha: 0.1)
                            : AppTheme.surfaceColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: _trustOnly
                                ? AppTheme.primaryColor
                                : AppTheme.outlineColor,
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _trustOnly = !_trustOnly;
                            });
                            _filterJobs();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: _trustOnly
                                      ? AppTheme.primaryColor
                                      : AppTheme.onSurfaceSecondary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Doar Verificați',
                                  style: TextStyle(
                                    color: _trustOnly
                                        ? AppTheme.primaryColor
                                        : AppTheme.onSurfaceSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredJobs.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _fetchJobs,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredJobs.length,
                      itemBuilder: (context, index) {
                        return _buildJobCard(_filteredJobs[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to post new job
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post new job feature coming soon!')),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String hint,
    required IconData icon,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.outlineColor),
        borderRadius: BorderRadius.circular(8),
        color: AppTheme.surfaceColor,
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        value: value,
        hint: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.onSurfaceSecondary),
            const SizedBox(width: 8),
            Text(hint, style: TextStyle(color: AppTheme.onSurfaceSecondary)),
          ],
        ),
        underline: const SizedBox(),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppTheme.onSurfaceSecondary,
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(value: value, child: Text(value));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    // Use the first craftsman for display (in real app would be separate entities)
    final craftsmen = job.craftsmenAvailable;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Job details for: ${job.title}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and category
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(job.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job.category,
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

              // Location and budget
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.onSurfaceSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.location,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ),
                  Text(
                    '${job.budgetMin} - ${job.budgetMax} RON',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Craftsmen count and trust
              Row(
                children: [
                  Icon(Icons.people, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '${craftsmen.length} meșteri disponibili',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceSecondary,
                    ),
                  ),
                  const Spacer(),
                  TrustBadge(
                    type:
                        craftsmen.any((c) => c.trustBadges.contains('Premium'))
                        ? TrustBadgeType.premium
                        : craftsmen.any(
                            (c) => c.trustBadges.contains('Verified'),
                          )
                        ? TrustBadgeType.verified
                        : TrustBadgeType.secure,
                  ),
                ],
              ),

              if (job.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  job.description.length > 100
                      ? '${job.description.substring(0, 100)}...'
                      : job.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceTertiary,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Trust indicators
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      size: 16,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Plată se aceasta garantează prin escrow',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: AppTheme.onSurfaceTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Nici o lucrare găsită',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.onSurfaceSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Încearcă să ajustezi filtrele de căutare sau postează o lucrare nouă pentru a atrage meșterii verificați.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    const Map<String, Color> categoryColors = {
      'Electrik': Colors.blue,
      'Plumbărie': Colors.green,
      'Zugrăveli': Colors.purple,
      'Montaj Mobilier': Colors.orange,
      'Construcții': Colors.brown,
      'Izolații': Colors.teal,
      'Instalații Termice': Colors.red,
      'Instalări Sanitare': Colors.cyan,
      'Reparații Acasă': Colors.pink,
    };

    return categoryColors[category] ?? AppTheme.primaryColor;
  }
}

extension on _SearchScreenState {
  Future<void> _fetchJobs() async {
    setState(() => _isLoading = true);
    try {
      final jobs = await _jobsService.getJobs(limit: 100);
      if (!mounted) return;
      setState(() {
        _allJobs = jobs;
        _filteredJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la încărcarea lucrărilor: $e')),
      );
    }
  }
}
