import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:app_client/src/core/models/service_insight_models.dart';
import 'package:app_client/src/core/models/job_models.dart';
import 'package:app_client/src/core/theme/app_theme.dart';
import 'package:app_client/src/features/home/application/service_discovery_controller.dart';

class ServiceDiscoveryScreen extends StatefulWidget {
  final String? category;

  const ServiceDiscoveryScreen({super.key, this.category});

  @override
  State<ServiceDiscoveryScreen> createState() => _ServiceDiscoveryScreenState();
}

class _ServiceDiscoveryScreenState extends State<ServiceDiscoveryScreen> {
  static const List<List<Color>> _cardGradients = [
    [Color(0xFF4C6EF5), Color(0xFF364FC7)],
    [Color(0xFF5E60CE), Color(0xFF4A4EAF)],
    [Color(0xFF00B4D8), Color(0xFF0077B6)],
    [Color(0xFFFF7F50), Color(0xFFFF5A36)],
    [Color(0xFF2EC4B6), Color(0xFF0B7285)],
  ];

  late final ServiceDiscoveryController _controller;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _controller = ServiceDiscoveryController();
    _controller.setAnalyticsHandler((event, payload) {
      if (kDebugMode) {
        debugPrint('[ServiceDiscoveryScreen] $event -> $payload');
      }
    });
    _pageController = PageController(viewportFraction: 0.86);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.initialize(initialCategoryId: widget.category);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _refreshInsights() async {
    final activeCategory =
        _controller.currentInsight?.categoryId ?? widget.category;
    await _controller.loadInsights(categoryId: activeCategory, forceRefresh: true);
  }

  void _handleReaction(
    ServiceDiscoveryController controller,
    ServiceInsightReaction reaction,
  ) {
    final insight = controller.currentInsight;
    if (insight == null) return;
    controller.recordReaction(insight.categoryId, reaction);
    HapticFeedback.selectionClick();

    if (reaction == ServiceInsightReaction.skip &&
        controller.currentIndex < controller.insights.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ServiceDiscoveryController>(
        builder: (context, controller, child) {
          _syncPageWithController(controller);

          return Scaffold(
            backgroundColor: AppTheme.surfaceColor,
            appBar: _buildAppBar(controller),
            body: RefreshIndicator(
              onRefresh: _refreshInsights,
              color: AppTheme.primaryColor,
              child: _buildBody(context, controller),
            ),
          );
        },
      ),
    );
  }

