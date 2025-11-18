import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_client/src/features/home/presentation/screens/home_screen.dart';
import 'package:app_client/src/features/jobs/presentation/screens/jobs_screen.dart';
import 'package:app_client/src/features/inspiration/presentation/screens/inspiration_feed_screen.dart';
import 'package:app_client/src/features/chat/presentation/screens/chat_list_screen.dart';
import 'package:app_client/src/features/account/presentation/screens/account_screen.dart';
import 'package:app_client/src/core/theme/app_theme.dart';
import 'package:app_client/src/core/utils/accessibility_utils.dart';

/// Main Navigator with Bottom Navigation Bar
/// Provides access to 5 main sections of the app:
/// 1. Home (Dashboard)
/// 2. Jobs (My Jobs)
/// 3. Feed (Inspiration)
/// 4. Messages (Chat)
/// 5. Profile (Account)
class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  // List of screens for bottom navigation
  final List<Widget> _screens = const [
    HomeScreen(),
    JobsScreen(),
    InspirationFeedScreen(),
    ChatListScreen(),
    AccountScreen(),
  ];

  // Navigation items configuration
  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Acasă',
      semanticLabel: 'Acasă - pagina principală',
    ),
    _NavItem(
      icon: Icons.work_outline,
      activeIcon: Icons.work,
      label: 'Lucrări',
      semanticLabel: 'Lucrările mele',
    ),
    _NavItem(
      icon: Icons.lightbulb_outline,
      activeIcon: Icons.lightbulb,
      label: 'Inspirație',
      semanticLabel: 'Feed de inspirație',
    ),
    _NavItem(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Mesaje',
      semanticLabel: 'Mesajele mele',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
      semanticLabel: 'Profilul meu',
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
