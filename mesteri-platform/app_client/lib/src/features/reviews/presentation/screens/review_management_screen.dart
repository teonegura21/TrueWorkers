import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Review and rating system
class Review {
  final String id;
  final String projectId;
  final String projectTitle;
  final String craftsmanId;
  final String craftsmanName;
  final double overallRating;
  final Map<String, double>
  dimensionRatings; // quality, timeliness, professionalism, communication
  final String feedbackText;
  final bool isPublic;
  final bool recommends;
  final DateTime createdAt;
  final DateTime? lastModified;
  final ReviewStatus status;
  final List<String> tags;
  final bool hasAttachments;
  final String? responseFromCraftsman;

  const Review({
    required this.id,
    required this.projectId,
    required this.projectTitle,
    required this.craftsmanId,
    required this.craftsmanName,
    required this.overallRating,
    required this.dimensionRatings,
    required this.feedbackText,
    this.isPublic = false,
    this.recommends = false,
    required this.createdAt,
    this.lastModified,
    this.status = ReviewStatus.pending,
    this.tags = const [],
    this.hasAttachments = false,
    this.responseFromCraftsman,
  });
}

enum ReviewStatus {
  draft,
  pending, // Client submitted, pending craftsman review
  published, // Public on platform
  responded, // Craftsman responded
  hidden, // Hidden by request
}

enum ReviewType { clientToCraftsman, craftsmanToClient }

class ReviewStats {
  final double averageRating;
  final int totalReviews;
  final int fiveStarCount;
  final int fourStarCount;
  final int threeStarCount;
  final int twoStarCount;
  final int oneStarCount;
  final double recommendationPercentage;
  final Map<String, double> dimensionAverages;

  const ReviewStats({
    required this.averageRating,
    required this.totalReviews,
    required this.fiveStarCount,
    required this.fourStarCount,
    required this.threeStarCount,
    required this.twoStarCount,
    required this.oneStarCount,
    required this.recommendationPercentage,
    required this.dimensionAverages,
  });
}

// Mock review data
final List<Review> mockReviews = [
  Review(
    id: 'review_001',
    projectId: 'proj_001',
    projectTitle: 'Reparație robinet bucătărie',
    craftsmanId: 'craftsman_001',
    craftsmanName: 'Ion Dumitrescu',
    overallRating: 4.8,
    dimensionRatings: {
      'quality': 5.0,
      'timeliness': 4.5,
      'professionalism': 5.0,
      'communication': 4.5,
    },
    feedbackText:
        'Serviciu excelent! Ion a ajuns la timp, a rezolvat problema profesional și a curățat perfect zona de lucru. Comunicarea a fost foarte bună prin mesaje. Recomand cu căldură!',
    isPublic: true,
    recommends: true,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    status: ReviewStatus.responded,
    tags: ['calitate excelentă', 'punctualitate', 'comunicare bună'],
    responseFromCraftsman:
        'Mulțumesc pentru recenzia frumoasă! A fost o plăcere să lucrez pentru dumneavoastră. Ion',
  ),

  Review(
    id: 'review_002',
    projectId: 'proj_002',
    projectTitle: 'Instalare aer condiționat',
    craftsmanId: 'craftsman_002',
    craftsmanName: 'Vasile Gheorghiță',
    overallRating: 3.2,
    dimensionRatings: {
      'quality': 2.5,
      'timeliness': 3.0,
      'professionalism': 4.0,
      'communication': 2.5,
    },
    feedbackText:
        'Serviciul a fost finalizat mai târziu decât convenit. Materialele folosite par să fie de calitate acceptabilă, dar site-ul de construcții avea dezordini.',
    isPublic: true,
    recommends: false,
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    status: ReviewStatus.published,
    tags: ['întârziere', 'curățenie'],
  ),
];

class ReviewManagementScreen extends StatefulWidget {
  const ReviewManagementScreen({super.key});

  @override
  State<ReviewManagementScreen> createState() => _ReviewManagementScreenState();
}

