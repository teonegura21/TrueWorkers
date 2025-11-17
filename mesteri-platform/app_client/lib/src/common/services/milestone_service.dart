import 'package:intl/intl.dart';
import '../../common/models/milestone.dart';
import 'package:app_client/src/core/services/projects_api_service.dart';
import 'package:app_client/src/core/models/api_models.dart' as api;

class MilestoneService {
  static final MilestoneService _instance = MilestoneService._internal();
  factory MilestoneService() => _instance;
  MilestoneService._internal();

  final ProjectsApiService _api = ProjectsApiService();
  final DateFormat _dateFmt = DateFormat('dd MMM yyyy');

  // Get all milestones for a project
  Future<List<Milestone>> getMilestones(String projectId) async {
    final apiMilestones = await _api.getProjectMilestones(projectId);
    return apiMilestones.map((m) => _mapApiToUi(m)).toList();
  }

  // Get a specific milestone
  Future<Milestone?> getMilestone(String projectId, String milestoneId) async {
    final list = await getMilestones(projectId);
    return list.firstWhere((m) => m.id == milestoneId);
  }

  // Update milestone progress
  Future<Milestone> updateMilestoneProgress(
    String projectId,
    String milestoneId,
    double progress,
  ) async {
    // Backend may not support progress; try updating status based on progress
    final status = progress >= 1.0
        ? 'completed'
        : (progress > 0 ? 'inProgress' : 'pending');
    final updated = await _api.updateMilestone(projectId, milestoneId, {
      'status': status,
    });
    return _mapApiToUi(updated);
  }

  // Approve milestone completion
  Future<Milestone> approveMilestoneCompletion(
    String projectId,
    String milestoneId,
  ) async {
    final updated = await _api.markMilestoneCompleted(projectId, milestoneId);
    return _mapApiToUi(updated).copyWith(paymentStatus: 'released');
  }

  // Add new milestone
  Future<Milestone> addMilestone(String projectId, Milestone milestone) async {
    final created = await _api.createMilestone(
      projectId: projectId,
      title: milestone.title,
      description: milestone.description,
      amount:
          double.tryParse(
            milestone.estimatedCost.replaceAll(RegExp(r'[^0-9\.]'), ''),
          ) ??
          0,
      dueDate: DateTime.now().add(const Duration(days: 7)),
      isPaymentRequired: true,
    );
    return _mapApiToUi(created);
  }

  // Update existing milestone
  Future<Milestone> updateMilestone(
    String projectId,
    Milestone milestone,
  ) async {
    final updated = await _api.updateMilestone(projectId, milestone.id, {
      'title': milestone.title,
      'description': milestone.description,
    });
    return _mapApiToUi(updated);
  }

  // Delete milestone
  Future<void> deleteMilestone(String projectId, String milestoneId) async {
    // If backend supports deletion, implement here. For now, mark as cancelled.
    await _api.updateMilestone(projectId, milestoneId, {'status': 'cancelled'});
  }

  // Start milestone
  Future<Milestone> startMilestone(String projectId, String milestoneId) async {
    final updated = await _api.updateMilestone(projectId, milestoneId, {
      'status': 'inProgress',
    });
    return _mapApiToUi(updated).copyWith(progress: 0.1);
  }

  // Mapper from API milestone to UI milestone
  Milestone _mapApiToUi(api.Milestone m) {
    final status =
        (m.status.toLowerCase() == 'inprogress' ||
            m.status.toLowerCase() == 'in_progress')
        ? 'in_progress'
        : (m.status.toLowerCase() == 'completed' ? 'completed' : 'pending');
    final progress = status == 'completed'
        ? 1.0
        : (status == 'in_progress' ? 0.5 : 0.0);
    final est = m.amount.toStringAsFixed(0);
    final created = m.createdAt;
    final due = m.dueDate;
    return Milestone(
      id: m.id,
      title: m.title,
      description: m.description,
      status: status,
      progress: progress,
      estimatedCost: '$est RON',
      actualCost: status == 'completed' ? '$est RON' : '0 RON',
      startDate: _dateFmt.format(created),
      endDate: _dateFmt.format(due),
      paymentStatus: status == 'completed' ? 'released' : 'pending',
      paymentAmount: '$est RON',
    );
  }
}
