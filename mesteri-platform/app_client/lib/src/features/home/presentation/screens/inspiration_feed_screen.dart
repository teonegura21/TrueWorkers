import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_client/src/core/models/job_models.dart';
import 'package:app_client/src/core/services/jobs_api_service.dart';
import 'package:app_client/src/core/theme/app_theme.dart';

class InspirationFeedScreen extends StatefulWidget {
  const InspirationFeedScreen({super.key});

  @override
  State<InspirationFeedScreen> createState() => _InspirationFeedScreenState();
}

class _InspirationFeedScreenState extends State<InspirationFeedScreen> {
  static const _feedCacheKey = 'inspiration_feed_cache_v1';

  final JobsApiService _jobsApi = JobsApiService();
  final PageController _feedController = PageController();

  List<_MarketingJob> _feedItems = [];
  bool _loadingFeed = true;
  String? _feedError;
  int _activeFeedIndex = 0;
  final Set<String> _likedJobs = <String>{};
  final Map<String, int> _likeCounts = <String, int>{};
  final Map<String, List<String>> _comments = <String, List<String>>{};

  @override
  void initState() {
    super.initState();
    _bootstrapFeed();
  }

  @override
  void dispose() {
    _feedController.dispose();
    super.dispose();
  }

  Future<void> _bootstrapFeed({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      if (forceRefresh) {
        _loadingFeed = true;
      }
      _feedError = null;
    });

    final prefs = await SharedPreferences.getInstance();

    if (!forceRefresh && _feedItems.isEmpty) {
      final cached = prefs.getString(_feedCacheKey);
      if (cached != null) {
        final decoded = jsonDecode(cached) as List<dynamic>;
        final cachedItems =
            decoded
                .whereType<Map<String, dynamic>>()
                .map(_MarketingJob.fromCache)
                .where((item) => item.mediaUrls.isNotEmpty)
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (cachedItems.isNotEmpty) {
          _hydrateInteractions(cachedItems);
          setState(() {
            _feedItems = cachedItems;
            _loadingFeed = false;
          });
        }
      }
    }

