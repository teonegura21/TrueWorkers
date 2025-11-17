import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/craftsmen_api_service.dart';
import '../../../craftsmen/presentation/screens/craftsman_profile_screen.dart';

class SearchCraftsmenScreen extends StatefulWidget {
  const SearchCraftsmenScreen({super.key});

  @override
  State<SearchCraftsmenScreen> createState() => _SearchCraftsmenScreenState();
}

class _SearchCraftsmenScreenState extends State<SearchCraftsmenScreen> {
  final CraftsmenApiService _apiService = CraftsmenApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _craftsmen = [];
  List<dynamic> _filteredCraftsmen = [];
  bool _isLoading = false;
  bool _showFilters = false;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  // Filter options
  String? _selectedCity;
  final List<String> _selectedSpecialties = [];
  double _minRating = 0;
  bool _verifiedOnly = false;
  String _sortBy = 'rating'; // rating, reviews, experience

  final List<String> _specialties = [
    'INSTALATII_SANITARE',
    'ELECTRIK',
    'CONSTRUCTII',
    'ALTELE',
  ];

  final List<String> _cities = [
    'Toate',
    'București',
    'Cluj-Napoca',
    'Timișoara',
    'Iași',
    'Constanța',
    'Brașov',
  ];

  @override
  void initState() {
    super.initState();
    _loadCraftsmen();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCraftsmen() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    try {
      final result = await _apiService.searchCraftsmen(
        query: _searchController.text.isNotEmpty ? _searchController.text : null,
        specialties: _selectedSpecialties.isNotEmpty ? _selectedSpecialties : null,
        city: _selectedCity != null && _selectedCity != 'Toate' ? _selectedCity : null,
        minRating: _minRating > 0 ? _minRating : null,
        isVerified: _verifiedOnly ? true : null,
        page: _currentPage,
        limit: 20,
      );
      
      setState(() {
        _craftsmen = result['craftsmen'] as List<dynamic>;
        _filteredCraftsmen = _craftsmen;
        _totalPages = result['totalPages'] as int;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eroare: $e')),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      final result = await _apiService.searchCraftsmen(
        query: _searchController.text.isNotEmpty ? _searchController.text : null,
        specialties: _selectedSpecialties.isNotEmpty ? _selectedSpecialties : null,
        city: _selectedCity != null && _selectedCity != 'Toate' ? _selectedCity : null,
        minRating: _minRating > 0 ? _minRating : null,
        isVerified: _verifiedOnly ? true : null,
        page: _currentPage + 1,
        limit: 20,
      );
      
      setState(() {
        _currentPage++;
        _craftsmen.addAll(result['craftsmen'] as List<dynamic>);
        _filteredCraftsmen = _craftsmen;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
    }
  }

  void _applyFilters() {
    // Reset to page 1 when filters change
    _currentPage = 1;
    _loadCraftsmen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caută Meșteri'),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFiltersPanel(),
          _buildResultsHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.05),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Caută după nume sau competență...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _applyFilters();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) => _applyFilters(),
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtre',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // City filter
          DropdownButtonFormField<String>(
            initialValue: _selectedCity,
            decoration: const InputDecoration(
              labelText: 'Oraș',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: _cities.map((city) {
              return DropdownMenuItem(value: city, child: Text(city));
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedCity = value);
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),

          // Rating filter
          Row(
            children: [
              const Text('Rating minim:'),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: _minRating,
                  min: 0,
                  max: 5,
                  divisions: 10,
                  label: _minRating.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() => _minRating = value);
                    _applyFilters();
                  },
                ),
              ),
              Text(_minRating.toStringAsFixed(1)),
            ],
          ),

          // Verified only
          CheckboxListTile(
            title: const Text('Doar verificați'),
            value: _verifiedOnly,
            onChanged: (value) {
              setState(() => _verifiedOnly = value ?? false);
              _applyFilters();
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 12),

          // Sort by
          Row(
            children: [
              const Text('Sortează după:'),
              const SizedBox(width: 16),
              Expanded(
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'rating', label: Text('Rating')),
                    ButtonSegment(value: 'reviews', label: Text('Review-uri')),
                    ButtonSegment(value: 'experience', label: Text('Experiență')),
                  ],
                  selected: {_sortBy},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() => _sortBy = selection.first);
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredCraftsmen.length} meșteri găsiți',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          if (_filteredCraftsmen.length != _craftsmen.length)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _selectedCity = null;
                  _minRating = 0;
                  _verifiedOnly = false;
                  _sortBy = 'rating';
                  _applyFilters();
                });
              },
              child: const Text('Resetează filtre'),
            ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    if (_filteredCraftsmen.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Nu am găsit meșteri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Încearcă să modifici filtrele'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCraftsmen.length,
      itemBuilder: (context, index) {
        return _buildCraftsmanCard(_filteredCraftsmen[index]);
      },
    );
  }

  Widget _buildCraftsmanCard(dynamic craftsman) {
    final String craftsmanId = craftsman['id'] ?? '';
    final String fullName = craftsman['fullName'] ?? 'Unknown';
    final String? profilePicture = craftsman['profilePicture'];
    final bool isVerified = craftsman['isVerified'] ?? false;
    final double averageRating = (craftsman['averageRating'] ?? 0.0).toDouble();
    final int totalReviews = craftsman['totalReviews'] ?? 0;
    final int yearsExperience = craftsman['yearsExperience'] ?? 0;
    final String city = craftsman['city'] ?? '';
    final List<dynamic> skillsTags = craftsman['skillsTags'] ?? [];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CraftsmanProfileScreen(craftsmanId: craftsmanId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile photo
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: profilePicture != null
                    ? CachedNetworkImage(
                        imageUrl: profilePicture,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Theme.of(context).primaryColor,
                        child: Center(
                          child: Text(
                            fullName[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blue, size: 20),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${averageRating.toStringAsFixed(1)} ($totalReviews)',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.work_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '$yearsExperience ani',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          city,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    if (skillsTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: skillsTags.take(3).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              skill,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
