import 'package:flutter/material.dart';
import 'src/core/config/app_config.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/routes/app_router.dart';

class MesteriApp extends StatelessWidget {
  const MesteriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
