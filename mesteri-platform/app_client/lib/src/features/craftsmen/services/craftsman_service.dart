import 'package:dio/dio.dart';
import '../models/craftsman.dart';

class CraftsmanService {
  final Dio _dio;
  final String baseUrl;

  CraftsmanService({
    Dio? dio,
    this.baseUrl = 'http://localhost:3000/api',
  }) : _dio = dio ?? Dio();

  /// Get all craftsmen
  Future<List<Craftsman>> getAllCraftsmen({
    String? specialty,
    bool? isVerified,
    double? minRating,
    String? city,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/users/craftsmen',
        queryParameters: {
          if (specialty != null) 'specialty': specialty,
          if (isVerified != null) 'isVerified': isVerified.toString(),
          if (minRating != null) 'minRating': minRating.toString(),
          if (city != null) 'city': city,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final craftsmen = (data['craftsmen'] as List)
            .map((json) => Craftsman.fromJson(json))
            .toList();
        return craftsmen;
      }
      return [];
    } catch (e) {
      print('Error fetching craftsmen: $e');
      return _getMockCraftsmen();
    }
  }

  /// Get craftsman by ID
  Future<Craftsman?> getCraftsmanById(String id) async {
    try {
      final response = await _dio.get('$baseUrl/users/craftsmen/$id');
      
      if (response.statusCode == 200) {
        return Craftsman.fromJson(response.data);
      }
      return null;
    } catch (e) {
      print('Error fetching craftsman: $e');
      return _getMockCraftsmen().firstOrNull;
    }
  }

  /// Get craftsman portfolio
  Future<Map<String, dynamic>?> getCraftsmanPortfolio(String id) async {
    try {
      final response = await _dio.get('$baseUrl/users/craftsmen/$id/portfolio');
      
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error fetching portfolio: $e');
      return null;
    }
  }

  /// Search craftsmen
  Future<List<Craftsman>> searchCraftsmen(String query) async {
    try {
      final response = await _dio.get(
        '$baseUrl/users/search',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final craftsmen = (data['users'] as List)
            .where((json) => json['role'] == 'CRAFTSMAN')
            .map((json) => Craftsman.fromJson(json))
            .toList();
        return craftsmen;
      }
      return [];
    } catch (e) {
      print('Error searching craftsmen: $e');
      return [];
    }
  }

  /// Mock data for development
  List<Craftsman> _getMockCraftsmen() {
    return [
      Craftsman(
        id: 'craftsman-1',
        email: 'ion.popescu@mesteri.ro',
        fullName: 'Ion Popescu',
        city: 'București',
        county: 'București',
        phone: '+40 724 111 222',
        profilePicture: 'https://i.pravatar.cc/300?img=33',
        bio: 'Meșter cu experiență în instalații sanitare. Lucrări garantate și materiale de calitate. Intervenții rapide în București și Ilfov.',
        yearsExperience: 15,
        portfolioPhotos: [
          'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?w=800',
          'https://images.unsplash.com/photo-1620626011761-996317b8d101?w=800',
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=800',
          'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=800',
          'https://images.unsplash.com/photo-1604014237800-1c9102c219da?w=800',
          'https://images.unsplash.com/photo-1563298723-dcfebaa392e3?w=800',
        ],
        skillsTags: ['Instalații sanitare', 'Reparații robinete', 'Montaj centrale', 'Canalizări'],
        certifications: ['Autorizație ANRE', 'Certificat instalator gaze'],
        insuranceVerified: true,
        isVerified: true,
        averageRating: 4.9,
        totalReviews: 127,
        specialties: ['instalații sanitare', 'centrale termice'],
        availability: 'Disponibil din 28 octombrie',
        createdAt: DateTime.now().subtract(const Duration(days: 365 * 15)),
      ),
      Craftsman(
        id: 'craftsman-2',
        email: 'vasile.ionescu@mesteri.ro',
        fullName: 'Vasile Ionescu',
        city: 'București',
        county: 'București',
        phone: '+40 725 333 444',
        profilePicture: 'https://i.pravatar.cc/300?img=52',
        bio: 'Electrician autorizat ANRE. Instalații electrice rezidențiale și comerciale. Montaj panouri fotovoltaice.',
        yearsExperience: 12,
        portfolioPhotos: [
          'https://images.unsplash.com/photo-1621905251918-48416bd8575a?w=800',
          'https://images.unsplash.com/photo-1473341304170-971dccb5ac1e?w=800',
          'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=800',
          'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=800',
        ],
        skillsTags: ['Instalații electrice', 'Tablouri electrice', 'Iluminat LED', 'Panouri fotovoltaice'],
        certifications: ['Autorizație ANRE electrician', 'Curs instalator fotovoltaic'],
        insuranceVerified: true,
        isVerified: true,
        averageRating: 4.8,
        totalReviews: 98,
        specialties: ['instalații electrice', 'automatizări'],
        availability: 'Disponibil acum',
        createdAt: DateTime.now().subtract(const Duration(days: 365 * 12)),
      ),
      Craftsman(
        id: 'craftsman-3',
        email: 'gheorghe.dumitrescu@mesteri.ro',
        fullName: 'Gheorghe Dumitrescu',
        city: 'Cluj-Napoca',
        county: 'Cluj',
        phone: '+40 726 555 666',
        profilePicture: 'https://i.pravatar.cc/300?img=60',
        bio: 'Constructor cu peste 20 de ani experiență. Specialitate: structuri, zidărie, renovări complete. Echipă proprie.',
        yearsExperience: 20,
        portfolioPhotos: [
          'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=800',
          'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=800',
          'https://images.unsplash.com/photo-1503387762-592deb58ef4e?w=800',
          'https://images.unsplash.com/photo-1590486803833-1c5dc8ddd4c8?w=800',
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
        ],
        skillsTags: ['Construcții', 'Zidărie', 'Renovări', 'Structuri beton'],
        certifications: ['Autorizație constructor', 'ISCIR'],
        insuranceVerified: true,
        isVerified: true,
        averageRating: 4.95,
        totalReviews: 156,
        specialties: ['construcții', 'renovări'],
        availability: 'Disponibil din noiembrie',
        createdAt: DateTime.now().subtract(const Duration(days: 365 * 20)),
      ),
    ];
  }
}
