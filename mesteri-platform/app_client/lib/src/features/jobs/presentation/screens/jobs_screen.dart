import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_client/src/core/models/job_models.dart';
import 'package:app_client/src/core/services/jobs_api_service.dart';
import 'package:app_client/src/features/jobs/presentation/widgets/job_card.dart';
import 'package:app_client/src/features/jobs/presentation/widgets/job_skeleton.dart';
import 'package:app_client/src/features/jobs/presentation/widgets/empty_jobs_state.dart';
import 'package:app_client/src/features/jobs/presentation/screens/post_job_screen.dart';
import 'package:app_client/src/core/theme/app_theme.dart';
import 'package:app_client/src/core/errors/error_type.dart';
import 'package:app_client/src/core/widgets/error_view.dart';
import 'package:app_client/src/core/widgets/skeleton_loading.dart';
import 'package:app_client/src/core/utils/accessibility_utils.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  AppError? _error;
  final JobsApiService _jobsService = JobsApiService();
  List<Job> _jobsOffers = [];
  List<Job> _jobsInProgress = [];
  List<Job> _jobsCompleted = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);
    _fetchJobs();
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryLight,
              Colors.white,
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildJobsTab(_jobsOffers, 'Oferte Primite'),
                  _buildJobsTab(_jobsInProgress, 'În Desfășurare'),
                  _buildJobsTab(_jobsCompleted, 'Finalizate'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lucrările Mele',
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AccessibilityUtils.accessibleIconButton(
                icon: Icons.add,
                label: 'Adaugă lucrare nouă',
                tooltip: 'Apasă pentru a posta o lucrare nouă',
                color: Colors.white,
                size: 28,
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PostJobScreen()),
                  );
                  if (result == true && mounted) {
                    context.announce('Lucrarea a fost postată cu succes');
                    await _fetchJobs();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Oferte Primite'),
                Tab(text: 'În Desfășurare'),
                Tab(text: 'Finalizate'),
              ],
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              indicator: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobsTab(List<Job> jobs, String tabTitle) {
    // Show error state with retry option
    if (_error != null && !_isLoading) {
      return ErrorView(
        error: _error!,
        onRetry: _error!.canRetry ? _fetchJobs : null,
      );
    }

    // Show skeleton loading
    if (_isLoading) {
      return _buildLoadingState();
    }

    // Show empty state
    if (jobs.isEmpty) {
      return _buildEmptyState(tabTitle);
    }

    // Show job list
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: Semantics(
        label: '$tabTitle, ${jobs.length} lucrări',
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: JobCard(
                job: jobs[index],
                onTap: () {
                  context.announce('Ai selectat lucrarea: ${jobs[index].title}');
                  // Navigate to job details
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ai selectat: ${jobs[index].title}'),
                      backgroundColor: MesteriColors.primary,
                    ),
                  );
                },
                onChanged: _fetchJobs,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Semantics(
      label: 'Se încarcă lucrările',
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: const JobCardSkeleton(),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String tabTitle) {
    switch (tabTitle) {
      case 'Oferte Primite':
        return EmptyJobsState(
          title: 'Nicio ofertă primită încă',
          subtitle:
              'Postează o lucrare nouă și meșterii verificați îți vor trimite oferte în curând.',
          icon: Icons.local_offer_outlined,
          actionText: 'Postează o Lucrare',
          onActionPressed: () async {
            final result = await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PostJobScreen()));
            if (result == true && mounted) {
              await _fetchJobs();
            }
          },
        );
      case 'În Desfășurare':
        return EmptyJobsState(
          title: 'Nicio lucrare în desfășurare',
          subtitle:
              'Acceptă o ofertă pentru a începe o lucrare sau așteaptă să primești oferte pentru lucrările postate.',
          icon: Icons.construction_outlined,
          actionText: 'Vezi Ofertele',
          onActionPressed: () {
            // Switch to Offers tab
            _tabController.animateTo(0);
          },
        );
      case 'Finalizate':
        return EmptyJobsState(
          title: 'Nicio lucrare finalizată',
          subtitle:
              'După ce finalizezi lucrările tale, ele vor apărea aici pentru a lăsa recenzii.',
          icon: Icons.check_circle_outline,
          actionText: 'Postează o Lucrare',
          onActionPressed: () async {
            final result = await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PostJobScreen()));
            if (result == true && mounted) {
              await _fetchJobs();
            }
          },
        );
      default:
        return const Center(child: Text('Nicio lucrare de afișat.'));
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jobs = await _jobsService.getJobs(limit: 100);
      if (!mounted) return;

      setState(() {
        _jobsOffers = jobs
            .where((j) => j.status == JobStatus.offersReceived)
            .toList();
        _jobsInProgress = jobs
            .where((j) => j.status == JobStatus.inProgress)
            .toList();
        _jobsCompleted = jobs
            .where((j) => j.status == JobStatus.completed)
            .toList();
        _isLoading = false;
        _error = null;
      });

      // Announce success to screen readers
      if (mounted) {
        context.announce('Lucrări încărcate cu succes');
      }
    } catch (e) {
      if (!mounted) return;

      final appError = AppError.fromException(e);
      setState(() {
        _isLoading = false;
        _error = appError;
      });

      // Announce error to screen readers
      if (mounted) {
        context.announce('Eroare la încărcarea lucrărilor');
      }
    }
  }
}
