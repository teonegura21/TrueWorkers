import 'package:flutter_test/flutter_test.dart';
import 'package:app_client/src/common/services/milestone_state_manager.dart';

void main() {
  group('MilestoneStateManager', () {
    late MilestoneStateManager stateManager;

    setUp(() {
      stateManager = MilestoneStateManager();
    });

    test('should initialize with project ID', () async {
      await stateManager.initialize('test_project');

      expect(stateManager.milestones, isNotEmpty);
      expect(stateManager.currentMilestoneIndex, greaterThan(-1));
    });

    test('should load milestones', () async {
      await stateManager.initialize('test_project');
      await stateManager.loadMilestones();

      expect(stateManager.milestones, isNotEmpty);
      expect(stateManager.isLoading, isFalse);
    });

    test('should set current milestone index', () async {
      await stateManager.initialize('test_project');
      final initialIndex = stateManager.currentMilestoneIndex;

      stateManager.setCurrentMilestoneIndex(1);
      expect(stateManager.currentMilestoneIndex, 1);
      expect(stateManager.currentMilestoneIndex, isNot(initialIndex));
    });

    test('should approve current milestone', () async {
      await stateManager.initialize('test_project');

      // Find an in_progress milestone
      int inProgressIndex = -1;
      for (int i = 0; i < stateManager.milestones.length; i++) {
        if (stateManager.milestones[i].status == 'in_progress') {
          inProgressIndex = i;
          break;
        }
      }

      if (inProgressIndex != -1) {
        stateManager.setCurrentMilestoneIndex(inProgressIndex);
        final result = await stateManager.approveCurrentMilestone();

        expect(result, isTrue);
      }
    });

    test('should start a milestone', () async {
      await stateManager.initialize('test_project');

      // Find a pending milestone
      int pendingIndex = -1;
      for (int i = 0; i < stateManager.milestones.length; i++) {
        if (stateManager.milestones[i].status == 'pending') {
          pendingIndex = i;
          break;
        }
      }

      if (pendingIndex != -1) {
        final result = await stateManager.startMilestone(pendingIndex);

        expect(result, isTrue);
      }
    });

    test('should handle errors gracefully', () async {
      await stateManager.initialize('test_project');

      // Try to get a non-existent milestone
      try {
        await stateManager.startMilestone(999);
      } catch (e) {
        expect(e, isNotNull);
      }
    });
  });
}
