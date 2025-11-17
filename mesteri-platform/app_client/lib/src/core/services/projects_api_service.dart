import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../models/api_models.dart';
import '../config/app_config.dart';
import '../models/service_insight_models.dart'; // New import

// Enums for project and milestone status
enum ProjectStatus {
  draft,
  inProgress,
  onHold,
  completed,
  cancelled,
}

enum MilestoneStatus {
  pending,
  inProgress,
  completed,
  overdue,
}

class ProjectsApiService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Fetch service insights overview
  Future<ServiceInsightCollection> getServicesOverview({
    String? categoryId,
    int? limit,
  }) async {
    try {
      final response = await _apiClient.get(
        '/jobs/services-overview',
        queryParameters: {
          if (categoryId != null) 'categoryId': categoryId,
          if (limit != null) 'limit': limit.toString(),
        },
      );
      return ServiceInsightCollection.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Fetch all projects with filtering
  Future<List<Project>> getProjects({
    ProjectStatus? status,
    String? clientId,
    String? craftsmanId,
    int page = 1,
    int limit = AppConfig.defaultPageSize,
  }) async {
    try {
      final response = await _apiClient.get(
        '/projects',
        queryParameters: {
          if (status != null) 'status': status.toString(),
          if (clientId != null) 'clientId': clientId,
          if (craftsmanId != null) 'craftsmanId': craftsmanId,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      final projectsList = data['data'] as List;
      return projectsList.map((json) => Project.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get specific project by ID
  Future<Project> getProjectById(String projectId) async {
    try {
      final response = await _apiClient.get('/projects/$projectId');
      return Project.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create new project
  Future<Project> createProject({
    required String jobId,
    required String clientId,
    required String craftsmanId,
    required String title,
    required String description,
    required double totalValue,
    required DateTime startDate,
    DateTime? endDate,
    List<Milestone>? initialMilestones,
  }) async {
    try {
      final response = await _apiClient.post(
        '/projects',
        data: {
          'jobId': jobId,
          'clientId': clientId,
          'craftsmanId': craftsmanId,
          'title': title,
          'description': description,
          'totalValue': totalValue,
          'startDate': startDate.toUtc().toIso8601String(),
          if (endDate != null) 'endDate': endDate.toUtc().toIso8601String(),
          'initialMilestones': initialMilestones?.map((m) => m.toJson()).toList() ?? [],
        },
      );

      return Project.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update project details
  Future<Project> updateProject(String projectId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put('/projects/$projectId', data: updates);
      return Project.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get project milestones
  Future<List<Milestone>> getProjectMilestones(String projectId) async {
    try {
      final response = await _apiClient.get('/projects/$projectId/milestones');
      final data = response.data as Map<String, dynamic>;
      final milestonesList = data['data'] as List;
      return milestonesList.map((json) => Milestone.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Create milestone for project
  Future<Milestone> createMilestone({
    required String projectId,
    required String title,
    required String description,
    required double amount,
    required DateTime dueDate,
    required bool isPaymentRequired,
  }) async {
    try {
      final response = await _apiClient.post(
        '/projects/$projectId/milestones',
        data: {
          'title': title,
          'description': description,
          'amount': amount,
          'dueDate': dueDate.toUtc().toIso8601String(),
          'isPaymentRequired': isPaymentRequired,
        },
      );

      return Milestone.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update milestone
  Future<Milestone> updateMilestone(String projectId, String milestoneId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put('/projects/$projectId/milestones/$milestoneId', data: updates);
      return Milestone.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark milestone as completed
  Future<Milestone> markMilestoneCompleted(String projectId, String milestoneId, {
    String? completionNotes,
    List<String>? attachments,
  }) async {
    try {
      final response = await _apiClient.post(
        '/projects/$projectId/milestones/$milestoneId/complete',
        data: {
          if (completionNotes != null) 'completionNotes': completionNotes,
          if (attachments != null) 'attachments': attachments,
        },
      );

      return Milestone.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get project payments
  Future<List<Payment>> getProjectPayments(String projectId) async {
    try {
      final response = await _apiClient.get('/projects/$projectId/payments');
      final data = response.data as Map<String, dynamic>;
      final paymentsList = data['data'] as List;
      return paymentsList.map((json) => Payment.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload project document/attachment
  Future<String> uploadProjectAttachment(String projectId, String filePath, String fileName) async {
    try {
      final file = await MultipartFile.fromFile(filePath, filename: fileName);
      final formData = FormData.fromMap({'file': file});

      final response = await _apiClient.post(
        '/projects/$projectId/attachments',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return response.data['fileUrl'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get project messages/conversations
  Future<List<Message>> getProjectMessages(String projectId) async {
    try {
      final response = await _apiClient.get('/projects/$projectId/messages');
      final data = response.data as Map<String, dynamic>;
      final messagesList = data['data'] as List;
      return messagesList.map((json) => Message.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Send message in project
  Future<Message> sendProjectMessage({
    required String projectId,
    required String senderId,
    required String content,
    List<String>? attachments,
  }) async {
    try {
      final response = await _apiClient.post(
        '/projects/$projectId/messages',
        data: {
          'senderId': senderId,
          'content': content,
          if (attachments != null) 'attachments': attachments,
        },
      );

      return Message.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get project reviews
  Future<List<Review>> getProjectReviews(String projectId) async {
    try {
      final response = await _apiClient.get('/projects/$projectId/reviews');
      final data = response.data as Map<String, dynamic>;
      final reviewsList = data['data'] as List;
      return reviewsList.map((json) => Review.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Archive completed project
  Future<void> archiveProject(String projectId) async {
    try {
      await _apiClient.post('/projects/$projectId/archive');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.response?.statusCode) {
      case 400:
        return Exception('Invalid request data');
      case 401:
        return Exception('Authentication required');
      case 403:
        return Exception('Access denied');
      case 404:
        return Exception('Project or milestone not found');
      case 422:
        return Exception('Project cannot be modified in current state');
      case 500:
        return Exception('Server error. Please try again later');
      default:
        return Exception('Network error: ${error.message}');
    }
  }
}