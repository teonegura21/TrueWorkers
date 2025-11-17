// Comprehensive Service Ecosystem for Mesteri Platform
// Integrates all API operations with proper error handling and caching

import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../config/app_config.dart';

// Basic API Models - compatible with both frontend and backend
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'client' or 'craftsman'
  final String? profilePicture;
  final double rating;
  final int completedProjects;
  final bool isVerified;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profilePicture,
    required this.rating,
    this.completedProjects = 0,
    this.isVerified = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phoneNumber'] ?? '',
      role: json['role'] ?? 'client',
      profilePicture: json['profilePicture'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      completedProjects: json['completedProjects'] ?? 0,
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'profilePicture': profilePicture,
      'rating': rating,
      'completedProjects': completedProjects,
      'isVerified': isVerified,
    };
  }
}

class PlatformProject {
  final String id;
  final String title;
  final String description;
  final String status;
  final String? clientId;
  final String? clientName;
  final String? craftsmanId;
  final String? craftsmanName;
  final double budget;
  final String location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> attachments;
  final List<Map<String, dynamic>> milestones;

  const PlatformProject({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.clientId,
    this.clientName,
    this.craftsmanId,
    this.craftsmanName,
    required this.budget,
    required this.location,
    required this.createdAt,
    this.updatedAt,
    this.attachments = const [],
    this.milestones = const [],
  });

  factory PlatformProject.fromJson(Map<String, dynamic> json) {
    return PlatformProject(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'active',
      clientId: json['clientId'],
      clientName: json['clientName'],
      craftsmanId: json['craftsmanId'],
      craftsmanName: json['craftsmanName'],
      budget:
          (json['budget'] as num?)?.toDouble() ??
          (json['totalValue'] as num?)?.toDouble() ??
          0.0,
      location: json['location'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      attachments: json['attachments'] != null
          ? List<String>.from(json['attachments'])
          : [],
      milestones: json['milestones'] != null
          ? List<Map<String, dynamic>>.from(json['milestones'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'clientId': clientId,
      'clientName': clientName,
      'craftsmanId': craftsmanId,
      'craftsmanName': craftsmanName,
      'budget': budget,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'attachments': attachments,
      'milestones': milestones,
    };
  }
}

// Main Comprehensive Service
class MesteriService {
  static final MesteriService _instance = MesteriService._internal();
  final ApiClient _apiClient = ApiClient.instance;
  bool get useMockData => AppConfig.useMockData;

  factory MesteriService() => _instance;
  MesteriService._internal();

  // AUTH OPERATIONS
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return {
        'token': 'mock_jwt_token_12345',
        'user': {
          'id': 'user_123',
          'name': 'Maria Popescu',
          'email': email,
          'role': 'client',
          'rating': 4.5,
          'isVerified': true,
        },
      };
    }

    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    required String role,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return {
        'user': {
          'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'email': email,
          'phone': phone,
          'role': role,
          'rating': 0.0,
          'isVerified': false,
        },
      };
    }

    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Firebase user synchronization
  Future<Map<String, dynamic>> syncFirebaseUser(
    Map<String, dynamic> userData,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'success': true,
        'user': {
          'id': 'local_${userData['uid']}',
          'firebaseUid': userData['uid'],
          'email': userData['email'],
          'name': userData['name'],
          'role': userData['role'],
          'isVerified': false,
        },
      };
    }

