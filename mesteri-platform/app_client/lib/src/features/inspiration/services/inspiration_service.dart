import 'package:dio/dio.dart';
import '../models/inspiration_post.dart';

class InspirationService {
  final Dio _dio;
  final String baseUrl;

  InspirationService({
    Dio? dio,
    this.baseUrl = 'http://localhost:3000/api',
  }) : _dio = dio ?? Dio();

  /// Get inspiration feed (TikTok-style)
  Future<List<InspirationPost>> getFeed({
    int page = 1,
    int limit = 20,
    String? userId,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/inspiration/feed',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (userId != null) 'userId': userId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final posts = (data['posts'] as List)
            .map((json) => InspirationPost.fromJson(json))
            .toList();
        return posts;
      }
      return [];
    } catch (e) {
      print('Error fetching inspiration feed: $e');
      return _getMockFeed(); // Return mock data for development
    }
  }

  /// Get posts by craftsman
  Future<List<InspirationPost>> getPostsByCraftsman(String craftsmanId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/inspiration',
        queryParameters: {
          'craftsmanId': craftsmanId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final posts = (data['posts'] as List)
            .map((json) => InspirationPost.fromJson(json))
            .toList();
        return posts;
      }
      return [];
    } catch (e) {
      print('Error fetching craftsman posts: $e');
      return [];
    }
  }

  /// Like a post
  Future<bool> likePost(String postId) async {
    try {
      final response = await _dio.post('$baseUrl/inspiration/$postId/like');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error liking post: $e');
      return false;
    }
  }

  /// Share a post
  Future<bool> sharePost(String postId) async {
    try {
      final response = await _dio.post('$baseUrl/inspiration/$postId/share');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error sharing post: $e');
      return false;
    }
  }

  /// Mock data for development (when backend is not available)
  List<InspirationPost> _getMockFeed() {
    return [
      InspirationPost(
        id: '1',
        craftsmanId: 'craftsman-1',
        title: 'Renovare baie completă - Sector 3',
        description:
            'Transformare totală baie veche. Montaj gresie mare format, instalații sanitare noi, cabină dus walk-in. Materiale premium, finisaje impecabile. Durată: 7 zile.',
        beforePhoto: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800',
        afterPhoto: 'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=800',
        additionalPhotos: [
          'https://images.unsplash.com/photo-1620626011761-996317b8d101?w=800',
          'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800',
        ],
        skillsShowcased: ['Instalații sanitare', 'Montaj gresie', 'Cabină dus'],
        category: 'INSTALATII_SANITARE',
        location: 'Str. Vitan 45, București',
        city: 'București',
        likes: 142,
        views: 2341,
        shares: 23,
        craftsman: CraftsmanInfo(
          id: 'craftsman-1',
          fullName: 'Ion Popescu',
          profilePicture: 'https://i.pravatar.cc/300?img=33',
          averageRating: 4.9,
          totalReviews: 127,
          isVerified: true,
          city: 'București',
          yearsExperience: 15,
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
      InspirationPost(
        id: '2',
        craftsmanId: 'craftsman-2',
        title: 'Tablou electric modern - casă 200mp',
        description:
            'Tablou electric ABB complet automatizat cu protecții diferențiale pe fiecare circuit. Etichetare profesională, organizare impecabilă.',
        afterPhoto: 'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=800',
        additionalPhotos: [
          'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=800',
        ],
        skillsShowcased: ['Tablouri electrice', 'Instalații electrice'],
        location: 'Pipera, București',
        city: 'București',
        likes: 234,
        views: 3892,
        shares: 45,
        isPromoted: true,
        craftsman: CraftsmanInfo(
          id: 'craftsman-2',
          fullName: 'Vasile Ionescu',
          profilePicture: 'https://i.pravatar.cc/300?img=52',
          averageRating: 4.8,
          totalReviews: 98,
          isVerified: true,
          city: 'București',
          yearsExperience: 12,
        ),
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      InspirationPost(
        id: '3',
        craftsmanId: 'craftsman-3',
        title: 'Casă nouă 180mp - de la fundație la acoperiș',
        description:
            'Construcție completă casă pe structură BCA + cărămidă. Fundații, zidărie, acoperiș țiglă. Execuție 6 luni. Garanție 10 ani structură!',
        beforePhoto: 'https://images.unsplash.com/photo-1590486803833-1c5dc8ddd4c8?w=800',
        afterPhoto: 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
        additionalPhotos: [
          'https://images.unsplash.com/photo-1503594384566-461fe158e797?w=800',
          'https://images.unsplash.com/photo-1599809275671-b5942cabc7a2?w=800',
        ],
        skillsShowcased: ['Construcții', 'Zidărie', 'Fundații'],
        category: 'CONSTRUCTII',
        location: 'Florești, Cluj',
        city: 'Cluj-Napoca',
        likes: 567,
        views: 8934,
        shares: 123,
        craftsman: CraftsmanInfo(
          id: 'craftsman-3',
          fullName: 'Gheorghe Dumitrescu',
          profilePicture: 'https://i.pravatar.cc/300?img=60',
          averageRating: 4.95,
          totalReviews: 156,
          isVerified: true,
          city: 'Cluj-Napoca',
          yearsExperience: 20,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
