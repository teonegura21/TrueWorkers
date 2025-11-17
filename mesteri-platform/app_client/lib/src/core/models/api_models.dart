export 'conversation_models.dart';
// API Models for Mesteri Platform - Matching Backend DTOs

// Alias for Job model to match existing structure
export 'job_models.dart' show Job, JobStatus, Craftsman, Offer;

// Generic API Response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;
  final String? error;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
    this.error,
  });

  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode ?? 200,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode ?? 500,
    );
  }

  static ApiResponse<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? true,
      message: json['message'],
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      statusCode: json['statusCode'],
      error: json['error'],
    );
  }
}

// Pagination Response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final int total;
  final int page;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  const PaginatedResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final data = (json['data'] as List<dynamic>)
        .map((item) => fromJsonT(item))
        .toList();

    return PaginatedResponse(
      data: data,
      total: json['total'] ?? data.length,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? data.length,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

// Create Job DTO
class CreateJobDto {
  final String title;
  final String description;
  final String category;
  final int budgetMin;
  final int budgetMax;
  final String location;

  const CreateJobDto({
    required this.title,
    required this.description,
    required this.category,
    required this.budgetMin,
    required this.budgetMax,
    required this.location,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'location': location,
    };
  }
}

// User models for authentication
class UserEntity {
  final String id;
  final String email;
  final String name;
  final String role; // 'client', 'craftsman', or 'admin'
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Flexible search/filter parameters
class JobSearchParams {
  final String? query;
  final String? category;
  final String? location;
  final int? budgetMin;
  final int? budgetMax;
  final int? page;
  final int? limit;
  final String? sortBy;
  final String? sortOrder;

  const JobSearchParams({
    this.query,
    this.category,
    this.location,
    this.budgetMin,
    this.budgetMax,
    this.page = 1,
    this.limit = 20,
    this.sortBy = 'createdAt',
    this.sortOrder = 'DESC',
  });

  Map<String, dynamic> toQueryParams() {
    return {
      if (query != null) 'query': query,
      if (category != null) 'category': category,
      if (location != null) 'location': location,
      if (budgetMin != null) 'budgetMin': budgetMin,
      if (budgetMax != null) 'budgetMax': budgetMax,
      'page': page,
      'limit': limit,
      'sortBy': sortBy,
      'sortOrder': sortOrder,
    };
  }
}

// Error handling
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }

  static ApiException from(Exception e) {
    return ApiException(
      message: e.toString(),
      statusCode: null,
    );
  }
}

// Project Management Models
class Project {
  final String id;
  final String title;
  final String description;
  final String status;
  final String clientId;
  final String clientName;
  final String? craftsmanId;
  final String? craftsmanName;
  final double budget;
  final String location;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.clientId,
    required this.clientName,
    this.craftsmanId,
    this.craftsmanName,
    required this.budget,
    required this.location,
    required this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      clientId: json['clientId'] ?? '',
      clientName: json['clientName'] ?? '',
      craftsmanId: json['craftsmanId'],
      craftsmanName: json['craftsmanName'],
      budget: (json['budget'] as num?)?.toDouble() ?? (json['totalValue'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'clientId': clientId,
      'clientName': clientName,
      'craftsmanId': craftsmanId,
      'craftsmanName': craftsmanName,
      'budget': budget,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Milestone {
  final String id;
  final String title;
  final String description;
  final double amount;
  final String status;
  final DateTime dueDate;
  final DateTime createdAt;
  final String? completionNotes;
  final List<String> attachments;

  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    this.completionNotes,
    this.attachments = const [],
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : DateTime.now(),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      completionNotes: json['completionNotes'],
      attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'amount': amount,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completionNotes': completionNotes,
      'attachments': attachments,
    };
  }
}

class Payment {
  final String id;
  final String projectId;
  final double amount;
  final String status;
  final String paymentMethod;
  final DateTime processedAt;
  final String? description;

  const Payment({
    required this.id,
    required this.projectId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    required this.processedAt,
    this.description,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? '',
      processedAt: json['processedAt'] != null ? DateTime.parse(json['processedAt']) : DateTime.now(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'amount': amount,
      'status': status,
      'paymentMethod': paymentMethod,
      'processedAt': processedAt.toIso8601String(),
      'description': description,
    };
  }
}

class Message {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final String? projectId;
  final String? recipientId;
  final List<String>? attachments;

  const Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    this.projectId,
    this.recipientId,
    this.attachments,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      projectId: json['projectId'],
      recipientId: json['recipientId'],
      attachments: json['attachments'] != null ? List<String>.from(json['attachments']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp.toIso8601String(),
      'projectId': projectId,
      'recipientId': recipientId,
      'attachments': attachments,
    };
  }
}

class Review {
  final String id;
  final String projectId;
  final int rating;
  final String comment;
  final String reviewerId;
  final String reviewedUserId;
  final String reviewerName;
  final String? reviewedUserName;
  final DateTime createdAt;
  final bool isVerified;
  final String? status;
  final List<String>? tags;
  final String? response;

  const Review({
    required this.id,
    required this.projectId,
    required this.rating,
    required this.comment,
    required this.reviewerId,
    required this.reviewedUserId,
    required this.reviewerName,
    this.reviewedUserName,
    required this.createdAt,
    this.isVerified = false,
    this.status,
    this.tags,
    this.response,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? '',
      reviewerId: json['reviewerId'] ?? '',
      reviewedUserId: json['reviewedUserId'] ?? json['revieweeId'] ?? '',
      reviewerName: json['reviewerName'] ?? '',
      reviewedUserName: json['reviewedUserName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isVerified: json['isVerified'] ?? false,
      status: json['status'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      response: json['response'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'rating': rating,
      'comment': comment,
      'reviewerId': reviewerId,
      'reviewedUserId': reviewedUserId,
      'reviewerName': reviewerName,
      'reviewedUserName': reviewedUserName,
      'createdAt': createdAt.toIso8601String(),
      'isVerified': isVerified,
      'status': status,
      'tags': tags,
      'response': response,
    };
  }
}

