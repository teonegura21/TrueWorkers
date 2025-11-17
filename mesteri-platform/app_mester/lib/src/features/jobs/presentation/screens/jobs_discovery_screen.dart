import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/config/app_config.dart';
import '../../data/mock_craftsman_jobs.dart';

enum SortBy {
  newest,
  closest,
  highestBudget,
  expiringSoon,
}

class JobsDiscoveryScreen extends StatefulWidget {
  const JobsDiscoveryScreen({super.key});

  @override
  State<JobsDiscoveryScreen> createState() => _JobsDiscoveryScreenState();
}

class _JobsDiscoveryScreenState extends State<JobsDiscoveryScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabAnimationController;

  // Search and filter states
  String _searchQuery = '';
  String? _selectedCategory;
  SortBy _sortBy = SortBy.newest;
  double _searchRadius = 50.0; // km
  bool _showFilters = false;

  // Jobs list state
  List<CraftsmanJob> _filteredJobs = [];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimationController.forward();
    _filteredJobs = mockCraftsmanJobs;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            _buildHeader(),

            // Filters (when expanded)
            if (_showFilters) _buildFilters(),

            // Results count
            _buildResultsHeader(),

            // Jobs list
            Expanded(
              child: _buildJobsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          const SizedBox(height: 12),

          // Quick actions row
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Search icon
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Icon(
              Icons.search_rounded,
              color: AppTheme.onSurfaceSecondary,
            ),
          ),

          // Search input
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Caută lucrări...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _performSearch(),
            ),
          ),

          // Filter button
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_list_off_rounded : Icons.filter_list_rounded,
              color: _showFilters ? AppTheme.primaryColor : AppTheme.onSurfaceSecondary,
            ),
            onPressed: _toggleFilters,
            tooltip: 'Filtre avansate',
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCategoryChip('❗ Urgent', 'urgent'),
          _buildCategoryChip('🆕 Nou', 'new'),
          _buildCategoryChip('👤 PFA', 'pfa'),
          _buildCategoryChip('🏢 SRL', 'srl'),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String category) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _isCategorySelected(category)
                ? Colors.white
                : AppTheme.onSurfaceColor,
          ),
        ),
        selected: _isCategorySelected(category),
        selectedColor: AppTheme.primaryColor,
        onSelected: (selected) => _onCategorySelected(category, selected),
        backgroundColor: AppTheme.surfaceVariant,
        checkmarkColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.outlineColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Distance filter
          _buildDistanceSlider(),

          const SizedBox(height: 12),

          // Category selector
          _buildCategoryDropdown(),

          const SizedBox(height: 12),

          // Sort options
          _buildSortOptions(),

          // Apply filters button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _applyFilters,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Aplică Filtrele'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              size: 18,
              color: AppTheme.onSurfaceSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Rază de căutare',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${_searchRadius.round()} km',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: _searchRadius,
          min: 10,
          max: 200,
          divisions: 19,
          activeColor: AppTheme.primaryColor,
          thumbColor: AppTheme.primaryColor,
          overlayColor: WidgetStateProperty.all(AppTheme.primaryColor.withValues(alpha: 0.2)),
          onChanged: (value) {
            setState(() {
              _searchRadius = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Specializare',
        prefixIcon: const Icon(Icons.category_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Toate categoriile'),
        ),
        ...AppConfig.serviceCategories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sortează după',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: SortBy.values.map((sortBy) {
            return FilterChip(
              label: Text(_getSortByLabel(sortBy)),
              selected: _sortBy == sortBy,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _sortBy = sortBy;
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildResultsHeader() {
    final resultsText = _filteredJobs.isEmpty
        ? 'Nicio lucrare găsită'
        : '${_filteredJobs.length} lucrări găsite';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppTheme.surfaceVariant,
      child: Row(
        children: [
          Text(
            resultsText,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceColor,
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedCategory != null) ...[
            const Spacer(),
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_rounded, size: 16),
              label: const Text('Resetează'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJobsList() {
    if (_filteredJobs.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshJobs,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _filteredJobs.length,
        itemBuilder: (context, index) {
          final job = _filteredJobs[index];
          return _buildJobCard(job);
        },
      ),
    );
  }

  Widget _buildJobCard(CraftsmanJob job) {
    return GestureDetector(
      onTap: () => _openJobDetails(job),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.outlineColor.withValues(alpha: 0.3),
            width: 1,
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
              // Header with title and budget
              Row(
                children: [
                  // Urgency indicator
                  if (job.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '${job.budgetMin}-${job.budgetMax} ${AppConfig.currencySymbol}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.successColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                job.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Description
              Text(
                job.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Client and ratings
              Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: AppTheme.onSurfaceSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.clientName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onSurfaceColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  // Rating
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppTheme.ratingColor,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        job.clientRating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.onSurfaceColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Location and deadline
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: AppTheme.onSurfaceSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${job.distance.toStringAsFixed(1)} km • ${job.location}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_getDaysUntilDeadline(job.deadline)} zile',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.errorColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // CTAs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionChip(
                    icon: Icons.phone_rounded,
                    label: 'CONTACT',
                    onTap: () => _contactClient(job),
                  ),
                  _buildActionChip(
                    icon: Icons.send_rounded,
                    label: 'OFERTĂ',
                    onTap: () => _submitOffer(job),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppTheme.onSurfaceSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Nicio lucrare găsită',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurfaceColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Încearcă să modifici căutarea sau filtrele pentru rezultate mai bune.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Resetează Filtrele'),
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
    return AnimatedBuilder(
      animation: _fabAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimationController.value,
          child: FloatingActionButton.extended(
            onPressed: _showAdvancedSearch,
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Căutare Avansată'),
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
        );
      },
    );
  }

  // Helper methods
  bool _isCategorySelected(String category) {
    return _selectedCategory == category;
  }

  void _onCategorySelected(String category, bool selected) {
    setState(() {
      _selectedCategory = selected ? category : null;
    });
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    if (query.length >= 2 || query.isEmpty) {
      _performSearch();
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
  }

  String _getSortByLabel(SortBy sortBy) {
    switch (sortBy) {
      case SortBy.newest:
        return 'Cele mai noi';
      case SortBy.closest:
        return 'Cele mai apropiate';
      case SortBy.highestBudget:
        return 'Buget maxim';
      case SortBy.expiringSoon:
        return 'Expiră curând';
    }
  }

  int _getDaysUntilDeadline(DateTime deadline) {
    final now = DateTime.now();
    return deadline.difference(now).inDays;
  }

  void _performSearch() {
    // Implement search logic
    setState(() {
      _filteredJobs = mockCraftsmanJobs.where((job) {
        final matchesQuery = _searchQuery.isEmpty ||
            job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            job.location.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesCategory = _selectedCategory == null ||
            job.category == _selectedCategory ||
            job.subCategory == _selectedCategory;

        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _applyFilters() {
    _performSearch();
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedCategory = null;
      _searchRadius = 50.0;
      _sortBy = SortBy.newest;
      _filteredJobs = mockCraftsmanJobs;
      _showFilters = false;
    });
    _searchController.clear();
  }

  void _openJobDetails(CraftsmanJob job) {
    // Navigate to job details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Detalii pentru: ${job.title}'),
      ),
    );
  }

  void _contactClient(CraftsmanJob job) {
    // Implement contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contactează ${job.clientName}'),
      ),
    );
  }

  void _submitOffer(CraftsmanJob job) {
    // Navigate to submit offer screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Trimite ofertă pentru: ${job.title}'),
      ),
    );
  }

  void _showAdvancedSearch() {
    // Navigate to advanced search screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Căutare avansată - în curând disponibile'),
      ),
    );
  }

  Future<void> _refreshJobs() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _filteredJobs = mockCraftsmanJobs;
    });
  }
}
