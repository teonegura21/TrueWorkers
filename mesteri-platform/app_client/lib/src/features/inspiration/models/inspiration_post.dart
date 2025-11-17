class InspirationPost {
  final String id;
  final String craftsmanId;
  final String title;
  final String description;
  final String? beforePhoto;
  final String afterPhoto;
  final List<String> additionalPhotos;
  final String? videoUrl;
  final List<String> skillsShowcased;
  final String? category;
  final String location;
  final String city;
  final int likes;
  final int views;
  final int shares;
  final bool isPromoted;
  final DateTime? promotionEnds;
  final CraftsmanInfo craftsman;
  final DateTime createdAt;

  InspirationPost({
    required this.id,
    required this.craftsmanId,
    required this.title,
    required this.description,
    this.beforePhoto,
    required this.afterPhoto,
    this.additionalPhotos = const [],
    this.videoUrl,
    this.skillsShowcased = const [],
    this.category,
    required this.location,
    required this.city,
    this.likes = 0,
    this.views = 0,
    this.shares = 0,
    this.isPromoted = false,
    this.promotionEnds,
    required this.craftsman,
    required this.createdAt,
  });

  factory InspirationPost.fromJson(Map<String, dynamic> json) {
    return InspirationPost(
      id: json['id'] as String,
      craftsmanId: json['craftsmanId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      beforePhoto: json['beforePhoto'] as String?,
      afterPhoto: json['afterPhoto'] as String,
      additionalPhotos: (json['additionalPhotos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      videoUrl: json['videoUrl'] as String?,
      skillsShowcased: (json['skillsShowcased'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      category: json['category'] as String?,
      location: json['location'] as String,
      city: json['city'] as String,
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      shares: json['shares'] as int? ?? 0,
      isPromoted: json['isPromoted'] as bool? ?? false,
      promotionEnds: json['promotionEnds'] != null
          ? DateTime.parse(json['promotionEnds'] as String)
          : null,
      craftsman: CraftsmanInfo.fromJson(json['craftsman'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'craftsmanId': craftsmanId,
      'title': title,
      'description': description,
      'beforePhoto': beforePhoto,
      'afterPhoto': afterPhoto,
      'additionalPhotos': additionalPhotos,
      'videoUrl': videoUrl,
      'skillsShowcased': skillsShowcased,
      'category': category,
      'location': location,
      'city': city,
      'likes': likes,
      'views': views,
      'shares': shares,
      'isPromoted': isPromoted,
      'promotionEnds': promotionEnds?.toIso8601String(),
      'craftsman': craftsman.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class CraftsmanInfo {
  final String id;
  final String fullName;
  final String? profilePicture;
  final double averageRating;
  final int totalReviews;
  final bool isVerified;
  final String city;
  final List<String>? specialties;
  final int? yearsExperience;

  CraftsmanInfo({
    required this.id,
    required this.fullName,
    this.profilePicture,
    required this.averageRating,
    required this.totalReviews,
    required this.isVerified,
    required this.city,
    this.specialties,
    this.yearsExperience,
  });

  factory CraftsmanInfo.fromJson(Map<String, dynamic> json) {
    return CraftsmanInfo(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      profilePicture: json['profilePicture'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 5.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      isVerified: json['isVerified'] as bool? ?? false,
      city: json['city'] as String,
      specialties: (json['specialties'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      yearsExperience: json['yearsExperience'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'profilePicture': profilePicture,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isVerified': isVerified,
      'city': city,
      'specialties': specialties,
      'yearsExperience': yearsExperience,
    };
  }
}
