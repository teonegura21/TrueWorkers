import 'package:flutter/material.dart';
import 'package:app_mester/src/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:app_mester/src/features/jobs/presentation/screens/jobs_screen.dart';
import 'package:app_mester/src/features/projects/presentation/screens/projects_screen.dart';
import 'package:app_mester/src/features/profile/presentation/screens/profile_screen.dart';
import 'package:app_mester/src/features/wallet/presentation/screens/wallet_screen.dart';

class MasterMainNavigator extends StatefulWidget {
  const MasterMainNavigator({super.key});

  @override
  State<MasterMainNavigator> createState() => _MasterMainNavigatorState();
}

class _MasterMainNavigatorState extends State<MasterMainNavigator> {
  int _selectedIndex = 0;

  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      const DashboardScreen(),
      const JobsScreen(),
      const ProjectsScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            label: 'Lucrări',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Proiecte',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Portofel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
