import 'package:flutter/foundation.dart';
import '../../common/models/milestone.dart';
import '../../common/services/milestone_service.dart';

class MilestoneStateManager extends ChangeNotifier {
  final MilestoneService _milestoneService = MilestoneService();
  
  bool _isLoading = false;
  String _projectId = '';
  List<Milestone> _milestones = [];
  int _currentMilestoneIndex = 0;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  List<Milestone> get milestones => _milestones;
  Milestone get currentMilestone => _milestones[_currentMilestoneIndex];
  int get currentMilestoneIndex => _currentMilestoneIndex;
  String? get error => _error;
  bool get hasError => _error != null;

  // Initialize with project data
  Future<void> initialize(String projectId) async {
    if (_projectId == projectId && _milestones.isNotEmpty) {
      return;
    }

    _projectId = projectId;
    await loadMilestones();
  }

  // Load all milestones for the project
  Future<void> loadMilestones() async {
    if (_isLoading) return;
    
    _setLoading(true);
    _setError(null);
    
    try {
      _milestones = await _milestoneService.getMilestones(_projectId);
      
      // Find the first in_progress milestone, or default to index 0
      _currentMilestoneIndex = _milestones.indexWhere(
        (milestone) => milestone.status == 'in_progress'
      );
      
      if (_currentMilestoneIndex == -1) {
        _currentMilestoneIndex = 0;
      }
      
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Update current milestone index
  void setCurrentMilestoneIndex(int index) {
    if (index >= 0 && index < _milestones.length) {
      _currentMilestoneIndex = index;
      notifyListeners();
    }
  }

  // Approve current milestone completion
  Future<bool> approveCurrentMilestone() async {
    if (_isLoading) return false;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final currentMilestone = _milestones[_currentMilestoneIndex];
      final updatedMilestone = await _milestoneService.approveMilestoneCompletion(
        _projectId,
        currentMilestone.id,
      );
      
      // Update the milestone in our list
      _milestones[_currentMilestoneIndex] = updatedMilestone;
      
      // Move to next milestone if available
      if (_currentMilestoneIndex < _milestones.length - 1) {
        _currentMilestoneIndex++;
        // Start the next milestone
        final nextMilestone = _milestones[_currentMilestoneIndex];
        if (nextMilestone.status == 'pending') {
          final startedMilestone = await _milestoneService.startMilestone(
            _projectId,
            nextMilestone.id,
          );
          _milestones[_currentMilestoneIndex] = startedMilestone;
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Start a milestone
  Future<bool> startMilestone(int index) async {
    if (_isLoading) return false;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final milestone = _milestones[index];
      final updatedMilestone = await _milestoneService.startMilestone(
        _projectId,
        milestone.id,
      );
      
      _milestones[index] = updatedMilestone;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update milestone progress
  Future<bool> updateMilestoneProgress(int index, double progress) async {
    if (_isLoading) return false;
    
    _setLoading(true);
    _setError(null);
    
    try {
      final milestone = _milestones[index];
      final updatedMilestone = await _milestoneService.updateMilestoneProgress(
        _projectId,
        milestone.id,
        progress,
      );
      
      _milestones[index] = updatedMilestone;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _setError(null);
  }
}
