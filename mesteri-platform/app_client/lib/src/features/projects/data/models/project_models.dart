
/// Project Status from Client Perspective
enum ProjectStatus {
  pending, // Waiting craftsman acceptance
  accepted, // Craftsman accepted, preparing
  inProgress, // Work in progress
  review, // Ready for client review
  completed, // Project completed
  disputed, // Issue raised
  cancelled // Cancelled
}

/// Message types
enum MessageType {
  clientToCraftsman,
  craftsmanToClient,
  systemNotification
}

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;
  final String? attachmentUrl;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.attachmentUrl,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    bool? isRead,
    String? attachmentUrl,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
    );
  }
}

class ProjectMilestone {
  final String id;
  final String title;
  final String description;
  final int progress; // 0-100
  final DateTime dueDate;
  final bool isCompleted;
  final double value;
  final String status;

  const ProjectMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.progress,
    required this.dueDate,
    required this.isCompleted,
    required this.value,
    required this.status,
  });

  ProjectMilestone copyWith({
    String? id,
    String? title,
    String? description,
    int? progress,
    DateTime? dueDate,
    bool? isCompleted,
    double? value,
    String? status,
  }) {
    return ProjectMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      value: value ?? this.value,
      status: status ?? this.status,
    );
  }
}

class ActiveProject {
  final String id;
  final String jobId;
  final String craftsmanId;
  final String craftsmanName;
  final String craftsmanPhoto;
  final double craftsmanRating;
  final ProjectStatus status;
  final String projectTitle;
  final String description;
  final List<ProjectMilestone> milestones;
  final int completedMilestones;
  final List<ChatMessage> messages;
  final double totalValue;
  final double paidAmount;
  final DateTime startDate;
  final DateTime? completionDate;
  final DateTime? deadline;
  final String location;
  final String? cancellationReason;
  final List<String> projectImages;

  const ActiveProject({
    required this.id,
    required this.jobId,
    required this.craftsmanId,
    required this.craftsmanName,
    required this.craftsmanPhoto,
    required this.craftsmanRating,
    required this.status,
    required this.projectTitle,
    required this.description,
    required this.milestones,
    required this.completedMilestones,
    required this.messages,
    required this.totalValue,
    required this.paidAmount,
    required this.startDate,
    this.completionDate,
    this.deadline,
    required this.location,
    this.cancellationReason,
    this.projectImages = const [],
  });

  double get progress => milestones.isNotEmpty
      ? (completedMilestones / milestones.length)
      : 0.0;

  double get paymentProgress => totalValue > 0 ? paidAmount / totalValue : 0.0;

  ActiveProject copyWith({
    String? id,
    String? jobId,
    String? craftsmanId,
    String? craftsmanName,
    String? craftsmanPhoto,
    double? craftsmanRating,
    ProjectStatus? status,
    String? projectTitle,
    String? description,
    List<ProjectMilestone>? milestones,
    int? completedMilestones,
    List<ChatMessage>? messages,
    double? totalValue,
    double? paidAmount,
    DateTime? startDate,
    DateTime? completionDate,
    DateTime? deadline,
    String? location,
    String? cancellationReason,
    List<String>? projectImages,
  }) {
    return ActiveProject(
      id: id ?? this.id,
      jobId: jobId ?? this.jobId,
      craftsmanId: craftsmanId ?? this.craftsmanId,
      craftsmanName: craftsmanName ?? this.craftsmanName,
      craftsmanPhoto: craftsmanPhoto ?? this.craftsmanPhoto,
      craftsmanRating: craftsmanRating ?? this.craftsmanRating,
      status: status ?? this.status,
      projectTitle: projectTitle ?? this.projectTitle,
      description: description ?? this.description,
      milestones: milestones ?? this.milestones,
      completedMilestones: completedMilestones ?? this.completedMilestones,
      messages: messages ?? this.messages,
      totalValue: totalValue ?? this.totalValue,
      paidAmount: paidAmount ?? this.paidAmount,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      deadline: deadline ?? this.deadline,
      location: location ?? this.location,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      projectImages: projectImages ?? this.projectImages,
    );
  }
}
