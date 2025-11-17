import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../data/contracts_models.dart';

class ContractsApiService {
  static final ApiClient _apiClient = ApiClient.instance;

  /// Create a new contract for a given job
  static Future<Contract> createContract({required String jobId}) async {
    try {
      final response = await _apiClient.post(
        '/contracts',
        data: {'jobId': jobId},
      );
      return _parseContractResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Retrieve a contract by ID
  static Future<Contract> getContractById(String contractId) async {
    try {
      final response = await _apiClient.get('/contracts/$contractId');
      return _parseContractResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// List contracts with optional filters
  static Future<List<Contract>> getContracts({
    String? projectId,
    String? jobId,
    String? status,
    int? page,
    int? limit,
  }) async {
    try {
      final response = await _apiClient.get(
        '/contracts',
        queryParameters: {
          if (projectId != null) 'projectId': projectId,
          if (jobId != null) 'jobId': jobId,
          if (status != null) 'status': status,
          if (page != null) 'page': page.toString(),
          if (limit != null) 'limit': limit.toString(),
        },
      );

      final raw = response.data;
      if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((e) => _mapContract(Map<String, dynamic>.from(e)))
              .toList();
        }
        return [_mapContract(Map<String, dynamic>.from(raw))];
      } else if (raw is List) {
        return raw
            .whereType<Map>()
            .map((e) => _mapContract(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Sign/accept a contract by ID
  static Future<Contract> signContract({required String contractId}) async {
    try {
      final response = await _apiClient.post('/contracts/$contractId/sign');
      return _parseContractResponse(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Try to get existing contract for a job, or return null if not found
  static Future<Contract?> getContractForJob(String jobId) async {
    try {
      final list = await getContracts(jobId: jobId, page: 1, limit: 1);
      if (list.isNotEmpty) return list.first;
      return null;
    } on Exception {
      // In case of 404 or parsing differences, gracefully return null and let caller decide to create
      return null;
    }
  }

  /// Get or create a contract for the given job
  static Future<Contract> getOrCreateContractForJob(String jobId) async {
    final existing = await getContractForJob(jobId);
    if (existing != null) return existing;
    return await createContract(jobId: jobId);
  }

  // -------------------- Helpers --------------------
  static Contract _parseContractResponse(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) {
        return _mapContract(data);
      }
      return _mapContract(raw);
    }
    // Unexpected format; return a safe default to avoid crashes
    return Contract(
      id: '',
      jobId: '',
      pdfUrl: '',
      hash: '',
      status: ContractStatus.pendingSignatures,
    );
  }

  static Contract _mapContract(Map<String, dynamic> json) {
    final statusValue = json['status'];
    return Contract(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      jobId: (json['jobId'] ?? json['job_id'] ?? '').toString(),
      pdfUrl: (json['pdfUrl'] ?? json['documentUrl'] ?? json['fileUrl'] ?? '')
          .toString(),
      hash: (json['hash'] ?? json['checksum'] ?? '').toString(),
      status: _parseStatus(statusValue),
    );
  }

  static ContractStatus _parseStatus(dynamic value) {
    if (value is String) {
      switch (value.toLowerCase()) {
        case 'signed':
        case 'complete':
        case 'completed':
          return ContractStatus.signed;
        case 'pending':
        case 'pending_signatures':
        case 'awaiting_signatures':
        default:
          return ContractStatus.pendingSignatures;
      }
    } else if (value is bool) {
      return value ? ContractStatus.signed : ContractStatus.pendingSignatures;
    } else if (value is num) {
      return value == 1
          ? ContractStatus.signed
          : ContractStatus.pendingSignatures;
    }
    return ContractStatus.pendingSignatures;
  }

  static Exception _handleError(DioException error) {
    switch (error.response?.statusCode) {
      case 400:
        return Exception('Invalid contract request data');
      case 401:
        return Exception('Authentication required');
      case 403:
        return Exception('Access denied');
      case 404:
        return Exception('Contract not found');
      case 422:
        return Exception('Contract cannot be modified in current state');
      case 500:
        return Exception('Server error. Please try again later');
      default:
        return Exception('Network error: ${error.message}');
    }
  }
}
