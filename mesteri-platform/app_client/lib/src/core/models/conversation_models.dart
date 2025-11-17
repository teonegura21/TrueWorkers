import 'package:equatable/equatable.dart';

/// Safely parses a nullable ISO-8601 value into a [DateTime] while
/// falling back to the current time to keep the UI responsive if the
/// backend payload is incomplete.
DateTime _parseDateTime(Object? value) {
  final raw = value?.toString();
  if (raw == null || raw.isEmpty) {
    return DateTime.now();
  }
  return DateTime.tryParse(raw) ?? DateTime.now();
}

/// Represents a participant visible inside a conversation thread.
class ConversationParticipant extends Equatable {
  /// The canonical user identifier.
  final String id;

  /// Role assigned by the backend (CLIENT, MESTER, SUPPORT, etc.).
  final String role;

  /// Display name rendered inside the thread and headers.
  final String name;

  /// Optional avatar URL for richer UI rendering.
  final String? avatarUrl;

  const ConversationParticipant({
    required this.id,
    required this.role,
    required this.name,
    this.avatarUrl,
  });

  /// Builds a participant from the backend conversation payload.
  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      id: (json['id'] as String?)?.trim() ?? '',
      role: (json['role'] as String?)?.trim() ?? 'SUPPORT',
      name: (json['name'] as String?)?.trim() ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, role, name, avatarUrl];
}

/// Represents a media attachment that belongs to a message.
class ConversationMessageAttachment extends Equatable {
  /// Attachment identifier used for preview/download flows.
  final String id;

  /// GCS bucket established by the Trust Engine storage workflow.
  final String bucket;

  /// Object path inside the bucket.
  final String objectPath;

  /// MIME type reported by the uploader.
  final String contentType;

  /// Reported file size in bytes.
  final int fileSize;

  /// Lifecycle status (PENDING, AVAILABLE, BLOCKED, etc.).
  final String status;

  const ConversationMessageAttachment({
    required this.id,
    required this.bucket,
    required this.objectPath,
    required this.contentType,
    required this.fileSize,
    required this.status,
  });

  /// Hydrates an attachment link from the storage API payload.
  factory ConversationMessageAttachment.fromJson(Map<String, dynamic> json) {
    return ConversationMessageAttachment(
      id: (json['id'] as String?)?.trim() ?? '',
      bucket: (json['bucket'] as String?)?.trim() ?? '',
      objectPath: (json['objectPath'] as String?)?.trim() ?? '',
      contentType: (json['contentType'] as String?)?.trim() ?? 'application/octet-stream',
      fileSize: (json['fileSize'] as num?)?.toInt() ?? 0,
      status: (json['status'] as String?)?.trim() ?? 'PENDING',
    );
  }

  @override
  List<Object?> get props => [id, bucket, objectPath, contentType, fileSize, status];
}

/// Immutable representation of a single conversation message.
class ConversationMessage extends Equatable {
  /// Unique message identifier.
  final String id;

  /// Message kind (TEXT, SYSTEM_NOTICE, etc.).
  final String kind;

  /// Optional rich-text body.
  final String? body;

  /// Server-issued send timestamp.
  final DateTime sentAt;

  /// Optional edit timestamp maintained by the backend.
  final DateTime? editedAt;

  /// Participant that authored the message.
  final ConversationParticipant? sender;

  /// Attachments associated with the message.
  final List<ConversationMessageAttachment> attachments;

  const ConversationMessage({
    required this.id,
    required this.kind,
    required this.body,
    required this.sentAt,
    this.editedAt,
    this.sender,
    this.attachments = const [],
  });

  /// Creates a message from the conversations API payload.
  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    final attachmentsJson = json['attachments'] as List<dynamic>?;
    return ConversationMessage(
      id: (json['id'] as String?)?.trim() ?? '',
      kind: (json['kind'] as String?)?.trim() ?? 'TEXT',
      body: (json['body'] as String?)?.trim(),
      sentAt: _parseDateTime(json['sentAt']),
      editedAt: json['editedAt'] != null ? _parseDateTime(json['editedAt']) : null,
      sender: json['sender'] is Map<String, dynamic>
          ? ConversationParticipant.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
      attachments: List<ConversationMessageAttachment>.unmodifiable(
        (attachmentsJson ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ConversationMessageAttachment.fromJson),
      ),
    );
  }

  /// Produces a modified copy while keeping the original instance immutable.
  ConversationMessage copyWith({
    String? kind,
    String? body,
    DateTime? sentAt,
    DateTime? editedAt,
    ConversationParticipant? sender,
    List<ConversationMessageAttachment>? attachments,
  }) {
    return ConversationMessage(
      id: id,
      kind: kind ?? this.kind,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
      editedAt: editedAt ?? this.editedAt,
      sender: sender ?? this.sender,
      attachments: List<ConversationMessageAttachment>.unmodifiable(
        attachments ?? this.attachments,
      ),
    );
  }

  @override
  List<Object?> get props => [id, kind, body, sentAt, editedAt, sender, attachments];
}

/// High-level summary used for inbox lists.
class ConversationSummary extends Equatable {
  /// Conversation identifier transmitted to detail endpoints.
  final String id;

  /// Human-readable title (project title fallback when missing).
  final String title;

  /// Conversation type emitted by the backend (PROJECT, SUPPORT, etc.).
  final String type;