class _ReviewManagementScreenState extends State<ReviewManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _feedbackController = TextEditingController();

  // Review creation state
  double _overallRating = 0.0;
  final Map<String, double> _dimensionRatings = {
    'quality': 0.0,
    'timeliness': 0.0,
    'professionalism': 0.0,
    'communication': 0.0,
  };
  bool _recommendCraftsman = false;
  final List<String> _selectedTags = [];
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recenzii și Feedback'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => _showHelp(),
            tooltip: 'Ajutor Recenzii',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.onSurfaceSecondary,
          tabs: const [
            Tab(icon: Icon(Icons.edit_rounded), text: 'Scrie Recenzie'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Recenziile Mele'),
            Tab(icon: Icon(Icons.analytics_rounded), text: 'Analize'),
            Tab(icon: Icon(Icons.receipt_rounded), text: 'Recenzii Altele'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCreateReviewTab(),
          _buildMyReviewsTab(),
          _buildAnalyticsTab(),
          _buildOtherReviewsTab(),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createReview(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Scrie Recenzie'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildCreateReviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Selection Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.build_rounded,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alege un proiect finalizat',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Poți scrie recenzii doar pentru proiecte completate',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.expand_more_rounded),
                  onPressed: () => _selectCompletedProject(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Overall Rating
          Text(
            'Evaluare Generală',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _RatingSelector(
            rating: _overallRating,
            onRatingChanged: (rating) =>
                setState(() => _overallRating = rating),
            title: 'Cât de mulțumit ești de serviciile oferite?',
          ),

          const SizedBox(height: 32),

          // Dimension Ratings
          Text(
            'Evaluări Detaliate',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ..._buildDimensionRatings(),

          const SizedBox(height: 32),

          // Recommendation
          _buildRecommendationQuestion(),

          const SizedBox(height: 32),

          // Feedback Text
          _buildFeedbackSection(),

          const SizedBox(height: 32),

          // Tags
          _buildTagsSection(),

          const SizedBox(height: 32),

          // Privacy Options
          _buildPrivacySection(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildMyReviewsTab() {
    return RefreshIndicator(
      onRefresh: _refreshMyReviews,
      child: mockReviews.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockReviews.length,
              itemBuilder: (context, index) =>
                  _buildReviewCard(mockReviews[index]),
            )
          : _buildEmptyReviewsState(),
    );
  }

  Widget _buildAnalyticsTab() {
    final stats = _calculateReviewStats();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Overview
          _buildStatsOverview(stats),

          const SizedBox(height: 24),

          // Rating Breakdown
          _buildRatingBreakdown(stats),

          const SizedBox(height: 24),

          // Dimension Performance
          _buildDimensionPerformance(stats),

          const SizedBox(height: 24),

          // Feedback Insights
          _buildFeedbackInsights(),
        ],
      ),
    );
  }

  Widget _buildOtherReviewsTab() {
    return RefreshIndicator(
      onRefresh: _refreshOtherReviews,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockReviews.length + 5, // Simulate more reviews
        itemBuilder: (context, index) {
          if (index < mockReviews.length) {
            return _buildReviewCard(mockReviews[index], showActions: false);
          } else {
            return _buildOtherReviewPlaceholder(index);
          }
        },
      ),
    );
  }

  List<Widget> _buildDimensionRatings() {
    final dimensions = [
      {
        'key': 'quality',
        'title': 'Calitatea Execuției',
        'subtitle': 'Satisfacție cu rezultatele finale',
      },
      {
        'key': 'timeliness',
        'title': 'Punctualitate',
        'subtitle': 'Respectarea termenelor agreate',
      },
      {
        'key': 'professionalism',
        'title': 'Profesionalism',
        'subtitle': 'Atitudinea și competența meșterului',
      },
      {
        'key': 'communication',
        'title': 'Comunicare',
        'subtitle': 'Claritatea mesajelor și răspunsurilor',
      },
    ];

    return dimensions.map((dimension) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dimension['title']!,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              dimension['subtitle']!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: 8),
            _RatingSelector(
              rating: _dimensionRatings[dimension['key']!] ?? 0.0,
              onRatingChanged: (rating) =>
                  setState(() => _dimensionRatings[dimension['key']!] = rating),
              maxRating: 5,
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildRecommendationQuestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ai recomanda acest meșter?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _recommendCraftsman = true),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _recommendCraftsman
                          ? AppTheme.successColor.withValues(alpha: 0.1)
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _recommendCraftsman
                            ? AppTheme.successColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _recommendCraftsman
                              ? Icons.thumb_up_alt_rounded
                              : Icons.thumb_up_alt_outlined,
                          color: _recommendCraftsman
                              ? AppTheme.successColor
                              : AppTheme.onSurfaceSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Da, recomand',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: _recommendCraftsman
                                      ? AppTheme.successColor
                                      : AppTheme.onSurfaceColor,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _recommendCraftsman = false),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: !_recommendCraftsman
                          ? AppTheme.errorColor.withValues(alpha: 0.1)
                          : AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: !_recommendCraftsman
                            ? AppTheme.errorColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          !_recommendCraftsman
                              ? Icons.thumb_down_alt_rounded
                              : Icons.thumb_down_alt_outlined,
                          color: !_recommendCraftsman
                              ? AppTheme.errorColor
                              : AppTheme.onSurfaceSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nu recomand',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: !_recommendCraftsman
                                      ? AppTheme.errorColor
                                      : AppTheme.onSurfaceColor,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Povestește experiența ta',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _feedbackController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Descrie ce ți-a plăcut, ce trebuie îmbunătățit...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppTheme.surfaceVariant,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppTheme.warningColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Feedback-ului tău autentic ajută alți clienți să aleagă meșteri buni.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    final availableTags = [
      'calitate excelentă',
      'punctualitate',
      'comunicare bună',
      'lucru curat',
      'preț corect',
      'profesionalism',
      'recomand',
      'întârziere',
      'probleme de comunicare',
      'necurat',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Etichete Relevante',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            return InkWell(
              onTap: () => setState(() {
                if (isSelected) {
                  _selectedTags.remove(tag);
                } else {
                  _selectedTags.add(tag);
                }
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.outlineColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.onSurfaceSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Selected tags display
        if (_selectedTags.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Etichete Selectate:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  children: _selectedTags
                      .map(
                        (tag) => Text(
                          tag,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.successColor),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confidențialitate și Publicare',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          SwitchListTile(
            title: const Text('Publicare Recenzie'),
            subtitle: const Text(
              'Alții vor vedea recenzia mea și vor ajuta prin alegerea meșterului',
            ),
            value: !_isAnonymous,
            onChanged: (value) => setState(() => _isAnonymous = !value),
            activeThumbColor: AppTheme.primaryColor,
          ),

          SwitchListTile(
            title: const Text('Anonim'),
            subtitle: const Text('Numele meu nu apare în recenzia publicată'),
            value: _isAnonymous,
            onChanged: (value) => setState(() => _isAnonymous = value),
            activeThumbColor: AppTheme.primaryColor,
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: AppTheme.successColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Toate recenziile sunt verificate manual înainte de publicare pentru autenticitate.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceSecondary,
                      height: 1.4,
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

  Widget _buildReviewCard(Review review, {bool showActions = true}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  review.craftsmanName[0],
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.projectTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_formatDate(review.createdAt)} • ${review.isPublic ? "Publicată" : "Privată"}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                children: [
                  Icon(
                    review.recommends
                        ? Icons.thumb_up_alt_rounded
                        : Icons.thumb_down_alt_rounded,
                    color: review.recommends
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    review.overallRating.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: review.overallRating >= 4.0
                          ? AppTheme.successColor
                          : review.overallRating >= 3.0
                          ? AppTheme.warningColor
                          : AppTheme.errorColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rating Details
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: review.dimensionRatings.entries.map((entry) {
              return Column(
                children: [
                  Text(
                    '${entry.key}: ${entry.value.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  SizedBox(
                    height: 4,
                    width: 50,
                    child: LinearProgressIndicator(
                      value: entry.value / 5,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Feedback Text
          Text(
            review.feedbackText,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),

          // Tags
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: review.tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],

          // Actions (only for user's own reviews)
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editReview(review),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Editează'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _deleteReview(review),
                  icon: const Icon(Icons.delete_rounded),
                  label: const Text('Șterge'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.errorColor,
                  ),
                ),
              ],
            ),
          ],

          // Craftsman response
          if (review.responseFromCraftsman != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.successColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        color: AppTheme.successColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Răspuns de la ${review.craftsmanName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.responseFromCraftsman!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // === MISSING WIDGET IMPLEMENTATIONS ===

  Widget _buildStatsOverview(ReviewStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  label: 'Medie Generală',
                  value: stats.averageRating.toStringAsFixed(1),
                  icon: Icons.star_rounded,
                  color: Colors.amber,
                ),
                _buildStatItem(
                  label: 'Total Recenzii',
                  value: '${stats.totalReviews}',
                  icon: Icons.receipt_long_rounded,
                  color: AppTheme.primaryColor,
                ),
                _buildStatItem(
                  label: 'Recomandare',
                  value:
                      '${stats.recommendationPercentage.toStringAsFixed(0)}%',
                  icon: Icons.thumb_up_alt_rounded,
                  color: AppTheme.successColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBreakdown(ReviewStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Împărțirea pe Stele',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildRatingBar(
              stars: 5,
              count: stats.fiveStarCount,
              total: stats.totalReviews,
            ),
            _buildRatingBar(
              stars: 4,
              count: stats.fourStarCount,
              total: stats.totalReviews,
            ),
            _buildRatingBar(
              stars: 3,
              count: stats.threeStarCount,
              total: stats.totalReviews,
            ),
            _buildRatingBar(
              stars: 2,
              count: stats.twoStarCount,
              total: stats.totalReviews,
            ),
            _buildRatingBar(
              stars: 1,
              count: stats.oneStarCount,
              total: stats.totalReviews,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionPerformance(ReviewStats stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performanță după Criterii',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...stats.dimensionAverages.entries.map(
              (entry) => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_translateDimensionKey(entry.key)),
                      Text(entry.value.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: entry.value / 5,
                    backgroundColor: AppTheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackInsights() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tendințe în Feedback',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildCommonTags(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyReviewsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: AppTheme.onSurfaceSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Nu ai recenzii încă',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scrie prima ta recenzie pentru a evalua serviciile primite',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(0),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Scrie o Recenzie'),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherReviewPlaceholder(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  '?',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recenzie ${index - 1}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Proiect recent completat',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Recenzia este în încărcare...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonTags() {
    final commonTags = [
      {'tag': 'Punctualitate', 'count': 12, 'percentage': 80},
      {'tag': 'Calitate Excelentă', 'count': 10, 'percentage': 67},
      {'tag': 'Comunicare Bună', 'count': 8, 'percentage': 53},
      {'tag': 'Preț Corect', 'count': 6, 'percentage': 40},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: commonTags
          .map(
            (item) => Chip(
              label: Text('${item['tag']} (${item['percentage']}%)'),
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              labelStyle: TextStyle(color: AppTheme.primaryColor),
            ),
          )
          .toList(),
    );
  }

  // === HELPER WIDGETS ===

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
        ),
      ],
    );
  }

  Widget _buildRatingBar({
    required int stars,
    required int count,
    required int total,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Row(
            children: List.generate(
              stars,
              (index) => const Icon(Icons.star, size: 16, color: Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              backgroundColor: AppTheme.surfaceVariant,
              valueColor: const AlwaysStoppedAnimation(Colors.amber),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _deleteReview(Review review) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ștergerea recenzie pentru ${review.projectTitle} în curând...',
        ),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajutor Recenzii'),
        content: const Text(
          '● Scrie recenzii pentru proiecte completate\n'
          '● Evaluări anonime sunt disponibile\n'
          '● Recenziile sunt verificate manual\n'
          '● Recomandamentele ajută alți clienți\n'
          '● Poți edita sau șterge recenziile tale',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Înțeleg'),
          ),
        ],
      ),
    );
  }

  void _createReview() {
    // Validate required fields
    if (_overallRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te rugăm să adaugi o evaluare generală')),
      );
      return;
    }

    if (_feedbackController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te rugăm să adaugi un feedback scris')),
      );
      return;
    }

    // Here you would typically send data to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recenzia a fost trimisă cu succes!')),
    );

    // Reset form
    setState(() {
      _overallRating = 0.0;
      _dimensionRatings.updateAll((key, value) => 0.0);
      _recommendCraftsman = false;
      _selectedTags.clear();
      _isAnonymous = false;
    });
    _feedbackController.clear();

    // Switch to My Reviews tab
    _tabController.animateTo(1);
  }

  void _selectCompletedProject() {
    // Mock project selection - in real app this would show project picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Selectarea proiectelor în curând...')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Astăzi';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return 'Acum ${difference.inDays} zile';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  Future<void> _refreshMyReviews() async {
    // Mock refresh - in real app this would reload data
    await Future.delayed(const Duration(seconds: 2));
    // No need for setState since we're not changing any mock data
  }

  Future<void> _refreshOtherReviews() async {
    // Mock refresh
    await Future.delayed(const Duration(seconds: 2));
  }

  ReviewStats _calculateReviewStats() {
    final reviews = mockReviews;
    final totalReviews = reviews.length;

    double totalRating = 0.0;
    int fiveStarCount = 0,
        fourStarCount = 0,
        threeStarCount = 0,
        twoStarCount = 0,
        oneStarCount = 0;
    int recommendationCount = 0;

    final dimensionTotals = <String, double>{
      'quality': 0.0,
      'timeliness': 0.0,
      'professionalism': 0.0,
      'communication': 0.0,
    };

    for (final review in reviews) {
      totalRating += review.overallRating;

      if (review.overallRating >= 4.5) {
        fiveStarCount++;
      } else if (review.overallRating >= 3.5) {
        fourStarCount++;
      } else if (review.overallRating >= 2.5) {
        threeStarCount++;
      } else if (review.overallRating >= 1.5) {
        twoStarCount++;
      } else {
        oneStarCount++;
      }

      if (review.recommends) recommendationCount++;

      review.dimensionRatings.forEach((key, value) {
        dimensionTotals[key] = (dimensionTotals[key] ?? 0.0) + value;
      });
    }

    return ReviewStats(
      averageRating: totalReviews > 0 ? totalRating / totalReviews : 0.0,
      totalReviews: totalReviews,
      fiveStarCount: fiveStarCount,
      fourStarCount: fourStarCount,
      threeStarCount: threeStarCount,
      twoStarCount: twoStarCount,
      oneStarCount: oneStarCount,
      recommendationPercentage: totalReviews > 0
          ? (recommendationCount / totalReviews) * 100
          : 0.0,
      dimensionAverages: dimensionTotals.map(
        (key, total) =>
            MapEntry(key, totalReviews > 0 ? total / totalReviews : 0.0),
      ),
    );
  }

  String _translateDimensionKey(String key) {
    switch (key) {
      case 'quality':
        return 'Calitatea Execuției';
      case 'timeliness':
        return 'Punctualitate';
      case 'professionalism':
        return 'Profesionalism';
      case 'communication':
        return 'Comunicare';
      default:
        return key;
    }
  }

  void _editReview(Review review) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Editarea recenzie pentru ${review.projectTitle} în curând...',
        ),
      ),
    );
  }
}

// === CUSTOM WIDGETS (MOVED OUTSIDE CLASS) ===

// Rating Selector Widget - Moved to top level
class _RatingSelector extends StatefulWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final String? title;
  final double? maxRating;

  const _RatingSelector({
    required this.rating,
    required this.onRatingChanged,
    this.title,
    this.maxRating = 5.0,
  });

  @override
  State<_RatingSelector> createState() => _RatingSelectorState();
}

class _RatingSelectorState extends State<_RatingSelector> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: List.generate(5, (index) {
            final starRating = index + 1.0;
            return IconButton(
              onPressed: () {
                setState(() => _currentRating = starRating);
                widget.onRatingChanged(starRating);
              },
              icon: Icon(
                _currentRating >= starRating
                    ? Icons.star_rounded
                    : _currentRating >= starRating - 0.5
                    ? Icons.star_half_rounded
                    : Icons.star_border_rounded,
                color: Colors.amber,
                size: 32,
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          '${_currentRating.toStringAsFixed(1)} din ${widget.maxRating}',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
        ),
      ],
    );
  }
}
