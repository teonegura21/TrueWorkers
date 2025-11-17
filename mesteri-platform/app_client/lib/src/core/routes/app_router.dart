import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../navigation/main_navigator.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthenticated = user != null;
      final isOnAuthPage =
          state.matchedLocation == '/' ||
          state.matchedLocation.startsWith('/auth');

      // Auto-login: If authenticated and on welcome/auth page, go to main
      if (isAuthenticated && isOnAuthPage) {
        debugPrint('🔄 Auto-login: Redirecting to /main');
        return '/main';
      }

      // If not authenticated and trying to access protected route
      if (!isAuthenticated && !isOnAuthPage) {
        debugPrint('🔒 Not authenticated: Redirecting to /');
        return '/';
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/main',
        builder: (context, state) => const MainNavigator(),
      ),
    ],
    errorBuilder: (context, state) => const WelcomeScreen(),
  );
}
