import 'package:flutter/material.dart';
import 'package:app_mester/src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:app_mester/src/features/jobs/presentation/screens/jobs_screen.dart';
import 'package:app_mester/src/features/projects/presentation/screens/projects_screen.dart';
import 'package:app_mester/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:app_mester/src/features/wallet/presentation/screens/wallet_screen.dart';
import 'package:app_mester/src/core/theme/app_theme.dart';
import 'package:app_mester/src/core/utils/accessibility_utils.dart';

/// Main Navigator with Bottom Navigation Bar for Craftsman App
/// Provides access to 5 main sections:
/// 1. Dashboard (Overview & Metrics)
/// 2. Jobs (Job Discovery & Offers)
/// 3. Projects (Active Projects)
/// 4. Wallet (Earnings & Withdrawals)
/// 5. Profile (Settings & Portfolio)
class MasterMainNavigator extends StatefulWidget {
  const MasterMainNavigator({super.key});

  @override
  State<MasterMainNavigator> createState() => _MasterMainNavigatorState();
}

class _MasterMainNavigatorState extends State<MasterMainNavigator> {
  int _currentIndex = 0;

  // List of screens for bottom navigation
  final List<Widget> _screens = const [
    DashboardScreen(),
    JobsScreen(),
    ProjectsScreen(),
    WalletScreen(),
    ProfileScreen(),
  ];

  // Navigation items configuration
  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      semanticLabel: 'Dashboard - privire de ansamblu',
    ),
    _NavItem(
      icon: Icons.work_outline,
      activeIcon: Icons.work,
      label: 'Lucrări',
      semanticLabel: 'Lucrări disponibile',
    ),
    _NavItem(
      icon: Icons.list_alt_outlined,
      activeIcon: Icons.list_alt,
      label: 'Proiecte',
      semanticLabel: 'Proiectele mele active',
    ),
    _NavItem(
      icon: Icons.account_balance_wallet_outlined,
      activeIcon: Icons.account_balance_wallet,
      label: 'Portofel',
      semanticLabel: 'Portofelul meu și câștiguri',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
      semanticLabel: 'Profilul și setările mele',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 72, // Ensures WCAG 2.1 AA touch target size (48dp minimum)
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navItems.length,
              (index) => _buildNavItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;

    return Expanded(
      child: AccessibilityUtils.ensureTouchTarget(
        minSize: 48.0, // WCAG 2.1 AA compliance
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
          // Announce navigation change to screen readers
          context.announce('Ai navigat la ${item.label}');
        },
        child: Semantics(
          label: item.semanticLabel,
          selected: isSelected,
          button: true,
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MesteriColors.primary.withOpacity(0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.icon,
                      color: isSelected
                          ? MesteriColors.primary
                          : MesteriColors.onSurfaceSecondary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? MesteriColors.primary
                          : MesteriColors.onSurfaceSecondary,
                    ),
                    child: Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Navigation item configuration
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String semanticLabel;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.semanticLabel,
  });
}
