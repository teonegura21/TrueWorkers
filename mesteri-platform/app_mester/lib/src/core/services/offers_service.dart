import 'package:dio/dio.dart';
import '../network/api_client.dart';

class OffersService {
  final ApiClient _apiClient = ApiClient();

  /// Get all offers for the current craftsman
  Future<List<dynamic>> getMyCraftsmanOffers(String craftsmanId) async {
    try {
      final response = await _apiClient.get('/offers/craftsman/$craftsmanId');
      if (response.data is List) {
        return response.data as List<dynamic>;
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Failed to load offers: ${e.message}');
    }
  }

  /// Get offer by ID
  Future<Map<String, dynamic>> getOfferById(String offerId) async {
    try {
      final response = await _apiClient.get('/offers/$offerId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to load offer details: ${e.message}');
    }
  }

  /// Submit a new offer for a job
  Future<Map<String, dynamic>> createOffer({
    required String jobId,
    required double bidAmount,
    required String description,
    required int estimatedDays,
    List<String>? attachments,
  }) async {
    try {
      final response = await _apiClient.post('/offers', data: {
        'jobId': jobId,
        'bidAmount': bidAmount,
        'description': description,
        'estimatedDays': estimatedDays,
        if (attachments != null) 'attachments': attachments,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to create offer: ${e.message}');
    }
  }

  /// Update an existing offer
  Future<Map<String, dynamic>> updateOffer({
    required String offerId,
    double? proposedPrice,
    String? description,
    int? estimatedDays,
    List<String>? attachments,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (proposedPrice != null) data['proposedPrice'] = proposedPrice;
      if (description != null) data['description'] = description;
      if (estimatedDays != null) data['estimatedDays'] = estimatedDays;
      if (attachments != null) data['attachments'] = attachments;

      final response = await _apiClient.put('/offers/$offerId', data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Failed to update offer: ${e.message}');
    }
  }

  /// Withdraw an offer
  Future<void> withdrawOffer(String offerId) async {
    try {
      await _apiClient.post('/offers/$offerId/withdraw');
    } on DioException catch (e) {
      throw Exception('Failed to withdraw offer: ${e.message}');
    }
  }

  /// Delete an offer
  Future<void> deleteOffer(String offerId) async {
    try {
      await _apiClient.delete('/offers/$offerId');
    } on DioException catch (e) {
      throw Exception('Failed to delete offer: ${e.message}');
    }
  }
}
