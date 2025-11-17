import 'package:dio/dio.dart';
import '../network/api_client.dart';

class ProjectsService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Get craftsman's projects
  Future<List<dynamic>> getCraftsmanProjects(String craftsmanId) async {
    try {
      final response = await _apiClient.get(
        '/projects',
        queryParameters: {'craftsmanId': craftsmanId},
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data as List;
        } else if (response.data is Map && response.data.containsKey('projects')) {
          return response.data['projects'] as List;
        } else if (response.data is Map && response.data.containsKey('data')) {
          return response.data['data'] as List;
        }
      }

      throw Exception('Failed to load projects');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No projects yet
      }
      throw Exception('Error loading projects: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching projects: $e');
    }
  }

  /// Get project details
  Future<Map<String, dynamic>> getProjectDetails(String projectId) async {
    try {
      final response = await _apiClient.get('/projects/$projectId');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('Failed to load project details');
    } on DioException catch (e) {
      throw Exception('Error loading project: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching project: $e');
    }
  }

  /// Get project milestones
  Future<List<dynamic>> getProjectMilestones(String projectId) async {
    try {
      final response = await _apiClient.get('/projects/$projectId/milestones');

      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data as List;
        } else if (response.data is Map && response.data.containsKey('milestones')) {
          return response.data['milestones'] as List;
        } else if (response.data is Map && response.data.containsKey('data')) {
          return response.data['data'] as List;
        }
      }

      throw Exception('Failed to load milestones');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return []; // No milestones yet
      }
      throw Exception('Error loading milestones: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching milestones: $e');
    }
  }

  /// Update milestone status
  Future<void> updateMilestoneStatus(
    String projectId,
    String milestoneId,
    String status,
  ) async {
    try {
      final response = await _apiClient.put(
        '/projects/$projectId/milestones/$milestoneId',
        data: {'status': status},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update milestone');
      }
    } on DioException catch (e) {
      throw Exception('Error updating milestone: ${e.message}');
    } catch (e) {
      throw Exception('Error updating milestone: $e');
    }
  }

  /// Update project status
  Future<void> updateProjectStatus(String projectId, String status) async {
    try {
      final response = await _apiClient.put(
        '/projects/$projectId',
        data: {'status': status},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update project');
      }
    } on DioException catch (e) {
      throw Exception('Error updating project: ${e.message}');
    } catch (e) {
      throw Exception('Error updating project: $e');
    }
  }

  /// Get project progress
  Future<Map<String, dynamic>> getProjectProgress(String projectId) async {
    try {
      final response = await _apiClient.get('/projects/$projectId/progress');

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('Failed to load project progress');
    } on DioException catch (e) {
      throw Exception('Error loading progress: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching progress: $e');
    }
  }
}
