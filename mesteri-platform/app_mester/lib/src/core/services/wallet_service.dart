import 'package:dio/dio.dart';
import '../network/api_client.dart';

class WalletService {
  final Dio _dio = ApiClient().dio;

  /// Get wallet balance
  Future<Map<String, dynamic>> getWallet(String userId) async {
    try {
      final response = await _dio.get('/wallets/$userId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  /// Get earnings history
  Future<List<dynamic>> getEarnings(String userId) async {
    try {
      final response = await _dio.get('/payments/craftsman/$userId/earnings');
      return response.data as List;
    } catch (e) {
      throw Exception('Failed to get earnings: $e');
    }
  }

  /// Request withdrawal
  Future<Map<String, dynamic>> requestWithdrawal({
    required String userId,
    required double amount,
    required String method, // 'BANK_TRANSFER', 'CARD', 'PAYPAL'
    required Map<String, String> accountDetails,
  }) async {
    try {
      final response = await _dio.post(
        '/withdrawals',
        data: {
          'userId': userId,
          'amount': amount,
          'method': method,
          'accountDetails': accountDetails,
        },
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to request withdrawal: $e');
    }
  }

  /// Get withdrawal history
  Future<List<dynamic>> getWithdrawalHistory(String userId) async {
    try {
      final response = await _dio.get('/withdrawals/user/$userId');
      return response.data as List;
    } catch (e) {
      throw Exception('Failed to get withdrawal history: $e');
    }
  }

  /// Get wallet statistics (earnings by period)
  Future<Map<String, dynamic>> getWalletStats(String userId) async {
    try {
      final response = await _dio.get('/wallets/$userId/stats');
      return response.data;
    } catch (e) {
      throw Exception('Failed to get wallet stats: $e');
    }
  }

  /// Get transaction history
  Future<List<dynamic>> getTransactionHistory(String userId) async {
    try {
      final response = await _dio.get('/wallets/$userId/transactions');
      if (response.data is List) {
        return response.data as List;
      } else if (response.data is Map && response.data.containsKey('transactions')) {
        return response.data['transactions'] as List;
      } else if (response.data is Map && response.data.containsKey('data')) {
        return response.data['data'] as List;
      }
      return [];
    } catch (e) {
      // Return earnings as fallback for transactions
      return getEarnings(userId);
    }
  }
}
