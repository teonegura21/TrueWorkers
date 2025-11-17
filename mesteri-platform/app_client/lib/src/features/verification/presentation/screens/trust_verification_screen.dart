import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

// Trust badges and verification levels
enum TrustLevel {
  basic, // Basic profile completion
  verified, // Email/phone verified
  trusted, // ID and background verified
  elite, // Premium craftsman status
}

class VerificationStatus {
  final String type;
  final String title;
  final String description;
  final bool isVerified;
  final DateTime? verifiedDate;
  final String? documentUrl;
  final Color statusColor;

  const VerificationStatus({
    required this.type,
    required this.title,
    required this.description,
    required this.isVerified,
    this.verifiedDate,
    this.documentUrl,
    required this.statusColor,
  });
}

// Craftsman verification profile
class CraftsmanVerification {
  final String craftsmanId;
  final String name;
  final TrustLevel trustLevel;
  final double rating;
  final int projectsCompleted;
  final List<VerificationStatus> verifications;
  final bool hasInsurance;
  final List<String> trustBadges;
  final DateTime memberSince;

  const CraftsmanVerification({
    required this.craftsmanId,
    required this.name,
    required this.trustLevel,
    required this.rating,
    required this.projectsCompleted,
    required this.verifications,
    required this.hasInsurance,
    required this.trustBadges,
    required this.memberSince,
  });

  Color getTrustLevelColor() {
    switch (trustLevel) {
      case TrustLevel.basic:
        return AppTheme.onSurfaceSecondary;
      case TrustLevel.verified:
        return AppTheme.primaryColor;
      case TrustLevel.trusted:
        return AppTheme.successColor;
      case TrustLevel.elite:
        return const Color(0xFFFFC107); // Amber
    }
  }

  String getTrustLevelText() {
    switch (trustLevel) {
      case TrustLevel.basic:
        return 'BASIC';
      case TrustLevel.verified:
        return 'VERIFICAT';
      case TrustLevel.trusted:
        return 'DE ÎNCREDERE';
      case TrustLevel.elite:
        return 'ELITÄ';
    }
  }
}

// Mock verification data
final CraftsmanVerification mockCraftsmanVerification = CraftsmanVerification(
  craftsmanId: 'craft_001',
  name: 'Ion Popescu',
  trustLevel: TrustLevel.trusted,
  rating: 4.8,
  projectsCompleted: 125,
  hasInsurance: true,
  memberSince: DateTime(2022, 3, 15),
  trustBadges: [
    'verified',
    'insured',
    'professional',
    'quick_response',
    'high_rated',
  ],
  verifications: [
    VerificationStatus(
      type: 'identity',
      title: 'Identitate Verificată',
      description: 'Carte de identitate și date personale verificate',
      isVerified: true,
      verifiedDate: DateTime(2024, 1, 15),
      statusColor: AppTheme.successColor,
    ),

    VerificationStatus(
      type: 'licenses',
      title: 'Licențe Autorizate',
      description: 'Autorizații ASC • Electrician calificat • Instalații gaz',
      isVerified: true,
      verifiedDate: DateTime(2023, 12, 10),
      documentUrl: 'licenses.pdf',
      statusColor: AppTheme.successColor,
    ),

    VerificationStatus(
      type: 'insurance',
      title: 'Asigurare Profesională',
      description: 'Asigurare răspundere civilă de 50.000 lei',
      isVerified: true,
      verifiedDate: DateTime(2024, 2, 20),
      documentUrl: 'insurance.pdf',
      statusColor: AppTheme.successColor,
    ),

    VerificationStatus(
      type: 'background',
      title: 'Verificare Antecedente',
      description: 'Certificate de cazier și antecedente profesionale',
      isVerified: true,
      verifiedDate: DateTime(2024, 2, 15),
      statusColor: AppTheme.successColor,
    ),

    VerificationStatus(
      type: 'training',
      title: 'Cursuri Specializate',
      description: 'Cursuri PSM • Securitate instalații ',
      isVerified: true,
      verifiedDate: DateTime(2023, 10, 22),
      documentUrl: 'training.pdf',
      statusColor: AppTheme.successColor,
    ),

    VerificationStatus(
      type: 'reviews',
      title: 'Recenzii Verificate',
      description: 'Recenzii autentice verificate de platformă',
      isVerified: true,
      verifiedDate: DateTime.now().subtract(const Duration(days: 1)),
      statusColor: AppTheme.successColor,
    ),

    VerificationStatus(
      type: 'portfolio',
      title: 'Portofoliu Aprobat',
      description: 'Poze și descrieri verificate',
      isVerified: false,
      statusColor: AppTheme.warningColor,
    ),
  ],
);

