import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../src/features/home/presentation/screens/home_screen.dart';

class MainNavigator extends StatelessWidget {
  const MainNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return const HomeScreen();
  }
}
