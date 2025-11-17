import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/projects_service.dart';

class MilestoneManagementScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const MilestoneManagementScreen({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<MilestoneManagementScreen> createState() => _MilestoneManagementScreenState();
}

class _MilestoneManagementScreenState extends State<MilestoneManagementScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _estimatedCostController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final ProjectsService _projectsService = ProjectsService();

  bool _isLoading = false;
  bool _showAddMilestoneForm = false;
  String? _error;
  List<dynamic> _milestones = [];

  @override
  void initState() {
    super.initState();
    _loadMilestones();
  }

  Future<void> _loadMilestones() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final milestones = await _projectsService.getProjectMilestones(widget.projectId);

      if (mounted) {
        setState(() {
          _milestones = milestones;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().contains('Exception: ')
              ? e.toString().substring(e.toString().indexOf('Exception: ') + 11)
              : e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedCostController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Etape'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _showAddMilestoneForm = true;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Project Header
            _buildProjectHeader(),
            
            const SizedBox(height: 24),
            
            // Milestone List
            Expanded(
              child: _buildMilestoneList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMilestoneDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.work,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.projectTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${widget.projectId}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.successColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'În Desfășurare',
              style: TextStyle(
                color: AppTheme.successColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Etapizare Proiect',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _milestones.length,
              itemBuilder: (context, index) {
                return _buildMilestoneItem(_milestones[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(Map<String, dynamic> milestone, int index) {
    final isCompleted = milestone['status'] == 'completed';
    final isInProgress = milestone['status'] == 'in_progress';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted 
                ? AppTheme.successColor.withValues(alpha: 0.1) 
                : (isInProgress ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.grey[50]),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted 
                      ? AppTheme.successColor 
                      : (isInProgress ? AppTheme.primaryColor : Colors.grey[300]),
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 20,
                        color: Colors.white,
                      )
                    : Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCompleted 
                              ? Colors.white 
                              : (isInProgress ? AppTheme.primaryColor : Colors.grey[600]),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    milestone['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCompleted 
                        ? AppTheme.successColor 
                        : (isInProgress ? AppTheme.primaryColor : null),
                    ),
                  ),
                ),
                if (milestone['status'] == 'completed')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Finalizat',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else if (milestone['status'] == 'in_progress')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'În Progres',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'În Așteptare',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  milestone['description'] as String,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: milestone['progress'] as double,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    milestone['status'] == 'completed' 
                      ? AppTheme.successColor 
                      : AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMilestoneDetail(
                        Icons.calendar_today,
                        '${milestone['startDate']} - ${milestone['endDate']}',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMilestoneDetail(
                        Icons.attach_money,
                        milestone['estimatedCost'] as String,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _showEditMilestoneDialog(milestone);
                        },
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Editează'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (milestone['status'] == 'in_progress')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showMarkAsCompletedDialog(milestone, index);
                          },
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Finalizează'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                        ),
                      )
                    else if (milestone['status'] == 'pending')
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _startMilestone(milestone, index);
                          },
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Pornește'),
                        ),
                      )
                    else
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Etapă finalizată'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle, size: 16),
                          label: const Text('Finalizată'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneDetail(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.onSurfaceSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.onSurfaceSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _showAddMilestoneDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return _AddMilestoneSheet(
          onAddMilestone: _addMilestone,
        );
      },
    );
  }

  void _showEditMilestoneDialog(Map<String, dynamic> milestone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return _EditMilestoneSheet(
          milestone: milestone,
          onUpdateMilestone: _updateMilestone,
        );
      },
    );
  }

  void _showMarkAsCompletedDialog(Map<String, dynamic> milestone, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Finalizează Etapa'),
          content: Text('Sunteți sigur că doriți să marcați etapa "${milestone['title']}" ca finalizată?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _markMilestoneAsCompleted(index);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
              ),
              child: const Text('Finalizează'),
            ),
          ],
        );
      },
    );
  }

  void _addMilestone(Map<String, String> milestoneData) {
    setState(() {
      _milestones.add({
        'id': '${_milestones.length + 1}',
        'title': milestoneData['title'],
        'description': milestoneData['description'],
        'status': 'pending',
        'progress': 0.0,
        'estimatedCost': milestoneData['estimatedCost'],
        'actualCost': '0 RON',
        'startDate': milestoneData['startDate'],
        'endDate': milestoneData['endDate'],
        'paymentStatus': 'pending',
        'paymentAmount': milestoneData['estimatedCost'],
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Etapă adăugată cu succes!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _updateMilestone(Map<String, dynamic> milestone, Map<String, String> updatedData) {
    setState(() {
      final index = _milestones.indexWhere((m) => m['id'] == milestone['id']);
      if (index != -1) {
        _milestones[index] = {
          ..._milestones[index],
          'title': updatedData['title'],
          'description': updatedData['description'],
          'estimatedCost': updatedData['estimatedCost'],
          'startDate': updatedData['startDate'],
          'endDate': updatedData['endDate'],
        };
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Etapă actualizată cu succes!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _startMilestone(Map<String, dynamic> milestone, int index) {
    setState(() {
      _milestones[index]['status'] = 'in_progress';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Etapă începută!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _markMilestoneAsCompleted(int index) {
    setState(() {
      _milestones[index]['status'] = 'completed';
      _milestones[index]['progress'] = 1.0;
      _milestones[index]['paymentStatus'] = 'released';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Etapă finalizată cu succes!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}

class _AddMilestoneSheet extends StatefulWidget {
  final Function(Map<String, String>) onAddMilestone;

  const _AddMilestoneSheet({required this.onAddMilestone});

  @override
  State<_AddMilestoneSheet> createState() => _AddMilestoneSheetState();
}

class _AddMilestoneSheetState extends State<_AddMilestoneSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _estimatedCostController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedCostController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Adaugă Etapă Nouă',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Form Fields
          _buildTextFormField(
            controller: _titleController,
            label: 'Titlu Etapă',
            hint: 'Introduceți titlul etapei',
            icon: Icons.title,
          ),
          
          const SizedBox(height: 16),
          
          _buildTextFormField(
            controller: _descriptionController,
            label: 'Descriere',
            hint: 'Descrieți etapa în detaliu',
            icon: Icons.description,
            maxLines: 3,
          ),
          
          const SizedBox(height: 16),
          
          _buildTextFormField(
            controller: _estimatedCostController,
            label: 'Cost Estimat (RON)',
            hint: 'Introduceți costul estimat',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _startDateController,
                  label: 'Dată Început',
                  hint: 'DD/MM/YYYY',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextFormField(
                  controller: _endDateController,
                  label: 'Dată Final',
                  hint: 'DD/MM/YYYY',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.datetime,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleAddMilestone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Adaugă Etapa'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _handleAddMilestone() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _estimatedCostController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vă rugăm să completați toate câmpurile'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        widget.onAddMilestone({
          'title': _titleController.text,
          'description': _descriptionController.text,
          'estimatedCost': _estimatedCostController.text,
          'startDate': _startDateController.text,
          'endDate': _endDateController.text,
        });

        Navigator.pop(context);
      }
    });
  }
}

class _EditMilestoneSheet extends StatefulWidget {
  final Map<String, dynamic> milestone;
  final Function(Map<String, dynamic>, Map<String, String>) onUpdateMilestone;

  const _EditMilestoneSheet({
    required this.milestone,
    required this.onUpdateMilestone,
  });

  @override
  State<_EditMilestoneSheet> createState() => _EditMilestoneSheetState();
}

class _EditMilestoneSheetState extends State<_EditMilestoneSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _estimatedCostController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.milestone['title'] as String);
    _descriptionController = TextEditingController(text: widget.milestone['description'] as String);
    _estimatedCostController = TextEditingController(text: widget.milestone['estimatedCost'] as String);
    _startDateController = TextEditingController(text: widget.milestone['startDate'] as String);
    _endDateController = TextEditingController(text: widget.milestone['endDate'] as String);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _estimatedCostController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Editează Etapa',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Form Fields
          _buildTextFormField(
            controller: _titleController,
            label: 'Titlu Etapă',
            hint: 'Introduceți titlul etapei',
            icon: Icons.title,
          ),
          
          const SizedBox(height: 16),
          
          _buildTextFormField(
            controller: _descriptionController,
            label: 'Descriere',
            hint: 'Descrieți etapa în detaliu',
            icon: Icons.description,
            maxLines: 3,
          ),
          
          const SizedBox(height: 16),
          
          _buildTextFormField(
            controller: _estimatedCostController,
            label: 'Cost Estimat (RON)',
            hint: 'Introduceți costul estimat',
            icon: Icons.attach_money,
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTextFormField(
                  controller: _startDateController,
                  label: 'Dată Început',
                  hint: 'DD/MM/YYYY',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextFormField(
                  controller: _endDateController,
                  label: 'Dată Final',
                  hint: 'DD/MM/YYYY',
                  icon: Icons.calendar_today,
                  keyboardType: TextInputType.datetime,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleUpdateMilestone,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Actualizează Etapa'),
            ),
          ),
          
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _handleUpdateMilestone() {
    if (_titleController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _estimatedCostController.text.isEmpty ||
        _startDateController.text.isEmpty ||
        _endDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vă rugăm să completați toate câmpurile'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(milliseconds: 1000)).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        widget.onUpdateMilestone(widget.milestone, {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'estimatedCost': _estimatedCostController.text,
          'startDate': _startDateController.text,
          'endDate': _endDateController.text,
        });

        Navigator.pop(context);
      }
    });
  }
}