    try {
      final jobs = await _jobsApi.getMarketingFeed(limit: 30);
      final mapped =
          jobs
              .map(_MarketingJob.fromJob)
              .where((item) => item.mediaUrls.isNotEmpty)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      if (mapped.isEmpty) {
        throw Exception(
          'Nu există lucrări cu galerie pregătite pentru promovare.',
        );
      }

      _hydrateInteractions(mapped);
      setState(() {
        _feedItems = mapped;
        _loadingFeed = false;
        _feedError = null;
        _activeFeedIndex = 0;
      });

      await prefs.setString(
        _feedCacheKey,
        jsonEncode(mapped.map((e) => e.toJson()).toList()),
      );
    } catch (error) {
      if (!mounted) return;
      if (_feedItems.isEmpty) {
        final fallback =
            _jobsApi
                .getMockJobs()
                .map(_MarketingJob.fromJob)
                .where((item) => item.mediaUrls.isNotEmpty)
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _hydrateInteractions(fallback);
        setState(() {
          _feedItems = fallback;
          _loadingFeed = false;
          _feedError = error.toString();
        });
      } else {
        setState(() {
          _feedError = error.toString();
        });
      }
    }
  }

  void _hydrateInteractions(List<_MarketingJob> jobs) {
    for (final job in jobs) {
      _likeCounts.putIfAbsent(job.id, () => 12 + (job.id.hashCode.abs() % 42));
      _comments.putIfAbsent(job.id, () => <String>[]);
    }
  }

  void _toggleLike(_MarketingJob job) {
    final jobId = job.id;
    final currentCount = _likeCounts[jobId] ?? 0;
    setState(() {
      if (_likedJobs.contains(jobId)) {
        _likedJobs.remove(jobId);
        _likeCounts[jobId] = currentCount > 0 ? currentCount - 1 : 0;
      } else {
        _likedJobs.add(jobId);
        _likeCounts[jobId] = currentCount + 1;
      }
    });
  }

  Future<void> _openComments(_MarketingJob job) async {
    final jobId = job.id;
    final entries = List<String>.from(_comments[jobId] ?? const <String>[]);
    final controller = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 4,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.outlineColor.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Comentarii',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppTheme.onSurfaceSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (entries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Fii primul care lasă un feedback pentru această lucrare.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    if (entries.isNotEmpty)
                      SizedBox(
                        height: 220,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          itemBuilder: (context, index) {
                            final comment = entries[index];
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppTheme.primaryLowOpacity,
                                  child: const Icon(
                                    Icons.person,
                                    size: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      comment,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemCount: entries.length,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (value) {
                                final trimmed = value.trim();
                                if (trimmed.isEmpty) return;
                                setModalState(() {
                                  entries.insert(0, trimmed);
                                });
                                controller.clear();
                              },
                              decoration: InputDecoration(
                                hintText: 'Scrie un comentariu empatic...',
                                filled: true,
                                fillColor: AppTheme.surfaceVariant,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () {
                              final trimmed = controller.text.trim();
                              if (trimmed.isEmpty) return;
                              setModalState(() {
                                entries.insert(0, trimmed);
                              });
                              controller.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(14),
                            ),
                            child: const Icon(Icons.send_rounded),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    controller.dispose();

    if (!mounted) return;
    setState(() {
      _comments[jobId] = entries;
    });
  }

  Future<void> _shareJob(_MarketingJob job) async {
    final link = 'https://trueworkers.app/lucrari/${job.id}';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link către lucrare copiat în clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Inspirație pentru tine',
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualizează feed-ul',
            onPressed: () => _bootstrapFeed(forceRefresh: true),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildFeedContent()),
          if (_feedError != null)
            Positioned(
              top: kToolbarHeight + 16,
              left: 16,
              right: 16,
              child: _FeedMessageBanner(message: _feedError!),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedContent() {
    if (_loadingFeed && _feedItems.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_feedItems.isEmpty) {
      return const Center(
        child: _FeedMessageCard(
          icon: Icons.bolt_outlined,
          message: 'Încă nu există lucrări promovate. Revino curând! ',
        ),
      );
    }

    return PageView.builder(
      controller: _feedController,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      onPageChanged: (index) => setState(() => _activeFeedIndex = index),
      itemCount: _feedItems.length,
      itemBuilder: (context, index) {
        final job = _feedItems[index];
        final likeCount = _likeCounts[job.id] ?? 0;
        final isLiked = _likedJobs.contains(job.id);
        final commentCount = _comments[job.id]?.length ?? 0;

        return _InspirationFeedCard(
          job: job,
          isActive: _activeFeedIndex == index,
          likeCount: likeCount,
          isLiked: isLiked,
          commentCount: commentCount,
          onLike: () => _toggleLike(job),
          onComment: () => _openComments(job),
          onShare: () => _shareJob(job),
        );
      },
    );
  }
}

class _FeedMessageBanner extends StatelessWidget {
  final String message;

  const _FeedMessageBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white70, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _InspirationFeedCard extends StatefulWidget {
  final _MarketingJob job;
  final bool isActive;
  final bool isLiked;
  final int likeCount;
  final int commentCount;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const _InspirationFeedCard({
    required this.job,
    required this.isActive,
    required this.isLiked,
    required this.likeCount,
    required this.commentCount,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  State<_InspirationFeedCard> createState() => _InspirationFeedCardState();
}

class _InspirationFeedCardState extends State<_InspirationFeedCard> {
  late final PageController _mediaController;
  int _mediaIndex = 0;

  @override
  void initState() {
    super.initState();
    _mediaController = PageController();
  }

  @override
  void dispose() {
    _mediaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final theme = Theme.of(context);

    return GestureDetector(
      onDoubleTap: widget.onLike,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _mediaController,
            itemCount: job.mediaUrls.length,
            onPageChanged: (index) => setState(() => _mediaIndex = index),
            itemBuilder: (context, index) {
              final imageUrl = job.mediaUrls[index];
              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.black26),
                errorWidget: (context, url, error) => Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white70,
                    size: 48,
                  ),
                ),
              );
            },
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: kToolbarHeight + 24,
            left: 20,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  job.category,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  job.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: kToolbarHeight + 32,
            right: 16,
            child: _MediaIndicator(
              current: _mediaIndex,
              total: job.mediaUrls.length,
            ),
          ),
          Positioned(
            right: 16,
            bottom: 140,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _VerticalActionButton(
                  icon: widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.isLiked ? Colors.pinkAccent : Colors.white,
                  label: widget.likeCount.toString(),
                  onTap: widget.onLike,
                ),
                const SizedBox(height: 18),
                _VerticalActionButton(
                  icon: Icons.mode_comment_outlined,
                  color: Colors.white,
                  label: widget.commentCount.toString(),
                  onTap: widget.onComment,
                ),
                const SizedBox(height: 18),
                _VerticalActionButton(
                  icon: Icons.share_outlined,
                  color: Colors.white,
                  label: 'Distribuie',
                  onTap: widget.onShare,
                ),
              ],
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 36,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  job.subtitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  job.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white24,
                      child: Text(
                        job.initials,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        job.clientLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaIndicator extends StatelessWidget {
  final int current;
  final int total;

  const _MediaIndicator({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    if (total <= 1) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${current + 1}/$total',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VerticalActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _VerticalActionButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Ink(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onTap,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: labelStyle),
      ],
    );
  }
}

class _FeedMessageCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _FeedMessageCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _MarketingJob {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final double budgetMin;
  final double budgetMax;
  final List<String> mediaUrls;
  final String? clientName;
  final DateTime createdAt;

  const _MarketingJob({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.budgetMin,
    required this.budgetMax,
    required this.mediaUrls,
    required this.clientName,
    required this.createdAt,
  });

  factory _MarketingJob.fromJob(Job job) {
    return _MarketingJob(
      id: job.id,
      title: job.title,
      description: job.description,
      location: job.location,
      category: job.category,
      budgetMin: job.budgetMin.toDouble(),
      budgetMax: job.budgetMax.toDouble(),
      mediaUrls: job.mediaUrls.isNotEmpty ? job.mediaUrls : const [],
      clientName: job.clientName,
      createdAt: job.createdAt,
    );
  }

  factory _MarketingJob.fromCache(Map<String, dynamic> json) {
    return _MarketingJob(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      budgetMin: (json['budgetMin'] as num?)?.toDouble() ?? 0,
      budgetMax: (json['budgetMax'] as num?)?.toDouble() ?? 0,
      mediaUrls: List<String>.from(json['mediaUrls'] ?? const []),
      clientName: json['clientName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'mediaUrls': mediaUrls,
      'clientName': clientName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get subtitle =>
      '$location • ${budgetMin.toStringAsFixed(0)} - ${budgetMax.toStringAsFixed(0)} RON';

  String get clientLabel => clientName != null && clientName!.isNotEmpty
      ? 'Client: $clientName'
      : 'Proiect publicat în platformă';

  String get initials => clientName != null && clientName!.isNotEmpty
      ? clientName!
            .split(' ')
            .where((element) => element.isNotEmpty)
            .map((e) => e[0].toUpperCase())
            .take(2)
            .join()
      : 'MK';
}

