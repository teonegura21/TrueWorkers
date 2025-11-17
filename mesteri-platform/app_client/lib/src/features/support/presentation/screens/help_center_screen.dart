import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _helpCategories = [
    {
      'id': '1',
      'title': 'Cont și Profil',
      'icon': Icons.person,
      'description': 'Gestionarea contului, profilului și setărilor',
      'articles': 12,
    },
    {
      'id': '2',
      'title': 'Lucrări și Oferte',
      'icon': Icons.work,
      'description': 'Postare lucrări, oferte și gestionare proiecte',
      'articles': 18,
    },
    {
      'id': '3',
      'title': 'Plăți și Facturare',
      'icon': Icons.payment,
      'description': 'Sistemul de plăți, escrow și facturare',
      'articles': 9,
    },
    {
      'id': '4',
      'title': 'Verificări și Securitate',
      'icon': Icons.security,
      'description': 'Verificarea identității și securitatea platformei',
      'articles': 7,
    },
    {
      'id': '5',
      'title': 'Recenzii și Evaluări',
      'icon': Icons.star,
      'description': 'Sistemul de recenzii și evaluări ale meșterilor',
      'articles': 5,
    },
    {
      'id': '6',
      'title': 'Asistență Tehnică',
      'icon': Icons.build,
      'description': 'Probleme tehnice și suport utilizator',
      'articles': 11,
    },
  ];

  final List<Map<String, dynamic>> _popularArticles = [
    {
      'id': '1',
      'title': 'Cum postezi o lucrare nouă',
      'category': 'Lucrări și Oferte',
      'views': 1250,
    },
    {
      'id': '2',
      'title': 'Cum funcționează sistemul de plăți escrow',
      'category': 'Plăți și Facturare',
      'views': 980,
    },
    {
      'id': '3',
      'title': 'Cum îți verifici contul de meșter',
      'category': 'Verificări și Securitate',
      'views': 756,
    },
    {
      'id': '4',
      'title': 'Cum evaluezi un meșter',
      'category': 'Recenzii și Evaluări',
      'views': 634,
    },
    {
      'id': '5',
      'title': 'Cum modifici datele de profil',
      'category': 'Cont și Profil',
      'views': 523,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centru de Ajutor'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            _buildSearchBar(),

            const SizedBox(height: 32),

            // Quick help cards
            _buildQuickHelpSection(),

            const SizedBox(height: 32),

            // Help categories
            _buildCategoriesSection(),

            const SizedBox(height: 32),

            // Popular articles
            _buildPopularArticlesSection(),

            const SizedBox(height: 32),

            // Contact support
            _buildContactSupportSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Caută în centrul de ajutor...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildQuickHelpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ajutor Rapid',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildQuickHelpCard(
                icon: Icons.question_answer,
                title: 'Întrebări Frecvente',
                subtitle: 'Răspunsuri la cele mai comune întrebări',
                onTap: () => _navigateToFAQ(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildQuickHelpCard(
                icon: Icons.video_library,
                title: 'Tutoriale Video',
                subtitle: 'Ghiduri video pas cu pas',
                onTap: () => _navigateToTutorials(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickHelpCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    final query = _searchQuery.trim().toLowerCase();
    final filteredCategories = query.isEmpty
        ? _helpCategories
        : _helpCategories.where((category) {
            final title = (category['title'] as String).toLowerCase();
            final description = (category['description'] as String)
                .toLowerCase();
            return title.contains(query) || description.contains(query);
          }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorii Ajutor',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        if (filteredCategories.isEmpty)
          const Text('Nu am găsit rezultate pentru căutarea ta.'),
        if (filteredCategories.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: filteredCategories.length,
            itemBuilder: (context, index) {
              final category = filteredCategories[index];
              return _buildCategoryCard(category);
            },
          ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToCategory(category),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  category['icon'] as IconData,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category['title'] as String,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                category['description'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                '${category['articles']} articole',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Articole Populare',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Column(
          children: _popularArticles.map((article) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 1,
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  article['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      article['category'] as String,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${article['views']} vizualizări',
                      style: TextStyle(
                        color: AppTheme.onSurfaceSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _navigateToArticle(article),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContactSupportSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.support_agent, size: 48, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'Ai nevoie de ajutor personalizat?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Echipa noastră de suport este aici pentru a te ajuta',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _contactSupport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Contactează Suportul',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFAQ() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigare la Întrebări Frecvente'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _navigateToTutorials() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigare la Tutoriale Video'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _navigateToCategory(Map<String, dynamic> category) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigare la: ${category['title']}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _navigateToArticle(Map<String, dynamic> article) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deschidere articol: ${article['title']}'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deschidere formular contact suport'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }
}
