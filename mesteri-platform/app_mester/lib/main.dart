import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/services/firebase_service.dart';
import 'src/core/services/secure_storage_service.dart';
import 'src/features/auth/presentation/screens/welcome_screen.dart';
import 'src/navigation/main_navigator.dart';
import 'services/push_notification_service.dart';
import 'handlers/notification_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await firebaseService.initialize();

  // Enable Firebase Auth persistence (craftsmen stay logged in)
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  // Initialize push notifications
  await PushNotificationService().initialize(
    
    apiBaseUrl: 'http://localhost:3000/api', // This should match your backend URL
    onTap: (message) {
      // Handle notification tap when app is in foreground/background
      print('Notification tapped: ${message.messageId}');
    },
  );

  runApp(const MasterApp());
}

class MasterApp extends StatelessWidget {
  const MasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'True Workers Mesteri',
      theme: AppTheme.lightTheme,
      home: const AuthStateHandler(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/main': (context) => const MasterMainNavigator(),
      },
      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior(),
          child: child!,
        );
      },
    );
  }
}

// Auth State Handler - automatically shows correct screen based on login state
// with session validation for security
class AuthStateHandler extends StatefulWidget {
  const AuthStateHandler({super.key});

  @override
  State<AuthStateHandler> createState() => _AuthStateHandlerState();
}

class _AuthStateHandlerState extends State<AuthStateHandler> {
  final SecureStorageService _storage = SecureStorageService();
  bool _isValidating = true;

  @override
  void initState() {
    super.initState();
    _validateSession();
  }

  /// Validate stored session on app start
  Future<void> _validateSession() async {
    try {
      final isValid = await _storage.isSessionValid();
      if (!isValid) {
        // Session expired, sign out
        await FirebaseAuth.instance.signOut();
        await _storage.clearAuthData();
      }
    } catch (e) {
      debugPrint('⚠️ Session validation error: $e');
    } finally {
      if (mounted) {
        setState(() => _isValidating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isValidating) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in (craftsman), show main navigator
        if (snapshot.hasData && snapshot.data != null) {
          debugPrint('✅ Craftsman logged in: ${snapshot.data!.email}');
          return const MasterMainNavigator();
        }

        // If not logged in, show welcome screen
        debugPrint('🚺 No craftsman logged in, showing welcome');
        return const WelcomeScreen();
      },
    );
  }
}
