import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/user_service.dart';

enum ProfileTab {
  overview,
  portfolio,
  certifications,
  business,
  reviews,
  settings,
}

class CraftsmanshipProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String bio;
  final List<String> specialties;
  final List<String> skills;
  final double rating;
  final int completedProjects;
  final int yearsExperience;
  final String profileStatus; // verified, premium, etc.
  final bool hasInsurance;
  final List<String> trustBadges;

  const CraftsmanshipProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.bio,
    required this.specialties,
    required this.skills,
    required this.rating,
    required this.completedProjects,
    required this.yearsExperience,
    required this.profileStatus,
    this.hasInsurance = false,
    this.trustBadges = const [],
  });
}

class PortfolioItem {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final String category;
  final String serviceType;
  final double projectValue;
  final DateTime completionDate;
  final Rating rating;

  const PortfolioItem({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.category,
    required this.serviceType,
    required this.projectValue,
    required this.completionDate,
    required this.rating,
  });
}

class Rating {
  final double value;
  final String reviewText;
  final DateTime date;
  final String clientName;

  const Rating({
    required this.value,
    required this.reviewText,
    required this.date,
    required this.clientName,
  });
}

class Certificate {
  final String id;
  final String title;
  final String provider;
  final String description;
  final DateTime issuedDate;
  final DateTime? expiryDate;
  final bool isVerified;
  final String category;

