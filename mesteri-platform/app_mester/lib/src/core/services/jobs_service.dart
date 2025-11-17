import 'package:dio/dio.dart';
import '../network/api_client.dart';

class JobsService {
  final ApiClient _apiClient = ApiClient();

  /// Get all available jobs (optionally filtered by category)
  Future<List<dynamic>> getAvailableJobs({String? category, String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      
      final response = await _apiClient.get(
        '/jobs',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load jobs: ${e.message}');
    }
  }

  /// Get job by ID
  Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      final response = await _apiClient.get('/jobs/$jobId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to load job details: ${e.message}');
    }
  }

  /// Get jobs by category
  Future<List<dynamic>> getJobsByCategory(String category) async {
    try {
      final response = await _apiClient.get('/jobs/category/$category');
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load jobs by category: ${e.message}');
    }
  }

  /// Search jobs
  Future<List<dynamic>> searchJobs(String query) async {
    try {
      final response = await _apiClient.get(
        '/jobs/search',
        queryParameters: {'q': query},
      );
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to search jobs: ${e.message}');
    }
  }

  /// Get offers for a specific job
  Future<List<dynamic>> getJobOffers(String jobId) async {
    try {
      final response = await _apiClient.get('/offers/job/$jobId');
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load job offers: ${e.message}');
    }
  }
}
