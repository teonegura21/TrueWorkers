import 'media_enums.dart';

class MediaAttachment {
  final String id;
  final String userId;
  final String fileUrl;
  final String? thumbnailUrl;
  final String? mediumUrl;
  final MediaFileType fileType;
  final MediaCategory category;
  final String? entityId;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final int? width;
  final int? height;
  final double? duration;
  final MediaStatus status;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  MediaAttachment({
    required this.id,
    required this.userId,
    required this.fileUrl,
    this.thumbnailUrl,
    this.mediumUrl,
    required this.fileType,
    required this.category,
    this.entityId,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    this.width,
    this.height,
    this.duration,
    required this.status,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MediaAttachment.fromJson(Map<String, dynamic> json) {
    return MediaAttachment(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fileUrl: json['fileUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      mediumUrl: json['mediumUrl'] as String?,
      fileType: MediaFileType.fromJson(json['fileType'] as String),
      category: MediaCategory.fromJson(json['category'] as String),
      entityId: json['entityId'] as String?,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      fileSize: json['fileSize'] as int,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] != null ? (json['duration'] as num).toDouble() : null,
      status: MediaStatus.fromJson(json['status'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'mediumUrl': mediumUrl,
      'fileType': fileType.toJson(),
      'category': category.toJson(),
      'entityId': entityId,
      'fileName': fileName,
      'mimeType': mimeType,
      'fileSize': fileSize,
      'width': width,
      'height': height,
      'duration': duration,
      'status': status.toJson(),
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  MediaAttachment copyWith({
    String? id,
    String? userId,
    String? fileUrl,
    String? thumbnailUrl,
    String? mediumUrl,
    MediaFileType? fileType,
    MediaCategory? category,
    String? entityId,
    String? fileName,
    String? mimeType,
    int? fileSize,
    int? width,
    int? height,
    double? duration,
    MediaStatus? status,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaAttachment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fileUrl: fileUrl ?? this.fileUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediumUrl: mediumUrl ?? this.mediumUrl,
      fileType: fileType ?? this.fileType,
      category: category ?? this.category,
      entityId: entityId ?? this.entityId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isImage => fileType == MediaFileType.image;
  bool get isVideo => fileType == MediaFileType.video;
  bool get isProcessing => status == MediaStatus.processing;
  bool get isActive => status == MediaStatus.active;
  bool get hasFailed => status == MediaStatus.failed;
  
  String get displaySize {
    final kb = fileSize / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }

  String? get displayDuration {
    if (duration == null) return null;
    final minutes = duration! ~/ 60;
    final seconds = (duration! % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class UploadResponse {
  final String id;
  final String url;
  final String? thumbnailUrl;
  final String? mediumUrl;
  final int? width;
  final int? height;
  final int fileSize;
  final String mimeType;
  final double? duration;

  UploadResponse({
    required this.id,
    required this.url,
    this.thumbnailUrl,
    this.mediumUrl,
    this.width,
    this.height,
    required this.fileSize,
    required this.mimeType,
    this.duration,
  });

  factory UploadResponse.fromJson(Map<String, dynamic> json) {
    return UploadResponse(
      id: json['id'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      mediumUrl: json['mediumUrl'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      fileSize: json['fileSize'] as int,
      mimeType: json['mimeType'] as String,
      duration: json['duration'] != null ? (json['duration'] as num).toDouble() : null,
    );
  }
}

class BatchUploadResponse {
  final List<UploadResponse> files;
  final int totalUploaded;
  final List<UploadError> failed;

  BatchUploadResponse({
    required this.files,
    required this.totalUploaded,
    required this.failed,
  });

  factory BatchUploadResponse.fromJson(Map<String, dynamic> json) {
    return BatchUploadResponse(
      files: (json['files'] as List<dynamic>)
          .map((e) => UploadResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalUploaded: json['totalUploaded'] as int,
      failed: (json['failed'] as List<dynamic>)
          .map((e) => UploadError.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasFailures => failed.isNotEmpty;
  bool get allSucceeded => failed.isEmpty;
}

class UploadError {
  final String fileName;
  final String error;

  UploadError({
    required this.fileName,
    required this.error,
  });

  factory UploadError.fromJson(Map<String, dynamic> json) {
    return UploadError(
      fileName: json['fileName'] as String,
      error: json['error'] as String,
    );
  }
}
