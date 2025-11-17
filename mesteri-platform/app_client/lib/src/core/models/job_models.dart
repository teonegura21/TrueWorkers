// Job Models Compatible with both Mock Data and Real API

enum JobStatus {
  pending,
  offersReceived,
  inProgress,
  completed,
  cancelled,
}

enum OfferStatus {
  pending,
  accepted,
  rejected,
  withdrawn,
}

// Craftsman model matching existing structure
class Craftsman {
  final String id;
  final String name;
  final double rating;
  final double? responseTimeHours;
  final int completedProjects;
  final List<String> trustBadges;

  const Craftsman({
    required this.id,
    required this.name,
    required this.rating,
    this.responseTimeHours,
    required this.completedProjects,
    this.trustBadges = const [],
  });

  factory Craftsman.fromJson(Map<String, dynamic> json) {
    return Craftsman(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      responseTimeHours: (json['responseTimeHours'] as num?)?.toDouble(),
      completedProjects: json['completedProjects'] ?? 0,
      trustBadges: List<String>.from(json['trustBadges'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'responseTimeHours': responseTimeHours,
      'completedProjects': completedProjects,
      'trustBadges': trustBadges,
    };
  }
}

// Offer model matching existing structure and backend DTO
class Offer {
  final String? id;
  final String? mesterName; // For backward compatibility
  final String? craftsmanId;
  final double price;
  final String details;
  final String? description; // For backend compatibility
  final String? status;
  final String? createdAt;
  final List<String>? attachments;

  const Offer({
    this.id,
    this.mesterName,
    this.craftsmanId,
    required this.price,
    required this.details,
    this.description,
    this.status,
    this.createdAt,
    this.attachments,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    // Handle both backend and mock data formats
    return Offer(
      id: json['id'],
      mesterName: json['mesterName'] ?? json['craftsmanName'],
      craftsmanId: json['craftsmanId'] ?? json['mesterId'],
      price: (json['price'] as num?)?.toDouble() ??
             (json['proposedPrice'] as num?)?.toDouble() ?? 0.0,
      details: json['details'] ?? json['description'] ?? '',
      description: json['description'],
      status: json['status'],
      createdAt: json['createdAt'],
      attachments: json['attachments'] != null ?
                  List<String>.from(json['attachments']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'price': price,
      'details': details,
      'description': description ?? details,
      'craftsmanId': craftsmanId,
      'status': status ?? 'pending',
      'attachments': attachments,
    };
  }
}

// Job model matching both mock data and backend entity
class Job {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final int budgetMin;
  final int budgetMax;
  final JobStatus status;
  final String? clientId;
  final String? clientName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Offer> offers;
  final List<Craftsman> craftsmenAvailable;
  final Offer? acceptedOffer;
  final double? finalPrice;
  final double? rating;
  final List<String> mediaUrls;

  const Job({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.budgetMin,
    required this.budgetMax,
    required this.status,
    this.clientId,
    this.clientName,
    required this.createdAt,
    required this.updatedAt,
    this.offers = const [],
    this.craftsmenAvailable = const [],
    this.acceptedOffer,
    this.finalPrice,
    this.rating,
    this.mediaUrls = const [],
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    // Handle both backend format and mock data format
    List<Offer> offersList = [];
    if (json['offers'] != null) {
      offersList = (json['offers'] as List)
          .map((offerJson) => Offer.fromJson(offerJson))
          .toList();
    }

    List<Craftsman> craftsmenList = [];
    if (json['craftsmenAvailable'] != null) {
      craftsmenList = (json['craftsmenAvailable'] as List)
          .map((craftsmanJson) => Craftsman.fromJson(craftsmanJson))
          .toList();
    }

    Offer? acceptedOffer;
    if (json['acceptedOffer'] != null) {
      acceptedOffer = Offer.fromJson(json['acceptedOffer']);
    }

    // Convert status strings to enum
    JobStatus status;
    switch (json['status']?.toString()) {
      case 'offersReceived':
      case 'offers_received':
        status = JobStatus.offersReceived;
        break;
      case 'inProgress':
      case 'in_progress':
        status = JobStatus.inProgress;
        break;
      case 'completed':
        status = JobStatus.completed;
        break;
      case 'cancelled':
        status = JobStatus.cancelled;
        break;
      default:
        status = JobStatus.pending;
    }

    return Job(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      category: json['category'] ?? '',
      budgetMin: json['budgetMin'] ?? json['budget_min'] ?? 0,
      budgetMax: json['budgetMax'] ?? json['budget_max'] ?? 0,
      status: status,
      clientId: json['clientId'],
      clientName: json['clientName'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      offers: offersList,
      craftsmenAvailable: craftsmenList,
      acceptedOffer: acceptedOffer,
      finalPrice: json['finalPrice'] != null ?
                 (json['finalPrice'] as num).toDouble() : null,
      rating: json['rating'] != null ?
              (json['rating'] as num).toDouble() : null,
      mediaUrls: json['mediaUrls'] != null
          ? List<String>.from(json['mediaUrls'].whereType<String>())
          : (json['attachments'] != null
              ? List<String>.from(json['attachments'].whereType<String>())
              : const []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'category': category,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'status': status.name,
      'clientId': clientId,
      'clientName': clientName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'offers': offers.map((offer) => offer.toJson()).toList(),
      'craftsmenAvailable': craftsmenAvailable.map((c) => c.toJson()).toList(),
      'acceptedOffer': acceptedOffer?.toJson(),
      'finalPrice': finalPrice,
      'rating': rating,
      'mediaUrls': mediaUrls,
    };
  }

  // Helper methods
  bool get hasOffers => offers.isNotEmpty;
  bool get hasAcceptedOffer => acceptedOffer != null;

  double get offerPriceRange => (budgetMax - budgetMin).toDouble();

  Job copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? category,
    int? budgetMin,
    int? budgetMax,
    JobStatus? status,
    String? clientId,
    String? clientName,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Offer>? offers,
    List<Craftsman>? craftsmenAvailable,
    Offer? acceptedOffer,
    double? finalPrice,
    double? rating,
    List<String>? mediaUrls,
  }) {
    return Job(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      category: category ?? this.category,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      status: status ?? this.status,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      offers: offers ?? this.offers,
      craftsmenAvailable: craftsmenAvailable ?? this.craftsmenAvailable,
      acceptedOffer: acceptedOffer ?? this.acceptedOffer,
      finalPrice: finalPrice ?? this.finalPrice,
      rating: rating ?? this.rating,
      mediaUrls: mediaUrls ?? this.mediaUrls,
    );
  }
}
