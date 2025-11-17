import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';
import 'package:app_client/src/core/models/job_models.dart';
import 'package:app_client/src/features/common/widgets/trust_badge.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final bool _isLoading = false;
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalii Lucrare'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showJobOptions();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Job Header
            _buildJobHeader(),

            const SizedBox(height: 24),

            // Job Details
            Expanded(child: _buildJobDetails()),

            const SizedBox(height: 24),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobHeader() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLowOpacity,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(widget.job.status),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TrustBadge(type: TrustBadgeType.secure, size: 20),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            widget.job.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.job.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
            maxLines: _isExpanded ? null : 3,
            overflow: _isExpanded ? null : TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                widget.job.location,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '15 Dec 2024',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
                size: 20,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? 'Arată mai puțin' : 'Arată mai mult',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobDetails() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status-specific content
          _buildStatusSpecificContent(),

          const SizedBox(height: 32),

          // Job Information
          _buildJobInformation(),

          const SizedBox(height: 32),

          // Trust Indicators
          _buildTrustIndicators(),

          const SizedBox(height: 32),

          // Timeline
          _buildJobTimeline(),
        ],
      ),
    );
  }

  Widget _buildStatusSpecificContent() {
    switch (widget.job.status) {
      case JobStatus.offersReceived:
        return _buildOffersContent();
      case JobStatus.inProgress:
        return _buildInProgressContent();
      case JobStatus.completed:
        return _buildCompletedContent();
      case JobStatus.pending:
        return const SizedBox.shrink();
      case JobStatus.cancelled:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOffersContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryVeryLowOpacity,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryLowOpacity),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLowOpacity,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_offer,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.job.offers.length} Oferte Primite',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Preț estimat: ${widget.job.offers.map((o) => o.price).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)} - ${widget.job.offers.map((o) => o.price).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} RON',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TrustBadge(type: TrustBadgeType.rated, size: 16),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Navigare către Ofertele Primite'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
              icon: const Icon(Icons.visibility, size: 18),
              label: const Text('Vezi Toate Ofertele'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressContent() {
    if (widget.job.acceptedOffer == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MesteriColors.warningVeryLowOpacity,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MesteriColors.warningLowOpacity),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MesteriColors.warningLowOpacity,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.construction,
                  color: AppTheme.warningColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lucrare în Desfășurare',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '60% Finalizat',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TrustBadge(type: TrustBadgeType.secure, size: 16),
            ],
          ),

          const SizedBox(height: 16),

          // Accepted Offer Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MesteriColors.warningHighOpacity),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: MesteriColors.warningLowOpacity,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.warningColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                                                                        widget.job.acceptedOffer!.mesterName ?? 'Nume necunoscut',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Preț agreat: ${widget.job.acceptedOffer!.price.toStringAsFixed(2)} RON',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.onSurfaceSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                TrustBadge(type: TrustBadgeType.verified, size: 16),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress Bar
          const LinearProgressIndicator(
            value: 0.6,
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.warningColor),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Deschidere chat cu meșterul...'),
                        backgroundColor: AppTheme.primaryColor,
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Mesaje'),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showCompletionDialog();
                  },
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Finalizează'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MesteriColors.successVeryLowOpacity,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MesteriColors.successLowOpacity),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MesteriColors.successLowOpacity,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lucrare Finalizată',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Finalizată pe 15 Dec 2024',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TrustBadge(type: TrustBadgeType.rated, size: 16),
            ],
          ),

          const SizedBox(height: 16),

          // Final Details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MesteriColors.successHighOpacity),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preț final',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${widget.job.finalPrice?.toStringAsFixed(2) ?? 'N/A'} RON',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (widget.job.rating != null) ...[
                  Row(
                    children: [
                      Text(
                        widget.job.rating!.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Deschidere recenzie...'),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
              },
              icon: const Icon(Icons.rate_review_outlined, size: 18),
              label: const Text('Lasă o Recenzie'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informații Lucrare',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildInfoItem(
          'Categorie',
          'Instalații Sanitare',
          Icons.category_outlined,
        ),

        const SizedBox(height: 16),

        _buildInfoItem(
          'Locație',
          widget.job.location,
          Icons.location_on_outlined,
        ),

        const SizedBox(height: 16),

        _buildInfoItem(
          'Buget Estimat',
          '800-1200 RON',
          Icons.attach_money_outlined,
        ),

        const SizedBox(height: 16),

        _buildInfoItem(
          'Data Postării',
          '15 Dec 2024, 14:30',
          Icons.calendar_today_outlined,
        ),

        const SizedBox(height: 16),

        _buildInfoItem(
          'ID Lucrare',
          '#JOB${widget.job.id.substring(0, 8).toUpperCase()}',
          Icons.confirmation_number_outlined,
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryLowOpacity,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustIndicators() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motorul de Încredere',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            TrustBadge(
              type: TrustBadgeType.secure,
              size: 24,
              showLabel: true,
              onTap: () {
                _showTrustInfo(
                  'Plăți Securizate',
                  'Toate plățile sunt păstrate într-un cont escrow până la finalizarea lucrării. '
                      'Banii sunt eliberați doar după confirmarea ta.',
                );
              },
            ),
            const SizedBox(width: 16),
            TrustBadge(
              type: TrustBadgeType.verified,
              size: 24,
              showLabel: true,
              onTap: () {
                _showTrustInfo(
                  'Meșteri Verificați',
                  'Toți meșterii sunt verificați prin procesul nostru riguros de KYC/KYB. '
                      'Poți avea încredere în profesionalismul lor.',
                );
              },
            ),
            const SizedBox(width: 16),
            TrustBadge(
              type: TrustBadgeType.rated,
              size: 24,
              showLabel: true,
              onTap: () {
                _showTrustInfo(
                  'Recenzii Verificate',
                  'Doar clienții care au finalizat plăți reale pot lăsa recenzii. '
                      'Toate recenziile sunt 100% autentice.',
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJobTimeline() {
    final timelineSteps = [
      {
        'title': 'Lucrare Postată',
        'description': 'Ai postat lucrarea pe platformă',
        'date': '15 Dec 2024, 14:30',
        'status': 'completed',
      },
      {
        'title': 'Oferte Primite',
        'description': '3 meșteri au trimis oferte',
        'date': '15 Dec 2024, 15:45',
        'status': 'completed',
      },
      {
        'title': 'Ofertă Acceptată',
        'description': 'Ai acceptat oferta lui Ion Popescu',
        'date': '15 Dec 2024, 16:20',
        'status': 'completed',
      },
      {
        'title': 'Plată Efectuată',
        'description': 'Ai depus 950 RON în contul escrow',
        'date': '15 Dec 2024, 17:30',
        'status': 'completed',
      },
      {
        'title': 'Lucrare În Desfășurare',
        'description': 'Meșterul lucrează la proiect',
        'date': '16 Dec 2024, 09:00',
        'status': 'in_progress',
      },
      {
        'title': 'Lucrare Finalizată',
        'description': 'Confirmă finalizarea lucrării',
        'date': 'Estimare: 18 Dec 2024',
        'status': 'pending',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline Lucrare',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        ...timelineSteps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          return _buildTimelineStep(
            step,
            index,
            index == timelineSteps.length - 1,
          );
        }),
      ],
    );
  }

  Widget _buildTimelineStep(Map<String, dynamic> step, int index, bool isLast) {
    final status = step['status'] as String;
    final isCompleted = status == 'completed';
    final isInProgress = status == 'in_progress';

    Color getStatusColor() {
      if (isCompleted) return AppTheme.successColor;
      if (isInProgress) return AppTheme.warningColor;
      return Colors.grey;
    }

    IconData getStatusIcon() {
      if (isCompleted) return Icons.check_circle;
      if (isInProgress) return Icons.construction;
      return Icons.pending;
    }

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
                    color: getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    getStatusIcon(),
                    color: getStatusColor(),
                    size: 20,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted
                        ? AppTheme.successColor
                        : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: isCompleted
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isCompleted
                          ? AppTheme.successColor
                          : AppTheme.onSurfaceColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['description'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step['date'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Înapoi'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: AppTheme.primaryHighOpacity,
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
                  : Text(_getActionText()),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(JobStatus status) {
    switch (status) {
      case JobStatus.offersReceived:
        return 'Oferte Primite';
      case JobStatus.inProgress:
        return 'În Desfășurare';
      case JobStatus.completed:
        return 'Finalizat';
      case JobStatus.pending:
        return 'Nou';
      case JobStatus.cancelled:
        return 'Anulat';
    }
  }

  String _getActionText() {
    switch (widget.job.status) {
      case JobStatus.offersReceived:
        return 'Vezi Ofertele';
      case JobStatus.inProgress:
        return 'Finalizează';
      case JobStatus.completed:
        return 'Lasă Recenzie';
      case JobStatus.pending:
        return 'Vezi Ofertele';
      case JobStatus.cancelled:
        return 'Închide';
    }
  }

  void _handleAction() {
    switch (widget.job.status) {
      case JobStatus.offersReceived:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigare către Ofertele Primite'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        break;
      case JobStatus.inProgress:
        _showCompletionDialog();
        break;
      case JobStatus.completed:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deschidere formular recenzie'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        break;
      case JobStatus.pending:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigare către Ofertele Primite'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        break;
      case JobStatus.cancelled:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Închidere'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        break;
    }
  }

  void _showJobOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Opțiuni Lucrare',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildOptionItem('Editează Lucrare', Icons.edit_outlined, () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Funcționalitatea va fi disponibilă în curând',
                    ),
                  ),
                );
              }),
              _buildOptionItem('Șterge Lucrare', Icons.delete_outline, () {
                Navigator.pop(context);
                _showDeleteConfirmationDialog();
              }),
              _buildOptionItem(
                'Raportează Problemă',
                Icons.report_outlined,
                () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Funcționalitatea va fi disponibilă în curând',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Anulează'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete, color: AppTheme.errorColor, size: 24),
              SizedBox(width: 12),
              Text('Șterge Lucrare'),
            ],
          ),
          content: const Text(
            'Ești sigur că vrei să ștergi această lucrare? Această acțiune este ireversibilă.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lucrare ștearsă cu succes!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Șterge'),
            ),
          ],
        );
      },
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.successColor, size: 24),
              SizedBox(width: 12),
              Text('Confirmă Finalizarea'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ești sigur că ai finalizat lucrarea?'),
              const SizedBox(height: 8),
              Text(
                'Această acțiune va elibera plata către meșter.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MesteriColors.successLowOpacity,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.successColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.security,
                      color: AppTheme.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Plata este securizată și va fi transferată imediat după confirmare.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Lucrare finalizată! Plata a fost eliberată.',
                    ),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirmă Finalizarea'),
            ),
          ],
        );
      },
    );
  }

  void _showTrustInfo(String title, String description) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Închide'),
            ),
          ],
        );
      },
    );
  }
}