  /// Optional project metadata bag (id/title/status).
  final Map<String, dynamic>? project;

  /// Participants displayed inside summary tiles.
  final List<ConversationParticipant> participants;

  /// Unread message count for the active user.
  final int unreadCount;

  /// Last message available for quick preview.
  final ConversationMessage? lastMessage;

  /// Timestamp used for ordering the inbox.
  final DateTime updatedAt;

  /// Whether the related project is still active.
  final bool isActive;

  const ConversationSummary({
    required this.id,
    required this.title,
    required this.type,
    required this.participants,
    required this.unreadCount,
    this.lastMessage,
    required this.updatedAt,
    this.project,
    this.isActive = true,
  });

  /// Hydrates a summary row from the list API payload.
  factory ConversationSummary.fromJson(Map<String, dynamic> json) {
    final participantsJson = json['participants'] as List<dynamic>?;
    final rawTitle = (json['title'] as String?)?.trim();
    return ConversationSummary(
      id: (json['id'] as String?)?.trim() ?? '',
      title: rawTitle != null && rawTitle.isNotEmpty ? rawTitle : 'Conversation',
      type: (json['type'] as String?)?.trim() ?? 'PROJECT',
      project: json['project'] is Map<String, dynamic>
          ? json['project'] as Map<String, dynamic>
          : null,
      participants: List<ConversationParticipant>.unmodifiable(
        (participantsJson ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ConversationParticipant.fromJson),
      ),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastMessage: json['lastMessage'] is Map<String, dynamic>
          ? ConversationMessage.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : null,
      updatedAt: _parseDateTime(json['updatedAt']),
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }

  /// Produces a modified summary, keeping immutable semantics.
  ConversationSummary copyWith({
    String? title,
    String? type,
    Map<String, dynamic>? project,
    List<ConversationParticipant>? participants,
    int? unreadCount,
    ConversationMessage? lastMessage,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ConversationSummary(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      participants: List<ConversationParticipant>.unmodifiable(
        participants ?? this.participants,
      ),
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      updatedAt: updatedAt ?? this.updatedAt,
      project: project ?? this.project,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, title, type, project, participants, unreadCount, lastMessage, updatedAt, isActive];
}

/// Represents a conversation thread including pagination metadata.
class ConversationThread extends Equatable {
  /// Summary metadata for the selected thread.
  final ConversationSummary summary;

  /// Messages ordered ascending for UI rendering.
  final List<ConversationMessage> messages;

  /// Total number of messages available on the server.
  final int total;

  /// Skip offset used for pagination.
  final int skip;

  /// Page size used for pagination.
  final int take;

  const ConversationThread({
    required this.summary,
    required this.messages,
    required this.total,
    required this.skip,
    required this.take,
  });

  /// Builds a thread object from the detail API payload.
  factory ConversationThread.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>?;
    final meta = json['meta'] as Map<String, dynamic>?;
    return ConversationThread(
      summary: ConversationSummary.fromJson(
        json['conversation'] as Map<String, dynamic>,
      ),
      messages: List<ConversationMessage>.unmodifiable(
        (itemsJson ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(ConversationMessage.fromJson),
      ),
      total: (meta?['total'] as num?)?.toInt() ?? 0,
      skip: (meta?['skip'] as num?)?.toInt() ?? 0,
      take: (meta?['take'] as num?)?.toInt() ?? 50,
    );
  }

  /// Creates an updated thread snapshot after new messages arrive.
  ConversationThread copyWith({
    ConversationSummary? summary,
    List<ConversationMessage>? messages,
    int? total,
    int? skip,
    int? take,
  }) {
    return ConversationThread(
      summary: summary ?? this.summary,
      messages: List<ConversationMessage>.unmodifiable(
        messages ?? this.messages,
      ),
      total: total ?? this.total,
      skip: skip ?? this.skip,
      take: take ?? this.take,
    );
  }

  @override
  List<Object?> get props => [summary, messages, total, skip, take];
}

/// DTO returned by the signed URL API when preparing uploads.
class SignedUrlResponse extends Equatable {
  /// Attachment identifier created server-side for later linkage.
  final String attachmentId;

  /// Pre-signed URL used by the client to upload the file.
  final String uploadUrl;

  /// GCS bucket hosting the object path.
  final String bucket;

  /// Storage path (folder/object) inside the bucket.
  final String objectPath;

  /// Expiration timestamp so the UI can refresh URLs proactively.
  final DateTime expiresAt;

  const SignedUrlResponse({
    required this.attachmentId,
    required this.uploadUrl,
    required this.bucket,
    required this.objectPath,
    required this.expiresAt,
  });

  /// Creates a response from the storage service payload.
  factory SignedUrlResponse.fromJson(Map<String, dynamic> json) {
    return SignedUrlResponse(
      attachmentId: (json['attachmentId'] as String?)?.trim() ?? '',
      uploadUrl: (json['uploadUrl'] as String?)?.trim() ?? '',
      bucket: (json['bucket'] as String?)?.trim() ?? '',
      objectPath: (json['objectPath'] as String?)?.trim() ?? '',
      expiresAt: _parseDateTime(json['expiresAt']),
    );
  }

  @override
  List<Object?> get props => [attachmentId, uploadUrl, bucket, objectPath, expiresAt];
}