    try {
      final response = await _apiClient.post(
        '/firebase-auth/sync-user',
        data: userData,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // JOBS OPERATIONS
  Future<List<Map<String, dynamic>>> getJobs({
    String? searchTerm,
    String? status,
    int page = 1,
    int limit = AppConfig.defaultPageSize,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _mockJobsData();
    }

    try {
      final response = await _apiClient.get(
        '/jobs',
        queryParameters: {
          if (searchTerm != null) 'search': searchTerm,
          if (status != null) 'status': status,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final raw = response.data;
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      } else if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final data = map['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
        return [map];
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> postJob(Map<String, dynamic> jobData) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 1500));
      return {
        'id': 'job_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        ...jobData,
      };
    }

    try {
      final response = await _apiClient.post('/jobs', data: jobData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PROJECTS OPERATIONS
  Future<List<Map<String, dynamic>>> getProjects({
    String? status,
    String? userId,
    int page = 1,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockProjectsData();
    }

    try {
      final response = await _apiClient.get(
        '/projects',
        queryParameters: {
          if (status != null) 'status': status,
          if (userId != null) 'userId': userId,
          'page': page.toString(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getProject(String projectId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockProjectDetail();
    }

    try {
      final response = await _apiClient.get('/projects/$projectId');
      final raw = response.data;
      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
      return {};
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getProjectMilestones(
    String projectId,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockMilestones();
    }

    try {
      final response = await _apiClient.get('/projects/$projectId/milestones');
      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateMilestone(
    String projectId,
    String milestoneId,
    Map<String, dynamic> updates,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return {
        'id': milestoneId,
        'status': 'completed',
        'updatedAt': DateTime.now().toIso8601String(),
        ...updates,
      };
    }

    try {
      final response = await _apiClient.put(
        '/projects/$projectId/milestones/$milestoneId',
        data: updates,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // MESSAGES OPERATIONS
  Future<List<Map<String, dynamic>>> getMessages({
    String? projectId,
    String? userId,
    int limit = 50,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _mockMessages();
    }

    try {
      final response = await _apiClient.get(
        '/messages',
        queryParameters: {
          if (projectId != null) 'projectId': projectId,
          if (userId != null) 'userId': userId,
          'limit': limit.toString(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String content,
    String? projectId,
    String? recipientId,
    List<String>? attachments,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'senderId': 'user_123',
        'projectId': projectId,
        'recipientId': recipientId,
        'attachments': attachments,
      };
    }

    try {
      final response = await _apiClient.post(
        '/messages',
        data: {
          'content': content,
          'projectId': projectId,
          'recipientId': recipientId,
          'attachments': attachments,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // REVIEWS OPERATIONS
  Future<List<Map<String, dynamic>>> getReviews({
    String? projectId,
    String? userId,
    String? participantType, // 'client' or 'craftsman'
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockReviews();
    }

    try {
      final response = await _apiClient.get(
        '/reviews',
        queryParameters: {
          if (projectId != null) 'projectId': projectId,
          if (userId != null) 'userId': userId,
          if (participantType != null) 'participantType': participantType,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitReview({
    required String projectId,
    required double rating,
    required String content,
    bool isPublic = false,
    Map<String, double>? dimensionRatings,
    List<String>? tags,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 1000));
      return {
        'id': 'review_${DateTime.now().millisecondsSinceEpoch}',
        'projectId': projectId,
        'rating': rating,
        'content': content,
        'isPublic': isPublic,
        'createdAt': DateTime.now().toIso8601String(),
      };
    }

    try {
      final response = await _apiClient.post(
        '/reviews',
        data: {
          'projectId': projectId,
          'rating': rating,
          'content': content,
          'isPublic': isPublic,
          'dimensionRatings': dimensionRatings,
          'tags': tags,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PAYMENTS OPERATIONS
  Future<List<Map<String, dynamic>>> getPayments({
    String? projectId,
    String? userId,
    String? status,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockPayments();
    }

    try {
      final response = await _apiClient.get(
        '/payments',
        queryParameters: {
          if (projectId != null) 'projectId': projectId,
          if (userId != null) 'userId': userId,
          if (status != null) 'status': status,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> processPayment({
    required String projectId,
    required double amount,
    String? milestoneId,
    String? description,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 2000));
      return {
        'id': 'payment_${DateTime.now().millisecondsSinceEpoch}',
        'projectId': projectId,
        'amount': amount,
        'milestoneId': milestoneId,
        'status': 'completed',
        'processedAt': DateTime.now().toIso8601String(),
      };
    }

    try {
      final response = await _apiClient.post(
        '/payments',
        data: {
          'projectId': projectId,
          'amount': amount,
          'milestoneId': milestoneId,
          'description': description,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // OFFERS OPERATIONS
  Future<List<Map<String, dynamic>>> getOffers({
    String? jobId,
    String? craftsmanId,
    String? status,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockOffers();
    }

    try {
      final response = await _apiClient.get(
        '/offers',
        queryParameters: {
          if (jobId != null) 'jobId': jobId,
          if (craftsmanId != null) 'craftsmanId': craftsmanId,
          if (status != null) 'status': status,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> submitOffer({
    required String jobId,
    required String craftsmanId,
    required double price,
    required String description,
    List<String>? attachments,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      return {
        'id': 'offer_${DateTime.now().millisecondsSinceEpoch}',
        'jobId': jobId,
        'craftsmanId': craftsmanId,
        'price': price,
        'description': description,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'attachments': attachments,
      };
    }

    try {
      final response = await _apiClient.post(
        '/offers',
        data: {
          'jobId': jobId,
          'craftsmanId': craftsmanId,
          'price': price,
          'description': description,
          'attachments': attachments,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateOfferStatus(
    String offerId,
    String status,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'id': offerId,
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      };
    }

    try {
      final response = await _apiClient.put(
        '/offers/$offerId/status',
        data: {'status': status},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // NOTIFICATIONS OPERATIONS
  Future<List<Map<String, dynamic>>> getNotifications({
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _mockNotifications();
    }

    try {
      final response = await _apiClient.get(
        '/notifications',
        queryParameters: {
          'unreadOnly': unreadOnly.toString(),
          'limit': limit.toString(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> markNotificationRead(String notificationId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 100));
      return;
    }

    try {
      await _apiClient.post('/notifications/$notificationId/read');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // VERIFICATION DOCUMENTS OPERATIONS
  Future<List<Map<String, dynamic>>> getVerificationDocuments({
    String? userId,
    String? documentType,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return _mockVerificationDocuments();
    }

    try {
      final response = await _apiClient.get(
        '/verifications',
        queryParameters: {
          if (userId != null) 'userId': userId,
          if (documentType != null) 'type': documentType,
        },
      );

      final data = response.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadVerificationDocument(
    String filePath,
    String fileName,
    String documentType,
    String? description,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 1500));
      return {
        'id': 'doc_${DateTime.now().millisecondsSinceEpoch}',
        'documentType': documentType,
        'fileName': fileName,
        'fileUrl': 'http://mock-storage-url/$fileName',
        'status': 'pending',
        'uploadedAt': DateTime.now().toIso8601String(),
        'description': description,
      };
    }

    try {
      final file = await MultipartFile.fromFile(filePath, filename: fileName);
      final formData = FormData.fromMap({
        'file': file,
        'documentType': documentType,
        'description': description,
      });

      final response = await _apiClient.post(
        '/verifications/upload',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // USER PROFILE OPERATIONS
  Future<UserProfile> getUserProfile(String userId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _mockUserProfile();
    }

    try {
      final response = await _apiClient.get('/users/$userId');
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserProfile> updateUserProfile(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 500));
      final currentProfile = _mockUserProfile();
      return currentProfile.copyWith(
        id: userId,
        name: updates['name'] as String? ?? currentProfile.name,
        phone: updates['phone'] as String? ?? currentProfile.phone,
      );
    }

    try {
      final response = await _apiClient.put('/users/$userId', data: updates);
      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ERROR HANDLING
  Exception _handleError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    switch (statusCode) {
      case 400:
        final message = data != null && data is Map
            ? data['message'] ?? 'Invalid request data'
            : 'Invalid request data';
        return Exception(message);

      case 401:
        return Exception('Authentication required. Please log in again.');

      case 403:
        return Exception('You do not have permission to perform this action.');

      case 404:
        return Exception('The requested resource was not found.');

      case 409:
        return Exception('A conflict occurred. Please try again.');

      case 422:
        return Exception('Validation error. Please check your input data.');

      case 500:
        return Exception('Server error. Please try again later.');

      default:
        return Exception(
          'Network error. Please check your connection and try again.',
        );
    }
  }

  // MOCK DATA METHODS
  UserProfile _mockUserProfile() => UserProfile(
    id: 'user_123',
    name: 'Maria Popescu',
    email: 'maria.popescu@example.com',
    phone: '+40 770 123 456',
    role: 'client',
    rating: 4.5,
    completedProjects: 12,
    isVerified: true,
  );

  List<Map<String, dynamic>> _mockJobsData() => [
    {
      'id': 'job_001',
      'title': 'Reparație robinet bucătărie',
      'description': 'Lucrări complete la robinetărie bucătărie',
      'location': 'București',
      'budget': 250.0,
      'status': 'pending',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    },
    {
      'id': 'job_002',
      'title': 'Montaj mobilier',
      'description': 'Montaj mobilier modular pentru bucătărie',
      'location': 'Cluj-Napoca',
      'budget': 1500.0,
      'status': 'offersReceived',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
    },
  ];

  List<Map<String, dynamic>> _mockProjectsData() => [
    {
      'id': 'proj_001',
      'title': 'Proiect Robinetărie',
      'description': 'Reparație completă sistem robinetărie',
      'status': 'inProgress',
      'budget': 850.0,
      'location': 'București',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 7))
          .toIso8601String(),
    },
  ];

  List<Map<String, dynamic>> _mockMessages() => [
    {
      'id': 'msg_001',
      'content': 'Lucrările sunt aproape terminate!',
      'senderId': 'craftsman_001',
      'senderName': 'Ion Dumitrescu',
      'timestamp': DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
    },
  ];

  List<Map<String, dynamic>> _mockReviews() => [
    {
      'id': 'review_001',
      'projectId': 'proj_001',
      'rating': 4.8,
      'content': 'Lucru excelent! Recomand cu căldură.',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 3))
          .toIso8601String(),
    },
  ];

  List<Map<String, dynamic>> _mockPayments() => [
    {
      'id': 'pay_001',
      'projectId': 'proj_001',
      'amount': 425.0,
      'status': 'completed',
      'processedAt': DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    },
  ];

  List<Map<String, dynamic>> _mockOffers() => [
    {
      'id': 'offer_001',
      'jobId': 'job_001',
      'craftsmanId': 'craftsman_001',
      'craftsmanName': 'Vasile Ionescu',
      'price': 450.0,
      'description': 'Pot veni săptămâna viitorară',
      'status': 'pending',
    },
  ];

  List<Map<String, dynamic>> _mockNotifications() => [
    {
      'id': 'notif_001',
      'type': 'message',
      'title': 'Mesaj nou',
      'message': 'Primit mesaj de la meșter',
      'timestamp': DateTime.now()
          .subtract(const Duration(minutes: 15))
          .toIso8601String(),
      'isRead': false,
    },
  ];

  List<Map<String, dynamic>> _mockVerificationDocuments() => [
    {
      'id': 'doc_001',
      'documentType': 'id_card',
      'fileName': 'carte_identitate.jpg',
      'status': 'verified',
      'uploadedAt': DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String(),
    },
  ];

  Map<String, dynamic> _mockProjectDetail() => {
    'id': 'proj_001',
    'title': 'Proiect Complex - Baie și Bucătărie',
    'description': 'Renovare completă baie + reparație robinetărie bucătărie',
    'status': 'inProgress',
    'budget': 1800.0,
    'location': 'București, Sector 3',
    'createdAt': DateTime.now()
        .subtract(const Duration(days: 7))
        .toIso8601String(),
  };

  List<Map<String, dynamic>> _mockMilestones() => [
    {
      'id': 'm1',
      'title': 'Achiziție materiale',
      'description': 'Cumpărarea robinetăriei și pieselor necesare',
      'amount': 200.0,
      'status': 'completed',
      'dueDate': DateTime.now()
          .subtract(const Duration(days: 3))
          .toIso8601String(),
    },
    {
      'id': 'm2',
      'title': 'Executare lucrări',
      'description': 'Demontarea și montarea noii robinetării',
      'amount': 400.0,
      'status': 'inProgress',
      'dueDate': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
    },
  ];
}

// Extension for UserProfile to make updates easier
extension UserProfileExtension on UserProfile {
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? profilePicture,
    double? rating,
    int? completedProjects,
    bool? isVerified,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profilePicture: profilePicture ?? this.profilePicture,
      rating: rating ?? this.rating,
      completedProjects: completedProjects ?? this.completedProjects,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}

// Singleton instance export
final mesteriService = MesteriService();
