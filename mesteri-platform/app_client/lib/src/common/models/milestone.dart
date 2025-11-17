class Milestone {
  final String id;
  final String title;
  final String description;
  final String status; // 'completed', 'in_progress', 'pending'
  final double progress;
  final String estimatedCost;
  final String actualCost;
  final String startDate;
  final String endDate;
  final String paymentStatus; // 'released', 'pending'
  final String paymentAmount;

  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.progress,
    required this.estimatedCost,
    required this.actualCost,
    required this.startDate,
    required this.endDate,
    required this.paymentStatus,
    required this.paymentAmount,
  });

  factory Milestone.fromJson(Map<String, dynamic> json) {
    return Milestone(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String,
      progress: (json['progress'] as num).toDouble(),
      estimatedCost: json['estimatedCost'] as String,
      actualCost: json['actualCost'] as String,
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      paymentStatus: json['paymentStatus'] as String,
      paymentAmount: json['paymentAmount'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'progress': progress,
      'estimatedCost': estimatedCost,
      'actualCost': actualCost,
      'startDate': startDate,
      'endDate': endDate,
      'paymentStatus': paymentStatus,
      'paymentAmount': paymentAmount,
    };
  }

  Milestone copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    double? progress,
    String? estimatedCost,
    String? actualCost,
    String? startDate,
    String? endDate,
    String? paymentStatus,
    String? paymentAmount,
  }) {
    return Milestone(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      actualCost: actualCost ?? this.actualCost,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentAmount: paymentAmount ?? this.paymentAmount,
    );
  }
}
