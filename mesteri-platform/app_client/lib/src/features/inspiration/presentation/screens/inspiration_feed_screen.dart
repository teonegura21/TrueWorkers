import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/inspiration_post.dart';
import '../../services/inspiration_service.dart';
import '../../widgets/tiktok_video_player.dart';

class InspirationFeedScreen extends StatefulWidget {
  const InspirationFeedScreen({super.key});

  @override
  State<InspirationFeedScreen> createState() => _InspirationFeedScreenState();
}

class _InspirationFeedScreenState extends State<InspirationFeedScreen> {
  final PageController _pageController = PageController();
  final InspirationService _service = InspirationService();
  List<InspirationPost> _posts = [];
  bool _isLoading = true;
  String? _error;
  // Store the playing state for each video
  final Map<int, bool> _playingStates = {};

  @override
  void initState() {
    super.initState();
    _loadFeed();
    // Listen to page changes to handle video playback
    _pageController.addListener(_onPageChanged);
  }

  Future<void> _loadFeed() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await _service.getFeed();

      if (!mounted) return;

      setState(() {
        _posts = posts;
        _isLoading = false;
        _error = null;
        // Initialize all videos as not playing initially
        for (int i = 0; i < _posts.length; i++) {
          _playingStates[i] = false;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onPageChanged() {
    // Determine which page is mostly visible
    final page = _pageController.page ?? 0;
    final currentPageIndex = page.round();
    
    // Pause videos that are not visible and play the current one
    for (int i = 0; i < _posts.length; i++) {
      if (i == currentPageIndex) {
        // Current video should play if it's a video post
        setState(() {
          _playingStates[i] = _posts[i].videoUrl != null && _posts[i].videoUrl!.isNotEmpty;
        });
      } else {
        // Other videos should pause
        setState(() {
          _playingStates[i] = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Show error state
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Eroare la încărcare',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadFeed,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Încearcă din nou'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show empty state
    if (_posts.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.photo_library_outlined, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              const Text(
                'Nu există postări încă',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Verifică mai târziu pentru inspirație nouă',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadFeed,
                icon: const Icon(Icons.refresh),
                label: const Text('Reîncarcă'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Inspirație',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: _posts.length,
        onPageChanged: (index) {
          // Handle page change if needed, but don't set unused field
        },
        itemBuilder: (context, index) {
          return _buildPostCard(_posts[index], index);
        },
      ),
    );
  }

  Widget _buildPostCard(InspirationPost post, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background based on media type (video or image)
        post.videoUrl != null && post.videoUrl!.isNotEmpty
            ? TikTokVideoPlayer(
                post: post,
                isPlaying: _playingStates[index] ?? false,
                onPlayStateChanged: (isPlaying) {
                  setState(() {
                    _playingStates[index] = isPlaying;
                  });
                },
              )
            : CachedNetworkImage(
                imageUrl: post.afterPhoto,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[900],
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, size: 64, color: Colors.white54),
                ),
              ),

        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.8),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),

        // Content overlay
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                // Craftsman info
                _buildCraftsmanInfo(post),
                const SizedBox(height: 12),

                // Title and description
                Text(
                  post.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  post.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Skills tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: post.skillsShowcased.take(3).map((skill) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        skill,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white70, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      post.city,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Right side interaction buttons
        Positioned(
          right: 12,
          bottom: 100,
          child: Column(
            children: [
              _buildActionButton(
                icon: Icons.favorite_border,
                label: _formatCount(post.likes),
                onTap: () => _handleLike(post),
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                icon: Icons.visibility_outlined,
                label: _formatCount(post.views),
                onTap: () {},
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                icon: Icons.share_outlined,
                label: _formatCount(post.shares),
                onTap: () => _handleShare(post),
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                icon: Icons.more_horiz,
                label: '',
                onTap: () => _showPostOptions(post),
              ),
            ],
          ),
        ),

        // Promoted badge
        if (post.isPromoted)
          Positioned(
            top: 60,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, size: 14, color: Colors.black),
                  SizedBox(width: 4),
                  Text(
                    'Promovat',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCraftsmanInfo(InspirationPost post) {
    return GestureDetector(
      onTap: () => _navigateToCraftsmanProfile(post.craftsmanId),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            backgroundImage: post.craftsman.profilePicture != null
                ? CachedNetworkImageProvider(post.craftsman.profilePicture!)
                : null,
            child: post.craftsman.profilePicture == null
                ? Text(
                    post.craftsman.fullName[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      post.craftsman.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (post.craftsman.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${post.craftsman.averageRating.toStringAsFixed(1)} (${post.craftsman.totalReviews})',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Contact',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Future<void> _handleLike(InspirationPost post) async {
    await _service.likePost(post.id);
    // Update local state optimistically
    setState(() {
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        // Create a new post with updated likes
        // Note: In a real app, you'd use a state management solution
      }
    });
  }

  Future<void> _handleShare(InspirationPost post) async {
    await _service.sharePost(post.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link copiat!')),
      );
    }
  }

  void _showPostOptions(InspirationPost post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person, color: Colors.white),
                title: const Text('Vezi profilul', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToCraftsmanProfile(post.craftsmanId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.white),
                title: const Text('Distribuie', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _handleShare(post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.report_outlined, color: Colors.red),
                title: const Text('Raportează', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _navigateToCraftsmanProfile(String craftsmanId) {
    // Navigate to craftsman profile screen
    // Navigator.push(...);
    print('Navigate to craftsman: $craftsmanId');
  }
}
