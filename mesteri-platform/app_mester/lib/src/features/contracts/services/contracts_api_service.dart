import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class ContractApiService {
  static final ContractApiService _instance = ContractApiService._internal();
  factory ContractApiService() => _instance;
  ContractApiService._internal();

  final ApiClient _apiClient = ApiClient.instance;

  /// Retrieve all contracts for the current user
  Future<Response> getUserContracts({int page = 1, int limit = 20}) async {
    return await _apiClient.get('/contracts/user');
  }

  /// Retrieve a specific contract by ID
  Future<Response> getContract(String contractId) async {
    return await _apiClient.get('/contracts/$contractId');
  }

  /// Sign a contract with a digital signature
  Future<Response> signContract(String contractId, String signatureData) async {
    return await _apiClient.post(
      '/contracts/$contractId/sign',
      data: {
        'signatureData': signatureData,
      },
    );
  }

  /// Retrieve contract document (PDF)
  Future<Response> getContractDocument(String contractId) async {
    return await _apiClient.get('/contracts/$contractId/download');
  }

  /// Create a new contract for a project
  Future<Response> createContractForProject(String projectId) async {
    return await _apiClient.post('/contracts/project/$projectId');
  }

  /// Accept a contract (change status to accepted)
  Future<Response> acceptContract(String contractId) async {
    return await _apiClient.post('/contracts/$contractId/accept');
  }

  /// Decline a contract
  Future<Response> declineContract(String contractId) async {
    return await _apiClient.post('/contracts/$contractId/decline');
  }

  /// Get contract status
  Future<Response> getContractStatus(String contractId) async {
    return await _apiClient.get('/contracts/$contractId/status');
  }
}