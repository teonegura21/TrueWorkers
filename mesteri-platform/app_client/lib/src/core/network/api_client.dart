import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../services/firebase_service.dart';

class ApiClient {
  static const int _receiveTimeout = 5000;
  static const int _connectTimeout = 5000;

  static ApiClient? _instance;
  late final Dio _dio;
  // Simple in-memory token store. For persistence, wire flutter_secure_storage.
  static String? _authToken;
  static String? _refreshToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static void setRefreshToken(String? token) {
    _refreshToken = token;
  }

  // Persistent storage for auth token
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Persist token securely (and update in-memory cache)
  static Future<void> setAuthTokenPersist(String? token) async {
    _authToken = token;
    if (token == null || token.isEmpty) {
      await _storage.delete(key: 'auth_token');
    } else {
      await _storage.write(key: 'auth_token', value: token);
    }
  }

  static Future<void> setRefreshTokenPersist(String? token) async {
    _refreshToken = token;
    if (token == null || token.isEmpty) {
      await _storage.delete(key: 'refresh_token');
    } else {
      await _storage.write(key: 'refresh_token', value: token);
    }
  }

  // Initialize in-memory token from secure storage
  static Future<void> initAuthToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      _authToken = token;
      final refreshToken = await _storage.read(key: 'refresh_token');
      _refreshToken = refreshToken;
    } catch (_) {
      // ignore storage errors
    }
  }

  static String? get authToken => _authToken;
  static String? get refreshToken => _refreshToken;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(milliseconds: _connectTimeout),
        receiveTimeout: const Duration(milliseconds: _receiveTimeout),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  factory ApiClient() {
    return _instance ??= ApiClient._internal();
  }

  static ApiClient get instance => _instance ??= ApiClient._internal();

  void _setupInterceptors() {
    _dio.interceptors.addAll([
      _AuthInterceptor(_dio),
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          if (kDebugMode) {
            print('dYO? API Request: ${options.method} ${options.uri}');
            if (options.data != null) {
              print('dY"\u000f Request Body: ${options.data}');
            }
            print('dY"< Headers: ${options.headers}');
          }
          return handler.next(options);
        },
        onResponse: (Response response, ResponseInterceptorHandler handler) {
          if (kDebugMode) {
            print(
              'o. API Response: ${response.statusCode} ${response.requestOptions.uri}',
            );
            print('dY" Response Data: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          if (kDebugMode) {
            print(
              '?O API Error: ${error.response?.statusCode} ${error.message}',
            );
            if (error.response?.data != null) {
              print('dYs" Error Response: ${error.response?.data}');
            }
          }
          return handler.next(error);
        },
      ),
    ]);
  }

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return response;
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return response;
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio _dio;

  _AuthInterceptor(this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Try to get Firebase ID token first, then fall back to stored token
    String? token = await firebaseService.getIdToken();
    token ??= ApiClient.authToken;

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final RequestOptions requestOptions = err.requestOptions;

      if (!requestOptions.extra.containsKey('retry')) {
        requestOptions.extra['retry'] = true; // Mark as retried

        try {
          // Try to refresh Firebase ID token
          final newToken = await firebaseService.getIdToken(forceRefresh: true);

          if (newToken != null) {
            // Retry the original request with the new token
            requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final Response response = await _dio.fetch(requestOptions);
            return handler.resolve(response);
          } else {
            // If no token available, user needs to login again
            if (kDebugMode) {
              print('No Firebase token available - user needs to login');
            }
            // TODO: Emit an event to notify the UI to navigate to login screen
          }
        } catch (e) {
          if (kDebugMode) {
            print('Firebase token refresh failed: $e');
          }
          // TODO: Emit an event to notify the UI to navigate to login screen
        }
      }
    }
    super.onError(err, handler);
  }
}
