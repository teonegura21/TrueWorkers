import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../models/job_models.dart';
import '../models/service_insight_models.dart';
import '../config/app_config.dart';

class JobsApiService {
  final ApiClient _apiClient = ApiClient.instance;

  /// Fetch all jobs from backend with optional filtering
  Future<List<Job>> getJobs({
    String? searchTerm,
    JobStatus? status,
    int page = 1,
    int limit = AppConfig.defaultPageSize,
  }) async {
    try {
      final response = await _apiClient.get(
        '/jobs',
        queryParameters: {
          if (searchTerm != null && searchTerm.isNotEmpty) 'search': searchTerm,
          if (status != null) 'status': status.toString(),
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final raw = response.data;
      if (raw is List) {
        return raw.whereType<Map>().map((item) => Job.fromJson(item as Map<String, dynamic>)).toList();
      } else if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          return data.whereType<Map>().map((item) => Job.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [Job.fromJson(raw)];
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Job>> getMarketingFeed({int limit = 20}) async {
    try {
      final response = await _apiClient.get(
        '/jobs/marketing/feed',
        queryParameters: {'limit': limit.toString()},
      );
      final raw = response.data;
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map((item) => Job.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (raw is Map<String, dynamic>) {
        final data = raw['data'];
        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => Job.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [Job.fromJson(raw)];
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ServiceInsightCollection> getServicesOverview({
    String? categoryId,
    int limit = 3,
  }) async {
    try {
      final response = await _apiClient.get(
        '/jobs/services-overview',
        queryParameters: {
          if (categoryId != null && categoryId.isNotEmpty)
            'categoryId': categoryId,
          'limit': limit.toString(),
        },
      );

      final raw = response.data;
      final collection = ServiceInsightCollection.fromJson(raw);
      return collection;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Search jobs by query string
  Future<List<Job>> searchJobs(String query) async {
    try {
      final response = await _apiClient.get(
        '/jobs/search',
        queryParameters: {'q': query},
      );

      final data = response.data as Map<String, dynamic>;
      final jobsList = data['data'] as List;
      return jobsList.map((json) => Job.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get specific job by ID
  Future<Job> getJobById(String jobId) async {
    try {
      final response = await _apiClient.get('/jobs/$jobId');
      return Job.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Job> postJob({
    required String title,
    required String description,
    required String location,
    required String category,
    required int budgetMin,
    required int budgetMax,
    required List<String> requiredSkills,
    List<String>? attachments,
  }) async {
    try {
      final response = await _apiClient.post(
        '/jobs',
        data: {
          'title': title,
          'description': description,
          'location': location,
          'category': category,
          'budgetMin': budgetMin,
          'budgetMax': budgetMax,
          'requiredSkills': requiredSkills,
          'attachments': attachments ?? [],
        },
      );

      return Job.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Update existing job
  Future<Job> updateJob(String jobId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiClient.put('/jobs/$jobId', data: updates);
      return Job.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete job
  Future<void> deleteJob(String jobId) async {
    try {
      await _apiClient.delete('/jobs/$jobId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get offers for a specific job
  Future<List<Offer>> getJobOffers(String jobId) async {
    try {
      final response = await _apiClient.get('/jobs/$jobId/offers');
      final data = response.data as Map<String, dynamic>;
      final offersList = data['data'] as List;
      return offersList.map((json) => Offer.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Accept an offer for a job
  Future<void> acceptOffer(String jobId, String offerId) async {
    try {
      await _apiClient.post('/jobs/$jobId/offers/$offerId/accept');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Decline an offer for a job
  Future<void> declineOffer(String jobId, String offerId) async {
    try {
      await _apiClient.post('/jobs/$jobId/offers/$offerId/decline');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  JobsApiException _handleError(DioException error) {
    final statusCode = error.response?.statusCode;
    final type = error.type;
    final isConnectivityIssue = statusCode == null &&
        (type == DioExceptionType.connectionTimeout ||
            type == DioExceptionType.receiveTimeout ||
            type == DioExceptionType.sendTimeout ||
            type == DioExceptionType.connectionError ||
            type == DioExceptionType.unknown);

    String message;
    if (isConnectivityIssue) {
      message = 'Network connection appears unstable. Please try again.';
    } else {
      switch (statusCode) {
        case 400:
          message = 'Invalid request data';
          break;
        case 401:
          message = 'Authentication required';
          break;
        case 403:
          message = 'Access denied';
          break;
        case 404:
          message = 'Resource not found';
          break;
        case 500:
          message = 'Server error. Please try again later';
          break;
        default:
          message = error.message ?? 'Unexpected network error';
      }
    }

    return JobsApiException(
      message: message,
      statusCode: statusCode,
      type: type,
      isConnectivityIssue: isConnectivityIssue,
      originalError: error,
    );
  }

  /// Legacy method for backward compatibility - returns mock data
  List<Job> getMockJobs() {
    return [
      Job(
        id: 'job_001',
        title: 'ReparaÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºie robinet bucÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢tÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢rie',
        description: '''Se cautÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ meseriaÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ experimentat pentru reparaÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºia completÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ a sistemului de robinet ÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢i conducta.

LucrÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ri incluse:
ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢ Demontarea robinetului vechi
ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢ Verificarea ÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢i repararea conductelor
ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢ Montare robinet nou
ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢ Teste de presiune
ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â¢ CurÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºare zona de lucru

Materialele sunt asigurate de client. Trebuie sÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ aveÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºi experienÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂºÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â®n instalaÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºii sanitare.''',
        location: 'BucureÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ti, Sector 2',
        category: 'InstalaÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºii Sanitare',
        budgetMin: 200,
        budgetMax: 300,
        status: JobStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
        clientId: 'client_001',
        clientName: 'Maria Popescu',
      ),

      Job(
        id: 'job_002',
        title: 'Montaj mobilier bucÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢tÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢rie modular',
        description: '''Necesit montare mobilier bucÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢tÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢rie modular de la IKEA.

Posibile resturi realizate anterior, dar trebuie verificat.
Dispecer, sertarular, rafturi suspendate ÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢i icoane de perete.

OraÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢: TimiÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢oara, LivrarÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢: weekend-ul viitor''',
        location: 'TimiÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢oara',
        category: 'Montaj mobilÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢',
        budgetMin: 1500,
        budgetMax: 2100,
        status: JobStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        clientId: 'client_002',
        clientName: 'Ana Maria Ionescu',
      ),

      Job(
        id: 'job_003',
        title: 'Renovare baie completÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ - Urgent',
        description: '''BAIE COMPLETÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ - 16 martie

CondiÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºii:
- FaianÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºa plasatÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ ÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢i gresie (materiale precisate)
- InstalaÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºii condiÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºionate ÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢i electrice
- UÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ din sticlÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ parfumatÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢
- Mobilier necesar (demontez/kase cu dispozitiv pentru partid)
- AmÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢nare cÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢tig cÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢nd lucraÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºi

URGENT - clientul concede este datÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ liber sau recomand.''',
        location: 'Cluj-Napoca',
        category: 'Renovare baie',
        budgetMin: 3500,
        budgetMax: 5500,
        status: JobStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
        clientId: 'client_003',
        clientName: 'Vlad Pantea',
      ),

      Job(
        id: 'job_004',
        title: 'ReparaÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºie acoperiÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ casÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ unifamilialÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢',
        description: '''ReparaÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºie acoperiÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ casÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ - UrgenÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºa mare

DeteriorÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ri acoperiÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ produse de furtunÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ puternicÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢.
NecesitÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ verificare structurÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ acoperiÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ ÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢i reparare ÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚ÂºiglÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢ ruptÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢/strÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢mtÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢.

Regiune: BraÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ov, arie ruralÃƒÆ’Ã¢â‚¬Å¾Ãƒâ€ Ã¢â‚¬â„¢''',
        location: 'BraÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ov, ZONE RURALÃƒÆ’Ã¢â‚¬Å¾ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡',
        category: 'ReparaÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â€šÂ¬Ã‚Âºii AcoperiÃƒÆ’Ã‹â€ ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢uri',
        budgetMin: 1000,
        budgetMax: 2000,
        status: JobStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        clientId: 'client_004',
        clientName: 'Ioanita Popa-Andrei',
      ),
    ];
  }
}

class JobsApiException implements Exception {
  const JobsApiException({
    required this.message,
    this.statusCode,
    this.type,
    this.isConnectivityIssue = false,
    this.originalError,
  });

  final String message;
  final int? statusCode;
  final DioExceptionType? type;
  final bool isConnectivityIssue;
  final DioException? originalError;

  @override
  String toString() {
    return 'JobsApiException(message: $message, statusCode: $statusCode, type: $type)';
  }
}
