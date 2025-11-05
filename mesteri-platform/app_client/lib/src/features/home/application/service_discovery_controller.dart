import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import 'package:app_client/src/core/config/app_config.dart';

import 'package:app_client/src/core/models/service_insight_models.dart';
import 'package:app_client/src/core/services/projects_api_service.dart'; // Changed from jobs_api_service.dart

enum ServiceInsightReaction { like, skip }

class ServiceDiscoveryController extends ChangeNotifier {
  ServiceDiscoveryController({ProjectsApiService? projectsApi, Duration? cacheTtl})
    : _projectsApi = projectsApi ?? ProjectsApiService(), // Changed from _jobsApi
      _cacheTtl = cacheTtl ?? Duration(minutes: AppConfig.cacheMaxAgeMinutes);
      

  final ProjectsApiService _projectsApi; // Changed from JobsApiService
  final Duration _cacheTtl;
  static const String _genericErrorMessage = 'Momentan nu putem incarca recomandarile. Te rugam sa incerci din nou.';
  static const String _connectivityErrorMessage = 'Conexiunea la internet pare instabila. Verifica si incearca din nou.';
  void Function(String event, Map<String, dynamic> payload)? _analyticsHandler;

  bool _isLoading = false;
  String? _error;
  List<ServiceInsight> _insights = const [];
  int _currentIndex = 0;
  DateTime? _lastFetchedAt;
  DateTime? _lastSuccessfulFetchAt;
  final Map<String, ServiceInsightReaction> _reactions = {};

  bool get isLoading => _isLoading;
  bool get hasError => _error != null;
  bool get hasInsights => _insights.isNotEmpty;
  String? get error => _error;
  List<ServiceInsight> get insights => _insights;
  int get currentIndex => _currentIndex;
  DateTime? get lastFetchedAt => _lastFetchedAt;
  DateTime? get lastSuccessfulFetchAt => _lastSuccessfulFetchAt;
  Duration get cacheTtl => _cacheTtl;
  bool get isStale => (_lastSuccessfulFetchAt == null) ? true : (DateTime.now().difference(_lastSuccessfulFetchAt!).compareTo(_cacheTtl) > 0);
  Map<String, ServiceInsightReaction> get reactions =>
      Map.unmodifiable(_reactions);

  ServiceInsight? get currentInsight =>
      (_currentIndex >= 0 && _currentIndex < _insights.length)
      ? _insights[_currentIndex]
      : null;

  bool isLiked(String categoryId) =>
      _reactions[categoryId] == ServiceInsightReaction.like;

  bool isSkipped(String categoryId) =>
      _reactions[categoryId] == ServiceInsightReaction.skip;

  Future<void> initialize({
    String? initialCategoryId,
    bool forceRefresh = false,
  }) async {
    await loadInsights(
      categoryId: initialCategoryId,
      forceRefresh: forceRefresh,
    );
  }

  Future<void> loadInsights({
    String? categoryId,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;

    final normalizedCategory = categoryId != null
        ? _normalizeCategoryId(categoryId)
        : null;

    if (_shouldUseCachedResult(normalizedCategory, forceRefresh)) {
      _trackEvent('service_insights_cache_hit', {
        'category': categoryId,
        'count': _insights.length,
      });
      if (categoryId != null) {
        selectCategory(categoryId);
      } else if (_insights.isNotEmpty) {
        _trackCurrentInsightView();
        notifyListeners();
      }
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final collection = await _projectsApi.getServicesOverview( // Changed from _jobsApi
        categoryId: categoryId,
        limit: 6,
      );
      _applyInsights(
        collection.insights,
        categoryId: categoryId,
        fetchedAt: collection.fetchedAt,
      );
      _trackEvent('service_insights_loaded', {
        'category': categoryId,
        'count': collection.insights.length,
      });
    } on DioException catch (error, stackTrace) {
      _handleLoadFailure(
        error: error,
        categoryId: categoryId,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      _handleLoadFailure(
        error: error,
        categoryId: categoryId,
        stackTrace: stackTrace,
      );
    } finally {
      _setLoading(false);
    }
  }

  void setCurrentIndex(int index) {
    if (index < 0 || index >= _insights.length || index == _currentIndex) {
      return;
    }
    _currentIndex = index;
    _trackCurrentInsightView();
    notifyListeners();
  }

  bool selectCategory(String categoryId) {
    if (_insights.isEmpty) return false;
    final normalized = _normalizeCategoryId(categoryId);
    final index = _insights.indexWhere((insight) {
      return _normalizeCategoryId(insight.categoryId) == normalized ||
          _normalizeCategoryId(insight.categoryName) == normalized;
    });
    if (index == -1) return false;
    setCurrentIndex(index);
    return true;
  }

  void recordReaction(String categoryId, ServiceInsightReaction reaction) {
    final normalized = _normalizeCategoryId(categoryId);
    final existing = _reactions[normalized];
    if (existing == reaction) {
      _reactions.remove(normalized);
    } else {
      _reactions[normalized] = reaction;
    }
    _trackEvent('service_insight_reacted', {
      'category': normalized,
      'reaction': reaction.name,
    });
    notifyListeners();
  }

  void setAnalyticsHandler(void Function(String event, Map<String, dynamic> payload) handler) {
    _analyticsHandler = handler;
  }

  void clearError() => _setError(null);

  void _applyInsights(
    List<ServiceInsight> insights, {String? categoryId, DateTime? fetchedAt}
  ) {
    _insights = insights;
    final resolvedFetchedAt = fetchedAt ?? DateTime.now();
    _lastFetchedAt = resolvedFetchedAt;
    if (insights.isNotEmpty) {
      _lastSuccessfulFetchAt = resolvedFetchedAt;
    }

    if (_insights.isEmpty) {
      _currentIndex = 0;
      notifyListeners();
      return;
    }

    if (categoryId != null && selectCategory(categoryId)) {
      return;
    }

    _currentIndex = _currentIndex.clamp(0, _insights.length - 1);
    _trackCurrentInsightView();
    notifyListeners();
  }

  String _normalizeCategoryId(String value) {
    final lower = value.trim().toLowerCase();
    return lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .trim();
  }

  bool _shouldUseCachedResult(String? normalizedCategory, bool forceRefresh) {
    if (forceRefresh || _insights.isEmpty || isStale) return false;
    return true;
  }

  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    if (_error == message) return;
    _error = message;
    notifyListeners();
  }

  void _handleLoadFailure({
    required Object error,
    String? categoryId,
    required StackTrace stackTrace,
  }) {
    if (error is DioException) {
      _setError(_connectivityErrorMessage);
    } else {
      _setError(_genericErrorMessage);
    }
    if (kDebugMode) {
      debugPrint('[ServiceDiscoveryController] Load failure: $error\n$stackTrace');
    }
  }

  void _trackCurrentInsightView() {
    final insight = currentInsight;
    if (insight == null) return;
    _trackEvent('service_insight_viewed', {
      'category': insight.categoryId,
      'position': _currentIndex,
    });
  }

  void _trackEvent(String event, Map<String, dynamic> payload) {
    if (_analyticsHandler != null) {
      _analyticsHandler!(event, payload);
      return;
    }
    if (kDebugMode) {
      debugPrint('[ServiceDiscoveryController] $event -> $payload');
    }
  }
}
