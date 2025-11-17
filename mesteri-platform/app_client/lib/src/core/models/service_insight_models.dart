import 'package:app_client/src/core/models/job_models.dart';

/// Service insight data returned by discovery/insights endpoints.
class ServiceInsight {
  final String categoryId;
  final String categoryName;
  final String? summary;
  final double? averageBudget;
  final double? averageBid;
  final int? averageDurationDays;
  final double? satisfactionScore;
  final List<Craftsman> topCraftsmen;
  final List<String> gallery;
  final List<String> topSkills;
  final Map<String, dynamic>? metadata;

  const ServiceInsight({
    required this.categoryId,
    required this.categoryName,
    this.summary,
    this.averageBudget,
    this.averageBid,
    this.averageDurationDays,
    this.satisfactionScore,
    this.topCraftsmen = const [],
    this.gallery = const [],
    this.topSkills = const [],
    this.metadata,
  });

  factory ServiceInsight.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'] as Map<String, dynamic>?;
    final galleryRaw = json['gallery'] ?? json['media'] ?? json['images'];
    final skillsRaw = json['topSkills'] ?? json['skills'] ?? json['tags'];
    final craftsmenRaw = json['topCraftsmen'] ?? json['craftsmen'] ?? json['top_craftsmen'];

    return ServiceInsight(
      categoryId: json['categoryId'] ?? categoryJson?['id'] ?? json['id']?.toString() ?? '',
      categoryName: json['categoryName'] ?? categoryJson?['name'] ?? json['name'] ?? 'Categorie',
      summary: json['summary'] ?? json['description'] ?? categoryJson?['summary'],
      averageBudget: _readDouble(json['averageBudget'] ?? json['avgBudget'] ?? json['average_price']),
      averageBid: _readDouble(json['averageBid'] ?? json['avgBid'] ?? json['averageBidAmount']),
      averageDurationDays: _readInt(json['averageDurationDays'] ?? json['avgDuration'] ?? json['average_duration_days']),
      satisfactionScore: _readDouble(json['satisfactionScore'] ?? json['rating'] ?? json['satisfaction']),
      topCraftsmen: _parseCraftsmen(craftsmenRaw),
      gallery: _parseStringList(galleryRaw),
      topSkills: _parseStringList(skillsRaw),
      metadata: json['metadata'] is Map<String, dynamic> ?
          (json['metadata'] as Map<String, dynamic>) : null,
    );
  }

  static double? _readDouble(Object? value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed;
    }
    return null;
  }

  static int? _readInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed;
    }
    return null;
  }

  static List<String> _parseStringList(Object? raw) {
    if (raw == null) return const [];
    if (raw is List) {
      return raw.map((e) => e?.toString() ?? '').where((value) => value.isNotEmpty).toList();
    }
    if (raw is String) {
      return raw.split(',').map((item) => item.trim()).where((value) => value.isNotEmpty).toList();
    }
    return const [];
  }

  static List<Craftsman> _parseCraftsmen(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((craftsman) => Craftsman.fromJson(craftsman.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }

  ServiceInsight copyWith({
    String? categoryId,
    String? categoryName,
    String? summary,
    double? averageBudget,
    double? averageBid,
    int? averageDurationDays,
    double? satisfactionScore,
    List<Craftsman>? topCraftsmen,
    List<String>? gallery,
    List<String>? topSkills,
    Map<String, dynamic>? metadata,
  }) {
    return ServiceInsight(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      summary: summary ?? this.summary,
      averageBudget: averageBudget ?? this.averageBudget,
      averageBid: averageBid ?? this.averageBid,
      averageDurationDays: averageDurationDays ?? this.averageDurationDays,
      satisfactionScore: satisfactionScore ?? this.satisfactionScore,
      topCraftsmen: topCraftsmen ?? this.topCraftsmen,
      gallery: gallery ?? this.gallery,
      topSkills: topSkills ?? this.topSkills,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ServiceInsightCollection {
  final List<ServiceInsight> insights;
  final DateTime fetchedAt;

  const ServiceInsightCollection({
    required this.insights,
    required this.fetchedAt,
  });

  factory ServiceInsightCollection.fromJson(Object? raw) {
    if (raw is List) {
      return ServiceInsightCollection(
        insights: raw
            .whereType<Map>()
            .map((item) => ServiceInsight.fromJson(item.cast<String, dynamic>()))
            .toList(),
        fetchedAt: DateTime.now(),
      );
    }

    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      final insightsRaw = data is List ? data : raw['insights'];
      final fetchedAtRaw = raw['fetchedAt'] ?? raw['timestamp'];
      return ServiceInsightCollection(
        insights: _parseInsights(insightsRaw),
        fetchedAt: fetchedAtRaw != null
            ? DateTime.tryParse(fetchedAtRaw.toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    }

    return ServiceInsightCollection(insights: const [], fetchedAt: DateTime.now());
  }

  static List<ServiceInsight> _parseInsights(Object? raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((item) => ServiceInsight.fromJson(item.cast<String, dynamic>()))
          .toList();
    }
    return const [];
  }
}