  void _syncPageWithController(ServiceDiscoveryController controller) {
    if (!_pageController.hasClients) return;
    final page = _pageController.page ?? _pageController.initialPage.toDouble();
    final target = controller.currentIndex.toDouble();
    if ((page - target).abs() < 0.01) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pageController.hasClients) return;
      _pageController.animateToPage(
        controller.currentIndex,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    });
  }

  PreferredSizeWidget _buildAppBar(ServiceDiscoveryController controller) {
    final theme = Theme.of(context);
    final activeInsight = controller.currentInsight;
    return AppBar(
      backgroundColor: AppTheme.surfaceColor,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Descopera servicii',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          if (activeInsight != null)
            Text(
              'Recomandari pentru ${activeInsight.categoryName.toLowerCase()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Actualizeaza',
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshInsights(),
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    ServiceDiscoveryController controller,
  ) {
    final insights = controller.insights;

    if (controller.isLoading && insights.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 200),
          Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (insights.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        children: [_EmptyState(onRetry: _refreshInsights)],
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      children: [
        if (controller.hasError && controller.error != null)
          _ErrorBanner(
            message: controller.error!,
            onDismiss: controller.clearError,
          ),
        const SizedBox(height: 12),
        _buildInsightCarousel(controller, insights),
        const SizedBox(height: 24),
        _buildActionRow(controller),
        const SizedBox(height: 32),
        _buildHighlights(controller),
        const SizedBox(height: 32),
        _buildCraftsmenStrip(controller),
      ],
    );
  }

  Widget _buildInsightCarousel(
    ServiceDiscoveryController controller,
    List<ServiceInsight> insights,
  ) {
    return Column(
      children: [
        SizedBox(
          height: 360,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: controller.setCurrentIndex,
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              final gradient = _cardGradients[index % _cardGradients.length];
              final isActive = index == controller.currentIndex;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _ServiceInsightCard(
                  insight: insight,
                  gradient: gradient,
                  isActive: isActive,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _CarouselIndicator(
          length: insights.length,
          activeIndex: controller.currentIndex,
        ),
      ],
    );
  }

  Widget _buildActionRow(ServiceDiscoveryController controller) {
    final currentInsight = controller.currentInsight;
    final isLiked =
        currentInsight != null && controller.isLiked(currentInsight.categoryId);
    final isSkipped =
        currentInsight != null &&
        controller.isSkipped(currentInsight.categoryId);

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: currentInsight == null
                ? null
                : () =>
                      _handleReaction(controller, ServiceInsightReaction.skip),
            icon: Icon(
              Icons.close,
              color: isSkipped
                  ? AppTheme.errorColor
                  : AppTheme.onSurfaceSecondary,
            ),
            label: Text(
              isSkipped ? 'Marcat ca in asteptare' : 'Vezi alta categorie',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: currentInsight == null
                ? null
                : () =>
                      _handleReaction(controller, ServiceInsightReaction.like),
            icon: Icon(
              Icons.favorite,
              color: isLiked ? Colors.white : AppTheme.surfaceColor,
            ),
            label: Text(isLiked ? 'Preferat' : 'Pastreaza pentru mai tarziu'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHighlights(ServiceDiscoveryController controller) {
    final insight = controller.currentInsight;
    if (insight == null) return const SizedBox.shrink();

    final stats = <Widget>[];
    if (insight.averageBid != null) {
      stats.add(
        _InsightStatChip(
          icon: Icons.payments_outlined,
          title: 'Buget mediu',
          value: '${insight.averageBid!.round()} RON',
        ),
      );
    }
    if (insight.averageDurationDays != null) {
      stats.add(
        _InsightStatChip(
          icon: Icons.schedule,
          title: 'Durata medie',
          value: '${insight.averageDurationDays} zile',
        ),
      );
    }
    if (insight.satisfactionScore != null) {
      stats.add(
        _InsightStatChip(
          icon: Icons.star_rate_rounded,
          title: 'Satisfactie',
          value: insight.satisfactionScore!.toStringAsFixed(1),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date rapide din comunitate',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (stats.isEmpty)
          Text(
            'Actualizam indicatorii in functie de ofertele recente.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
          )
        else
          Wrap(spacing: 12, runSpacing: 12, children: stats),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              (insight.topSkills.isNotEmpty
                      ? insight.topSkills
                      : const ['Recomandat', 'Verificat', 'Popular'])
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                      backgroundColor: AppTheme.primaryUltraLowOpacity,
                      labelStyle: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(
                            color: AppTheme.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildCraftsmenStrip(ServiceDiscoveryController controller) {
    final insight = controller.currentInsight;
    if (insight == null || insight.topCraftsmen.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mesteri recomandati',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            'Salveaza categoria pentru a primi recomandari personalizate in pagina proiectelor.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mesteri recomandati',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: insight.topCraftsmen.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final craftsman = insight.topCraftsmen[index];
              return _CraftsmanBadge(craftsman: craftsman);
            },
          ),
        ),
      ],
    );
  }
}

class _ServiceInsightCard extends StatelessWidget {
  final ServiceInsight insight;
  final List<Color> gradient;
  final bool isActive;

  const _ServiceInsightCard({
    required this.insight,
    required this.gradient,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradient.last.withValues(alpha: isActive ? 0.28 : 0.18),
            blurRadius: isActive ? 28 : 16,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      insight.categoryName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      insight.summary ??
                          'Vezi proiecte reale si oferte verificate din aceasta categorie.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.auto_awesome, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (insight.gallery.isNotEmpty)
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: insight.gallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final url = insight.gallery[index];
                  return Container(
                    width: 86,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      ),
                    ),
                  );
                },
              ),
            )
          else
            _InsightPlaceholderStrip(),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.explore, color: Colors.white.withValues(alpha: 0.82)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  insight.topSkills.isNotEmpty
                      ? 'Top abilitati: ${insight.topSkills.take(3).join(', ')}'
                      : 'Categoria preferata de clientii nostri in ultimele 30 de zile.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightPlaceholderStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              'Incarcam galerii reale pe masura ce se conecteaza mesterii.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ),
        ),
      ],
    );
  }
}

class _CarouselIndicator extends StatelessWidget {
  final int length;
  final int activeIndex;

  const _CarouselIndicator({required this.length, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primaryColor
                : AppTheme.primaryLowOpacity,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

class _InsightStatChip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InsightStatChip({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryUltraLowOpacity,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryLowOpacity),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryDark),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurfaceColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CraftsmanBadge extends StatelessWidget {
  final Craftsman craftsman;

  const _CraftsmanBadge({required this.craftsman});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryLowOpacity,
                child: Text(
                  craftsman.name.isNotEmpty
                      ? craftsman.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      craftsman.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: AppTheme.primaryDark,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          craftsman.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${craftsman.completedProjects} proiecte finalizate',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.warningLowOpacity,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.warningColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
            tooltip: 'Ascunde',
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _EmptyState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.search_off,
          size: 56,
          color: AppTheme.onSurfaceSecondary,
        ),
        const SizedBox(height: 16),
        Text(
          'Nu avem inca suficiente date pentru aceasta categorie.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        OutlinedButton(onPressed: onRetry, child: const Text('Reincarca')),
      ],
    );
  }
}