class TrustVerificationScreen extends StatefulWidget {
  final String craftsmanId;

  const TrustVerificationScreen({super.key, required this.craftsmanId});

  @override
  State<TrustVerificationScreen> createState() =>
      _TrustVerificationScreenState();
}

class _TrustVerificationScreenState extends State<TrustVerificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final craftsman = mockCraftsmanVerification;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificare de Încredere'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _shareVerification(),
            tooltip: 'Împărtășește Verificare',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => _showHelp(),
            tooltip: 'Ajutor Verificare',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: craftsman.getTrustLevelColor(),
          labelColor: craftsman.getTrustLevelColor(),
          unselectedLabelColor: AppTheme.onSurfaceSecondary,
          tabs: const [
            Tab(text: '⛡️ Verificări'),
            Tab(text: '🏆 Antene & Insigna'),
            Tab(text: '🎯 Statistici'),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVerificationsTab(craftsman),
          _buildBadgesTab(craftsman),
          _buildStatisticsTab(craftsman),
        ],
      ),

      floatingActionButton: _buildContactFab(craftsman),
    );
  }

  Widget _buildVerificationsTab(CraftsmanVerification craftsman) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trust Level Header
          _buildTrustLevelHeader(craftsman),

          const SizedBox(height: 24),

          // Verifications List
          Text(
            'Documentele Verificate',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ...craftsman.verifications.map(_buildVerificationItem),

          const SizedBox(height: 32),

          // Trust Meter
          _buildTrustMeter(craftsman),

          const SizedBox(height: 24),

          // Risk Assessment
          _buildRiskAssessment(),

          const SizedBox(height: 24),

          // Guidelines
          _buildVerificationGuidelines(),
        ],
      ),
    );
  }

  Widget _buildTrustLevelHeader(CraftsmanVerification craftsman) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            craftsman.getTrustLevelColor(),
            craftsman.getTrustLevelColor().withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: craftsman.getTrustLevelColor().withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTrustLevelIcon(craftsman.trustLevel),
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Trust Level Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    craftsman.getTrustLevelText(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  craftsman.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${craftsman.rating}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${craftsman.projectsCompleted} proiecte',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Membru din ${_formatDate(craftsman.memberSince)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(VerificationStatus verification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: verification.isVerified
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.warningColor.withValues(alpha: 0.3),
          width: verification.isVerified ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: verification.statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                _getVerificationIcon(verification.type),
                color: verification.statusColor,
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        verification.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: verification.statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            verification.isVerified
                                ? Icons.verified_rounded
                                : Icons.pending_rounded,
                            size: 14,
                            color: verification.statusColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            verification.isVerified
                                ? 'Verificat'
                                : 'În așteptare',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: verification.statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  verification.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),

                if (verification.verifiedDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Verificat în ${_formatDate(verification.verifiedDate!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ),

                if (verification.documentUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: InkWell(
                      onTap: () => _viewDocument(verification.documentUrl!),
                      child: Row(
                        children: [
                          Icon(
                            Icons.attach_file_rounded,
                            size: 14,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Vezi document',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustMeter(CraftsmanVerification craftsman) {
    final verifiedCount = craftsman.verifications
        .where((v) => v.isVerified)
        .length;
    final totalCount = craftsman.verifications.length;
    final trustScore = (verifiedCount / totalCount) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.security_rounded,
                color: craftsman.getTrustLevelColor(),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Scor de Încredere',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Trust Score
          Text(
            '${trustScore.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: craftsman.getTrustLevelColor(),
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '($verifiedCount/$totalCount verificări completate)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
            ),
          ),

          const SizedBox(height: 16),

          // Trust Progress Bar
          LinearProgressIndicator(
            value: trustScore / 100,
            backgroundColor: AppTheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              craftsman.getTrustLevelColor(),
            ),
          ),

          const SizedBox(height: 16),

          // Trust Level Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTrustLevelIndicator(
                'BASIC',
                trustScore >= 20,
                AppTheme.onSurfaceSecondary,
              ),
              _buildTrustLevelIndicator(
                'VERIFICAT',
                trustScore >= 50,
                AppTheme.primaryColor,
              ),
              _buildTrustLevelIndicator(
                'ÎNCREDERE',
                trustScore >= 80,
                AppTheme.successColor,
              ),
              _buildTrustLevelIndicator(
                'ELITÄ',
                trustScore >= 95,
                const Color(0xFFFFC107),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustLevelIndicator(String level, bool isActive, Color color) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isActive ? color : AppTheme.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive
                ? Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          level,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isActive ? color : AppTheme.onSurfaceSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskAssessment() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_rounded,
                color: AppTheme.successColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Evaluare Riscuri',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            '✅ Riscuri scăzute - Meșter complet verificat și de încredere',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.successColor,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              _buildRiskIndicator(
                'Calitate',
                AppTheme.successColor,
                'Excelentă',
              ),
              const SizedBox(width: 16),
              _buildRiskIndicator(
                'Încredere',
                AppTheme.successColor,
                'Risc scăzut',
              ),
              const SizedBox(width: 16),
              _buildRiskIndicator(
                'Siguranță',
                AppTheme.successColor,
                'Asigurat',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationGuidelines() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Ghid Verificări',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildGuidelineItem(
            'Verificare de identitate',
            'Documente de identitate personale pentru verificare',
          ),

          _buildGuidelineItem(
            'Autorizații profesionale',
            'Licențe și certificate pentru lucrările efectuate',
          ),

          _buildGuidelineItem(
            'Asigurare RCA',
            'Asigurare de răspundere civilă pentru lucrări de construcții',
          ),

          _buildGuidelineItem(
            'Antecedente penale',
            'Certificat de cazier judiciar curat',
          ),

          const SizedBox(height: 12),

          Text(
            '💡 Toate documentele sunt criptate și verificate manual de echipa noastră.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '→',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskIndicator(String label, Color color, String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $status',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBadgesTab(CraftsmanVerification craftsman) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insigne de Încredere',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Badge Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: craftsman.trustBadges.length,
            itemBuilder: (context, index) =>
                _buildTrustBadge(craftsman.trustBadges[index]),
          ),

          const SizedBox(height: 24),

          // Badge Explanations
          Text(
            'Ce înseamnă insignia',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          ...craftsman.trustBadges.map(_buildBadgeExplanation),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(String badge) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _getBadgeIcon(badge),
          const SizedBox(height: 8),
          Text(
            _getBadgeTitle(badge),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeExplanation(String badge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _getBadgeIcon(badge),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getBadgeTitle(badge),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _getBadgeDescription(badge),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab(CraftsmanVerification craftsman) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performanță și Statistici',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 24),

          // Key Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatMetric(
                  'Rating',
                  '${craftsman.rating.toStringAsFixed(1)}/5',
                  Icons.star_rounded,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatMetric(
                  'Proiecte',
                  craftsman.projectsCompleted.toString(),
                  Icons.work_rounded,
                  AppTheme.primaryColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatMetric(
                  'Rată Succes',
                  '97%',
                  Icons.query_stats_rounded,
                  AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatMetric(
                  'Membru',
                  '${DateTime.now().year - craftsman.memberSince.year} ani',
                  Icons.calendar_month_rounded,
                  AppTheme.warningColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Performance Chart Placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart_rounded,
                    size: 48,
                    color: AppTheme.onSurfaceSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Grafic performanță lunare',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Certification Timeline
          _buildCertificationTimeline(craftsman),
        ],
      ),
    );
  }

  Widget _buildStatMetric(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificationTimeline(CraftsmanVerification craftsman) {
    final certifications = craftsman.verifications
        .where((v) => v.isVerified)
        .map((v) => {'title': v.title, 'date': v.verifiedDate})
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Certificări Cronologie',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          ...certifications.map((cert) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cert['title'] as String,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        if (cert['date'] != null)
                          Text(
                            _formatDate(cert['date'] as DateTime),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.onSurfaceSecondary,
                                  fontSize: 10,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildContactFab(CraftsmanVerification craftsman) {
    return FloatingActionButton.extended(
      onPressed: () => _contactCraftsman(craftsman),
      icon: const Icon(Icons.message_rounded),
      label: const Text('Contactează'),
      backgroundColor: craftsman.getTrustLevelColor(),
    );
  }

  // Helper methods
  IconData _getTrustLevelIcon(TrustLevel level) {
    switch (level) {
      case TrustLevel.basic:
        return Icons.person_outline_rounded;
      case TrustLevel.verified:
        return Icons.verified_rounded;
      case TrustLevel.trusted:
        return Icons.security_rounded;
      case TrustLevel.elite:
        return Icons.star_rounded;
    }
  }

  IconData _getVerificationIcon(String type) {
    switch (type) {
      case 'identity':
        return Icons.person_rounded;
      case 'licenses':
        return Icons.document_scanner_rounded;
      case 'insurance':
        return Icons.shield_rounded;
      case 'background':
        return Icons.fact_check_rounded;
      case 'training':
        return Icons.school_rounded;
      case 'reviews':
        return Icons.star_rounded;
      case 'portfolio':
        return Icons.photo_library_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _getBadgeIcon(String badge) {
    IconData icon;
    Color color;
    switch (badge) {
      case 'verified':
        icon = Icons.verified_rounded;
        color = AppTheme.successColor;
        break;
      case 'insured':
        icon = Icons.security_rounded;
        color = AppTheme.primaryColor;
        break;
      case 'professional':
        icon = Icons.engineering_rounded;
        color = AppTheme.primaryColor;
        break;
      case 'quick_response':
        icon = Icons.flash_on_rounded;
        color = const Color(0xFFFFC107);
        break;
      case 'high_rated':
        icon = Icons.star_rounded;
        color = Colors.amber;
        break;
      default:
        icon = Icons.badge_rounded;
        color = AppTheme.onSurfaceSecondary;
    }

    return Icon(icon, color: color, size: 32);
  }

  String _getBadgeTitle(String badge) {
    switch (badge) {
      case 'verified':
        return 'Verificat';
      case 'insured':
        return 'Asigurat';
      case 'professional':
        return 'Profesional';
      case 'quick_response':
        return 'Răspuns Rapid';
      case 'high_rated':
        return 'Top Evaluări';
      default:
        return badge;
    }
  }

  String _getBadgeDescription(String badge) {
    switch (badge) {
      case 'verified':
        return 'Documente personale și profesionale verificate complet';
      case 'insured':
        return 'Asigurare de răspundere civilă până la 50.000 lei';
      case 'professional':
        return 'Licențe și autorizații profesionale valide';
      case 'quick_response':
        return 'Răspunde la cereri în mai puțin de 1 oră';
      case 'high_rated':
        return 'Rating ul mediu peste 4.5 din 5 stele';
      default:
        return 'Insignă de încredere verificată de platformă';
    }
  }

  // Action handlers
  void _shareVerification() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link-ul verificării a fost copiat!')),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajutor Verificare'),
        content: const Text(
          '✅ Verificare înseamnă că meșterul a trecut prin procesul nostru de evaluare\n\n'
          '✅ Verifcăm identitatea, licențele, asigurările și antecedentele\n\n'
          '✅ Meșterii veríați oferă garantje pentru lucrările efectuate',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Îțeleg'),
          ),
        ],
      ),
    );
  }

  void _viewDocument(String url) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Deschidere document: $url')));
  }

  void _contactCraftsman(CraftsmanVerification craftsman) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Mesaj către ${craftsman.name}')));
  }
}

// Helper widget for QR code display (placeholder) Renaming to avoid conflicts
