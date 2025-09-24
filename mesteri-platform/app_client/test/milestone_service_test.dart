import 'package:flutter_test/flutter_test.dart';
import 'package:app_client/src/common/services/milestone_service.dart';

void main() {
  group('MilestoneService', () {
    late MilestoneService milestoneService;

    setUp(() {
      milestoneService = MilestoneService();
    });

    test('should get milestones for a project', () async {
      final milestones = await milestoneService.getMilestones('test_project');
      
      expect(milestones, isNotEmpty);
      expect(milestones.length, greaterThan(0));
    });

    test('should get a specific milestone', () async {
      final milestone = await milestoneService.getMilestone('test_project', '1');
      
      expect(milestone, isNotNull);
      expect(milestone!.id, '1');
      expect(milestone.title, 'Proiectare și Planificare');
    });

    test('should update milestone progress', () async {
      final updatedMilestone = await milestoneService.updateMilestoneProgress(
        'test_project',
        '2',
        0.8,
      );
      
      expect(updatedMilestone.progress, 0.8);
      expect(updatedMilestone.status, 'in_progress');
    });

    test('should approve milestone completion', () async {
      final completedMilestone = await milestoneService.approveMilestoneCompletion(
        'test_project',
        '1',
      );
      
      expect(completedMilestone.progress, 1.0);
      expect(completedMilestone.status, 'completed');
      expect(completedMilestone.paymentStatus, 'released');
    });

    test('should start a milestone', () async {
      final startedMilestone = await milestoneService.startMilestone(
        'test_project',
        '3',
      );
      
      expect(startedMilestone.status, 'in_progress');
      expect(startedMilestone.progress, 0.1);
    });
  });
}
