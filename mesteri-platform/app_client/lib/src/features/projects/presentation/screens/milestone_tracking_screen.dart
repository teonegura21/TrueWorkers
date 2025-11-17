import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/models/milestone.dart';
import '../../../../common/services/milestone_state_manager.dart';
import '../../../../core/theme/app_theme.dart';

class MilestoneTrackingScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;

  const MilestoneTrackingScreen({
    super.key,
    required this.projectId,
    required this.projectTitle,
  });

  @override
  State<MilestoneTrackingScreen> createState() => _MilestoneTrackingScreenState();
}

class _MilestoneTrackingScreenState extends State<MilestoneTrackingScreen> {
  late MilestoneStateManager _milestoneManager;

  @override
  void initState() {
    super.initState();
    _milestoneManager = MilestoneStateManager();
    _initializeMilestones();
  }

  Future<void> _initializeMilestones() async {
    await _milestoneManager.initialize(widget.projectId);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _milestoneManager,
      child: Consumer<MilestoneStateManager>(
        builder: (context, milestoneManager, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Urmărire Etape'),
              backgroundColor: AppTheme.surfaceColor,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // Project Header
                  _buildProjectHeader(),
                  
                  const SizedBox(height: 24),
                  
                  // Loading indicator
                  if (milestoneManager.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (milestoneManager.hasError)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Eroare: ${milestoneManager.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _initializeMilestones,
                            child: const Text('Încearcă din nou'),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Milestone Timeline
                    _buildMilestoneTimeline(),
                    
                    const SizedBox(height: 24),
                    
                    // Current Milestone Details
                    Expanded(
                      child: _buildCurrentMilestoneDetails(),
                    ),
                    
                    // Action Buttons
                    _buildActionButtons(),
                  ],
                ],
              ),
            ),
          );
        },
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

  Widget _buildMilestoneTimeline() {
    return Consumer<MilestoneStateManager>(
      builder: (context, milestoneManager, child) {
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
              ...milestoneManager.milestones.asMap().entries.map((entry) {
                final index = entry.key;
                final milestone = entry.value;
                final isCompleted = milestone.status == 'completed';
                final isInProgress = milestone.status == 'in_progress';
                final isCurrent = index == milestoneManager.currentMilestoneIndex;
                
                return _buildMilestoneItem(milestone, index, isCompleted, isInProgress, isCurrent);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMilestoneItem(
    Milestone milestone,
    int index,
    bool isCompleted,
    bool isInProgress,
    bool isCurrent,
  ) {
    return Consumer<MilestoneStateManager>(
      builder: (context, milestoneManager, child) {
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted 
                          ? AppTheme.successColor 
                          : (isInProgress ? AppTheme.primaryColor : Colors.grey[300]),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCurrent ? AppTheme.primaryColor : Colors.transparent,
                          width: 2,
                        ),
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
                    if (index < milestoneManager.milestones.length - 1)
                      Container(
                        width: 2,
                        height: 40,
                        color: isCompleted ? AppTheme.successColor : Colors.grey[300],
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => milestoneManager.setCurrentMilestoneIndex(index),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isCurrent ? AppTheme.primaryColor.withValues(alpha: 0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent ? AppTheme.primaryColor : Colors.grey[200]!,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  milestone.title,
                                  style: TextStyle(
                                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                    color: isCurrent ? AppTheme.primaryColor : null,
                                  ),
                                ),
                              ),
                              if (milestone.status == 'completed')
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
                              else if (milestone.status == 'in_progress')
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
                          const SizedBox(height: 8),
                          Text(
                            milestone.description,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurfaceSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: milestone.progress,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              milestone.status == 'completed' 
                                ? AppTheme.successColor 
                                : AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(milestone.progress * 100).toInt()}% finalizat',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrentMilestoneDetails() {
    return Consumer<MilestoneStateManager>(
      builder: (context, milestoneManager, child) {
        if (milestoneManager.milestones.isEmpty) {
          return const Center(child: Text('Nu există etape disponibile'));
        }

        final currentMilestone = milestoneManager.currentMilestone;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detalii Etapă Curentă',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Milestone Info
              _buildDetailItem('Titlu Etapă', currentMilestone.title),
              _buildDetailItem('Descriere', currentMilestone.description),
              _buildDetailItem('Perioadă', '${currentMilestone.startDate} - ${currentMilestone.endDate}'),
              _buildDetailItem('Cost Estimat', currentMilestone.estimatedCost),
              _buildDetailItem('Cost Real', currentMilestone.actualCost),
              
              const SizedBox(height: 16),
              
              // Payment Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status Plată',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentDetailItem('Sumă', currentMilestone.paymentAmount),
                    _buildPaymentDetailItem('Status', currentMilestone.paymentStatus == 'released' ? 'Eliberată' : 'În Așteptare'),
                    _buildPaymentDetailItem('Metodă', 'Escrow - Mangopay'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Consumer<MilestoneStateManager>(
      builder: (context, milestoneManager, child) {
        if (milestoneManager.milestones.isEmpty) {
          return const SizedBox.shrink();
        }

        final currentMilestone = milestoneManager.currentMilestone;
        final isLoading = milestoneManager.isLoading;
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              if (currentMilestone.status == 'in_progress')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _handleApproveMilestone(milestoneManager),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Aprobă Finalizarea Etapei'),
                  ),
                )
              else if (currentMilestone.status == 'pending')
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isLoading 
                        ? null 
                        : () => _handleStartMilestone(milestoneManager, milestoneManager.currentMilestoneIndex),
                    child: const Text('Pornește Etapa'),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Această etapă este deja finalizată'),
                        ),
                      );
                    },
                    child: const Text('Etapă Finalizată'),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _showMilestoneDetails(currentMilestone),
                  child: const Text('Vezi Toate Detaliile'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleApproveMilestone(MilestoneStateManager milestoneManager) async {
    final success = await milestoneManager.approveCurrentMilestone();
    
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Etapă aprobată cu succes!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eroare la aprobarea etapei'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleStartMilestone(MilestoneStateManager milestoneManager, int index) async {
    final success = await milestoneManager.startMilestone(index);
    
    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Etapă începută cu succes!'),
          backgroundColor: AppTheme.primaryColor,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eroare la pornirea etapei'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showMilestoneDetails(Milestone milestone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return _MilestoneDetailsSheet(milestone: milestone);
      },
    );
  }
}

class _MilestoneDetailsSheet extends StatelessWidget {
  final Milestone milestone;

  const _MilestoneDetailsSheet({required this.milestone});

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
                'Detalii Etapă',
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
          
          // Detailed Info
          _buildDetailSection(context, 'Informații Generale', [
            {'label': 'Titlu', 'value': milestone.title},
            {'label': 'Descriere', 'value': milestone.description},
            {'label': 'Status', 'value': _getStatusText(milestone.status)},
            {'label': 'Progres', 'value': '${(milestone.progress * 100).toInt()}%'},
          ]),
          
          const SizedBox(height: 24),
          
          _buildDetailSection(context, 'Perioadă', [
            {'label': 'Dată Început', 'value': milestone.startDate},
            {'label': 'Dată Final', 'value': milestone.endDate},
          ]),
          
          const SizedBox(height: 24),
          
          _buildDetailSection(context, 'Costuri', [
            {'label': 'Cost Estimat', 'value': milestone.estimatedCost},
            {'label': 'Cost Real', 'value': milestone.actualCost},
          ]),
          
          const SizedBox(height: 24),
          
          _buildDetailSection(context, 'Plăți', [
            {'label': 'Sumă', 'value': milestone.paymentAmount},
            {'label': 'Status Plată', 'value': milestone.paymentStatus == 'released' ? 'Eliberată' : 'În Așteptare'},
            {'label': 'Metodă', 'value': 'Escrow - Mangopay'},
          ]),
          
          const SizedBox(height: 24),
          
          Center(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Închide'),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, String title, List<Map<String, String>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['label']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceSecondary,
                        ),
                      ),
                    ),
                    Text(
                      item['value']!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Finalizat';
      case 'in_progress':
        return 'În Progres';
      case 'pending':
        return 'În Așteptare';
      default:
        return status;
    }
  }
}

