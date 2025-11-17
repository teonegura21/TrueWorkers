import 'package:dio/dio.dart';
import '../network/api_client.dart';

class PaymentService {
  final Dio _dio = ApiClient().dio;

  /// Create payment intent for project
  Future<Map<String, dynamic>> createPaymentIntent({
    required String projectId,
    required String clientId,
    required String craftsmanId,
    required double amount,
    String? milestoneId,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/stripe/create-payment-intent',
        data: {
          'projectId': projectId,
          'clientId': clientId,
          'craftsmanId': craftsmanId,
          'amount': amount,
          if (milestoneId != null) 'milestoneId': milestoneId,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  /// Get payment details
  Future<Map<String, dynamic>> getPayment(String paymentId) async {
    try {
      final response = await _dio.get('/payments/$paymentId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get payment: $e');
    }
  }

  /// Get user's payment history
  Future<List<dynamic>> getPaymentHistory(String userId) async {
    try {
      final response = await _dio.get('/payments/user/$userId');
      return response.data as List;
    } catch (e) {
      throw Exception('Failed to get payment history: $e');
    }
  }

  /// Request refund
  Future<Map<String, dynamic>> requestRefund({
    required String paymentId,
    required String reason,
    double? amount,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/$paymentId/refund',
        data: {'reason': reason, if (amount != null) 'amount': amount},
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to request refund: $e');
    }
  }
}