  const Certificate({
    required this.id,
    required this.title,
    required this.provider,
    required this.description,
    required this.issuedDate,
    this.expiryDate,
    this.isVerified = false,
    required this.category,
  });

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  ProfileTab _selectedTab = ProfileTab.overview;
  late TabController _tabController;
  final UserService _userService = UserService();

  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _profile;
  List<dynamic> _portfolio = [];
  List<dynamic> _certificates = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Utilizator neautentificat');
      }

      final profile = await _userService.getUserProfile(currentUser.uid);
      final portfolio = await _userService.getPortfolio(currentUser.uid);
      final certificates = await _userService.getCertificates(currentUser.uid);

      if (mounted) {
        setState(() {
          _profile = profile;
          _portfolio = portfolio;
          _certificates = certificates;
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
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    setState(() {
      _selectedTab = ProfileTab.values[_tabController.index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: const Text('Profil Profesionist'),
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.share_rounded),
                  onPressed: () => _shareProfile(),
                  tooltip: 'Sharează Profil',
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => _editProfile(),
                  tooltip: 'Editează Profil',
                ),
              ],
              floating: true,
              snap: true,
              bottom: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: AppTheme.primaryColor,
                labelColor: AppTheme.primaryColor,
                unselectedLabelColor: AppTheme.onSurfaceSecondary,
                tabs: const [
                  Tab(icon: Icon(Icons.insights_rounded), text: 'Profil'),
                  Tab(icon: Icon(Icons.photo_library_rounded), text: 'Portofoliu'),
                  Tab(icon: Icon(Icons.verified_rounded), text: 'Certificate'),
                  Tab(icon: Icon(Icons.business_center_rounded), text: 'Afaceri'),
                  Tab(icon: Icon(Icons.star_rounded), text: 'Recenzii'),
                  Tab(icon: Icon(Icons.settings_rounded), text: 'Setări'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildPortfolioTab(),
            _buildCertificationsTab(),
            _buildBusinessTab(),
            _buildReviewsTab(),
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  // Overview Tab - Professional Profile Summary
  Widget _buildOverviewTab() {
    final profile = _profile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header Card
          _buildProfileHeader(),

          const SizedBox(height: 24),

          // Professional Summary
          _buildProfessionalSummary(),

          const SizedBox(height: 24),

          // Skills & Trust Badges
          _buildSkillsAndTrust(),

          const SizedBox(height: 24),

          // Quick Stats
          _buildQuickStats(),

          const SizedBox(height: 24),

          // Recent Portfolio Preview
          _buildRecentWork(),

          const SizedBox(height: 24),

          // Contact Information
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final profile = _profile;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: profile.photoUrl.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      profile.photoUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
          ),

          const SizedBox(width: 16),

          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${profile.rating.toStringAsFixed(1)} (${profile.completedProjects} proiecte)',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Trust Badges
                Wrap(
                  spacing: 8,
                  children: profile.trustBadges.take(3).map((badge) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getBadgeText(badge),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalSummary() {
    final profile = _profile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.work_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Despre Mine',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            profile.bio,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),

          // Specializations
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: profile.specialties.map((specialty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  specialty,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsAndTrust() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Abilități și Calificare',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Trust Badges
          if (_profile.trustBadges.isNotEmpty) ...[
            Text(
              'Insigne de Încredere',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: _profile.trustBadges.map((badge) {
                return _TrustBadge(badge: _getBadgeText(badge));
              }).toList(),
            ),

            const SizedBox(height: 16),
          ],

          // Skills
          if (_profile.skills.isNotEmpty) ...[
            Text(
              'Servicii Oférte',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _profile.skills.map((skill) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          skill,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final profile = _profile;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.timeline_rounded,
            title: 'Experiență',
            value: '${profile.yearsExperience} ani',
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.work_rounded,
            title: 'Proiecte Finalizate',
            value: profile.completedProjects.toString(),
            color: AppTheme.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildInsuranceStatus(),
        ),
      ],
    );
  }

  Widget _buildInsuranceStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _profile.hasInsurance
            ? AppTheme.successColor.withValues(alpha: 0.1)
            : AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _profile.hasInsurance
              ? AppTheme.successColor.withValues(alpha: 0.3)
              : AppTheme.warningColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            _profile.hasInsurance
                ? Icons.security_rounded
                : Icons.warning_rounded,
            color: _profile.hasInsurance
                ? AppTheme.successColor
                : AppTheme.warningColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            _profile.hasInsurance ? 'Asigurat' : 'Fără Asigurare',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _profile.hasInsurance
                  ? AppTheme.successColor
                  : AppTheme.warningColor,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentWork() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.photo_library_rounded,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Lucrări Recente',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _portfolio.take(4).length,
            itemBuilder: (context, index) {
              final item = _portfolio[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    if (item.imageUrls.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.photo_rounded,
                            size: 32,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        Center(
          child: TextButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: const Text('Vezi Portofoliul Complet'),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    final profile = _profile;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informații de Contact',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Icon(
                Icons.phone_rounded,
                color: AppTheme.onSurfaceSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  profile.phone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call_rounded),
                onPressed: () => _callProfessional(),
                tooltip: 'Sună',
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.email_rounded,
                color: AppTheme.onSurfaceSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  profile.email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.mail_rounded),
                onPressed: () => _emailProfessional(),
                tooltip: 'Trimite Mail',
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _messageProfessional(),
                  icon: const Icon(Icons.message_rounded),
                  label: const Text('Trimite Mesaj'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              OutlinedButton(
                onPressed: () => _viewLocation(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.location_on_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Portfolio Tab
  Widget _buildPortfolioTab() {
    return refreshablePortfolioGrid();
  }

  Widget refreshablePortfolioGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _portfolio.length,
      itemBuilder: (context, index) {
        final item = _portfolio[index];
        return PortfolioCard(item: item);
      },
    );
  }

  // Certifications Tab
  Widget _buildCertificationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _certificates.length,
      itemBuilder: (context, index) {
        final cert = _certificates[index];
        return CertificateCard(certificate: cert);
      },
    );
  }

  // Business Tab - Service Areas, Hours, Settings
  Widget _buildBusinessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ServiceAreaCard(),
          const SizedBox(height: 16),
          _WorkingHoursCard(),
          const SizedBox(height: 16),
          _BusinessSettingsCard(),
        ],
      ),
    );
  }

  // Reviews Tab
  Widget _buildReviewsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingsOverview(),
          const SizedBox(height: 24),
          _buildReviewsList(),
        ],
      ),
    );
  }

  Widget _buildRatingsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: AppTheme.ratingColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '4.8',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.onSurfaceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Din 24 recenzii',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '94% dintre clienți recomandă',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Rating breakdown
          Row(
            children: [
              const Icon(
                Icons.thumb_up_alt_rounded,
                color: AppTheme.successColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '23.cliente/calitate',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.successColor,
                ),
              ),

              const Spacer(),

              const Icon(
                Icons.thumb_down_alt_rounded,
                color: AppTheme.errorColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '1 client/termene',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _portfolio.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = _portfolio[index];
        return ReviewCard(portfolio: item);
      },
    );
  }

  // Settings Tab
  Widget _buildSettingsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SettingsGroup(
          title: 'Notificări',
          children: [
            _buildNotificationSetting(
              'Noi oferte de lucru',
              'Primit notificări când găsesc proiecte noi.',
              Icons.notifications_active_rounded,
              true,
            ),
            _buildNotificationSetting(
              'Mesaje clienți',
              'Alertelor pentru conversații noi.',
              Icons.message_rounded,
              true,
            ),
            _buildNotificationSetting(
              'Recenzii client',
              'Anunță-mă când primesc recenzii noi.',
              Icons.star_rounded,
              false,
            ),
            _buildNotificationSetting(
              'Actualizări platformă',
              'Știri și actualizări Mesteri.',
              Icons.info_rounded,
              false,
            ),
          ],
        ),

        const SizedBox(height: 24),

        _SettingsGroup(
          title: 'Cont și Confidențialitate',
          children: [
            _buildSettingItem(
              'Date personale',
              'Gestionați informațiile de profil.',
              Icons.person_rounded,
            ),
            _buildSettingItem(
              'Securitatea contului',
              'Schimbați parola și setările de securitate.',
              Icons.security_rounded,
            ),
            _buildSettingItem(
              'Confidențialitatea datelor',
              'Controlați ce partajați cu alt utilizatori.',
              Icons.privacy_tip_rounded,
            ),
            _buildSettingItem(
              'Preferințe de limbă',
              'Schimbați limba aplicației.',
              Icons.language_rounded,
            ),
          ],
        ),

        const SizedBox(height: 32),

        OutlinedButton.icon(
          onPressed: () => _logout(),
          icon: const Icon(
            Icons.logout_rounded,
            color: AppTheme.errorColor,
          ),
          label: const Text(
            'Delogare',
            style: TextStyle(color: AppTheme.errorColor),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.errorColor),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Sunteți conectat la contul pro.mes onal. Toate datele vă vor fi păstrate păstrare când vă întoarceți.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.onSurfaceSecondary,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildNotificationSetting(String title, String subtitle, IconData icon, bool isEnabled) {
    return SwitchListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.onSurfaceSecondary,
        ),
      ),
      secondary: Icon(
        icon,
        color: isEnabled ? AppTheme.primaryColor : AppTheme.onSurfaceSecondary,
      ),
      value: isEnabled,
      onChanged: (value) => _toggleNotification(title, value),
      activeThumbColor: AppTheme.primaryColor,
    );
  }

  Widget _buildSettingItem(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.onSurfaceSecondary,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.onSurfaceSecondary,
      ),
      onTap: () => _openSetting(title),
    );
  }

  // Helper methods
  String _getBadgeText(String badge) {
    switch (badge) {
      case 'verified':
        return 'Verificat';
      case 'premium':
        return 'Premium';
      case 'fast_response':
        return 'Răspunde Rapid';
      case 'high_rated':
        return 'Top Evaluații';
      default:
        return badge;
    }
  }

  // Action handlers
  void _shareProfile() {
    // TODO: Implement profile sharing
  }

  void _editProfile() {
    // TODO: Navigate to profile edit screen
  }

  void _callProfessional() {
    // TODO: Make phone call
  }

  void _emailProfessional() {
    // TODO: Compose email
  }

  void _messageProfessional() {
    // TODO: Open messaging screen
  }

  void _viewLocation() {
    // TODO: Show location on map
  }

  void _toggleNotification(String title, bool value) {
    // TODO: Save notification preference
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? 'Notificări activate pentru: $title'
              : 'Notificări dezactivate pentru: $title',
        ),
      ),
    );
  }

  void _openSetting(String title) {
    // TODO: Navigate to specific setting
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deschidere setări: $title')),
    );
  }

  void _logout() {
    // TODO: Handle logout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delogare - implementare în curând')),
    );
  }
}

