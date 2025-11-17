import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../jobs/presentation/screens/jobs_discovery_screen.dart';
import '../../../offers/presentation/screens/my_offers_screen.dart';
import '../../../projects/presentation/screens/projects_screen.dart';
import '../../../earnings/presentation/screens/earnings_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Calendar all major screens for craftsmen
  final List<Widget> _screens = [
    const JobsDiscoveryScreen(), // 0: Job Discovery
    const MyOffersScreen(),      // 1: My Offers
    const ProjectsScreen(),      // 2: Active Projects
    const EarningsScreen(),      // 3: Earnings & Money
    const ProfileScreen(),       // 4: Profile & Settings
  ];

  final List<String> _titles = [
    'Caută Lucrări',
    'Ofertele Mele',
    'Proiectele Mele',
    'Veniturile Mele',
    'Profil',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getTabIcon(_selectedIndex),
              color: AppTheme.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _titles[_selectedIndex],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.surfaceColor,
      elevation: 0,
      foregroundColor: AppTheme.onSurfaceColor,
      actions: _buildAppBarActions(),
    );
  }

  List<Widget> _buildAppBarActions() {
    switch (_selectedIndex) {
      case 0: // Jobs Discovery
        return [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () => _showJobsFilters(),
            tooltip: 'Filtrează Lucrări',
          ),
          IconButton(
            icon: const Icon(Icons.location_on_rounded),
            onPressed: () => _showLocationFilters(),
            tooltip: 'Rază de Acțiune',
          ),
        ];
      case 1: // My Offers
        return [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () => _sortOffers(),
            tooltip: 'Sortează Oferte',
          ),
          IconButton(
            icon: const Icon(Icons.notifications_off_rounded),
            onPressed: () => _showOfferAlerts(),
            tooltip: 'Alerte Oferte Expirați',
          ),
        ];
      case 2: // Projects
        return [
          IconButton(
            icon: const Icon(Icons.calendar_today_rounded),
            onPressed: () => _showProjectCalendar(),
            tooltip: 'Calendar Proiecte',
          ),
          IconButton(
            icon: const Icon(Icons.flag_rounded),
            onPressed: () => _showMilestoneAlerts(),
            tooltip: 'Milestone-uri Urgente',
          ),
        ];
      case 3: // Earnings
        return [
          IconButton(
            icon: const Icon(Icons.trending_up_rounded),
            onPressed: () => _showEarningsStats(),
            tooltip: 'Statistici Venituri',
          ),
          IconButton(
            icon: const Icon(Icons.account_balance_wallet_rounded),
            onPressed: () => _showWalletActions(),
            tooltip: 'Acțiuni Portofel',
          ),
        ];
      default: // Profile
        return [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => _openSettings(),
            tooltip: 'P Settings',
          ),
          IconButton(
            icon: const Icon(Icons.support_agent_rounded),
            onPressed: () => _contactSupport(),
            tooltip: 'Contactează Ne'
          ),
        ];
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: AppTheme.onSurfaceSecondary,
      backgroundColor: AppTheme.surfaceColor,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.search_rounded, size: 24),
          activeIcon: Icon(Icons.search_rounded, size: 26),
          label: 'Caută',
          tooltip: 'Caută Lucrări Disponibile',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment_rounded, size: 24),
          activeIcon: Icon(Icons.assignment_rounded, size: 26),
          label: 'Oferte',
          tooltip: 'Ofertele Mele',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build_rounded, size: 24),
          activeIcon: Icon(Icons.build_rounded, size: 26),
          label: 'Muncesc',
          tooltip: 'Proiectele Active',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_rounded, size: 24),
          activeIcon: Icon(Icons.account_balance_wallet_rounded, size: 26),
          label: 'Bani',
          tooltip: 'Venitul și Portofelul Meu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded, size: 24),
          activeIcon: Icon(Icons.person_rounded, size: 26),
          label: 'Profil',
          tooltip: 'Gestionați Profilul',
        ),
      ],
    );
  }

  // Helper method to get the appropriate icon for each tab
  IconData _getTabIcon(int index) {
    switch (index) {
      case 0: return Icons.search_rounded;
      case 1: return Icons.assignment_rounded;
      case 2: return Icons.build_rounded;
      case 3: return Icons.account_balance_wallet_rounded;
      case 4: return Icons.person_rounded;
      default: return Icons.home_rounded;
    }
  }

  // Action handlers - these will show bottom sheets or navigate to settings
  void _showJobsFilters() {
    // TODO: Implement jobs filters bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filtre pentru lucrări - implementare în curând'),
      ),
    );
  }

  void _showLocationFilters() {
    // TODO: Implement location/radius filters
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Rază de căutare - implementare în curând'),
      ),
    );
  }

  void _sortOffers() {
    // TODO: Implement offers sorting options
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sortare oferte - implementare în curând'),
      ),
    );
  }

  void _showOfferAlerts() {
    // TODO: Implement offer alerts management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Alert oferte - implementare în curând'),
      ),
    );
  }

  void _showProjectCalendar() {
    // TODO: Navigate to project calendar view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calendar proiecte - implementare în curând'),
      ),
    );
  }

  void _showMilestoneAlerts() {
    // TODO: Show urgent milestones
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mile stone urgente - implementare în curând'),
      ),
    );
  }

  void _showEarningsStats() {
    // TODO: Navigate to earnings statistics
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statistici venituri - implementare în curând'),
      ),
    );
  }

  void _showWalletActions() {
    // TODO: Show wallet actions (withdraw, etc.)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Acțiuni portofel - implementare în curând'),
      ),
    );
  }

  void _openSettings() {
    // TODO: Navigate to settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Setări - implementare în curând'),
      ),
    );
  }

  void _contactSupport() {
    // TODO: Navigate to support contact
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Suport meșter - implementare în curând'),
      ),
    );
  }
}
