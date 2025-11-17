class Craftsman {
  final String id;
  final String email;
  final String fullName;
  final String city;
  final String county;
  final String? address;
  final String? phone;
  final String? profilePicture;
  final String? bio;
  final int? yearsExperience;
  final List<String> portfolioPhotos;
  final List<String> skillsTags;
  final List<String> certifications;
  final bool insuranceVerified;
  final bool isVerified;
  final double averageRating;
  final int totalReviews;
  final List<String> specialties;
  final String? availability;
  final DateTime createdAt;

  Craftsman({
    required this.id,
    required this.email,
    required this.fullName,
    required this.city,
    required this.county,
    this.address,
    this.phone,
    this.profilePicture,
    this.bio,
    this.yearsExperience,
    this.portfolioPhotos = const [],
    this.skillsTags = const [],
    this.certifications = const [],
    this.insuranceVerified = false,
    this.isVerified = false,
    this.averageRating = 5.0,
    this.totalReviews = 0,
    this.specialties = const [],
    this.availability,
    required this.createdAt,
  });

  factory Craftsman.fromJson(Map<String, dynamic> json) {
    return Craftsman(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      city: json['city'] as String,
      county: json['county'] as String,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      profilePicture: json['profilePicture'] as String?,
      bio: json['bio'] as String?,
      yearsExperience: json['yearsExperience'] as int?,
      portfolioPhotos: (json['portfolioPhotos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      skillsTags: (json['skillsTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      certifications: (json['certifications'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      insuranceVerified: json['insuranceVerified'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 5.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      availability: json['availability'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'city': city,
      'county': county,
      'address': address,
      'phone': phone,
      'profilePicture': profilePicture,
      'bio': bio,
      'yearsExperience': yearsExperience,
      'portfolioPhotos': portfolioPhotos,
      'skillsTags': skillsTags,
      'certifications': certifications,
      'insuranceVerified': insuranceVerified,
      'isVerified': isVerified,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'specialties': specialties,
      'availability': availability,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get experienceText {
    if (yearsExperience == null) return 'Experiență nedeclarată';
    if (yearsExperience! == 1) return '1 an experiență';
    return '$yearsExperience ani experiență';
  }

  String get ratingText {
    return '${averageRating.toStringAsFixed(1)} ($totalReviews review-uri)';
  }

  String get verificationBadge {
    if (isVerified && insuranceVerified) return 'Verificat & Asigurat';
    if (isVerified) return 'Verificat';
    return 'Neverificat';
  }
}