// Supporting Widgets

class _TrustBadge extends StatelessWidget {
  final String badge;

  const _TrustBadge({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        badge,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PortfolioCard extends StatelessWidget {
  final PortfolioItem item;

  const PortfolioCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.photo_library_rounded,
                size: 32,
                color: Colors.grey,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppTheme.ratingColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.rating.value.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  '${item.serviceType} • ${item.projectValue.toStringAsFixed(0)} lei',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CertificateCard extends StatelessWidget {
  final Certificate certificate;

  const CertificateCard({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: certificate.isVerified
                  ? AppTheme.successColor.withValues(alpha: 0.1)
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              certificate.category.contains('Electric')
                  ? Icons.bolt_rounded
                  : certificate.category.contains('Sanitare')
                      ? Icons.plumbing_rounded
                      : Icons.verified_rounded,
              color: certificate.isVerified
                  ? AppTheme.successColor
                  : AppTheme.primaryColor,
              size: 24,
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
                        certificate.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    if (certificate.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Verificat',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  certificate.provider,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  certificate.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Icon(
                      certificate.expiryDate != null && certificate.expiryDate!.isAfter(DateTime.now())
                          ? Icons.calendar_today_rounded
                          : Icons.schedule_rounded,
                      size: 14,
                      color: AppTheme.onSurfaceSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(certificate.issuedDate) +
                          (certificate.expiryDate != null
                              ? ' - Exp: ${_formatDate(certificate.expiryDate!)}'
                              : ''),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (certificate.expiryDate != null &&
              certificate.expiryDate!.isBefore(DateTime.now().add(Duration(days: 30))))
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.warningColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final PortfolioItem portfolio;

  const ReviewCard({super.key, required this.portfolio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                child: Text(
                  portfolio.rating.clientName[0].toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      portfolio.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 2),

                    Row(
                      children: [
                        Text(
                          portfolio.rating.clientName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(portfolio.rating.date),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Row(
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppTheme.ratingColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    portfolio.rating.value.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            portfolio.rating.reviewText,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}

// _formatDate function
String _formatDate(DateTime date) {
  return '${date.day}-${date.month}-${date.year}';
}

// Missing widget classes

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _ServiceAreaCard extends StatelessWidget {
  const _ServiceAreaCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zone Servicii',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'București',
              'Ilfov',
              'Otopeni',
              'Otopeni',
              'Pantelimon',
            ].map((area) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  area,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _WorkingHoursCard extends StatelessWidget {
  const _WorkingHoursCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Program Lucru',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Luni - Vineri: 08:00 - 18:00',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sâmbătă: 08:00 - 14:00',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: AppTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Duminică: Închis',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BusinessSettingsCard extends StatelessWidget {
  const _BusinessSettingsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.outlineColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Setări Afaceri',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: Text(
              'Disponibil pentru noi proiecte',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Primit notificări pentru proiecte noi în zona ta.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            value: true,
            onChanged: (value) {},
            activeThumbColor: AppTheme.primaryColor,
          ),
          SwitchListTile(
            title: Text(
              'Lucrări urgente',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Disponibil pentru intervenții de urgență.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            value: false,
            onChanged: (value) {},
            activeThumbColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
